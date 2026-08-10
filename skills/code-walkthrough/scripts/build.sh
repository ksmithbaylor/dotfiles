#!/usr/bin/env bash
#
# Build a self-contained walkthrough HTML file from walkthrough JSON.
#
#   build.sh <walkthrough.json> <out.html> [--diff "<command>"]
#
# With --diff, the command is run through bash and its unified-diff output is
# compared against the JSON before anything is built: both the walkthrough
# sections and the files array must contain exactly the diff's added and
# removed lines, with matching statuses. On a mismatch the build fails and
# prints what is missing or extra so the JSON can be corrected.

set -euo pipefail

usage='usage: build.sh <walkthrough.json> <out.html> [--diff "<command>"]'
json=${1:?$usage}
out=${2:?$usage}
shift 2
skill_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

diff_file=""
if [[ ${1:-} == "--diff" ]]; then
  cmd=${2:?--diff requires a command that prints the diff}
  diff_file=$(mktemp)
  trap 'rm -f "$diff_file"' EXIT
  bash -c "$cmd" > "$diff_file"
fi

python3 - "$json" "$out" "$skill_dir" "$diff_file" <<'PY'
import json, pathlib, re, sys
from collections import Counter

json_path, out_path, skill, diff_path = sys.argv[1:5]
skill = pathlib.Path(skill)

data = json.loads(pathlib.Path(json_path).read_text())
for field in ("title", "sections"):
    if field not in data:
        sys.exit(f"walkthrough JSON is missing required field: {field}")

HUNK_RE = re.compile(r"^@@ -(\d+)(?:,(\d+))? \+(\d+)(?:,(\d+))? @@")


def changes_in(text):
    """Ordered +/- lines from unified-diff text, ignoring headers/context."""
    out, in_hunk = [], False
    for ln in text.split("\n"):
        if HUNK_RE.match(ln):
            in_hunk = True
            continue
        if not in_hunk or ln.startswith("+++") or ln.startswith("---"):
            continue
        if ln.startswith("+"):
            out.append("+" + ln[1:])
        elif ln.startswith("-"):
            out.append("-" + ln[1:])
    return out


def parse_expected(text):
    """Parse `git diff`/`git show` output into {path: {status, old, changes}}."""
    entries, cur = [], None
    for ln in text.split("\n"):
        if ln.startswith("diff --git "):
            cur = {"status": "modified", "old": None, "changes": [],
                   "a": None, "b": None, "in_hunk": False}
            m = re.match(r"diff --git a/(.*) b/(.*)$", ln)
            if m:
                cur["a"], cur["b"] = m.group(1), m.group(2)
            entries.append(cur)
        elif cur is None:
            continue
        elif ln.startswith("new file"):
            cur["status"] = "added"
        elif ln.startswith("deleted file"):
            cur["status"] = "deleted"
        elif ln.startswith("rename from "):
            cur["status"] = "renamed"
            cur["old"] = ln[len("rename from "):]
        elif ln.startswith("rename to "):
            cur["b"] = ln[len("rename to "):]
        elif ln.startswith("--- "):
            p = ln[4:]
            if p != "/dev/null":
                cur["a"] = p[2:] if p.startswith("a/") else p
        elif ln.startswith("+++ "):
            p = ln[4:]
            if p != "/dev/null":
                cur["b"] = p[2:] if p.startswith("b/") else p
        elif HUNK_RE.match(ln):
            cur["in_hunk"] = True
        elif cur["in_hunk"]:
            if ln.startswith("+"):
                cur["changes"].append("+" + ln[1:])
            elif ln.startswith("-"):
                cur["changes"].append("-" + ln[1:])
    result = {}
    for cur in entries:
        path = cur["b"] if cur["status"] != "deleted" else cur["a"]
        result[path] = {"status": cur["status"], "old": cur["old"],
                        "changes": cur["changes"]}
    return result


def sections_changes(data):
    """Per file: +/- lines across all section diff blocks, in file order.

    Pieces of split hunks are re-sorted by their @@ start positions, so a
    correct split reassembles into the original sequence.
    """
    per = {}
    for s in data.get("sections", []):
        for b in s.get("blocks", []):
            if b.get("type") != "diff":
                continue
            cur = None
            for ln in b.get("hunks", "").split("\n"):
                m = HUNK_RE.match(ln)
                if m:
                    cur = {"o": int(m.group(1)), "n": int(m.group(3)), "changes": []}
                    per.setdefault(b["file"], []).append(cur)
                    continue
                if cur is None or ln.startswith("+++") or ln.startswith("---"):
                    continue
                if ln.startswith("+"):
                    cur["changes"].append("+" + ln[1:])
                elif ln.startswith("-"):
                    cur["changes"].append("-" + ln[1:])
    return {
        f: [c for p in sorted(pieces, key=lambda p: (p["n"], p["o"]))
            for c in p["changes"]]
        for f, pieces in per.items()
    }


