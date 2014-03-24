package Data::Cleaner;

use 5.010000;
use strict;
use warnings;
use Time::Local;

use constant ENCODING         => 'UTF-8';
use constant DATE_FORMAT      => '%d-%m-%Y';
use constant TIME_FORMAT      => '%X %z';
use constant DATE_TIME_FORMAT => DATE_FORMAT.' '.TIME_FORMAT;

our $VERSION = 0.0.2;

#
# Main methods
#

sub new {

    my ($class, %options) = @_;
    my $self = {};
    %{$self} = %options;

    my $typemodule = ucfirst(lc($self->{'type'}));
    my $namespace  = 'Data::Cleaner::'.$typemodule;
    my $usemodule  = 'Data/Cleaner/'.$typemodule.'.pm';
    require $usemodule;

    $self->{'encoding'}       = ENCODING         unless (defined $self->{'encoding'});
    $self->{'dateFormat'}     = DATE_FORMAT      unless (defined $self->{'dateFormat'});
    $self->{'timeFormat'}     = TIME_FORMAT      unless (defined $self->{'timeFormat'});
    $self->{'dateTimeFormat'} = DATE_TIME_FORMAT unless (defined $self->{'dateTimeFormat'});
    $self->{'enumOptions'}    = []               unless (defined $self->{'enumOptions'});
    unless (defined $self->{'tz'}) {
        $self->{'tz'} = sprintf '%+05d', (100 * ((timegm(localtime) - timelocal(localtime)) / (3600)));
    }

    #
    # Each of the three main methods (validate, format and fix), is a
    # reference to a subroutine in a datatype submodule. Each datatype
    # module is a black box - they all have the same inputs and outputs.
    #
    # Submodules also have their own defaults which get loaded by the
    # constructor (defaults can be overwritten using set_default). 
    #

    eval('push @{$self->{\'_validate\'}}, \\\&'.$namespace.'::_validate');
    eval('$self->{\'_fix\'} = \\\&'.$namespace.'::_fix');
    eval('$self->{\'_format\'} = \\\&'.$namespace.'::_format');
    unless (defined $self->{'default'}) {
        eval('$self->{\'default\'} = $'.$namespace.'::DEFAULT');
    }
    $self->{'_ns'} = $namespace;

    bless $self, $class;
    return $self;

}

sub load {

    #
    # Loads an item of data into the object as 'raw' data without
    # attempting validation. Useful if only fix and/or format will
    # be used.
    #
    
    my ($self, $value) = @_;
    $self->{'_raw'} = $value;
    
}

sub validate {

    #
    # A proxy for Data::Cleaner::<Datatype>::_validate
    # Updates the '_pass', '_raw' and '_processTime' properties
    #
    # The '_validate' property is an array of subroutine references
    # allowing the addition of further tests (with order preserved).
    #
    
    my ($self, $value) = @_;
    return undef unless (defined $value || defined $self->{'_raw'});    

    my $start = time;
    
    $self->{'_raw'}  = $value if (defined $value);
    $self->{'_pass'} = undef;
    $self->{'_processTime'} = undef;

    foreach my $test (@{$self->{'_validate'}}) {

        my $out = ${$test}->($self, $self->{'_raw'});
        
        if (defined $out) {
            $self->{'_pass'} = 1;
            $self->{'_raw'}  = $out;
        } else {
            $self->{'_pass'} = 0;
            $self->{'_raw'}  = $value || $self->{'_raw'};
            last;
        }
        
    }

    $self->{'_processTime'} = time - $start;
    return $self->{'_pass'};

}

sub reset {

    #
    # Definitive method of flushing previous data from the
    # object before reuse (not usually required, since the validate
    # function does the same thing whenever data is loaded as an
    # argument)
    #
    
    my $self = $_[0];
    $self->{'_raw'}         = undef;
    $self->{'_pass'}        = undef;
    $self->{'_processTime'} = undef;

}

sub format {

    #
    # A proxy for Data::Cleaner::<Datatype>::_format
    # Updates the '_raw' and '_processTime' properties
    #
    
    my $self = $_[0];
    my $start = time;
    $self->{'_raw'} = ${$self->{'_format'}}->($self, $self->{'_raw'});
    $self->{'_processTime'} = time - $start;
    return $self->{'_raw'};

}

sub fix {

    #
    # A proxy for Data::Cleaner::<Datatype>::_fix
    # Updates the '_raw' and '_processTime' properties
    #
    
    my $self = $_[0];
    my $start = time;
    $self->{'_raw'} = ${$self->{'_fix'}}->($self, $self->{'_raw'});
    $self->{'_processTime'} = time - $start;
    
}

