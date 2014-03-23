package Data::Cleaner::Notype;

use strict;
use warnings;

our $VERSION = 0.0.1;
our $DEFAULT = '';

sub _validate {
    return $_[1];
}

sub _fix {
    return $_[1];
}

sub _format {
    return $_[1];
}

1;

__END__

=head1 NAME

Data::Cleaner::Notype

=head1 DESCRIPTION

This is a starter datatype for use when constructing a datatype
from scratch.

Input values are output unchanged - no validation or processing is
done. The intention is that this is a starting point, where tests
can be added to provide validation, and the fix and/or format
functions can be replaced.

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
