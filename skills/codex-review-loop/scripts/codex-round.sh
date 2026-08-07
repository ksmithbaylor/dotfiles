#!/usr/bin/env bash
#
# Run one round of a Codex review conversation.
#
#   codex-round.sh <state-dir> <prompt-file>
#
# The first call starts a Codex session and records its thread id. Every later
# call resumes that same thread, so Codex keeps the whole review in context
# instead of meeting the code fresh each round.
#
# Prints the path to Codex's JSON verdict for this round.

set -euo pipefail

state_dir=${1:?usage: codex-round.sh <state-dir> <prompt-file>}
prompt_file=${2:?usage: codex-round.sh <state-dir> <prompt-file>}

skill_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
schema=$skill_dir/reference/verdict-schema.json

[[ -r $prompt_file ]] || { echo "no such prompt file: $prompt_file" >&2; exit 1; }
mkdir -p "$state_dir"

thread_file=$state_dir/thread-id
shopt -s nullglob
previous_rounds=("$state_dir"/round-*-verdict.json)
round=$(( ${#previous_rounds[@]} + 1 ))
events=$state_dir/round-$round-events.jsonl
verdict=$state_dir/round-$round-verdict.json

# `codex exec resume` takes a narrower flag set than `codex exec`: no --color and
# no --sandbox. Read-only is restated as a config override so the resumed turns
# do not rely on inheriting it from the session that started the review.
codex_args=(
  --json
  --output-schema "$schema"
  --output-last-message "$verdict"
)

if [[ -f $thread_file ]]; then
  codex exec resume "$(cat "$thread_file")" \
    -c sandbox_mode="read-only" "${codex_args[@]}" - < "$prompt_file" > "$events"
else
  codex exec --color never --sandbox read-only \
    "${codex_args[@]}" - < "$prompt_file" > "$events"
  jq -rs 'map(select(.type == "thread.started"))[0].thread_id // empty' "$events" > "$thread_file"
  if [[ ! -s $thread_file ]]; then
    rm -f "$thread_file"
    echo "codex reported no thread id; see $events" >&2
    exit 1
  fi
fi

if ! jq -e . "$verdict" > /dev/null 2>&1; then
  echo "round $round produced no valid verdict; see $events" >&2
  exit 1
fi

echo "$verdict"
