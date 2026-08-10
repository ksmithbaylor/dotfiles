---
name: code-walkthrough
description: Produce a guided visual walkthrough of a diff, reordered into a logical narrative instead of file-path order and rendered as a self-contained HTML page. Use when the user asks to be walked through changes you or someone else made, wants a narrative or guided review of a diff, or says "walk me through this diff", "walk me through your changes", or "code walkthrough".
argument-hint: "<scope>, e.g. this branch | src/billing/, uncommitted only | last 2 commits; optionally what to focus on"
---

# Code walkthrough

A diff sorted by file path is almost never in the order the change makes sense.
This skill reorders it into a narrative: sections of related edits, each with a
short explanation, arranged so the reader builds understanding as they go. You
author a JSON file describing the walkthrough; a build script renders it into a
single dark-mode HTML page which you then open for the user. The page has two
tabs, the narrative walkthrough and a Tree view of the raw diff with a file
tree, cross-linked in both directions, with syntax highlighting, line numbers,
review-tracking, and diff display controls handled by the template.

## Scope

Default to everything not yet on the main branch, committed and uncommitted:

```bash
git diff $(git merge-base HEAD origin/main 2>/dev/null || git merge-base HEAD origin/master)
```

If the user named a narrower target (a path, a commit range, uncommitted only),
use that instead. When the scope is ambiguous and the readings differ
materially, ask.

**Re-review rounds.** When regenerating after review feedback, the feedback
prompt carries a snapshot SHA for the tree the user reviewed. After making
your changes, take a fresh snapshot with `scripts/snapshot.sh` (the new
walkthrough needs it anyway) and scope to
`git diff <reviewed sha> <fresh sha>`, passing the same command to the build
script's `--diff` check. Always diff snapshot-to-snapshot; diffing a snapshot
against the working tree misreports files that are still untracked. If the
reviewed snapshot has been pruned, fall back to the original full scope and
tell the user.

## Grouping and ordering

Read the full diff before writing anything. If you didn't author the change,
read enough surrounding code to know why each edit exists, not just what it
does.

Group related hunks by concept, not by file: "the new data model", "wiring it
into the CLI", "test coverage for the edge cases". One file's hunks may be
split across several sections, and one section may pull from several files.

Order the sections so each builds on the last: foundations first, then the
code that uses them, with mechanical fallout (renames, imports, lockfiles,
generated files) batched near the end. When there is no clean dependency
order, lead with whatever makes the rest easiest to understand, usually the
heart of the change.

**Every hunk in the diff appears in exactly one section.** Nothing may be
summarized away: a closing section batching lockfile churn or renames is fine,
but it shows those hunks like any other section. Coverage is enforced
mechanically: pass the scope's diff command to the build script (below) and it
refuses to build on any mismatch, telling you what is missing or extra.

To split one large hunk across sections, don't recompute `@@` headers by
hand; pipe the file's diff through `scripts/slice-hunks.py` (see the script
reference) and paste each emitted piece into its section.

Never use the word "stop" for these groupings anywhere in the output. They are
just sections.

## Context beyond the diff

When the diff calls into existing code the reader needs in front of them, or
when you want to point at something specific the change interacts with, add a
`context` block: a verbatim excerpt of code that is not part of the diff. The
UI renders these visually distinct from diff blocks and labels them as not
part of the change, so use them freely where they help and nowhere else. Give
each a `startLine` and, when the reason it's there isn't obvious, a one-line
`note`.

## Writing style

The reader is a maintainer of this codebase. Assume they know the project's
architecture, conventions, and domain. Do not explain things they would
already know, restate what the diff plainly shows, or pad sections with
generalities. A few sentences per section is the norm: what the code now does
differently, or why it exists at all. If a section needs a paragraph, fine,
but earn it. Prose fields are markdown.

## Building the page

