#include "TDNTPTypes.h"

#include <assert.h>
#include <math.h>
#include <stdlib.h>

ufixed32_t ufixed32(uint16_t whole, uint16_t fraction) {
    return (struct ufixed32) { .whole = whole, .fraction = fraction };
}

ufixed64_t ufixed64(uint32_t whole, uint32_t fraction) {
    return (struct ufixed64) { .whole = whole, .fraction = fraction };
}

double ufixed64_as_double(ufixed64_t uf64) {
    return uf64.whole + uf64.fraction * pow(2, -32);
}

ufixed64_t ufixed64_with_double(double value) {
    assert(value >= 0);
    return ufixed64(value, (value - trunc(value) * pow(2, 32)));
}

ufixed32_t hton_ufixed32(ufixed32_t uf32) {
    return ufixed32(htons(uf32.whole), htons(uf32.fraction));
}
ufixed32_t ntoh_ufixed32(ufixed32_t uf32) {
    return ufixed32(ntohs(uf32.whole), ntohs(uf32.fraction));
}

ufixed64_t hton_ufixed64(ufixed64_t uf64) {
    return ufixed64(htonl(uf64.whole), htonl(uf64.fraction));
}
ufixed64_t ntoh_ufixed64(ufixed64_t uf64) {
    return ufixed64(ntohl(uf64.whole), ntohl(uf64.fraction));
}

ntp_packet_t hton_ntp_packet(ntp_packet_t p) {
    p.root_delay = hton_ufixed32(p.root_delay);
    p.root_dispersion = hton_ufixed32(p.root_dispersion);
    
    p.reference_timestamp = hton_ufixed64(p.reference_timestamp);
    p.originate_timestamp = hton_ufixed64(p.originate_timestamp);
    p.receive_timestamp = hton_ufixed64(p.receive_timestamp);
    p.transmit_timestamp = hton_ufixed64(p.transmit_timestamp);
    
    return p;
}

ntp_packet_t ntoh_ntp_packet(ntp_packet_t p) {
    p.root_delay = ntoh_ufixed32(p.root_delay);
    p.root_dispersion = ntoh_ufixed32(p.root_dispersion);
    
    p.reference_timestamp = ntoh_ufixed64(p.reference_timestamp);
    p.originate_timestamp = ntoh_ufixed64(p.originate_timestamp);
    p.receive_timestamp = ntoh_ufixed64(p.receive_timestamp);
    p.transmit_timestamp = ntoh_ufixed64(p.transmit_timestamp);
    
    return p;
}