sub add_test {

    #
    # Appends a test subroutine reference to $self->{'_validate'}
    #

    if (ref($_[1]) && ref($_[1]) eq 'REF') {
        push @{$_[0]->{'_validate'}}, $_[1];
    }

}

sub set_format {

    #
    # Replaces the default format subroutine reference in
    # $self->{'_format'}
    #
    
    if (ref($_[1]) && ref($_[1]) eq 'REF') {
        $_[0]->{'_format'} = $_[1];
    }
    
}

sub set_fix {

    #
    # Replaces the default fix subroutine reference in
    # $self->{'_fix'}
    #
    
    if (ref($_[1]) && ref($_[1]) eq 'REF') {
        $_[0]->{'_fix'} = $_[1];
    }
    
}

#
# Helper methods - get property value
#

sub is_valid {

    #
    # Reports whether or not the input data passed [all stages of] validation
    #
    
    return $_[0]->{'_pass'};
    
}

sub get_raw {

    #
    # Returns the data item in raw (pre-processed) form
    #
    
    return $_[0]->{'_raw'};
    
}

sub get_default {

    #
    # Returns the default value for the type
    #
    
    return $_[0]->{'default'};
    
}

sub get_type {

    #
    # Returns the type setting for the object
    #
    
    return $_[0]->{'type'};

}

sub get_encoding {

    #
    # Returns the encoding the module expects all input data to be encoded in
    #
    
    return $_[0]->{'encoding'};
    
}

sub get_timezone {

    #
    # Returns the timezone +/-nnnn
    # By default this is calculated by the constructor as the difference
    # between GMT (UTC) and localtime. Can be overridden
    #
    
    return $_[0]->{'tz'};
    
}

sub get_datetime_format {

    #
    # Returns the datetime formatting (uses time2str convention)
    #
    
    return $_[0]->{'dateTimeFormat'};
    
}

sub get_date_format {

    #
    # Returns the date formatting (uses time2str convention)
    #
    
    return $_[0]->{'dateFormat'};
    
}

sub get_time_format {

    #
    # Returns the time format (uses time2str convention)
    #
    
    return $_[0]->{'timeFormat'};
    
}

sub get_enum_options {

    #
    # Returns the defined enum options in an array
    #
    
    return $_[0]->{'enumOptions'};
    
}

#
# Helper methods - set property value
#

sub set_default {

    #
    # Sets a new default value for the type
    #
    
    $_[0]->{'default'} = $_[1];
    
}

sub set_encoding {

    #
    # Sets the encoding to be used for processing all text input
    #
    
    $_[0]->{'encoding'} = $_[1];
    
}

sub set_timezone {

    #
    # Sets a timezone to override the default for formatting of date and time values
    # Can be +/-nnnn or a 3-letter code
    #
    
    $_[0]->{'tz'} = $_[1];
    
}

sub set_datetime_format {

    #
    # Set datetime formatting (uses time2str convention)
    #
    
    $_[0]->{'dateTimeFormat'} = $_[1];
    
}

sub set_date_format {

    #
    # Set date formatting (uses time2str convention)
    #
    
    $_[0]->{'dateFormat'} = $_[1];
    
}

sub set_time_format {

    #
    # Set time formatting (uses time2str convention)
    #
    
    $_[0]->{'timeFormat'} = $_[1];
    
}

sub set_enum_options {

    #
    # Sets the defined enum options
    #
    
    $_[0]->{'enumOptions'} = $_[1];
    
}

1;

__END__

=head1 NAME

Data::Cleaner - allows rule-based cleaning of datasets

=head1 SYNOPSIS

    use Data::Cleaner;

    my $cleaner = Data::Cleaner->new(type => 'datatype');
    
    my $dubious = 'Some input data';
    
    unless ($cleaner->validate($dubious)) {
    
       $cleaner->fix;
        
    }
    
    my $fragrant = $cleaner->format;

=head1 DESCRIPTION

Data::Cleaner is a lightweight, fast framework for writing dataset
cleaners. It has less features than some modules which perform
similar functions, but it's fast, which makes it more suitable for
large datasets. It's also simple, making it easier to get results
quickly.

The Data::Cleaner itself is pure Perl, and so are the datatype
submodules bundled with it, but some of the other available datatype
modules may not be.

=head1 USAGE SUMMARY

