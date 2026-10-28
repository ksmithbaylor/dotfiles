#!/usr/bin/env python3
"""Who on my team is around right now?

Each command prints either the finished table or a single NEXT line telling the
caller which Slack data to fetch and which command to pipe it into.

  plan [ARG]     ARG is empty, "refresh", or a channel (#name or C-id)
  save-roster    stdin: {"channel_id", "channel_name", "me", "members": [{"id", "username", "name"}]}
  render         stdin: [{"id", "tz", "status", "last_msg", "last_channel"}]

GitHub lookups start in the background as soon as the roster is known, so they
overlap with the caller's Slack fetching.
"""

import json
import re
import subprocess
import sys
import time
from concurrent.futures import ThreadPoolExecutor
from datetime import datetime, timedelta, timezone
from pathlib import Path
from zoneinfo import ZoneInfo

STATE_DIR = Path.home() / ".config" / "team-status"
CONFIG_PATH = STATE_DIR / "config.json"
ROSTER_PATH = STATE_DIR / "roster.json"
GITHUB_SEEN_PATH = STATE_DIR / "github.json"
GITHUB_PENDING_PATH = STATE_DIR / "github.pending"
DEFAULT_CONFIG = {"roster_max_age_days": 7}
KEYCHAIN_SERVICE = "team-status-slack"

ACTIVE_WINDOW = timedelta(minutes=15)
RECENT_WINDOW = timedelta(minutes=90)
WORKDAY_HOURS = range(8, 19)
PREFETCH_MAX_WAIT = timedelta(seconds=20)

GITHUB_EVENT_VERBS = {
    "PushEvent": "pushed",
    "PullRequestReviewEvent": "reviewed",
    "PullRequestReviewCommentEvent": "commented",
    "IssueCommentEvent": "commented",
    "PullRequestEvent": "updated PR",
    "CreateEvent": "created branch",
}


# ---------- state ----------

def load_json(path, default):
    return json.loads(path.read_text()) if path.exists() else default


def save_json(path, data):
    STATE_DIR.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2) + "\n")


def load_config():
    config = {**DEFAULT_CONFIG, **load_json(CONFIG_PATH, {})}
    if "github_me" not in config:
        config.update(github_identity())
    save_json(CONFIG_PATH, config)
    return config


def roster_is_stale(roster, config):
    age = time.time() - roster.get("saved_at", 0)
    return age > config["roster_max_age_days"] * 86400


def same_channel(arg, roster):
    wanted = arg.lstrip("#").lower()
    return wanted in (roster.get("channel_id", "").lower(), roster.get("channel_name", "").lstrip("#").lower())


# ---------- commands ----------

def plan(arg):
    config = load_config()
    roster = load_json(ROSTER_PATH, {})
    arg = arg.strip()

    if not roster and arg in ("", "refresh"):
        print("NEXT: ask-for-channel")
    elif arg and arg != "refresh" and not same_channel(arg, roster):
        print(f"NEXT: fetch-roster {arg}")
    elif arg == "refresh" or roster_is_stale(roster, config):
        print(f"NEXT: fetch-roster {roster['channel_id']}")
    elif slack_token():
        print_table_from_api(roster, config)
    else:
        print_activity_request(roster)


def save_roster(payload):
    config = load_config()
    previous = {m["id"]: m for m in load_json(ROSTER_PATH, {}).get("members", [])}
    members = [
        {**m, "github": previous.get(m["id"], {}).get("github") or guess_github_login(m["username"], config)}
        for m in payload["members"]
        if m["id"] != payload.get("me")
    ]
    roster = {
        "channel_id": payload["channel_id"],
        "channel_name": "#" + payload["channel_name"].lstrip("#"),
        "saved_at": int(time.time()),
        "members": members,
    }
    save_json(ROSTER_PATH, roster)
    if slack_token():
        print_table_from_api(roster, config)
    else:
        print_activity_request(roster)


def render(activity):
    config = load_config()
    roster = load_json(ROSTER_PATH, {})
    wait_for_github_prefetch()
    print(render_table(roster, config, {a["id"]: a for a in activity}, remembered_github_activity()))


def prefetch_github():
    try:
        remember_github_activity(load_json(ROSTER_PATH, {}), load_config())
    finally:
        GITHUB_PENDING_PATH.unlink(missing_ok=True)


