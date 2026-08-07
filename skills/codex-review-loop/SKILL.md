---
name: codex-review-loop
description: Run an adversarial code review as a back-and-forth conversation with Codex, resuming one persistent Codex session each round until no disagreements remain. Use when the user asks to have Codex review changes, wants a second opinion argued out rather than a one-shot review, or says "review this with Codex", "argue with Codex about", "codex review loop", or "keep going until you two agree".
argument-hint: "<scope>, e.g. this branch | src/billing/proration.ts, uncommitted only | last 3 commits; then what it does, what to focus on, what to skip"
---

# Codex review loop

Codex reviews, you fix or rebut, Codex re-checks. One Codex session carries the
whole argument, so it never re-litigates a point it already conceded. The run
ends when every finding is resolved, withdrawn, or declared an impasse, and the
transcript of that argument is written to a local markdown file.

Codex runs read-only. You make every edit. Two agents writing the same tree is
the main way this goes wrong.

The user is the third participant. They get a checkpoint after every reply from
either side, and what they say carries more weight than either agent's argument.

## Before starting

Run `codex exec --version` to confirm the CLI is there, and work from the repo
root. `codex exec resume` has no `--cd` flag, so the review follows the current
directory.

Create a run directory and announce it:

```bash
run=.codex-review/$(date +%Y%m%d-%H%M%S)
mkdir -p "$run"
```

Everything for the run lives there: prompts, Codex's raw events, the JSON
verdict per round, and `review.md`. Suggest the user gitignore `.codex-review/`
if it is not already ignored.

## The argument

The invocation carries up to four things, and they land in different places:

- **Scope** (leads): a branch, a path, a commit range, and whether uncommitted
  work counts. Drives the `git diff` below.
- **Intent**: what the change is meant to do. Goes in the opening prompt so
  Codex reviews against the goal rather than reviewing generic code.
- **Focus**: what to weight heavily. Passed through as a priority.
- **Skip**: what the user already knows and does not want argued. Tell Codex
  outright; every pre-empted nit is a round not spent on it.

Only scope is required. Missing intent costs the most, so infer it from the
diff and commits and say in the transcript that it was inferred.

## Scope

Default to everything not yet on the main branch, committed and uncommitted:

```bash
git diff $(git merge-base HEAD origin/main 2>/dev/null || git merge-base HEAD origin/master)
```

If the user named a narrower target (a PR, a file, a single commit), use that
instead. When the scope is ambiguous and the readings differ materially, ask.

## Round 1

Write the opening prompt to `$run/round-1-prompt.md`. It needs the review
request, the diff, and the protocol Codex must follow:

> You are reviewing changes in this repository as an adversarial second
> opinion. Another agent (Claude) wrote them and will respond to your findings.
> We will go several rounds in this same conversation.
>
> Intent: [what the change is meant to do]
>
> Weight these heavily: [focus, if given]
>
> Already known, do not raise: [skip, if given]
>
> [the diff]
>
> Read whatever else in the repo you need for context. Rules for the whole
> review:
>
> - Give each finding a stable id (F1, F2, ...). Never renumber or reuse an id.
> - Carry every finding forward in each response, including ones already
>   resolved or withdrawn, so the list is always complete.
> - Mark a finding `resolved` only after you have verified the fix in the
>   working tree, not because a fix was described to you.
> - Mark it `withdrawn` when Claude's rebuttal convinces you. Changing your
>   mind on evidence is the point of this exercise, not a loss.
> - Mark it `impasse` when neither of you is moving and the disagreement is a
>   judgment call for the human.
> - Raise new findings in later rounds only if the new code introduced them.
>   Do not pad the list to look thorough.
> - Severity: blocker (broken or unsafe), major (probably bites in
>   production), minor (real but survivable), nit (taste).
> - Later messages may contain a block headed `HUMAN`. That is the author
>   speaking, not Claude. Their ruling on a finding is final: mark it as they
>   direct and do not re-argue it. Everything outside that block is Claude's.

Then run the round, from the repo under review:

```bash
~/.claude/skills/codex-review-loop/scripts/codex-round.sh "$run" "$run/round-1-prompt.md"
```

The script starts the session, records its thread id, and prints the path to
Codex's JSON verdict. Read that file. Its shape is
`reference/verdict-schema.json`, enforced by Codex, so you can branch on
`verdict` and finding `status` directly rather than interpreting prose.

