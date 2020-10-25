use 5.008005;
use ExtUtils::MakeMaker 7.12; # for XSMULTI option

WriteMakefile(
    NAME           => 'Opus',
    VERSION_FROM   => 'lib/Opus.pm',
    ABSTRACT_FROM  => 'lib/Opus.pm',
    AUTHOR         => 'Oliver Youle',
    CCFLAGS        => '-g -Wall -std=c99',
    LIBS           => ['-lopus'],
    OPTIMIZE       => '-O3',
    XSMULTI        => 1,
);
