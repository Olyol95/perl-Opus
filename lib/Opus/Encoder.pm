package Opus::Encoder;

use Opus;

use Carp;

use constant APPLICATION_VOIP => 2048;
use constant APPLICATION_AUDIO => 2049;
use constant APPLICATION_RESTRICTED_LOWDELAY => 2051;

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

1;
