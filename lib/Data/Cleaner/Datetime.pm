package Data::Cleaner::Datetime;

use strict;
use warnings;

use Date::Parse qw(str2time);
use Date::Format qw(time2str);

our $VERSION = 0.0.1;
our $DEFAULT = '';

sub _validate {
    my $seconds = str2time($_[1]);
    $seconds ? return $seconds : return undef;
}

sub _fix {
    return $_[0]->get_default;
}

sub _format {
    return time2str($_[0]->get_datetime_format(), $_[1], $_[0]->get_timezone());
}

1;

__END__

=head1 NAME

Data::Cleaner::Datetime

=head1 DESCRIPTION

Provides validation and formatting of date/time data expressed
in a recognised format (specifically, one recognised by the
Date::Parse module).

The B<validate> function converts datetimes into epoch time,
which is then stored internally as 'raw' data.

The formatted datetime can be accessed using the B<format>
function. The output format is stored as a property of the
Data::Cleaner instance and is passed to Date::Format along with
the configured timezone and the epoch value itself.

The output format can be read/set using the B<get_datetime_format>
and B<set_datetime_format> functions.

The configured timezone can be read/set using the B<get_timezone>
and B<set_timezone> functions.

The B<fix> function returns the configured default.

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
