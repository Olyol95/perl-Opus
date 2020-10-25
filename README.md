# perl-Opus

This package provides perl bindings to the libopus audio codec (https://opus-codec.org/docs/) for converting Opus frames to and from PCM data via `opus_encode_float` and `opus_decode_float`.

## Opus::Encoder

Encode a PCM audio stream into opus frames:

```perl
use Opus::Encoder;

my $enc = Opus::Encoder->new(
    sample_rate => 24_000,
    channels    => 2,
    application => Opus::Encoder::APPLICATION_VOIP,
);

my @opus_frame = $enc->encode(\@pcm_slice);
```

## Opus::Decoder

Decode an Opus audio frame into a PCM stream:

```perl
use Opus::Decoder;

my $dec = Opus::Decoder->new(
    sample_rate => 24_000,
    channels    => 2,
);

my @pcm_slice = $dec->decode(\@opus_frame);
```
