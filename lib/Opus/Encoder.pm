=head1 NAME

Opus::Encoder - Encode PCM audio data into an Opus frame

=head1 SYNOPSIS

 use Opus::Encoder;

 my $enc = Opus::Encoder->new(
     sample_rate => 24_000,
     channels    => 2,
     application => Opus::Encoder::APPLICATION_VOIP,
 );
 my @opus_frame = $enc->encode(\@pcm_data);

=head1 DESCRIPTION

This module provides perl bindings to the libopus audio
codec (https://opus-codec.org/docs/) for converting
PCM float data into an Opus frame using opus_encode_float.

=cut

package Opus::Encoder;

use Opus;

use Carp;

=head1 CONSTANTS

=over

=item APPLICATION_VOIP

Gives best quality at a given bitrate for voice signals.
It enhances the input signal by high-pass filtering and 
emphasizing formants and harmonics. Optionally it includes
in-band forward error correction to protect against packet
loss. Use this mode for typical VoIP applications.

Because of the enhancement, even at high bitrates the output
may sound different from the input.

=item APPLICATION_AUDIO

Gives best quality at a given bitrate for most non-voice
signals like music. Use this mode for music and mixed
(music/voice) content, broadcast, and applications requiring
less than 15 ms of coding delay.

=item APPLICATION_RESTRICTED_LOWDELAY

Configures low-delay mode that disables the speech-optimised
mode in exchange for slightly reduced delay. This mode can
only be set on an newly initialized or freshly reset encoder
because it changes the codec delay.

This is useful when the caller knows that the speech-optimised
modes will not be needed (use with caution).

=back

=cut

use constant APPLICATION_VOIP => 2048;
use constant APPLICATION_AUDIO => 2049;
use constant APPLICATION_RESTRICTED_LOWDELAY => 2051;

=head1 CONSTRUCTOR PARAMETERS

=over

=item sample_rate

Sampling rate of input signal (Hz).

This must be one of 8000, 12000, 16000, 24000, or 48000.

Defaults to 24000.

=item channels

Number of channels (1 or 2) in input signal.

Defaults to 2.

=item application

Coding mode (must be one of the defined CONSTANTS).

Defaults to APPLICATION_AUDIO.

=back

=cut

sub new {
    my ($class, %args) = @_;

    my $self = {};

    $self->{sample_rate} = $args{sample_rate} // 24_000;
    croak("Sample rate must be one of 8000, 12000, 16000, 24000 or 48000")
        unless $self->{sample_rate} =~ /^(8|12|16|24|48)000$/;

    $self->{channels} = $args{channels} // 2;
    croak("Number of channels must be either 1 or 2")
        unless $self->{channels} =~ /^[12]$/;

    $self->{application} = $args{application} // APPLICATION_AUDIO;
    croak("Invalid application value")
        unless ($self->{application} == APPLICATION_VOIP
                || $self->{application} == APPLICATION_AUDIO
                || $self->{application} == APPLICATION_RESTRICTED_LOWDELAY);

    $self->{_ptr} = _opus_encoder_create(
        $self->{sample_rate}, $self->{channels}, $self->{application},
    );

    return bless $self, $class;
}

=head1 METHODS

=over

=item encode( DATA )

Encodes an array of PCM float values using opus_encode_float.

DATA should be an array of float values (interleaved if 2 channels), with
a normal range of +/-1.0.

The provided PCM data must fit exactly into a multiple of 2.5ms.

Returns an array of unsigned bytes - a single Opus frame.

The absolute maximum length of the output is 8191 bytes.

On error, this method will return error codes from libopus, referenced at:
https://opus-codec.org/docs/opus_api-1.3.1/group__opus__errorcodes.html

=cut

sub encode {
    my ($self, $data) = @_;

    die "No data provided" unless $data;

    my $packed_data = pack("f*", @$data);

    my $frame_size = scalar(@$data) / $self->{channels};

    my $bytes = _opus_encode_float(
        $self->{_ptr}, $packed_data, $frame_size, 8191
    );

    return unpack("C*", $bytes);
}

=back

=head1 AUTHOR

Oliver Youle <oliver@youle.io>
https://oliver.youle.io/

=cut

1;
