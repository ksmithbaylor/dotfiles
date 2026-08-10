#!/usr/bin/env bash
#
# Print the SHA of a commit object capturing the current working tree
# (tracked and untracked files, minus ignored ones) without touching the
# real index, the worktree, or any ref. The commit is dangling: invisible
# to log/status/stash, diffable like any commit, garbage-collected only
# weeks later.
#
#   snapshot.sh   ->  <sha>

set -euo pipefail

export GIT_INDEX_FILE=$(mktemp -u)
trap 'rm -f "$GIT_INDEX_FILE"' EXIT

if git rev-parse -q --verify HEAD >/dev/null; then
  git read-tree HEAD
  git add -A
  git commit-tree "$(git write-tree)" -p HEAD -m "code-walkthrough snapshot"
else
  git add -A
  git commit-tree "$(git write-tree)" -m "code-walkthrough snapshot"
fi
