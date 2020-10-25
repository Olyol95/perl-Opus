=head1 NAME

Opus - Perl bindings for libopus audio codec

=head1 SYNOPSIS

 # Encode PCM data into an Opus frame with Opus::Encoder

 use Opus::Encoder;

 my $enc = Opus::Encoder->new( ... );
 my @opus_frame = $enc->encode(\@pcm_data);

 # Decode an Opus frame into PCM with Opus::Decoder

 my $dec = Opus::Decoder->new( ... );
 my @pcm_data = $dec->decode(\@opus_frame);

=head1 DESCRIPTION

This module provides perl bindings to the libopus audio
codec (https://opus-codec.org/docs/) for converting
opus frames to and from PCM data via opus_encode_float
and opus_decode_float.

See Opus::Encoder for converting PCM data to Opus frames.

See Opus::Decoder for converting Opus frames to PCM data.

=cut

package Opus;

use strict;
use warnings;

use XSLoader;

our $VERSION = '1.0';

XSLoader::load("Opus", $VERSION);

=head1 AUTHOR

Oliver Youle <oliver@youle.io>
https://oliver.youle.io/

=cut

1;
