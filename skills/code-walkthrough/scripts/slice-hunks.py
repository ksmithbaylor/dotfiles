#!/usr/bin/env python3
"""Slice a line range out of one file's unified diff, recomputing @@ headers.

Reads the diff for ONE file on stdin (one or more @@ hunks; any diff/index/
---/+++ header lines are ignored). Writes the hunk pieces that fall inside
the requested range to stdout, each with a correctly recomputed @@ header,
ready to paste into a walkthrough JSON diff block.

usage: slice-hunks.py [--old] START END

  START END   inclusive line range, in new-file numbering by default
  --old       interpret the range in old-file numbering (use for deleted
              files, which have no new-side numbers)

Removed lines carry no new-file number, so in new-file mode a removed line
belongs to the range when the position it was removed from falls inside it
(and symmetrically for added lines in --old mode).
"""

import re
import sys

HUNK_RE = re.compile(r"^@@ -(\d+)(?:,(\d+))? \+(\d+)(?:,(\d+))? @@")
SKIP_PREFIXES = ("diff ", "index ", "--- ", "+++ ", "new file", "deleted file",
                 "similarity", "rename ", "old mode", "new mode", "Binary files")


def parse(stdin_text):
    hunks, cur = [], None
    lines = stdin_text.split("\n")
    if lines and lines[-1] == "":
        lines.pop()
    for raw in lines:
        m = HUNK_RE.match(raw)
        if m:
            cur = {"o": int(m.group(1)), "n": int(m.group(3)),
                   "oc": 1 if m.group(2) is None else int(m.group(2)),
                   "nc": 1 if m.group(4) is None else int(m.group(4)),
                   "lines": []}
            hunks.append(cur)
            continue
        if cur is None or raw.startswith(SKIP_PREFIXES):
            continue
        cur["lines"].append(raw)
    return hunks


def slice_hunk(hunk, start, end, use_old):
    o, n = hunk["o"], hunk["n"]
    picked = []          # (raw_line, old_no|None, new_no|None, o_at, n_at)
    for raw in hunk["lines"]:
        kind = raw[:1]
        if kind == "\\":  # "\ No newline at end of file" rides with its line
            if picked:
                picked.append((raw, None, None, o, n))
            continue
        o_at, n_at = o, n
        if kind == "+":
            old_no, new_no = None, n
            pos = o if use_old else n
            n += 1
        elif kind == "-":
            old_no, new_no = o, None
            pos = o if use_old else n
            o += 1
        else:
            old_no, new_no = o, n
            pos = o if use_old else n
            o += 1
            n += 1
        if start <= pos <= end:
            picked.append((raw, old_no, new_no, o_at, n_at))
    return picked


def emit(hunk, picked):
    old_nos = [o for _, o, _, _, _ in picked if o is not None]
    new_nos = [n for _, _, n, _, _ in picked if n is not None]
    real = [raw for raw, *_ in picked if not raw.startswith("\\")]
    old_count = sum(1 for r in real if not r.startswith("+"))
    new_count = sum(1 for r in real if not r.startswith("-"))
    # A side with zero lines anchors git-style to the line before the
    # insertion point ("-12,0", or "-0,0" for a new file). When the original
    # hunk already had nothing on that side its header start IS the anchor;
    # otherwise the counter points at the next line, so back up one.
    _, _, _, o_at, n_at = picked[0]
    old_start = old_nos[0] if old_nos else (hunk["o"] if hunk["oc"] == 0 else o_at - 1)
    new_start = new_nos[0] if new_nos else (hunk["n"] if hunk["nc"] == 0 else n_at - 1)
    print(f"@@ -{old_start},{old_count} +{new_start},{new_count} @@")
    for raw, *_ in picked:
        print(raw)


def main():
    args = sys.argv[1:]
    use_old = "--old" in args
    args = [a for a in args if a != "--old"]
    if len(args) != 2 or not all(a.lstrip("-").isdigit() for a in args):
        sys.exit(__doc__.strip())
    start, end = int(args[0]), int(args[1])
    if start > end:
        sys.exit(f"empty range: {start} > {end}")
    hunks = parse(sys.stdin.read())
    if not hunks:
        sys.exit("no @@ hunks found on stdin")
    any_out = False
    for hunk in hunks:
        picked = slice_hunk(hunk, start, end, use_old)
        if picked:
            emit(hunk, picked)
            any_out = True
    if not any_out:
        side = "old" if use_old else "new"
        sys.exit(f"no lines in {side}-file range {start}..{end}")


if __name__ == "__main__":
    main()
