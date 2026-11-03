#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use Test::Alien;
use Alien::TinyCDB;

# The XS consumer path from the POD: compile against ->cflags and link ->libs
# into a Perl shared object. On the share path this fails with
# "relocation R_X86_64_32 ... recompile with -fPIC" when libcdb.a was built
# without PIC objects (cdb_make_put.o is the one that carries the relocation).
alien_ok 'Alien::TinyCDB';

my $xs = <<'END_XS';
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include <cdb.h>

MODULE = TA_TinyCDB PACKAGE = TA_TinyCDB

int
hash(key)
    SV *key
  CODE:
    STRLEN len;
    const char *p = SvPV(key, len);
    RETVAL = (int)(cdb_hash(p, (unsigned)len) & 0x7fffffff);
  OUTPUT:
    RETVAL

int
make_cdb_ok()
  CODE:
    struct cdb_make cdbm;
    FILE *f = tmpfile();
    RETVAL = -1;
    if (f) {
      RETVAL = cdb_make_start(&cdbm, fileno(f));
      if (RETVAL == 0)
        RETVAL = cdb_make_put(&cdbm, "key", 3, "value", 5, CDB_PUT_ADD);
      if (RETVAL == 0)
        RETVAL = cdb_make_finish(&cdbm);
      fclose(f);
    }
  OUTPUT:
    RETVAL
END_XS

xs_ok { xs => $xs, verbose => 0 }, with_subtest {
  is(TA_TinyCDB::make_cdb_ok(), 0, 'cdb_make_start/put/finish succeed');
  # the cdb hash of the empty string is the djb seed
  is(TA_TinyCDB::hash(''), 5381, 'cdb_hash("") is the djb seed 5381');
};

done_testing;
