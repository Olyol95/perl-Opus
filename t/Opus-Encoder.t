use strict;
use warnings;

use Test::More tests => 5;

use Test::Exception;
use Test::MemoryGrowth;

use_ok('Opus::Encoder');

subtest 'constants' => sub {
    plan tests => 1;

    my @constants = (
        'APPLICATION_VOIP',
        'APPLICATION_AUDIO',
        'APPLICATION_RESTRICTED_LOWDELAY',
    );

    can_ok('Opus::Encoder', @constants);
};

subtest 'new' => sub {
    plan tests => 20;

    my $enc = new_ok( 'Opus::Encoder' );
    is($enc->{sample_rate}, 24_000, 'Default sample rate is 24,000');
    is($enc->{channels}, 2, 'Default channels is 2');
    is($enc->{application}, Opus::Encoder->APPLICATION_AUDIO);

    foreach my $sample_rate (qw(8000 12000 16000 24000 48000)) {
        lives_ok {
            Opus::Encoder->new( sample_rate => $sample_rate );
        } "Sample rate of $sample_rate accepted";
    }

    throws_ok {
        Opus::Encoder->new( sample_rate => 1234 );
    } qr/^Sample rate must be one of/, 'Sample rate of 1234 not accepted';

    foreach my $channels (qw(1 2)) {
        lives_ok {
            Opus::Encoder->new( channels => $channels );
        } "$channels channels accepted";
    }

    throws_ok {
        Opus::Encoder->new( channels => 3 );
    } qr/^Number of channels must be either/, '3 channels not accepted';

    my @applications = (
        Opus::Encoder->APPLICATION_VOIP,
        Opus::Encoder->APPLICATION_AUDIO,
        Opus::Encoder->APPLICATION_RESTRICTED_LOWDELAY,
    );
    foreach my $application (@applications) {
        lives_ok {
            Opus::Encoder->new( application => $application );
        } "Application type $application accepted";
    }

    throws_ok {
        Opus::Encoder->new( application => 99999 );
    } qr/^Invalid application value/, 'Application type 99999 not accepted';

    $enc = Opus::Encoder->new(
        sample_rate => 8_000,
        channels    => 1,
        application => Opus::Encoder->APPLICATION_RESTRICTED_LOWDELAY,
    );
    is($enc->{sample_rate}, 8_000, 'Passed sample rate is retained');
    is($enc->{channels}, 1, 'Passed number of channels is retained');
    is(
        $enc->{application},
        Opus::Encoder->APPLICATION_RESTRICTED_LOWDELAY,
        'Passed application type is retained'
    );
};

subtest 'encode' => sub {
    plan tests => 2;

    can_ok('Opus::Encoder', qw(encode));

    open(my $pcm_in, '<:raw', 't/data/pcm.raw')
        or die "Failed to open 't/data/pcm.raw': $!";

    local $/;
    my @pcm = unpack('f*', <$pcm_in>);

    close($pcm_in);

    open(my $opus_in, '<:raw', 't/data/encode.opus')
        or die "Failed to open 't/data/encode.opus': $!";

    my @expected = unpack('C*', <$opus_in>);

    close($opus_in);

    my $encoder = Opus::Encoder->new(
        channels    => 2,
        sample_rate => 48_000,
    );

    my @opus = $encoder->encode(\@pcm);

    is_deeply(\@opus, \@expected, 'PCM data encoded correctly');
};

subtest 'destroy' => sub {
    plan tests => 1;

    no_growth {
        Opus::Encoder->new;
    } 'DESTROY frees OpusEncoder struct';
};
