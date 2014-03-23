package Data::Cleaner::Hex;

use strict;
use warnings;

use Data::Validate qw(is_hex);

our $VERSION = 0.0.1;
our $DEFAULT = '00';

sub _validate {
    my $hex = $_[1];
    $hex =~ s/^0x//i;
    is_hex($hex) ? return $hex : return undef;
}

sub _fix {
    return $_[0]->get_default;
}

sub _format {
    return uc($_[1]);
}

1;

__END__

=head1 NAME

Data::Cleaner::Hex

=head1 DESCRIPTION

Provides validation of hexadecimal numbers.

The B<fix> function returns the current default.

The B<format> function returns the input with A-Z in uppercase.

=head1 DEFAULT VALUE (CONSTRUCTOR)

'00'

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

