use strict;
use warnings;
use Test::More;
use Test::Alien;
use Alien::TinyCDB;

# A share build on a non-Linux host may legitimately have no shared libcdb:
# upstream's sharedlib target needs GNU ld flags and the alienfile skips it
# there (see t/load.t).
plan skip_all => 'no shared libcdb built on this platform'
  if Alien::TinyCDB->install_type eq 'share' && $^O ne 'linux'
    && !Alien::TinyCDB->dynamic_libs;

# The FFI consumer path from the POD: dlopen ->dynamic_libs and call into it.
alien_ok 'Alien::TinyCDB';

ffi_ok { symbols => ['cdb_hash', 'cdb_make_start'] }, with_subtest {
  my ($ffi) = @_;
  my $hash = $ffi->function(cdb_hash => ['string', 'uint'] => 'uint');
  is($hash->call('', 0), 5381, 'cdb_hash("") is the djb seed 5381');
  is($hash->call('a', 1), 177604, 'cdb_hash("a") == (5381*33) ^ 97');
};

done_testing;
