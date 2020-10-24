#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <opus/opus.h>

MODULE = Opus PACKAGE = Opus::Encoder
PROTOTYPES: ENABLE

SV*
_opus_encoder_create(opus_int32 sample_rate, int channels, int application)
PREINIT:
    int error;
    OpusEncoder* enc;
CODE:
    enc = opus_encoder_create(sample_rate, channels, application, &error);
    if (error) {
        croak("error calling opus_encoder_create: %i", error);
    }
    RETVAL = newSViv(PTR2IV(enc));
OUTPUT:
    RETVAL

SV*
_opus_encode_float(SV* enc_ptr, char* pcm_pack, int frame_size, opus_int32 max_data_bytes)
PREINIT:
    OpusEncoder* enc;
    int data_length;
CODE:
    unsigned char data[max_data_bytes];
    const float* pcm = (float*) pcm_pack;
    enc  = (OpusEncoder*) SvIV(enc_ptr);
    data_length = opus_encode_float(enc, pcm, frame_size, data, max_data_bytes);
    if (data_length < 0) {
        croak("error calling opus_encode_float: %i", data_length);
    }
    RETVAL = newSVpv( (char*) data, data_length * sizeof(char));
OUTPUT:
    RETVAL

void
DESTROY(SV* self)
PREINIT:
    OpusEncoder* enc;
    HV* hash;
CODE:
    hash = (HV*) SvRV(self);
    enc  = (OpusEncoder*) SvIV(
        *hv_fetchs( hash, "_ptr", FALSE )
    );
    opus_encoder_destroy(enc);


MODULE = Opus PACKAGE = Opus::Decoder
PROTOTYPES: ENABLE

SV*
_opus_decoder_create(opus_int32 sample_rate, int channels)
PREINIT:
    int error;
    OpusDecoder* dec;
CODE:
    dec = opus_decoder_create(sample_rate, channels, &error);
    if (error) {
        croak("error calling opus_decoder_create: %i", error);
    }
    RETVAL = newSViv(PTR2IV(dec));
OUTPUT:
    RETVAL

SV*
_opus_decode_float(SV* dec_ptr, char* opus_pack, opus_int32 opus_length, int channels, int frame_size)
PREINIT:
    OpusDecoder* dec;
    int samples;
CODE:
    float pcm[frame_size * channels * sizeof(float)];
    const unsigned char* opus = (unsigned char*) opus_pack;
    dec  = (OpusDecoder*) SvIV(dec_ptr);
    samples = opus_decode_float(dec, opus, opus_length, pcm, frame_size, 0);
    if (samples < 0) {
        croak("error calling opus_decode_float: %i", samples);
    }
    RETVAL = newSVpv( (char*) pcm, samples * sizeof(float));
OUTPUT:
    RETVAL

void
DESTROY(SV* self)
PREINIT:
    OpusDecoder* dec;
    HV* hash;
CODE:
    hash = (HV*) SvRV(self);
    dec  = (OpusDecoder*) SvIV(
        *hv_fetchs( hash, "_ptr", FALSE )
    );
    opus_decoder_destroy(dec);
