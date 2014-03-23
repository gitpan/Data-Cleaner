package Data::Cleaner::Enum;

use strict;
use warnings;

our $VERSION = 0.0.1;
our $DEFAULT = '';

sub _validate {

    my ($self, $value) = @_;

    foreach my $opt (@{$self->get_enum_options}) {
        return $opt if ($opt eq $value);
    }
    
    return undef;
    
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

Data::Cleaner::Enum

=head1 DESCRIPTION

Checks that a value is present on a list. The list
is managed using the b<get_enum_options> and
b<set_enum_options> functions.

The B<fix> function returns the current default.

The B<format> function returns the input unchanged.

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
