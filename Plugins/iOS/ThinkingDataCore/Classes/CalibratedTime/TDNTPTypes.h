#ifndef NTPTypes_h
#define NTPTypes_h

#include <stdint.h>

typedef struct ufixed32 {
    uint16_t whole, fraction;
} ufixed32_t;

ufixed32_t ufixed32(uint16_t whole, uint16_t fraction);

typedef struct ufixed64 {
    uint32_t whole, fraction;
} ufixed64_t;

ufixed64_t ufixed64(uint32_t whole, uint32_t fraction);

double ufixed64_as_double(ufixed64_t);
ufixed64_t ufixed64_with_double(double);

typedef struct ntp_packet_t {
    uint8_t	mode : 3;
    uint8_t	version_number : 3;
    uint8_t	leap_indicator : 2;
    
    uint8_t stratum;
    uint8_t poll;
    uint8_t precision;
    
    ufixed32_t root_delay;
    ufixed32_t root_dispersion;
    uint8_t reference_identifier[4];
    
    ufixed64_t reference_timestamp;
    ufixed64_t originate_timestamp;
    ufixed64_t receive_timestamp;
    ufixed64_t transmit_timestamp;
} ntp_packet_t;



ufixed32_t hton_ufixed32(ufixed32_t);
ufixed32_t ntoh_ufixed32(ufixed32_t);

ufixed64_t hton_ufixed64(ufixed64_t);
ufixed64_t ntoh_ufixed64(ufixed64_t);

ntp_packet_t hton_ntp_packet(ntp_packet_t);
ntp_packet_t ntoh_ntp_packet(ntp_packet_t);

#endif 