def compare_changes(path, exp, act, problems, warnings, label):
    if exp == act:
        return
    ce, ca = Counter(exp), Counter(act)
    if ce == ca:
        warnings.append(f"[{label}] {path}: content matches the diff but line "
                        "order differs; check the @@ headers on split hunks")
        return

    def fmt(lines):
        shown = ["      " + l for l in lines[:5]]
        if len(lines) > 5:
            shown.append(f"      … and {len(lines) - 5} more")
        return "\n".join(shown)

    missing = list((ce - ca).elements())
    extra = list((ca - ce).elements())
    msg = f"[{label}] {path}:"
    if missing:
        msg += f"\n   missing {len(missing)} changed line(s) that are in the diff:\n{fmt(missing)}"
    if extra:
        msg += f"\n   contains {len(extra)} line(s) that are NOT in the diff:\n{fmt(extra)}"
    problems.append(msg)


def verify(data, expected):
    problems, warnings = [], []

    files_actual = {
        f["file"]: {"status": f.get("status", "modified"),
                    "old": f.get("oldFile"),
                    "changes": changes_in(f.get("hunks", ""))}
        for f in data.get("files", [])
    }
    for path in sorted(set(expected) - set(files_actual)):
        problems.append(f"[file tree] {path}: file is in the diff but missing from `files`")
    for path in sorted(set(files_actual) - set(expected)):
        problems.append(f"[file tree] {path}: listed in `files` but not in the diff "
                        "(remove it, or fix the path)")
    for path in sorted(set(expected) & set(files_actual)):
        exp, act = expected[path], files_actual[path]
        if exp["status"] != act["status"]:
            problems.append(f"[file tree] {path}: status is \"{act['status']}\" "
                            f"but the diff says \"{exp['status']}\"")
        if exp["status"] == "renamed" and exp["old"] != act["old"]:
            problems.append(f"[file tree] {path}: oldFile is {act['old']!r} "
                            f"but the diff says {exp['old']!r}")
        compare_changes(path, exp["changes"], act["changes"],
                        problems, warnings, "file tree")

    sections_actual = sections_changes(data)
    expected_with_lines = {p: e for p, e in expected.items() if e["changes"]}
    for path in sorted(set(expected_with_lines) - set(sections_actual)):
        problems.append(f"[sections] {path}: file is in the diff but none of its "
                        "hunks appear in any walkthrough section")
    for path in sorted(set(sections_actual) - set(expected)):
        problems.append(f"[sections] {path}: appears in a section but is not in "
                        "the diff (remove it, or fix the path)")
    for path in sorted(set(expected_with_lines) & set(sections_actual)):
        compare_changes(path, expected_with_lines[path]["changes"],
                        sections_actual[path], problems, warnings, "sections")

    return problems, warnings


if diff_path:
    expected = parse_expected(pathlib.Path(diff_path).read_text())
    if not expected:
        sys.exit("coverage check: the --diff command produced no parseable diff")
    problems, warnings = verify(data, expected)
    for w in warnings:
        print(f"coverage warning: {w}", file=sys.stderr)
    if problems:
        print("COVERAGE CHECK FAILED — the walkthrough does not match the diff.\n"
              "Fix the JSON and rebuild. Problems:", file=sys.stderr)
        for p in problems:
            print(f" - {p}", file=sys.stderr)
        sys.exit(1)
    adds = sum(1 for e in expected.values() for c in e["changes"] if c.startswith("+"))
    dels = sum(1 for e in expected.values() for c in e["changes"] if c.startswith("-"))
    print(f"coverage OK: {len(expected)} file(s), +{adds} −{dels}; "
          "sections and file tree both match the diff")

template = (skill / "assets" / "template.html").read_text()
vendor = "\n".join(
    (skill / "assets" / "vendor" / lib).read_text()
    for lib in ("marked.min.js", "highlight.min.js")
)
payload = json.dumps(data).replace("</", "<\\/")

html = template.replace("/*__VENDOR_JS__*/", vendor, 1)
html = html.replace("/*__DATA__*/null", payload, 1)
pathlib.Path(out_path).write_text(html)
print(out_path)
PY
