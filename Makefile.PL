use 5.008005;
use ExtUtils::MakeMaker 7.12; # for XSMULTI option

WriteMakefile(
    NAME           => 'Opus',
    VERSION_FROM   => 'lib/Opus.pm',
    PREREQ_PM      => {
        'Carp'                => 0,
        'ExtUtils::MakeMaker' => '7.12',
        'Test::Exception'     => 0,
        'Test::MemoryGrowth'  => 0,
        'Test::More'          => 0,
    },
    ABSTRACT_FROM  => 'lib/Opus.pm',
    AUTHOR         => 'Oliver Youle',
    CCFLAGS        => '-Wall -std=c99',
    LIBS           => ['-lopus'],
    OPTIMIZE       => '-O3',
    XSMULTI        => 1,
);