An object is created for each column heading (or other class of data.
Dataset rows can then be processed by validating each data item
using the appropriate cleaner object.

The datatype is the only property required at creation, although
others can be specified at the same time, rather than individually
using set functions:

    my @enum_options = qw(red orange yellow green blue brown black);
   
    my $cleaner = Data::Cleaner->new(
                        type        => 'enum',
                        default     => 'purple'
                        enumOptions => \@enum_options);

    # is the same as:

    my $cleaner = Data::Cleaner->new(type => 'enum');

    my @enum_options = qw(red orange yellow green blue brown black);

    $cleaner->set_default('purple');

    $cleaner->set_enum_options(\@enum_options);

Data::Cleaner objects are differentiated by the datatype they
validate. But each supported datatype provides the same three
principal functions:

=over 4

=item B<validate>

Checks the compliance of the data element with the requirements of
the datatype. In general (with some exceptions), the focus of this
function is format and structure rather than content. So for example,
barcode tests validate the length and character types, but do not
test checksums.

=item B<fix>

Depending on the nature of the datatype, will either:

1. attempt to fix the data element so that it complies with the
requirements of the datatype, or

2. return the default for that datatype (defaults can be modified
using the B<set_default> function).

=item B<format>

Applies standardised formatting to the supplied data element.

=back

The data content is passed between stages internally as 'raw' data,
which can be retrieved at any time using the B<get_raw> function.

Raw data will likely be different from the original, since the
output of any pre-processing performed by the validation process
will be written to raw data after validation. This is done to
reduce processing time by avoiding process duplication across the
three core functions (validate-fix-format).

One or more custom validation tests can be loaded to supplement the
standard one provided by a datatype submodule. It is also possible
to replace the standard B<fix> and B<format> functions. In the case
of B<validate>, multiple validation tests can be loaded, which are
appended to a list of tests of which the default is the first and
remains the first. There is no replacement. In contrast, by loading
a new B<fix> or B<format> function, the current one is replaced.
There can only be one B<fix> or B<format> function, so every time
one is loaded it replaces the existing one.

For cases where it is necessary to create a completely fresh
validation scheme, the 'notype' datatype can be used. This provides
B<validate>, B<fix> and B<format> functions which simply return the
input values unaltered, allowing the actual validation function(s)
to be implemented without the processing overhead of unwanted
defaults or unnecessary duplication.

The validation stage can also be bypassed altogether. In order to use
Data::Cleaner only to apply formatting (or to attempt to fix an item
of data), the data item can be loaded directly as raw data:

    $cleaner->load('Some input data');

Careful how you use this though - since they're really designed to
process the output of the validate method (and also to keep process
times down), fix and format don't validate their inputs. In some
cases they also expect the pre-formatted output of B<validate>.

=head1 DATATYPES

Datatypes are supported by submodules. Some basic datatype submodules
come bundled with Data::Cleaner. More are available, most but not all
are pure Perl. Add to your environment as required.

New datatypes are added from time to time. Contact me with requests
if you can't find what you need and I'll see what I can do. You can
also write datatype submodules yourself (see Writing Datatype Modules
below). If you do, don't forget to upload to CPAN (share and enjoy ...)

The names of submodules directly relate to the datatype names to be
used in the Data::Cleaner constructor - the datatype name is an all
lower-case version of the submodule name. There is no need to 'use'
these submodules in your code - functions from the correct namespace
will be imported automatically by Data::Cleaner at object creation
time.

The current complete list of datatypes is:

=head3 Basic datatypes (installed together with Data::Cleaner):

int, posint, negint, float, boolean, oct, hex, utf8, enum, notype

=head3 Dates and times (installed together with Data::Cleaner):

datetime, date, time, timeticks

=head3 Networking and Communications:

ipv4, ipv6, macaddr, hostname, msisdn, uri

=head3 Computing:

email, hashtag, twitterid

=head3 Scientific:

dna, prime

=head3 Geopositioning:

longitude, latitude

=head3 Financial:

currency, iban

=head3 Barcodes:

code11, code39, code39ext, code93, code128, codabar, ean8, ean13,
itf14, upca, upce, isbn, issn

=head1 FUNCTIONS

=head2 new

Creates a new object. The only argument required is the datatype. For
example:

    my $cleaner = Data::Cleaner->new(type => 'boolean');

=head2 reset

Reliably resets the object for reuse. In particular, raw data and
last test result are set to undef.

    $cleaner->reset;

This function is performed every time the B<validate> function
processes data passed as an argument (rather than internal raw data),
so in normal usage this function will not be necessary.

=head2 load

Allows the loading of data as raw data bypassing the validate
function. Use caution with this - the fix and format functions don't
validate their inputs (that's what validate is for).

    $cleaner->load('Yet more data');

=head2 validate

Checks the compliance of the data element with the requirements of
the datatype (defined in the submodule).

    my $result = $cleaner->validate('is this a hostname?');

Returns 1 for pass; 0 for fail. The data is saved internally as raw
data, ie. in its current state (after any preprocessing which might
form part of the validation). This prevents wasted time through
duplication of operations at the fix or format stage. Not all
datatype submodules apply processing in the course of validation.
If the original data is left intact then that is how it will be
saved internally.

The internal 'raw' data can be retrieved using B<get_raw>:

    my $preprocessed = $cleaner->get_raw;

If validate is called without arguments, the validation will be
applied to the 'raw' internal data will be used (if defined), which
will then be overwritten by the result of the validation. If the
raw data is undefined, undef will be returned.

=head2 format

Applies formatting to the object's internal 'raw' copy of the data
and returns the result.

    $result = $cleaner->format;

The formatting used depends on the datatype - in many cases the
format method leaves the value unaltered. See the submodule
documentation for more information.

=head2 fix

Attempts to fix the internal 'raw' copy of the data after failed
validation.

    $cleaner->fix;

How successful this turns out to be depends on the data itself, the
datatype (ie the datatype submodule), and the reason the validation
failed in the first place. With many datatypes there is no scope for
fixing a non-compliant value. Where this is the case, the raw value
will be left unaltered.

=head2 is_valid

Returns the result of the last validation: 1 for pass, 0 for fail.

    $result = $cleaner->is_valid;

=head2 add_test

By default, the datatype validate function only tests the input data
in terms of the basic requirements of the datatype (such as format
and structure). More targeted tests can be added to improve the
integrity of the data further. Tests are run against the data in the
order they are added, with the output from one being passed as input
to the next.

For example, the posint datatype submodule will validate an input in
terms of a) whether it is an integer or not, and b)whether it is
positive or not. In order to validate it in terms of range - in this
case it should be between 0 and 1000, a custom test must be added:

    my $new_test = sub {

        $_[1] <= 1000 ? return $_[1] : return undef;

    }
   
    $cleaner->add_test(\$new_test);

