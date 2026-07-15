#!/usr/bin/env bash
# Claude Code status line — Claude-session info first (model, context, cost),
# then git + directory. Reads the JSON Claude Code pipes on stdin.

input=$(cat)

# ---- Fields from the status-line JSON schema ----
model=$(echo "$input"      | jq -r '.model.display_name // empty')
effort=$(echo "$input"     | jq -r '.effort.level // empty')
output_style=$(echo "$input" | jq -r '.output_style.name // empty')
cwd=$(echo "$input"        | jq -r '.workspace.current_dir // .cwd // empty')
cost_usd=$(echo "$input"   | jq -r '.cost.total_cost_usd // empty')
session_name=$(echo "$input" | jq -r '.session_name // empty')
session_id=$(echo "$input"   | jq -r '.session_id // empty')
lines_added=$(echo "$input"   | jq -r '.cost.total_lines_added // empty')
lines_removed=$(echo "$input" | jq -r '.cost.total_lines_removed // empty')
ctx_pct=$(echo "$input"    | jq -r '.context_window.used_percentage // empty')
ctx_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // empty')
transcript_path=$(echo "$input" | jq -r '.transcript_path // empty')

# ---- Colors ----
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
ORANGE_BOLD='\033[1;38;5;208m' # model name, bold bright orange
ORANGE_DIM='\033[38;5;130m'    # effort level, deeper amber-brown orange
DIM='\033[38;5;245m'          # secondary text (token count, duration, output style)
GRAY='\033[38;5;244m'          # field separator pipes
GOLD='\033[38;5;220m'          # session cost
MAGENTA='\033[38;5;213m'      # generation throughput (tok/s)
RESET='\033[0m'
SEP=" $(printf "${GRAY}│${RESET}") "