Write the walkthrough as JSON matching `reference/walkthrough-schema.json`:
title, repo, scope, date, a markdown overview at the level of a good PR
description, the ordered sections, each with prose and its blocks, and a
`files` array holding the complete per-file diff in git's own order (with each
file's `status`, and `oldFile` for renames), which the Tree tab renders. Diff
blocks and `files` entries carry raw unified-diff text exactly as git produced
it, `@@` headers included; the renderer derives line numbers and the
cross-links between the two tabs from those headers, so do not trim or
renumber lines within a hunk. Splitting one large hunk across sections is fine
as long as each piece keeps a correct `@@` header for where it starts. Set
`lang` only when the file's extension would misidentify the language.

Every walkthrough also records where the next round starts from: run
`scripts/snapshot.sh` and put the SHA it prints in the JSON's `snapshot`
field. The page embeds it in the copied review prompt, which is how a future
round (even in a fresh session) knows to scope itself to just what changed.

Name both files `YYYY-MM-DD-HHMMSS-<repo>-<slug>` (timestamp from
`date +%Y-%m-%d-%H%M%S`) where `<repo>` is `basename $(pwd)` and `<slug>` is a
two-or-three-word kebab-case name for the change, then build and open:

```bash
out=~/.claude/code-walkthroughs
mkdir -p $out
~/.claude/skills/code-walkthrough/scripts/build.sh $out/<name>.json $out/<name>.html \
  --diff "<the exact command that produces the scope's diff>"
open $out/<name>.html
```

Always pass `--diff` with the same command the scope came from (e.g.
`git diff <merge-base>`, `git show <sha>`, `git diff --cached`); it is what
guarantees the walkthrough shows the whole diff and nothing else. If the check
fails, fix the JSON and rebuild; don't narrate the failure to the user.

The timestamp matters: the page stores the user's review state (comments,
reviewed marks) in the browser keyed by filename, so a unique name per
generation is what makes each review start fresh. Never reuse or overwrite an
earlier walkthrough's filename.

The JSON stays next to the HTML so a walkthrough can be rebuilt or revised
later.

## Reporting back

Close with a short summary about the change itself: what it does, why, and
anything worth the reviewer's attention first. Do not summarize the
walkthrough's structure, the steps you took, or the coverage verification;
all of that happens in the background. Give exactly two mechanics: the HTML
path (never the JSON path) and the diff command the walkthrough is based on.
The `open` in the build step already put it on screen. Do not dump walkthrough
content into the conversation.

## Script reference

`scripts/build.sh <walkthrough.json> <out.html> [--diff "<command>"]`
renders the JSON into the self-contained HTML page. With `--diff`, the command
runs through bash and its output is compared against the JSON before building:

- The `files` array must contain exactly the diff's files, with matching
  added/removed lines, matching `status`, and matching `oldFile` on renames.
- The union of all section diff blocks must likewise contain exactly the
  diff's added/removed lines per file, with split-hunk pieces reassembled by
  their `@@` positions.
- On mismatch, nothing is built; the failure lists each missing or extra line
  so the JSON can be corrected. Matching content in the wrong order builds
  with a warning that points at the `@@` headers of split hunks.

`scripts/snapshot.sh`
prints the SHA of a commit object capturing the current working tree, tracked
and untracked files alike, without touching the index, the worktree, or any
ref (it stages into a throwaway index and uses `commit-tree`). The commit is
dangling: invisible to log/status/stash, diffable like any commit, and safe
from garbage collection for weeks. Run it from the repo root at generation
time and store the SHA in the JSON's `snapshot` field. Round-to-round deltas
are always computed snapshot-to-snapshot (`git diff <old> <new>`), never
snapshot-to-worktree, which misreports still-untracked files.

`scripts/slice-hunks.py [--old] START END`
reads one file's unified diff on stdin and writes the hunk pieces covering
the inclusive line range START..END to stdout, with `@@` headers recomputed
(zero-count sides anchor git-style to the line before the insertion point).
The range is in new-file numbering; pass `--old` to use old-file numbering,
which is what deleted files need. Removed lines belong to the range containing
the position they were removed from. Example, splitting one file across two
sections:

```bash
git show <sha> -- src/big.ts | scripts/slice-hunks.py 1 80    # first piece
git show <sha> -- src/big.ts | scripts/slice-hunks.py 81 200  # second piece
```
