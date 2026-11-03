# Alien::TinyCDB

[Alien](https://metacpan.org/pod/Alien::Base) package for [TinyCDB](http://www.corpit.ru/mjt/tinycdb.html), Michael Tokarev's small, fast C library for creating and reading constant databases.

## Synopsis

```perl
use Alien::TinyCDB;
use ExtUtils::MakeMaker;

WriteMakefile(
    ...
    LIBS => Alien::TinyCDB->libs,
    INC  => Alien::TinyCDB->cflags,
    ...
);
```

Or with [FFI::Platypus](https://metacpan.org/pod/FFI::Platypus):

```perl
use FFI::Platypus;
use Alien::TinyCDB;

my $ffi = FFI::Platypus->new( api => 1 );
$ffi->lib(Alien::TinyCDB->dynamic_libs);
```

## Description

TinyCDB is a public-domain implementation of Dan Bernstein's constant database
(cdb) format. It creates and reads constant key-value databases of up to 4GB;
the files are immutable once created and tuned for fast reading.

`Alien::TinyCDB` is built on [Alien::Base](https://metacpan.org/pod/Alien::Base).
It uses a system TinyCDB found via `pkg-config` (`libcdb`). Without one, it
fetches the pinned upstream release over https, verifies its SHA256, and builds
it from source. The static library is compiled with `-fPIC`, so XS consumers
can link it into a Perl shared object. The shared library is built as well for
FFI consumers.

## Interface

### cflags

```perl
my $cflags = Alien::TinyCDB->cflags;
```

The C compiler flags for compiling against TinyCDB.

### libs

```perl
my $libs = Alien::TinyCDB->libs;
```

The linker flags for linking against TinyCDB (`-lcdb`).

### dynamic_libs

```perl
my @libs = Alien::TinyCDB->dynamic_libs;
```

The paths of the shared library, for use with
[FFI::Platypus](https://metacpan.org/pod/FFI::Platypus).

## Installation

```
cpanm Alien::TinyCDB
```

The build from source needs a C compiler, `make` and network access.

## See Also

- [Alien::Base](https://metacpan.org/pod/Alien::Base)
- [TinyCDB homepage](http://www.corpit.ru/mjt/tinycdb.html)
- [CDB_File](https://metacpan.org/pod/CDB_File), an XS interface to cdb files with its own cdb implementation

## Author

Torsten Raudssus `<getty@cpan.org>`

## License

This software is copyright (c) 2026 by Torsten Raudssus. This is free software; you can redistribute it and/or modify it under the same terms as the Perl 5 programming language system itself.
