package Data::Cleaner::Timeticks;

use strict;
use warnings;

use Data::Types qw(is_float);
use Time::Interval qw(parseInterval);

our $VERSION = 0.0.2;
our $DEFAULT = 0;

sub _validate {
    is_float($_[1]) ? return ($_[1] / 100) : return undef;
}

sub _fix {
    return $_[0]->get_default;
}

sub _format {
    $_[1] =~ /\.(\d{1,3})/;
    my $m = $1 || '0';
    my $iraw = parseInterval(seconds => int($_[1]));
    return sprintf '%dd %02d:%02d:%06.3f',
            ($iraw->{'days'}, $iraw->{'hours'}, $iraw->{'minutes'}, $iraw->{'seconds'}.'.'.$m);
}

1;

__END__

=head1 NAME

Data::Cleaner::Timeticks

=head1 DESCRIPTION

Provides validation, correction and formatting of timetick
(milliseconds) values.

The B<fix> function returns the current default.

The B<format> function formats the timeticks value as:

=over 12

    0d 00:00:00.000

=back

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
