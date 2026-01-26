use strict;
use warnings;
use Test::More tests => 3;

use_ok('Alien::TinyCDB');

diag("cflags: " . Alien::TinyCDB->cflags);
diag("libs: " . Alien::TinyCDB->libs);

ok(Alien::TinyCDB->cflags, 'cflags available');
ok(Alien::TinyCDB->libs, 'libs available');
