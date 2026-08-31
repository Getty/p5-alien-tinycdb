---
name: alien-tinycdb-core
description: "Use when working on Alien::TinyCDB — the dist.ini alien_* build config, the Alien::Base::ModuleBuild probe/download/make pipeline, lib/Alien/TinyCDB.pm, or the cflags/libs/dynamic_libs contract this Alien hands to XS or FFI consumers of Michael Tokarev's TinyCDB (corpit.ru cdb) C library. Covers why there is no alienfile, share-vs-system, and that upstream is fetched (not vendored)."
---

# Alien::TinyCDB — what this distribution actually decides

`Alien::TinyCDB` is a thin `Alien::Base` wrapper whose whole job is to make the
**TinyCDB** C library (Michael Tokarev's public-domain implementation of djb's constant
database, `http://www.corpit.ru/mjt/tinycdb`) available to Perl consumers through the
standard `cflags`/`libs`/`dynamic_libs` methods — either by detecting a system install or
by building it from upstream source.

Generic Alien / consumer mechanics live in skill `perl-alien`; the XS/link side in skill
`perl-xs`. This skill is only the TinyCDB-specific invariants — read it before editing
`dist.ini`'s build config or reasoning about why a consumer's link broke.

## There is no alienfile — the build is configured in dist.ini

This is the invariant a reader will get wrong first. `perl-alien` (and the sibling
`Alien::Tree::Sitter`) describe the modern `Alien::Build` + **`alienfile`** path. This
distribution uses the **older `Alien::Base::ModuleBuild`** path instead:

- `cpanfile` declares `Alien::Base::ModuleBuild` under `configure` — the generated
  `Build.PL` is a `Module::Build` subclass, not `Alien::Build::MM`.
- `[@Author::GETTY]` has **no `alien_build = 1`**. That flag is what switches the bundle
  to the alienfile path; without it, the bundle wires the `alien_*` keys into a
  `Build.PL` built on `Alien::Base::ModuleBuild`.

So **there is no `alienfile` and no `Build.PL` in the repo** — the bundle generates the
`Build.PL` at `dzil build` time from the `alien_*` keys. To change build behaviour you
edit those keys in `dist.ini`; do not go looking for an alienfile to edit or add one.

The keys that drive it, and what each decides:

```ini
alien_repo = http://www.corpit.ru/mjt/tinycdb   # directory the tarball is fetched from
alien_name = tinycdb
alien_pattern_prefix  = tinycdb-                 # }
alien_pattern_version = ([\d\.]+)                # } match tinycdb-<version>.tar.gz
alien_pattern_suffix  = \.tar\.gz                # }
alien_autoconf_with_pic = 0                      # TinyCDB has no ./configure — do not treat it as autoconf
alien_build_command   = make prefix=%s          # plain Makefile; %s is the install prefix
alien_install_command = make install prefix=%s
```

`alien_autoconf_with_pic = 0` and the explicit `alien_build_command`/`alien_install_command`
are load-bearing together: TinyCDB ships a **plain hand-written `Makefile`, not an
autoconf project**, so the default autoconf `configure && make` path does not apply — the
build is driven by `make prefix=%s` directly. `%s` is the staging/install prefix Alien
supplies; never replace it with a literal path.

## Upstream is fetched, not vendored

Unlike a dist that bundles a `share/*.tar.gz`, this one has **no tarball in the repo**.
The share build downloads from `alien_repo` at install time and the pattern matches the
**newest** `tinycdb-<version>.tar.gz` the directory lists — the version is **not pinned**.
Consequences:

- The share-build path needs **network access, a C compiler, and `make`** at install
  time. An air-gapped host with no system TinyCDB cannot install.
- A new upstream release is picked up automatically. If a specific version ever must be
  held, that is a `dist.ini` change (pin the pattern), not a code change — and a
  maintainer decision.

## share vs system

`Alien::Base::ModuleBuild` probes first: if a usable system TinyCDB is found it takes the
**system** path and gathers flags from it; otherwise it takes the **share** path and runs
the download + `make` above into the Alien's own prefix. A machine that has the library
installed never exercises the share build — so a change to the build config must be tested
with the share path forced, not just on the maintainer's box.

## The consumer contract

Everything downstream asks the class and never repeats the logic:

```perl
Alien::TinyCDB->cflags         # C compiler flags to compile against TinyCDB
Alien::TinyCDB->libs           # linker flags to link against it
Alien::TinyCDB->dynamic_libs   # dynamic library paths, for FFI::Platypus->lib(...)
```

An XS consumer feeds `cflags`/`libs` into `INC`/`LIBS` in its `Makefile.PL`; an FFI
consumer passes `dynamic_libs` to `FFI::Platypus->lib`. The Alien belongs in the
consumer's **`configure_requires`** — its flags are needed before the consumer's build
runs. **Consumers never hardcode a `-l`/`-I` string; they ask the Alien**, which is the
entire reason this distribution exists.

`lib/Alien/TinyCDB.pm` is `use parent 'Alien::Base';` plus POD — **no logic, do not add
any**. Every flag a consumer gets comes from `Alien::Base` reading what the build
gathered; nothing is computed in the `.pm`.

## The smoke test

`t/load.t` asserts the contract minimally: the module loads, and `cflags` and `libs` both
return a true value (it also `diag`s them). That is the reason the distribution exists — a
change that leaves either empty breaks every consumer's compile/link, so keep that
assertion meaningful rather than loosening it to pass.
