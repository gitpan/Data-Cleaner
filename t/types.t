##################################################################################################
#
# Tests Data::Cleaner bundled datatype submodule functions
#

use strict;

use Test::More tests => 11;
use Data::Cleaner;

##################################################################################################
#
# Test 1. Int
#

my $datatype = 'int';
my $cleaner  = undef;
my $testcase_pass = 7483294;
my $testdata_pass = undef;
my $testcase_fail = 64372.43278;
my $testdata_fail = undef;
my $testcase_fix  = undef;
my $testdata_fix  = undef;

eval {
    $cleaner = Data::Cleaner->new(type => $datatype);
    $cleaner->validate($testcase_pass);
    if ($cleaner->is_valid) {
        $testdata_pass = $cleaner->get_raw;
    }
    $cleaner->validate($testcase_fail);
    if (! $cleaner->is_valid) {
        $cleaner->fix;
        $testdata_fail = $cleaner->format;
    }
};

ok(
    ($testdata_pass == $testcase_pass && $testdata_fail == int($testcase_fail)),
    'Validate/reject datatype '.$datatype
);

##################################################################################################
#
# Test 2. Posint
#

$datatype = 'posint';
$cleaner  = undef;
$testcase_pass = 7483294;
$testdata_pass = undef;
$testcase_fail = -64372.43278;
$testdata_fail = undef;

eval {
    $cleaner = Data::Cleaner->new(type => $datatype);
    $cleaner->validate($testcase_pass);
    if ($cleaner->is_valid) {
        $testdata_pass = $cleaner->get_raw;
    }
    $cleaner->validate($testcase_fail);
    if (! $cleaner->is_valid) {
        $cleaner->fix;
        $testdata_fail = $cleaner->format;
    }
};

ok(
    ($testdata_pass == $testcase_pass && $testdata_fail == int($testcase_fail * -1)),
    'Validate/reject datatype '.$datatype
);

##################################################################################################
#
# Test 3. Negint
#

$datatype = 'negint';
$cleaner  = undef;
$testcase_pass = -7483294;
$testdata_pass = undef;
$testcase_fail = 64372.43278;
$testdata_fail = undef;

eval {
    $cleaner = Data::Cleaner->new(type => $datatype);
    $cleaner->validate($testcase_pass);
    if ($cleaner->is_valid) {
        $testdata_pass = $cleaner->get_raw;
    }
    $cleaner->validate($testcase_fail);
    if (! $cleaner->is_valid) {
        $cleaner->fix;
        $testdata_fail = $cleaner->format;
    }
};

ok(
    ($testdata_pass == $testcase_pass && $testdata_fail == int($testcase_fail * -1)),
    'Validate/reject datatype '.$datatype
);

##################################################################################################
#
# Test 4. Float
#

$datatype = 'float';
$cleaner  = undef;
$testcase_pass = 64372.43278;
$testdata_pass = undef;
$testcase_fail = '47382bf';
$testdata_fail = undef;

eval {
    $cleaner = Data::Cleaner->new(type => $datatype);
    $cleaner->validate($testcase_pass);
    if ($cleaner->is_valid) {
        $testdata_pass = $cleaner->get_raw;
    }
    $cleaner->validate($testcase_fail);
    if (! $cleaner->is_valid) {
        $cleaner->fix;
        $testdata_fail = $cleaner->format;
    }
};

ok(
    ($testdata_pass == $testcase_pass && $testdata_fail == 0),
    'Validate/reject datatype '.$datatype
);

##################################################################################################
#
# Test 5. UTF-8
#

$datatype = 'utf8';
$cleaner  = undef;
$testcase_pass = '1234ABCD';
$testdata_pass = undef;
$testcase_fail = ';3wlv53,w90im)@%&∂©§∞§ß¶†•†¥©ß∆';
$testdata_fail = undef;
#$testcase_fix  = 'YES';
#$testdata_fix  = undef;

eval {
    $cleaner = Data::Cleaner->new(type => $datatype);
    $cleaner->validate($testcase_pass);
    if ($cleaner->is_valid) {
        $testdata_pass = $cleaner->get_raw;
    }
    $cleaner->validate($testcase_fail);
    if (! $cleaner->is_valid) {
        $cleaner->fix;
        $testdata_fail = $cleaner->get_raw;
    }
};

ok(
     ($testdata_pass eq $testcase_pass && $testdata_fail ne ''),
    'Validate/reject datatype '.$datatype
);

##################################################################################################
#
# Test 6. Boolean
#

$datatype = 'boolean';
$cleaner  = undef;
$testcase_pass = 'faLSe';
$testdata_pass = undef;
$testcase_fail = 'S(*SD3N|KShs=';
$testdata_fail = undef;
$testcase_fix  = 'YES';
$testdata_fix  = undef;