Then go to the checkpoint below. Do not start fixing anything yet.

## Checkpoints

Stop for the user twice per round, once after each side speaks. Never chain two
rounds together without them.

**After Codex replies**, before doing any work: show the verdict and the open
findings, one line each, then ask with `AskUserQuestion`:

> Anything to add before I respond to Codex?
> Options: `Nothing, continue` / `You two finish it` / `Stop the review here`

The free-text option is where their commentary goes. Whatever they type steers
the work: `F2 is wrong, push back` means rebut rather than fix, `skip F3` means
defer it, `F1 matters most` reorders the effort.

**After you draft your response**, before it goes out: show the response and ask
the same way. This is their chance to contradict or reinforce an argument you
made, and their addition rides along in the same message to Codex.

Two rules about their words. Pass them **verbatim**, never paraphrased, and
never merged into your own prose. And attribute them, so Codex can weigh them
correctly:

```
## HUMAN (round N)

> [their text, exactly as typed]

The human's ruling is final on any finding it addresses.
```

If they rule on a finding, apply that ruling in your own response too. Do not
keep arguing a point the user has settled, in either direction.

Their comment also counts as a new argument, so it clears the impasse counter
below. A stalled disagreement that the user weighs in on is worth another round.

## When the user hands off

`You two finish it` means they are done with the detail and want the argument
settled without them. It holds for the rest of the run, both checkpoints, not
just the round it was said in. Stop asking and run to termination.

The stop conditions do not change. Rounds still cap at five, impasses are still
recorded as impasses rather than resolved by you, and the transcript still lands
where it was going to. What changes is only that nobody is asked along the way,
so the transcript becomes the whole record of what happened after they left.
Note the round they handed off in, so a reader can tell which decisions had a
human in the loop.

Come back to them anyway for two things: a fix that reaches outside the scope
they set, and anything destructive or hard to undo. Handing off the argument is
not handing off that judgment. If either comes up, say what happened and what
you need, and treat the answer as re-engagement unless they hand off again.

They can also cut back in whenever they like, since the run is in the
conversation. It is a handoff, not a lock.

## Each round after that

Work every `open` finding. Each one gets exactly one of three answers, and none
may be skipped:

- **Fixed**: make the change, then state what you changed and where.
- **Rebutted**: argue it, with `file:line` evidence for why Codex is wrong.
  Do this when you believe you are right; a review loop where one side always
  folds produces worse code than no review.
- **Deferred**: accepted as valid but out of scope, with the reason.

Write the response to `$run/round-N-prompt.md` addressing findings by id, plus
the diff of what you changed this round and any `HUMAN` block from either
checkpoint. Take the second checkpoint on that draft, then resume the session:

```bash
~/.claude/skills/codex-review-loop/scripts/codex-round.sh "$run" "$run/round-N-prompt.md"
```

Every call after the first resumes automatically, since the thread id is on disk.
Never start a second session for the same review.

## When to stop

Stop when no finding is `open`, meaning each is resolved, withdrawn, or at
impasse. Codex's `verdict` should be `approved` at that point; if it approves
while findings are still open, keep going, since the open list is what matters.

Four other exits, all of which end the run and go to the user:

- **The user stops it.** Either checkpoint can end the run. Write the transcript
  and report where things stood, mid-argument is fine.
- **Impasse.** A finding stays open two rounds with no new argument from either
  side and no user comment on it. Say so in your response and ask Codex to mark
  it `impasse`.
- **Round cap.** Five rounds. Past that the two of you are circling.
- **Failure.** The script exits non-zero when Codex returns no valid verdict.
  Report the round that failed and where its event log is instead of retrying
  blind.

## The transcript

Maintain `$run/review.md` and update it after every round, so an interrupted
run still leaves something readable. Structure it as:

- **Summary**: rounds taken, how it ended, counts by outcome, and the round the
  user handed off in if they did.
- **Findings**: one section per finding id, covering what Codex claimed, what
  you answered, and how it resolved. Quote the arguments where they matter;
  this file is the record of *why* the code looks the way it does. Where the
  user intervened, quote them verbatim and attribute it, since a call they made
  is the strongest reason a finding ended the way it did.
- **Changes made**: the fixes applied, with file references.
- **Unresolved**: impasses and deferrals, each stated as a decision waiting on
  the user.

Close by giving the user the transcript path, the count of fixes applied, and
anything at impasse. Lead with what needs their attention.
