# Alien::TinyCDB House Rules

The shared house rules come from skilletor — bundle `getty-cpan-dist@getty`: engineering
discipline, the delegation lock, the publish gate, karr coordination, CPAN release. They
load as `.claude/rules/.local.*.md`; if they are missing, run `skilletor sync` and publish
nothing until they load. This file adds what is true only here, and wins where it differs.

## What this repo is

Alien package for the TinyCDB library — deliberately tiny: `dist.ini` build config, an
`alienfile`, a POD-only `.pm`, one smoke test. Read first: the `alienfile` end to end before
changing any part; probe, download, `make` and the gathered flags are one chain.

## Agent team

| Task | Agent |
|---|---|
| Implement / refactor / debug the `alienfile`/`dist.ini` build config, the `.pm`, or `t/` | `alien-tinycdb-worker` (default) |
| Commits, `Changes`, card → done, pre-release audit | `alien-tinycdb-release-manager` |
| Read-only research, audit, gap analysis | `alien-tinycdb-worker` ("read-only, change nothing") |

Behavior-relevant = the `alienfile` build recipe and `dist.ini`'s `alien_build=1` config
(probe/download/build/install), `lib/Alien/TinyCDB.pm`, and `t/`. Prose in `README.md` and
`Changes` bullets are not.

## Hazards — mechanism and background: skill `alien-tinycdb-core`

- **The build lives in the `alienfile` (Alien::Build path).** `[@Author::GETTY]` carries
  `alien_build = 1`, which generates a `Makefile.PL` via `Alien::Build::MM` — MakeMaker
  stays, there is no `Build.PL`. Change build behaviour by editing the `alienfile`, not
  `dist.ini`.
- **Upstream is fetched at build time, not vendored, pinned to one tarball and its
  SHA256.** The share build downloads `tinycdb-0.81.tar.gz` over https and runs `make`, so
  it needs network + a C compiler + `make`; a version bump changes the file name and the
  digest together and is a maintainer decision.
- **`t/load.t` asserts the consumer contract** — assert the actual flags, not a proxy.
- **An untracked file does not exist as far as dzil is concerned.** `Git::GatherDir` skips
  it; `prove` runs it and passes while the release tarball omits it. `git add` new files as
  soon as they exist.
- **Only `alien-tinycdb-core` is owned here; the other skills and the shared rules are
  build artifacts.** The ones `skilletor` installs are overwritten by the next
  `skilletor sync` — never edit them, they change in their source repo.

## Perl / Alien conventions — reference, don't restate

The Alien mechanics and consumer contract live in `perl-alien`; the XS/link side in
`perl-xs`; the release flow in `getty-perl-release-author-getty` and `perl-release-dist-ini`;
the TinyCDB specifics in `alien-tinycdb-core` — all force-loaded via `briefing.skills`.
