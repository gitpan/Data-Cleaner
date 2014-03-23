package Data::Cleaner::Boolean;

use strict;
use warnings;

our $VERSION = 0.0.1;
our $DEFAULT = 'false';

sub _validate {
    $_[1] =~ /^true$/i || $_[1] =~ /^false$/i ? return $_[1] : return undef;
}

sub _fix {

    if ($_[1] =~ /^yes$/i) {
        return 'true';
    } elsif ($_[1] =~ /^no$/i) {
        return 'false';
    } else {
        return 'false';
    }

}

sub _format {
    return lc($_[1]);
}

1;

__END__

=head1 NAME

Data::Cleaner::Boolean

=head1 DESCRIPTION

Provides validation, correction (where possible) and formatting of
boolean data values.

All formatted values are lower-case.

=head1 DEFAULT VALUE (CONSTRUCTOR)

'false'

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
