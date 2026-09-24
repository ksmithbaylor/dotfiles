---
name: pr-description
description: Write or revise a pull request description so it serves the reviewer instead of recording your investigation. Use when opening a PR, editing a PR body, filling in a PR template, or when asked to summarize a change for reviewers.
argument-hint: "<PR number or branch>, or nothing to use the current branch"
---

# PR descriptions

A PR description answers one question: **should this change go in, and does it
do what it says?** Anything that instead records how you got there does not
belong.

The length tracks the complexity of the change, not the effort you spent. A
two-line migration gets a two-line description no matter how long you spent
confirming it was safe. Effort does not earn words.

## What belongs

- **What changes, and why now.** One or two sentences. Link the issue, ticket,
  or prior PR that supplies the context rather than restating it.
- **Anything a reviewer cannot see in the diff.** A constraint that shaped the
  design, a deliberate omission, a consequence in another system, a blocking
  dependency.
- **Whatever the repo's template genuinely asks for.** Fill the sections
  honestly and briefly; a checkbox plus a short line beats a paragraph.

That is usually the whole thing.

## What to cut

Every item below is something that felt worth saying because it was a live
question for *you*. None of it helps someone review the change.

- **Your process history.** A file you renumbered, a name upstream took first, a
  rebase, an approach you tried and dropped. Real work, invisible value.
- **Standard semantics of the tools you used.** `DROP TABLE` takes the primary
  key, foreign keys, indexes, and triggers with it. That is the database's
  behaviour, not your change. Never enumerate it.
- **Anything the diff already shows.** Regenerated lockfiles or schemas, file
  counts, which block moved where. Reviewers read diffs.
- **Verification evidence.** Row counts, deploy timestamps, version tags, base
  rates, query output. If a precondition is met, say so in one sentence. Do not
  publish the investigation that established it.
- **Sign-offs you chased.** Approval you were told to stop asking about should
  not resurface as a line in the PR.
- **Justifications for decisions nobody questioned.** Explaining why you did the
  ordinary, default thing implies it was contentious. It reads as defensive and
  invites a debate that was not happening.

## The blocked-PR case

When a PR must wait on something, state the condition and its status in one
sentence:

> The prior PR is now deployed and no longer writes to the table, so it can be
> dropped.

Not the deploy timestamps, not the build tags, not the telemetry that convinced
you. If a reviewer wants the evidence, they will ask.

## The accuracy trap

Padding pulls you toward clean absolutes, and clean absolutes are easy to get
wrong. "Not referenced in any documentation" is a satisfying line to write and
is falsified the moment your own diff touches a comment. The shorter version is
usually the more accurate one, because it claims less.

Re-check every absolute against your own diff before posting.

## Worked example

A migration that drops an unused table. Before:

> `V141` (not V139 as the earlier PR said — upstream has since taken V139 for
> the token enum and V140 for a relay type) is a plain `DROP TABLE`, no
> `CASCADE`, so an unexpected dependency fails loudly rather than being silently
> dropped. The PK, the `(network_id, token, address)` unique constraint, the FK
> to `networks`, the `updated_at` trigger, and the two role grants all go with
> the table.
>
> Also removes the trigger's stanza from `R__updated_at_triggers.sql` and
> regenerates `schema.sql` (five blocks).

After:

> `V141` drops the table cleanly, and the trigger for the table in
> `R__updated_at_triggers.sql` is also removed.

Four cuts, one per category: the renumbering is process history, the `CASCADE`
note defends an unquestioned default, the constraint list is database
semantics, and the regenerated schema is visible in the diff.

## Process

1. Draft the description.
2. Delete every sentence that is about *your work* rather than *the change*.
   Read each one and ask who it is for. If the answer is "me, three days ago,
   when I wasn't sure," cut it.
3. Re-check each remaining factual claim, especially absolutes, against the diff.
4. Match the repo's template and tone. Look at two or three recent merged PRs if
   you have not written for this repo before.

## Where the rest goes

The material you cut is often genuinely interesting, and some of it matters. Put
it in the conversation with the person you are working with, where they can ask
follow-ups, or in a commit message where the detail is closer to the code. Do
not put it in an artifact that every reviewer has to read past.
