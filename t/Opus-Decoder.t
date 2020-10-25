use strict;
use warnings;

use Test::More tests => 4;

use Test::Exception;
use Test::MemoryGrowth;

use_ok('Opus::Decoder');

subtest 'new' => sub {
    plan tests => 14;

    my $dec = new_ok( 'Opus::Decoder' );
    is($dec->{sample_rate}, 24_000, 'Default sample rate is 24,000');
    is($dec->{channels}, 2, 'Default channels is 2');

    foreach my $sample_rate (qw(8000 12000 16000 24000 48000)) {
        lives_ok {
            Opus::Decoder->new( sample_rate => $sample_rate );
        } "Sample rate of $sample_rate accepted";
    }

    throws_ok {
        Opus::Decoder->new( sample_rate => 1234 );
    } qr/^Sample rate must be one of/, 'Sample rate of 1234 not accepted';

    foreach my $channels (qw(1 2)) {
        lives_ok {
            Opus::Decoder->new( channels => $channels );
        } "$channels channels accepted";
    }

    throws_ok {
        Opus::Decoder->new( channels => 3 );
    } qr/^Number of channels must be either/, '3 channels not accepted';

    $dec = Opus::Decoder->new(
        sample_rate => 8_000,
        channels    => 1,
    );
    is($dec->{sample_rate}, 8_000, 'Passed sample rate is retained');
    is($dec->{channels}, 1, 'Passed number of channels is retained');
};

subtest 'decode' => sub {
    plan tests => 2;

    can_ok('Opus::Decoder', qw(decode));

    open(my $opus_in, '<:raw', 't/data/decode.opus')
        or die "Failed to open 't/data/decode.opus': $!";

    local $/;
    my @opus = unpack('C*', <$opus_in>);

    close($opus_in);

    open(my $pcm_in, '<:raw', 't/data/pcm.raw')
        or die "Failed to open 't/data/pcm.raw': $!";

    my @expected = unpack('f*', <$pcm_in>);

    close($pcm_in);

    my $decoder = Opus::Decoder->new(
        channels    => 2,
        sample_rate => 48_000,
    );

    my @pcm = $decoder->decode(\@opus);

    is_deeply(\@pcm, \@expected, 'Opus data decoded correctly');
};

subtest 'destroy' => sub {
    plan tests => 1;

    no_growth {
        Opus::Decoder->new;
    } 'DESTROY frees OpusDecoder struct';
};