Full details of the inputs and outputs of the B<add_test> function
(and also the B<set_format> and B<set_fix> functions), and given in
the Writing Datatype Modules section below.

=head2 set_format

The B<format> function provided by the datatype submodule can be
overwritten if required. For example, the default formatting action
in many cases is to make the output more readable. In the case of
some of the more general datatypes (for example int), it might be
necessary to format the output to a specific number of decimal
places. In this case, a subroutine reference can be loaded which
follows the input/output standards of a submodule B<format> function
(see Writing Datatype Submodules, below).

To specify that the formatted output should be accurate to three
decimal places, the following commands can be used:

    my $new_format_function = sub {

        return sprintf '%.3f', $_[1];

    }

    $cleaner->set_format(\$new_format_function);

=head2 set_fix

The B<fix> function provided by the datatype submodule can be
overwritten if required. For example, the default action is many
cases is to return either zero, an empty string, or some kind of
default. Perhaps, in place of '00.0' (the standard default for
the currency datatype), the string '------.--' is required. This
can be achieved using the following commands:

    my $new_fix_function = sub {

        return '------.--';

    }
   
    $cleaner->set_fix(\$new_fix_function);

As with B<add_test> and B<set_format>, the subroutine should
follow the requirements in Writing Datatype Submodules section
below.

=head2 get_raw

Returns the raw data stored internally for fixing (in the case of
non-compliant data) or formatting.

    my $data = $cleaner->get_raw;
   
Typically the raw data is first stored as a result of a
validation (irrespective of the result). The fix method operates
only on internal raw data, overwriting any existing raw data with
its output. The format method uses the raw data as its input.

=head2 get_type

Returns the datatype specified when the Data::Cleaner object was
created.

    my $datatype = $cleaner->get_type;

=head2 get_default

Returns the default value for the datatype (often used by the
B<fix> function).

    my $default = $cleaner->get_default;

=head2 get_encoding

Gets the current encoding used to process text strings in the utf8
datatype submodule.

    my $encoding = $cleaner->get_encoding;

=head2 get_timezone