# ---- Per-session color marker (stable hash of session_id -> palette) ----
# Effectively random per session, but consistent across renders of the same one.
marker=""
if [ -n "$session_id" ]; then
  palette=(196 208 226 46 49 51 33 99 129 201)
  hash=$(printf "%s" "$session_id" | cksum | awk '{print $1}')
  color=${palette[$(( hash % ${#palette[@]} ))]}
  marker=$(printf "\033[38;5;%sm⬤${RESET}" "$color")
fi

# ---- Context window usage (native field) ----
ctx_str=""
if [ -n "$ctx_pct" ]; then
  pct=$(printf "%.0f" "$ctx_pct")
  # Color the percentage as it climbs toward compaction.
  if   [ "$pct" -ge 80 ]; then ctx_color="$RED"
  elif [ "$pct" -ge 50 ]; then ctx_color="$YELLOW"
  else ctx_color="$GREEN"
  fi
  if [ -n "$ctx_tokens" ]; then
    k=$(( ctx_tokens / 1000 ))
    ctx_str=$(printf "${ctx_color}ctx %s%% ${DIM}(%sk)${RESET}" "$pct" "$k")
  else
    ctx_str=$(printf "${ctx_color}ctx %s%%${RESET}" "$pct")
  fi
fi

# ---- Session cost + duration ----
cost_str=""
if [ -n "$cost_usd" ]; then
  cost_str=$(printf "${GOLD}\$%.2f${RESET}" "$cost_usd")
fi

# ---- Generation throughput (output tokens / actual generation time) ----
# Uses the gap between each assistant entry and the prior transcript entry as
# that turn's generation latency, which excludes tool-execution and idle time
# (gaps capped at 120s to drop outliers like long-running tool calls).
tps_str=""
if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
  tps=$(python3 - "$transcript_path" <<'PYEOF'
import json, sys
from datetime import datetime

def parse(ts):
    return datetime.fromisoformat(ts.replace('Z', '+00:00'))

path = sys.argv[1]
total_out = 0
total_dt = 0.0
prev_ts = None
with open(path) as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        try:
            d = json.loads(line)
        except json.JSONDecodeError:
            continue
        ts_raw = d.get('timestamp')
        if not ts_raw:
            continue
        ts = parse(ts_raw)
        if d.get('type') == 'assistant':
            out = d.get('message', {}).get('usage', {}).get('output_tokens', 0)
            if prev_ts is not None:
                dt = (ts - prev_ts).total_seconds()
                if 0 < dt < 120:
                    total_out += out
                    total_dt += dt
        prev_ts = ts

if total_dt > 0:
    print(f"{total_out / total_dt:.0f}")
PYEOF
)
  [ -n "$tps" ] && tps_str=$(printf "${MAGENTA}%s tps${RESET}" "$tps")
fi

# ---- Lines changed ----
lines_str=""
if { [ -n "$lines_added" ] && [ "$lines_added" -gt 0 ] 2>/dev/null; } || \
   { [ -n "$lines_removed" ] && [ "$lines_removed" -gt 0 ] 2>/dev/null; }; then
  lines_str=$(printf "${GREEN}+%s${RESET}/${RED}-%s${RESET}" "${lines_added:-0}" "${lines_removed:-0}")
fi

# ---- Directory (abbreviate ~ and ~/circle) ----
if [ -n "$cwd" ]; then
  directory="${cwd##*/}"   # last path segment only
else
  directory="$(basename "$(pwd)")"
fi

# ---- Git branch + dirty + ahead/behind ----
git_str=""
if [ -n "$cwd" ] && git -C "$cwd" --no-optional-locks rev-parse --git-dir >/dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
  [ -z "$branch" ] && branch=$(git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
  state=""
  git -C "$cwd" --no-optional-locks diff --cached --quiet 2>/dev/null || state="${state}●"
  git -C "$cwd" --no-optional-locks diff --quiet 2>/dev/null        || state="${state}+"
  [ -n "$(git -C "$cwd" --no-optional-locks ls-files --other --exclude-standard 2>/dev/null)" ] && state="${state}?"
  # Ahead/behind upstream
  ab=""
  counts=$(git -C "$cwd" --no-optional-locks rev-list --left-right --count @{u}...HEAD 2>/dev/null)
  if [ -n "$counts" ]; then
    behind=$(echo "$counts" | awk '{print $1}')
    ahead=$(echo "$counts" | awk '{print $2}')
    [ "$ahead" -gt 0 ] 2>/dev/null && ab="${ab}↑${ahead}"
    [ "$behind" -gt 0 ] 2>/dev/null && ab="${ab}↓${behind}"
  fi
  label="$branch"
  [ -n "$state" ] && label="$label $state"
  [ -n "$ab" ] && label="$label $ab"
  git_str=$(printf "${BLUE}(%s)${RESET}" "$label")
fi

# ---- Assemble: every field its own segment, joined by gray pipes ----
parts=()

# Model + effort share one segment (model bold orange, effort amber).
if [ -n "$model" ]; then
  m=$(printf "${ORANGE_BOLD}%s${RESET}" "$model")
  [ -n "$effort" ] && m="$m $(printf "${ORANGE_DIM}%s${RESET}" "$effort")"
  # Session color marker first, separated by a space (no pipe).
  [ -n "$marker" ] && m="$marker  $m"
  parts+=("$m")
elif [ -n "$marker" ]; then
  parts+=("$marker")
fi
if [ -n "$output_style" ] && [ "$output_style" != "default" ] && [ "$output_style" != "null" ]; then
  parts+=("$(printf "${DIM}[%s]${RESET}" "$output_style")")
fi
[ -n "$ctx_str" ]  && parts+=("$ctx_str")
[ -n "$cost_str" ] && parts+=("$cost_str")
[ -n "$tps_str" ]  && parts+=("$tps_str")

# Git status (branch + dirty) and diff (lines +/-) share one segment.
git_seg=""
[ -n "$git_str" ]   && git_seg="$git_str"
[ -n "$lines_str" ] && git_seg="${git_seg:+$git_seg }$lines_str"
[ -n "$git_seg" ]   && parts+=("$git_seg")

parts+=("$(printf "${CYAN}%s${RESET}" "$directory")")
[ -n "$session_name" ] && parts+=("$(printf "${DIM}%s${RESET}" "$session_name")")

# Join with separators
out=""
for i in "${!parts[@]}"; do
  if [ "$i" -eq 0 ]; then out="${parts[$i]}"; else out="${out}${SEP}${parts[$i]}"; fi
done

printf "%b\n" "$out"
