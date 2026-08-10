#!/usr/bin/env bash
#
# Build a self-contained walkthrough HTML file from walkthrough JSON.
#
#   build.sh <walkthrough.json> <out.html>
#
# Inlines the vendored renderer libraries and the JSON payload into the
# template, so the output is a single file that works offline.

set -euo pipefail

json=${1:?usage: build.sh <walkthrough.json> <out.html>}
out=${2:?usage: build.sh <walkthrough.json> <out.html>}
skill_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

python3 - "$json" "$out" "$skill_dir" <<'PY'
import json, sys, pathlib

json_path, out_path, skill = sys.argv[1:4]
skill = pathlib.Path(skill)

data = json.loads(pathlib.Path(json_path).read_text())
for field in ("title", "sections"):
    if field not in data:
        sys.exit(f"walkthrough JSON is missing required field: {field}")

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
