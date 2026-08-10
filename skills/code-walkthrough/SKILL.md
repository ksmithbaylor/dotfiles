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
but it shows those hunks like any other section. Before building, verify
coverage two ways: every entry in `files` (below) has its lines accounted for
across the sections, and the per-file added/removed line counts match
`git diff --numstat` for the scope.

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

Name both files `YYYY-MM-DD-HHMMSS-<repo>-<slug>` (timestamp from
`date +%Y-%m-%d-%H%M%S`) where `<repo>` is `basename $(pwd)` and `<slug>` is a
two-or-three-word kebab-case name for the change, then build and open:

```bash
out=~/.claude/code-walkthroughs
mkdir -p $out
~/.claude/skills/code-walkthrough/scripts/build.sh $out/<name>.json $out/<name>.html
open $out/<name>.html
```

The timestamp matters: the page stores the user's review state (comments,
reviewed marks) in the browser keyed by filename, so a unique name per
generation is what makes each review start fresh. Never reuse or overwrite an
earlier walkthrough's filename.

The JSON stays next to the HTML so a walkthrough can be rebuilt or revised
later. Finish by giving the user both paths and a one-line summary of the
section count; do not dump the walkthrough content into the conversation.
