# Alien::TinyCDB House Rules

Apply to every task in this distribution unless explicitly overridden. Bias: caution over
speed on non-trivial work; use judgment on trivial tasks. Loaded automatically at launch
(same priority as `CLAUDE.md`). Subagents get their conventions from the skills
force-loaded via `briefing.skills` — this file is for the orchestrating agent.

## Engineering discipline

1. **Think before coding** — State assumptions; ask rather than guess. Push back when a
   simpler approach exists. Stop when confused; name what's unclear.
2. **Simplicity first, surgically applied** — Minimum code that solves the problem,
   nothing speculative. This dist is deliberately tiny: `dist.ini` build config, a
   POD-only `.pm`, one smoke test. Touch only what you must.
3. **Goal-driven execution** — Define success criteria, loop until verified.
4. **Surface conflicts, don't average them** — Contradicting patterns: pick one, explain
   why, flag the other. Don't blend.
5. **Read before you write** — Read the `alien_*` block in `dist.ini` end to end before
   changing any key; probe, download, `make` and the gathered flags are one chain.
6. **Tests verify intent, not just behavior** — `t/load.t` asserts the consumer contract;
   assert the actual flags, not a proxy. Reproduce a bug before fixing it; leave the
   regression test behind.
7. **A red test is a claim before it is a failure** — Before changing code to turn a test
   green, say what the test asserts and whether your fix keeps that claim or replaces it.
8. **Checkpoint and fail loud** — Summarize done / verified / left after each significant
   step. "Done" is wrong if anything was skipped silently; "tests pass" is wrong if any
   were skipped — say so.
9. **Match the codebase's conventions, even if you disagree** — Conformance > taste.

## Delegation

Depends on whether the Agent/Task tool is available to you.

- **You can spawn subagents** (orchestrating main agent): Do NOT touch behavior-relevant
  code yourself — delegate. Your lane: coordinate, inspect, plan, review diffs, run
  tests, manage git, edit `Changes`/`README.md`. When in doubt, delegate. Why: only the
  `alien-tinycdb-*` agents get their skills force-loaded via `briefing.skills`; you get no
  briefing and would edit the build config without the Alien and TinyCDB context.

  | Task | Agent |
  |---|---|
  | Implement / refactor / debug the `dist.ini` build config, the `.pm`, or `t/` | `alien-tinycdb-worker` (default) |
  | Pre-release audit | `alien-tinycdb-release-checker` |

- **You cannot spawn subagents** (you ARE an `alien-tinycdb-*` agent): the lock does not
  apply — implement, refactor, debug and test per these rules.

Behavior-relevant = the `dist.ini` `alien_*` build config (probe/download/build/install),
`lib/Alien/TinyCDB.pm`, and `t/`. Prose in `README.md` and `Changes` bullets are not.

## Coordination — karr board (always in scope)

Ticket coordination is the orchestrating agent's job, so `karr` is always in scope — don't
invoke the `kanban-issues-karr-cli` skill first, just use it. Git-native kanban; state
lives in `refs/karr/*`.

- `karr list --compact` / `karr board` — open work · `karr show ID` — detail
- `karr create "Title" --priority high --tags a,b --body '…'` · `karr edit ID -a "note"`
  · `karr move ID in-progress --claim NAME` · `karr handoff ID --claim NAME --note "…"`
  — full surface: skill `kanban-issues-karr-cli`

Record drift and follow-up work as tickets rather than growing the current change.
**Serialize board mutations when fanning out** — parallel implementation is fine, but
collect results and then loop `karr move`/`handoff`/`sync` sequentially.

## Release — never without permission

`dzil build` / `dzil test` are fine anytime. `dzil release` and any CPAN upload are
STRICTLY forbidden without the maintainer's explicit go-ahead — even if a ticket lists
"release" as the next step. For anything heading toward release: stop and ask. Only the
local repo state matters; CPAN lag is never a blocker and never a ticket.

## Hazards specific to this distribution

- **There is no alienfile — the build lives in `dist.ini`.** This is the
  `Alien::Base::ModuleBuild` path (no `alien_build = 1`), so the `alien_*` keys generate
  the `Build.PL`. A worker that goes looking for an `alienfile` to edit, or adds one, is
  changing the wrong thing. Mechanism: skill `alien-tinycdb-core`.
- **Upstream is fetched at build time, not vendored, and the version is not pinned.** The
  share build downloads the newest `tinycdb-*.tar.gz` from `alien_repo` and runs `make`,
  so it needs network + a C compiler + `make`, and a host without a system TinyCDB is the
  path that actually exercises the build. Pinning a version is a `dist.ini` change and a
  maintainer decision.
- **An untracked file does not exist as far as dzil is concerned.** `Git::GatherDir` skips
  it; `prove` runs it and passes while the release tarball omits it. `git add` new files
  as soon as they exist.
- **Shared skills under `.claude/skills/` are hardlinks.** `Edit`/`Write` on one detaches
  it from the library silently. Only `alien-tinycdb-core` is owned here; everything else
  changes via `manage-skills` in its home repo.

## Perl / Alien conventions — reference, don't restate

The Alien mechanics and consumer contract live in `perl-alien`; the XS/link side in
`perl-xs`; the release flow in `getty-perl-release-author-getty` and
`perl-release-dist-ini`; the TinyCDB specifics in `alien-tinycdb-core` (all force-loaded
per lane via `briefing.skills`). Do not duplicate that content here.
