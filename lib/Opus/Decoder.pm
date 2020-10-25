=head1 NAME

Opus::Decoder - Decode an Opus audio frame into PCM data

=head1 SYNOPSIS

 use Opus::Decoder;

 my $dec = Opus::Decoder->new(
     sample_rate => 24_000,
     channels    => 2,
 );
 my @pcm_data = $dec->decode(\@opus_frame);

=head1 DESCRIPTION

This module provides perl bindings to the libopus audio
codec (https://opus-codec.org/docs/) for converting
an Opus audio frame into PCM data using opus_decode_float.

=cut

package Opus::Decoder;

use Opus;

use Carp;

=head1 CONSTRUCTOR PARAMETERS

=over

=item sample_rate

Sample rate to decode at (Hz).

This must be one of 8000, 12000, 16000, 24000, or 48000.

Defaults to 24000.

=item channels

Number of channels (1 or 2) to decode.

Defaults to 2.

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

    $self->{_ptr} = _opus_decoder_create(
        $self->{sample_rate}, $self->{channels},
    );

    return bless $self, $class;
}

=head1 METHODS

=over

=item decode( DATA )

Decodes an opus audio frame into a PCM signal using opus_decode_float.

DATA should be an array of unsigned byte values from a single Opus frame.

Returns an array of float values (interleaved if 2 channels), with a normal
range of +/-1.0.

On error, this method will return error codes from libopus, referenced at:
https://opus-codec.org/docs/opus_api-1.3.1/group__opus__errorcodes.html

=cut

sub decode {
    my ($self, $data) = @_;

    die "No data provided" unless $data;

    my $data_length = @$data;
    my $packed_data = pack("C*", @$data);

    my $frame_size = $self->{sample_rate} * 0.10 * $self->{channels};

    my $pcm = _opus_decode_float(
        $self->{_ptr}, $packed_data, $data_length, $self->{channels}, $frame_size,
    );

    return unpack("f*", $pcm);
}

=back

=head1 AUTHOR

Oliver Youle <oliver@youle.io>
https://oliver.youle.io/

=cut

1;
