package Data::Cleaner::Oct;

use strict;
use warnings;

use Data::Validate qw(is_oct);

our $VERSION = 0.0.1;
our $DEFAULT = 0;

sub _validate {
    defined(is_oct($_[1])) ? return $_[1] : return undef;
}

sub _fix {
    return $_[0]->get_default;
}

sub _format {
    return $_[1];
}

1;

__END__

=head1 NAME

Data::Cleaner::Oct

=head1 DESCRIPTION

Provides validation, correction (where possible) and formatting of
octal numbers.

The B<fix> function returns the current default.

The B<format> function returns the input unchanged.

=head1 DEFAULT VALUE (CONSTRUCTOR)

0

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
