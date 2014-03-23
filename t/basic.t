##################################################################################################
#
# Tests Data::Cleaner basic functions
#

use strict;

use Test::More tests => 8;
use Data::Cleaner;

##################################################################################################
#
# Test 1. Create instance 
#

my $cleaner = undef;
my $type    = 'enum';

eval {
    $cleaner = Data::Cleaner->new(type => $type);
};

ok(
    (defined($cleaner) && $cleaner->get_type eq $type),
    'Create Data::Cleaner instance'
);

##################################################################################################
#
# Test 2. Set default
#

my $old_default = undef;
my $new_default = undef;
my $set_default = 'Enum Test Default';

eval {
    $old_default = $cleaner->get_default;
    $cleaner->set_default($set_default);
    $new_default = $cleaner->get_default;
};

ok(
    ($old_default eq '' && $new_default eq $set_default),
    'Get/set instance default'
);

##################################################################################################
#
# Test 3. Get enum options
#

my @enumOptions = undef;

eval {
    @enumOptions = $cleaner->get_enum_options;
};

ok(
    ($#enumOptions == 0),
    'Get enum options'
);

##################################################################################################
#
# Test 4. Set enum options
#

my $new_enum_options = undef;
my @set_enum_options = qw(
    red
    orange
    yellow
    green
);

eval {
    $cleaner->set_enum_options(\@set_enum_options);
    $new_enum_options = $cleaner->get_enum_options;
};

ok(
    ($#{$new_enum_options} == $#set_enum_options),
    'Set enum options'
);

##################################################################################################
#
# Test 5. Validate test data
#

my $test_data_fail = 'purple';
my $test_data_pass = 'yellow';
my $raw_data       = undef;
my $result_fail    = undef;
my $result_pass    = undef;

eval {
    $result_fail = $cleaner->validate($test_data_fail);
    $result_pass = $cleaner->validate($test_data_pass);
    $raw_data    = $cleaner->get_raw;
};

ok((
    $result_fail == 0 && $result_pass == 1 && $raw_data eq $test_data_pass),
    'Validate test input'
);

##################################################################################################
#
# Test 6. Add validation test
#

my $test_data_pass2 = 'red';
my $result_pass2    = undef;
my $user_test = sub { length($_[1]) == 3 ? return $_[1] : return undef };
$result_fail = undef;
$result_pass = undef;
$raw_data    = undef;

eval {
    $cleaner->add_test(\$user_test);
    $result_fail  = $cleaner->validate($test_data_fail);
    $result_pass  = $cleaner->validate($test_data_pass);
    $result_pass2 = $cleaner->validate($test_data_pass2);
    $raw_data     = $cleaner->get_raw;
};

ok(
    ($result_fail == 0 && $result_pass == 0 && $result_pass2 == 1 && $raw_data eq $test_data_pass2),
    'Validate test input with user-added validation test'
);

##################################################################################################
#
# Test 7. Replace format function
#

my $user_format = sub { return uc($_[1]) };
$result_pass    = undef;

eval {
    $cleaner->set_format(\$user_format);
    $result_pass = $cleaner->format;
};

ok(
    ($result_pass eq uc($test_data_pass2)),
    'Load and test user format function'
);

##################################################################################################
#
# Test 8. Replace fix function
#

my $user_fix = sub { return 'Shame, it failed' };
$result_pass = undef;

eval {
    $cleaner->set_fix(\$user_fix);
    $cleaner->fix;
    $result_pass = $cleaner->format;
};

ok(
    ($result_pass eq 'SHAME, IT FAILED'),
    'Load and test user fix function'
);
