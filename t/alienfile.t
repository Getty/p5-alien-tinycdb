use strict;
use warnings;
use Test::More;
use Alien::Build;

# The share build fetches upstream at install time. A future Alien::Build dies
# on an insecure fetch without a digest, so the recipe must pin a file over
# https and carry its SHA256.
plan skip_all => 'no alienfile in the current directory' unless -f 'alienfile';

my $build = Alien::Build->load('alienfile');
my $prop  = $build->meta->prop;

like($prop->{start_url}, qr{^https://}, 'start_url uses https');
like($prop->{start_url}, qr{/tinycdb-[0-9.]+\.tar\.gz$}, 'start_url pins one release tarball');

ok($prop->{check_digest}, 'digest checking is enabled');
my ($file) = $prop->{start_url} =~ m{([^/]+)$};
my $digest = $prop->{digest}{$file} || $prop->{digest}{'*'};
is(ref $digest, 'ARRAY', 'a digest is declared for the pinned tarball');
is($digest && $digest->[0], 'SHA256', 'digest algorithm is SHA256');
like($digest && $digest->[1], qr/^[0-9a-f]{64}$/, 'digest is a 64 hex char SHA256');

done_testing;
