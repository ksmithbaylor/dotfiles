---
name: team-status
description: Show a table of who on my team is around right now, with presence, local time, Slack status, last Slack message, and last GitHub action. Use when the user runs /team-status or asks who on their team is online or available for a review or quick question. It runs in the background, so its table reaches the main session, not the user. When the result arrives, always print the table to the user exactly as returned, before anything else.
argument-hint: "[#channel | refresh]"
context: fork
agent: general-purpose
model: haiku
allowed-tools: Bash(python3 ${CLAUDE_SKILL_DIR}/team_status.py *), mcp__plugin_slack_slack__slack_search_channels, mcp__plugin_slack_slack__slack_list_channel_members, mcp__plugin_slack_slack__slack_read_user_profile, mcp__plugin_slack_slack__slack_search_public_and_private
---

# Team status

`team_status.py` does all the bookkeeping and formatting. Your job is to fetch the Slack data it asks for and pass it back. Never summarize, reformat, or comment on the table.

Start with:

```
python3 ${CLAUDE_SKILL_DIR}/team_status.py plan "$ARGUMENTS"
```

Every command prints either the finished table or one `NEXT:` line. Keep following `NEXT:` lines until you get a table. Then reply with this line, followed by the table exactly as printed, and nothing else:

```
Print this /team-status table to the user verbatim:
```

Your reply goes to the main session, not to the user, who only sees what the main session prints. That line is what gets the table onto their screen.

## NEXT: ask-for-channel

Reply only: "No team channel set yet. Run `/team-status #your-team-channel` once and I'll remember it."

## NEXT: fetch-roster <channel>

1. If `<channel>` isn't already an ID (starts with C or G), find it with `slack_search_channels` (`channel_types: "public_channel,private_channel"`, `response_format: "concise"`). Pick the exact name match. If nothing matches exactly, reply that the channel wasn't found and stop.
2. Call `slack_list_channel_members` with `response_format: "concise"`, following the cursor until every page is read. The tool description names your own user ID; that's `me`.
3. Pipe the result to the script:

```
python3 ${CLAUDE_SKILL_DIR}/team_status.py save-roster <<'EOF'
{"channel_id": "C...", "channel_name": "team-channel", "me": "U...", "members": [{"id": "U...", "username": "first.last", "name": "First Last"}]}
EOF
```

## NEXT: fetch-activity <user ids...>

For every ID, make these two calls. Make all of them in parallel in a single turn:

- `slack_read_user_profile` with `user_id` and `response_format: "detailed"` (concise omits the timezone). Record the timezone and status.
- `slack_search_public_and_private` with `filters: "from:<@ID>"`, `sort: "timestamp"`, `limit: 1`, `include_context: false`, `response_format: "concise"`. Record the timestamp exactly as shown (e.g. `2026-10-21 10:28:07 EDT`) and the channel name. Write `"#DM"` for direct messages.

Then pipe it all to the script. Use `null` for anything missing:

```
python3 ${CLAUDE_SKILL_DIR}/team_status.py render <<'EOF'
[{"id": "U...", "tz": "America/New_York", "status": ":palm_tree: OOO", "last_msg": "2026-10-21 10:28:07 EDT", "last_channel": "#eng"}]
EOF
```