eval {
    $cleaner = Data::Cleaner->new(type => $datatype);
    $cleaner->validate($testcase_pass);
    if ($cleaner->is_valid) {
        $testdata_pass = $cleaner->get_raw;
    }
    $cleaner->validate($testcase_fail);
    if (! $cleaner->is_valid) {
        $cleaner->fix;
        $testdata_fail = $cleaner->format;
    }
    $cleaner->validate($testcase_fix);
    if (! $cleaner->is_valid) {
        $cleaner->fix;
        $testdata_fix = $cleaner->format;
    }
};

ok(
    ($testdata_pass eq $testcase_pass && $testdata_fail eq 'false' && $testdata_fix eq 'true'),
    'Validate/reject datatype '.$datatype
);

##################################################################################################
#
# Test 7. Enum
#

$datatype = 'enum';
$cleaner  = undef;
$testcase_pass = 'green';
$testdata_pass = undef;
$testcase_fail = 'indigo';
$testdata_fail = undef;

my $default  = 'taupe with mustard spots';
my @enumopts = qw(
    red
    yellow
    green
    blue
    orange
);

eval {
    $cleaner = Data::Cleaner->new(type => $datatype, enumOptions => \@enumopts, default => $default);
    $cleaner->validate($testcase_pass);
    if ($cleaner->is_valid) {
        $testdata_pass = $cleaner->get_raw;
    }
    $cleaner->validate($testcase_fail);
    if (! $cleaner->is_valid) {
        $cleaner->fix;
        $testdata_fail = $cleaner->get_raw;
    }
};

ok(
    ($testdata_pass eq $testcase_pass && $testdata_fail eq $default),
    'Validate/reject datatype '.$datatype
);

##################################################################################################
#
# Test 8. Hex
#

$datatype = 'hex';
$cleaner  = undef;
$testcase_pass = '0xFFBA1C';
$testdata_pass = undef;
$testcase_fail = '87^#(*^(*yNOYED';
$testdata_fail = undef;

eval {
    $cleaner = Data::Cleaner->new(type => $datatype);
    $cleaner->validate($testcase_pass);
    if ($cleaner->is_valid) {
        $testdata_pass = $cleaner->get_raw;
    }
    $cleaner->validate($testcase_fail);
    if (! $cleaner->is_valid) {
        $cleaner->fix;
        $testdata_fail = $cleaner->format;
    }
};

ok(
    ($testdata_pass == $testcase_pass && $testdata_fail eq '00'),
    'Validate/reject datatype '.$datatype
);

##################################################################################################
#
# Test 9. Oct
#

$datatype = 'oct';
$cleaner  = undef;
$testcase_pass = 7643;
$testdata_pass = undef;
$testcase_fail = 8215;
$testdata_fail = undef;

eval {
    $cleaner = Data::Cleaner->new(type => $datatype);
    $cleaner->validate($testcase_pass);
    if ($cleaner->is_valid) {
        $testdata_pass = $cleaner->get_raw;
    }
    $cleaner->validate($testcase_fail);
    if (! $cleaner->is_valid) {
        $cleaner->fix;
        $testdata_fail = $cleaner->format;
    }
};

ok(
    ($testdata_pass == $testcase_pass && $testdata_fail == 0),
    'Validate/reject datatype '.$datatype
);

##################################################################################################
#
# Test 10. Datetime
#

$datatype = 'datetime';
$cleaner  = undef;
$testcase_pass = '02/06/2004 09:47pm';
$testdata_pass = undef;
$testcase_fail = 'Thu, 33 Oct 94 10:13:13 -0700';
$testdata_fail = undef;

eval {
    $cleaner = Data::Cleaner->new(type => $datatype);
    $cleaner->validate($testcase_pass);
    if ($cleaner->is_valid) {
        $testdata_pass = $cleaner->get_raw;
    }
    $cleaner->validate($testcase_fail);
    if (! $cleaner->is_valid) {
        $cleaner->fix;
        $testdata_fail = $cleaner->format;
    }
};

ok(
    ($testdata_pass == 1076104020 && $testdata_fail =~ /^01-01-1970/),
    'Validate/reject datatype '.$datatype
);

##################################################################################################
#
# Test 11. Timeticks
#

$datatype = 'timeticks';
$cleaner  = undef;
$testcase_pass = 29384723345;
$testdata_pass = undef;
$testcase_fail = '56:22';
$testdata_fail = undef;

eval {
    $cleaner = Data::Cleaner->new(type => $datatype);
    $cleaner->validate($testcase_pass);
    if ($cleaner->is_valid) {
        $testdata_pass = $cleaner->get_raw;
    }
    $cleaner->validate($testcase_fail);
    if (! $cleaner->is_valid) {
        $cleaner->fix;
        $testdata_fail = $cleaner->format;
    }
};

ok(
    ($testdata_pass == ($testcase_pass / 100) && $testdata_fail eq '0d 00:00:00.000'),
    'Validate/reject datatype '.$datatype.' '.$testdata_fail.' 0d 00:00:00.000'
);

