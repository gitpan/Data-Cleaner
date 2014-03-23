package Data::Cleaner::Utf8;

use strict;
use warnings;

use Encode qw(decode encode is_utf8);

our $VERSION = 0.0.1;
our $DEFAULT = '';

sub _validate {
    my $decoded = decode($_[0]->get_encoding, $_[1]);
    is_utf8($decoded) && ($decoded eq $_[1]) ? return $decoded : return undef;
}

sub _fix {
    my $encoded = encode('UTF-8', $_[1]);
    return $encoded;
}

sub _format {
    my $encoded = encode('UTF-8', $_[1]);
    return $encoded;
}

1;

__END__

=head1 NAME

Data::Cleaner::Utf8

=head1 DESCRIPTION

Validates the encoding of input strings as utf8 (B<validate>), and
encodes to UTF-8 (B<fix> and B<format>).

=head1 DEFAULT VALUE (CONSTRUCTOR)

'' (empty string)

=head1 FUNCTIONS

B<validate>, B<fix>, B<format>

Refer to main Data::Cleaner documentation

=head1 AUTHOR

Jason Turner <jason.turner@gridx.eu>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Jason Turner. All rights
reserved. This program is free software; you can redistribute it
and/or modify it under the same terms as Perl itself.

=cut