Returns the timezone setting, used for formatting dates and times.

    my $timezone = $cleaner->get_timezone;

A default timezone is added when the object is created. It is
calculated from the time - localtime difference and stored in
+/-hhmm format. Abbreviated timezone representations such as CET
can also be used.

=head2 get_datetime_format

The datetime submodule uses Date::Format, which uses '%' +
character combinations to define the format of datetimes as text.

    my $time_format = $cleaner->get_datetime_format;

The get_datetime_format method returns the '%' + character
combination which Data::Cleaner will pass to Date::Format.

=head2 get_date_format

Same as get_datetime_format but just for dates.

=head2 get_time_format

Same as get_datetime_format but just for times.

=head2 get_enum_options ['enum' datatype only]

The 'enum' datatype tests the input data against a fixed set of
options. This method returns an array of options used to test
the input data. By default this array is empty.

=head2 set_default

Overwrites the datatype default added when the object was
created.

    $cleaner->set_default('Something new');

=head2 set_encoding

Sets the encoding used to process text strings in the utf8
datatype submodule. Should be set to a Encode-compatible
value.

    $cleaner->set_encoding('iso-8859-1');

=head2 set_timezone

The default timezone can be overwritten using

    $cleaner->set_timezone('value');

The format can be +/-hhmm or a timezone abbreviation such as
CET.

=head2 set_datetime_format

The datetime submodule uses Date::Format, which uses '%' +
character combinations to define the format of datetimes as
text.

    $cleaner->set_datetime_format('%d-%m-%Y %X %z');

The set_datetime_format method updates the '%' + character
combination which Data::Cleaner will pass to Date::Format.

=head2 set_date_format

Same as set_datetime_format but just for dates.

=head2 set_time_format

Same as set_datetime_format but just for times.

=head2 set_enum_options ['enum' datatype only]

The 'enum' datatype tests the input data against a fixed set
of options. For example, to check that a field contains only
the text 'black', 'white', 'red' or 'green', the following
code should be added either as part of the constructor
(example 1) or following instance creation:

=head3 Example 1:

    my @enum_options = qw(black white red green);

    my $cleaner = Data::Cleaner->new(
                            type        => 'enum',
                            enumOptions => \@enum_options);

=head3 Example 2:

    my @enum_options = qw(black white red green);
    $cleaner->set_enum_options(\@enum_options);

The enum test will fail if these options have not been set,
since no defaults are configured at object creation.

=head1 WRITING DATATYPE SUBMODULES

Datatype submodules are simple, small and unremarkable in
terms of what they do. They are like black boxes, in the
sense that they all share the same inputs, outputs and
functions. These are:

=head2 Inputs:

An array of two values:

=over 12

=item $_[0]

The object instance, conventionally referred to as $self.
Often not used in practice, but required if it becomes
necessary to retrieve instance property values. For example:

    my $default = $_[0]->get_default

=item $_[1]

The value being passed to the function

=back

A neater way to do this might be:

    my ($self, $input) = @_;

=head2 Outputs:

There is only ever one scalar output, depending on the
function. End with:

    return $output;

=head2 Functions:

=over 12

=item validate

The validate function (actually named '_validate' in the
submodule itself), takes the input value and applies
whatever rules are necessary to confirm or reject it.

If the input data passes validation, the function returns
the input value following any modification which took place
as part of the validation process. This becomes useful if it
reduces the amount of processing necessary at the format
stage, but remember to take the pre-processing into account
in writing the B<format> function.

If the input data fails validation the function should
return 'undef'

Note that this differs from the behaviour of Data::Cleaner
from a user perspective - user code expects validate=1;
fail=0. This is because Data::Cleaner is inbetween the type
submodule and user code. It writes the output from the
submodule into 'raw' data and then returns 1 or 0 depending
on whether the submodule output exists or is 'undef'.

=item format

The format function (actually named '_format' in the
submodule itself), takes the input value and applies
formatting according to the nature of the datatype.

It returns the formatted version of the input.

=item fix

The fix function (actually named '_fix' in the submodule
itself), takes the input value and attempts to make it
pass validation. In many cases fixing a value will be
impossible, so the only option is to return the default or
the value itself unaltered.

=back

=head2 Example:

The example below shows the submodule for the 'oct' datatype:

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

=head1 AUTHOR

Jason Turner <jason.turner@gridx.eu>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Jason Turner. All rights
reserved. This program is free software; you can redistribute it
and/or modify it under the same terms as Perl itself.

=cut
