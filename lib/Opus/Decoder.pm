package Opus::Decoder;

use Opus;

use Carp;

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

1;
