package Alien::TinyCDB;
# ABSTRACT: Alien package for the TinyCDB library
our $VERSION = '0.002';
use strict;
use warnings;
use parent 'Alien::Base';

=synopsis

    use Alien::TinyCDB;
    use ExtUtils::MakeMaker;

    WriteMakefile(
        ...
        LIBS   => Alien::TinyCDB->libs,
        INC    => Alien::TinyCDB->cflags,
        ...
    );

Or with L<FFI::Platypus>:

    use FFI::Platypus;
    use Alien::TinyCDB;

    my $ffi = FFI::Platypus->new( api => 1 );
    $ffi->lib(Alien::TinyCDB->dynamic_libs);

=description

This module provides the TinyCDB library. TinyCDB is a small, fast and reliable
utility and subroutine library for creating and reading constant databases.
The database structure is tuned for fast reading.

TinyCDB is a public-domain implementation of Dan Bernstein's constant database
(cdb) library. It creates and reads constant key-value databases with size up
to 4GB. CDB files are immutable once created, making them ideal for fast
lookups of data that doesn't change frequently.

This distribution uses L<Alien::Base> to either detect a system-installed
TinyCDB library or build and install it from source.

=head1 METHODS

This module inherits all methods from L<Alien::Base>. The most commonly used are:

=head2 cflags

    my $cflags = Alien::TinyCDB->cflags;

Returns the C compiler flags needed to compile against TinyCDB.

=head2 libs

    my $libs = Alien::TinyCDB->libs;

Returns the linker flags needed to link against TinyCDB.

=head2 dynamic_libs

    my @libs = Alien::TinyCDB->dynamic_libs;

Returns a list of dynamic library paths that can be used with L<FFI::Platypus>.

=seealso

=over 4

=item * L<Alien::Base> - Base class providing the build and usage framework

=item * L<http://www.corpit.ru/mjt/tinycdb.html> - TinyCDB homepage

=item * L<CDB_File> - Pure Perl interface to cdb files (doesn't require TinyCDB)

=back

=cut

1;