def print_activity_request(roster):
    start_github_prefetch()
    ids = " ".join(m["id"] for m in roster["members"])
    print(f"NEXT: fetch-activity {ids}")


def print_table_from_api(roster, config):
    print(render_table(roster, config, slack_activity_from_api(roster), remember_github_activity(roster, config)))


# ---------- github ----------

def gh(*args, stdin=None):
    result = subprocess.run(["gh", *args], input=stdin, capture_output=True, text=True)
    return json.loads(result.stdout) if result.returncode == 0 and result.stdout.strip() else None


def github_logins(roster):
    return [m["github"] for m in roster.get("members", []) if m.get("github")]


def start_github_prefetch():
    STATE_DIR.mkdir(parents=True, exist_ok=True)
    GITHUB_PENDING_PATH.touch()
    subprocess.Popen([sys.executable, __file__, "prefetch-github"], start_new_session=True,
                     stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


def wait_for_github_prefetch():
    deadline = datetime.now() + PREFETCH_MAX_WAIT
    while GITHUB_PENDING_PATH.exists() and datetime.now() < deadline:
        time.sleep(0.2)


def remember_github_activity(roster, config):
    """GitHub search sometimes silently drops results, so keep whichever action is newer:
    the one just found or the latest one seen on an earlier run."""
    seen = remembered_github_activity()
    fresh = github_activity(github_logins(roster), config)
    latest = {login: max(found) for login in seen.keys() | fresh.keys()
              if (found := [a for a in (seen.get(login), fresh.get(login)) if a])}
    save_json(GITHUB_SEEN_PATH, {login: [when.isoformat(), what] for login, (when, what) in latest.items()})
    return latest


def remembered_github_activity():
    return {login: (parse_iso(when), what) for login, (when, what) in load_json(GITHUB_SEEN_PATH, {}).items()}


def gh_succeeds(*args):
    return subprocess.run(["gh", *args], capture_output=True).returncode == 0


def github_identity():
    """Infers the org (when you belong to exactly one) and the login suffix that
    enterprise-managed accounts share (first-last_suffix) from your own gh login."""
    me = (gh("api", "user") or {}).get("login") or ""
    orgs = [org["login"] for org in gh("api", "user/orgs") or []]
    _, underscore, suffix = me.rpartition("_")
    return {
        "github_me": me,
        "github_org": orgs[0] if len(orgs) == 1 else None,
        "github_login_suffix": underscore + suffix,
    }


def guess_github_login(slack_username, config):
    if not config["github_org"]:
        return None
    login = slack_username.lstrip("@").replace(".", "-") + config["github_login_suffix"]
    return login if gh_succeeds("api", f"orgs/{config['github_org']}/members/{login}") else None


def github_activity(logins, config):
    """Latest known GitHub action per login: {login: (datetime, description)}."""
    if not config["github_org"]:
        return {}
    with ThreadPoolExecutor() as pool:
        feed = pool.submit(recent_org_events, config)
        searched = pool.submit(searched_activity, logins, config["github_org"])
        candidates = [*feed.result(), *searched.result()]

    latest = {}
    for login, when, what in candidates:
        if login in logins and (login not in latest or when > latest[login][0]):
            latest[login] = (when, what)
    return latest


def recent_org_events(config):
    """The org activity feed covers only the last few hundred events, but timestamps are exact."""
    me = config["github_me"]
    if not me:
        return []
    url = f"users/{me}/events/orgs/{config['github_org']}?per_page=100&page="
    with ThreadPoolExecutor() as pool:
        pages = pool.map(lambda page: gh("api", f"{url}{page}") or [], range(1, 4))
    return [
        (e["actor"]["login"], parse_iso(e["created_at"]),
         f"{GITHUB_EVENT_VERBS.get(e['type'], e['type'])} {short_repo(e['repo']['name'])}")
        for page in pages for e in page
    ]


def searched_activity(logins, org):
    """Latest review, comment, and authored-PR push per login, found through search."""
    with ThreadPoolExecutor() as pool:
        return [found for per_login in pool.map(lambda login: searched_activity_for(login, org), logins)
                for found in per_login]


def searched_activity_for(login, org):
    variables = {
        "login": login,
        "reviewed": f"org:{org} is:pr reviewed-by:{login} sort:updated-desc",
        "commented": f"org:{org} commenter:{login} sort:updated-desc",
        "authored": f"org:{org} is:pr author:{login} sort:updated-desc",
    }
    body = json.dumps({"query": GITHUB_SEARCH_QUERY, "variables": variables})
    data = (gh("api", "graphql", "--input", "-", stdin=body) or {}).get("data") or {}
    return [
        *latest_reviews(login, data.get("reviewed")),
        *latest_comments(login, data.get("commented")),
        *latest_pushes(login, data.get("authored")),
    ]


GITHUB_SEARCH_QUERY = """
query($login: String!, $reviewed: String!, $commented: String!, $authored: String!) {
  reviewed: search(query: $reviewed, type: ISSUE, first: 3) { nodes { ... on PullRequest {
    number repository { name } reviews(author: $login, last: 1) { nodes { submittedAt } } } } }
  commented: search(query: $commented, type: ISSUE, first: 3) { nodes {
    ... on PullRequest { number repository { name } comments(last: 30) { nodes { author { login } createdAt } } }
    ... on Issue { number repository { name } comments(last: 30) { nodes { author { login } createdAt } } } } }
  authored: search(query: $authored, type: ISSUE, first: 1) { nodes { ... on PullRequest {
    number repository { name } createdAt commits(last: 1) { nodes { commit { committedDate } } } } } }
}
"""


def search_nodes(result):
    return [n for n in (result or {}).get("nodes", []) if n]


def pr_label(node):
    return f"{node['repository']['name']}#{node['number']}"


def latest_reviews(login, result):
    return [
        (login, parse_iso(review["submittedAt"]), f"reviewed {pr_label(node)}")
        for node in search_nodes(result)
        for review in node["reviews"]["nodes"]
        if review.get("submittedAt")
    ]


def latest_comments(login, result):
    return [
        (login, parse_iso(comment["createdAt"]), f"commented {pr_label(node)}")
        for node in search_nodes(result)
        for comment in node["comments"]["nodes"]
        if (comment.get("author") or {}).get("login") == login
    ]


def latest_pushes(login, result):
    found = []
    for node in search_nodes(result):
        found.append((login, parse_iso(node["createdAt"]), f"opened {pr_label(node)}"))
        found += [(login, parse_iso(c["commit"]["committedDate"]), f"pushed {pr_label(node)}")
                  for c in node["commits"]["nodes"]]
    return found


def short_repo(full_name):
    return full_name.split("/")[-1]


# ---------- slack (token mode) ----------

def slack_token():
    result = subprocess.run(["security", "find-generic-password", "-s", KEYCHAIN_SERVICE, "-w"],
                            capture_output=True, text=True)
    return result.stdout.strip() if result.returncode == 0 else None


def slack_api(method, **params):
    """curl, because Python's bundled CA store doesn't trust TLS-inspecting corporate proxies."""
    curl_config = f'header = "Authorization: Bearer {slack_token()}"\n'
    query = "&".join(f"{k}={v}" for k, v in params.items())
    result = subprocess.run(["curl", "-s", "--config", "-", f"https://slack.com/api/{method}?{query}"],
                            input=curl_config, capture_output=True, text=True)
    return json.loads(result.stdout or "{}")


def slack_activity_from_api(roster):
    with ThreadPoolExecutor(max_workers=8) as pool:
        return dict(pool.map(lambda m: (m["id"], slack_member_activity(m["id"])), roster["members"]))


def slack_member_activity(user_id):
    profile = slack_api("users.info", user=user_id).get("user", {})
    presence = slack_api("users.getPresence", user=user_id).get("presence")
    matches = slack_api("search.messages", query=f"from:<@{user_id}>", sort="timestamp", count=1) \
        .get("messages", {}).get("matches", [])
    latest = matches[0] if matches else {}
    status = profile.get("profile", {})
    return {
        "tz": profile.get("tz"),
        "status": f"{status.get('status_emoji', '')} {status.get('status_text', '')}".strip(),
        "presence": presence,
        "last_msg": latest.get("ts"),
        "last_channel": "#" + latest["channel"]["name"] if latest.get("channel", {}).get("name") else "",
    }


# ---------- table ----------

def render_table(roster, config, slack_activity, github):
    now = datetime.now(timezone.utc)
    rows = [member_row(m, slack_activity.get(m["id"], {}), github.get(m.get("github")), now)
            for m in roster["members"]]
    rows.sort(key=lambda r: r["last_active"], reverse=True)

    lines = [
        f"**{roster['channel_name']}** · {len(rows)} people · {datetime.now(home_zone()).strftime('%a %H:%M')}",
        "",
        "| | Who | Local time | Status | Last Slack | Last GitHub |",
        "|---|---|---|---|---|---|",
    ]
    lines += [f"| {r['presence']} | {r['name']} | {r['local_time']} | {r['status']} | {r['slack']} | {r['github']} |"
              for r in rows]
    lines += ["", legend(slack_activity)]
    unmapped = [m["name"] for m in roster["members"] if not m.get("github")]
    if not config["github_org"]:
        lines.append(f"Set github_org in {CONFIG_PATH} to include GitHub activity.")
    elif unmapped:
        lines.append(f"No GitHub login for {', '.join(unmapped)} (set it in {ROSTER_PATH}).")
    return "\n".join(lines)


def member_row(member, slack, github, now):
    slack_at = parse_slack_time(slack.get("last_msg"))
    github_at = github[0] if github else None
    last_active = max(filter(None, [slack_at, github_at]), default=datetime.min.replace(tzinfo=timezone.utc))
    return {
        "name": member["name"],
        "presence": presence_marker(slack.get("presence"), now - last_active),
        "local_time": local_time(slack.get("tz"), now),
        "status": escape_cell(slack.get("status") or ""),
        "slack": f"{ago(slack_at, now)} {slack.get('last_channel', '')}".strip() if slack_at else "–",
        "github": f"{ago(github_at, now)} · {github[1]}" if github else "–",
        "last_active": last_active,
    }


def presence_marker(slack_presence, idle):
    if slack_presence == "active":
        return "🟢"
    if slack_presence == "away":
        return "⚪"
    if idle < ACTIVE_WINDOW:
        return "🟢"
    if idle < RECENT_WINDOW:
        return "🟡"
    return "⚪"


def legend(slack_activity):
    if any(a.get("presence") for a in slack_activity.values()):
        return "🟢 online in Slack · ⚪ away · 🌙 outside 8am–7pm their time"
    return "🟢 active in last 15m · 🟡 last 90m · ⚪ quiet · 🌙 outside 8am–7pm their time (presence inferred from activity)"


def local_time(tz_name, now):
    if not tz_name:
        return "?"
    local = now.astimezone(ZoneInfo(tz_name))
    off_hours = local.weekday() >= 5 or local.hour not in WORKDAY_HOURS
    city = tz_name.split("/")[-1].replace("_", " ")
    return f"{local.strftime('%H:%M')} {city}{' 🌙' if off_hours else ''}"


def ago(when, now):
    seconds = int((now - when).total_seconds())
    if seconds < 3600:
        return f"{max(seconds // 60, 0)}m ago"
    if seconds < 86400:
        return f"{seconds // 3600}h ago"
    return f"{seconds // 86400}d ago"


def escape_cell(text):
    return text.replace("|", "\\|")


def parse_iso(value):
    return datetime.fromisoformat(value.replace("Z", "+00:00"))


def parse_slack_time(value):
    """Accepts a Slack ts ("1729521000.1234") or MCP search output ("2026-10-21 10:28:07 EDT").

    MCP search renders times in the caller's own zone, so the abbreviation is dropped
    and the time read in the machine's home zone.
    """
    if not value:
        return None
    if re.fullmatch(r"\d+(\.\d+)?", str(value)):
        return datetime.fromtimestamp(float(value), timezone.utc)
    stamp = re.match(r"\d{4}-\d{2}-\d{2} \d{2}:\d{2}(:\d{2})?", str(value))
    return datetime.fromisoformat(stamp.group(0)).replace(tzinfo=home_zone()).astimezone(timezone.utc) if stamp else None


def home_zone():
    """The Mac's configured zone, which a TZ override in the shell (e.g. TZ=UTC) would otherwise mask."""
    zone_path = Path("/etc/localtime").resolve().as_posix()
    return ZoneInfo(zone_path.split("zoneinfo/")[-1]) if "zoneinfo/" in zone_path else None


def main():
    command, arg = sys.argv[1], " ".join(sys.argv[2:])
    if command == "plan":
        plan(arg)
    elif command == "save-roster":
        save_roster(json.load(sys.stdin))
    elif command == "render":
        render(json.load(sys.stdin))
    elif command == "prefetch-github":
        prefetch_github()
    else:
        sys.exit(f"unknown command: {command}")


if __name__ == "__main__":
    main()
