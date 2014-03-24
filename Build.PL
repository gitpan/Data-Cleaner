use 5.010000;

use Module::Build;

my $builder = Module::Build->new(
        module_name        => 'Data::Cleaner',
        dist_author        => 'Jason Turner <jason.turner@gridx.eu>',
        license            => 'perl',
        requires           => {
            perl                   => '5.010000',
            Encode                 => 0,
            Time::Local            => 0,
            Time::Interval         => 0,
            Data::Types            => 0,
        },
        recommends         => {
            Date::Parse            => 0,
            Date::Format           => 0,
            Data::Validate         => 0,
            Data::Validate::IP     => 0,
            Data::Validate::URI    => 0,
            Data::Validate::Email  => 0,
            Data::Validate::Domain => 0,
            Algorithm::CheckDigits => 0,
        },
        dist_version       => '0.000_002',
        create_makefile_pl => 'traditional',
        create_license     => 1,
);

$builder->create_build_script;

exit 0;
