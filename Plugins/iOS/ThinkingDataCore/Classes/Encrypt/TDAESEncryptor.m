//
//  TDAESEncryptor.m
//  ThinkingSDK
//
//  Created by wwango on 2022/1/21.
//

#import "TDAESEncryptor.h"
#import <CommonCrypto/CommonCryptor.h>
#import <Security/SecRandom.h>

/// AES-GCM IV / nonce length in bytes (aligned with Android SDK).
static const size_t kTDAesGcmIVLength = 12;
/// AES-GCM authentication tag length in bytes (128-bit tag).
static const size_t kTDAesGcmTagLength = 16;
/// AES block size (128-bit).
static const size_t kTDAesBlockSize = 16;

#pragma mark - AES-GCM building blocks (public CommonCrypto only)
//
// CommonCrypto exposes no public AES-GCM API (its GCM symbols are non-public
// SPI and are rejected by App Store review as ITMS-90338). We build
// AES-128-GCM ourselves from public primitives:
//   * AES single-block ECB (CCCrypt / kCCOptionECBMode) to derive H and E(J0)
//   * AES-CTR (CCCryptorCreateWithMode / kCCModeCTR) for the keystream
//   * a hand-written GHASH over GF(2^128) for authentication
// The wire format is unchanged (IV || ciphertext || tag), so it stays byte
// compatible with the previous SPI-based implementation and the Android SDK.

/// Encrypt a single 16-byte block with AES in ECB mode. Used only to derive the
/// GHASH subkey H = E(0^128) and the tag mask E(J0); never for payload data.
static BOOL td_aes_ecb_block(const uint8_t *key,
                             size_t keyLength,
                             const uint8_t in[16],
                             uint8_t out[16]) {
    size_t moved = 0;
    CCCryptorStatus status = CCCrypt(kCCEncrypt,
                                     kCCAlgorithmAES,
                                     kCCOptionECBMode,
                                     key,
                                     keyLength,
                                     NULL,
                                     in,
                                     kTDAesBlockSize,
                                     out,
                                     kTDAesBlockSize,
                                     &moved);
    return status == kCCSuccess && moved == kTDAesBlockSize;
}

/// AES-CTR keystream over `dataIn`. CTR is symmetric, so the same routine serves
/// both encryption and decryption. `counter` is the initial 16-byte counter block.
static BOOL td_aes_ctr(const uint8_t *key,
                       size_t keyLength,
                       const uint8_t counter[16],
                       const uint8_t *dataIn,
                       size_t dataInLength,
                       uint8_t *dataOut) {
    CCCryptorRef cryptor = NULL;
    CCCryptorStatus status = CCCryptorCreateWithMode(kCCEncrypt,
                                                     kCCModeCTR,
                                                     kCCAlgorithmAES,
                                                     ccNoPadding,
                                                     counter,
                                                     key,
                                                     keyLength,
                                                     NULL,
                                                     0,
                                                     0,
                                                     kCCModeOptionCTR_BE,
                                                     &cryptor);
    if (status != kCCSuccess || cryptor == NULL) {
        return NO;
    }
    size_t moved = 0;
    status = CCCryptorUpdate(cryptor, dataIn, dataInLength, dataOut, dataInLength, &moved);
    if (status != kCCSuccess) {
        CCCryptorRelease(cryptor);
        return NO;
    }
    size_t movedFinal = 0;
    status = CCCryptorFinal(cryptor, dataOut + moved, dataInLength - moved, &movedFinal);
    CCCryptorRelease(cryptor);
    return status == kCCSuccess;
}

/// Multiply two 128-bit blocks in GF(2^128) as defined by NIST SP 800-38D
/// (bit-by-bit shift-and-xor, reduction polynomial R = 0xE1 || 0^120).
/// `out` may alias `X` (the second operand `Y` is copied up front).
static void td_gf_mult(const uint8_t X[16], const uint8_t Y[16], uint8_t out[16]) {
    uint8_t Z[16] = {0};
    uint8_t V[16];
    memcpy(V, Y, 16);
    for (int i = 0; i < 128; i++) {
        if ((X[i >> 3] >> (7 - (i & 7))) & 1) {
            for (int j = 0; j < 16; j++) {
                Z[j] ^= V[j];
            }
        }
        uint8_t lsb = V[15] & 1;
        for (int j = 15; j > 0; j--) {
            V[j] = (uint8_t)((V[j] >> 1) | (V[j - 1] << 7));
        }
        V[0] >>= 1;
        if (lsb) {
            V[0] ^= 0xe1;
        }
    }
    memcpy(out, Z, 16);
}

/// GHASH over ciphertext with empty AAD:
/// GHASH_H( C_padded || [len(A)=0]_64 || [bitlen(C)]_64 ).
static void td_ghash(const uint8_t H[16],
                     const uint8_t *data,
                     size_t length,
                     uint8_t out[16]) {
    uint8_t Y[16] = {0};
    size_t offset = 0;
    while (offset + kTDAesBlockSize <= length) {
        for (int j = 0; j < 16; j++) {
            Y[j] ^= data[offset + j];
        }
        td_gf_mult(Y, H, Y);
        offset += kTDAesBlockSize;
    }
    if (offset < length) {
        uint8_t block[16] = {0};
        memcpy(block, data + offset, length - offset);
        for (int j = 0; j < 16; j++) {
            Y[j] ^= block[j];
        }
        td_gf_mult(Y, H, Y);
    }
    // Length block: 64-bit AAD bit length (0) || 64-bit ciphertext bit length, big-endian.
    uint8_t lenBlock[16] = {0};
    uint64_t bitLength = (uint64_t)length * 8;
    for (int j = 0; j < 8; j++) {
        lenBlock[15 - j] = (uint8_t)(bitLength >> (8 * j));
    }
    for (int j = 0; j < 16; j++) {
        Y[j] ^= lenBlock[j];
    }
    td_gf_mult(Y, H, Y);
    memcpy(out, Y, 16);
}

/// Constant-time comparison of two byte buffers (NIST warns memcmp is unsafe for tags).
static BOOL td_constant_time_equal(const uint8_t *a, const uint8_t *b, size_t length) {
    uint8_t diff = 0;
    for (size_t i = 0; i < length; i++) {
        diff |= (uint8_t)(a[i] ^ b[i]);
    }
    return diff == 0;
}

@interface TDAESEncryptor ()

@end

@implementation TDAESEncryptor

- (NSString *)randomKey {
    NSUInteger length = 16;
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:length];
    for (NSUInteger i = 0; i < length; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex:arc4random_uniform((uint32_t)[letters length])]];
    }
    return randomString;
}

- (NSString *)key {
    if (_key == nil) {
        _key = [self randomKey];
    }
    return _key;
}

- (NSString *)algorithm {
    return @"AES";
}

- (NSData *)keyBytes {
    NSData *keyData = [self.key dataUsingEncoding:NSUTF8StringEncoding];
    if (!keyData || keyData.length == 0) {
        return nil;
    }
    if (keyData.length >= kCCKeySizeAES128) {
        return [keyData subdataWithRange:NSMakeRange(0, kCCKeySizeAES128)];
    }
    return nil;
}

- (NSData *)encryptData:(NSData *)data {
    if (!data) {
        return nil;
    }

    NSData *keyData = [self keyBytes];
    if (!keyData) {
        return nil;
    }
    const uint8_t *key = keyData.bytes;
    size_t keyLength = keyData.length;

    uint8_t iv[kTDAesGcmIVLength];
    if (SecRandomCopyBytes(kSecRandomDefault, kTDAesGcmIVLength, iv) != errSecSuccess) {
        return nil;
    }

    // H = E(0^128), the GHASH subkey.
    uint8_t H[16];
    uint8_t zeroBlock[16] = {0};
    if (!td_aes_ecb_block(key, keyLength, zeroBlock, H)) {
        return nil;
    }

    // J0 = IV || 0x00000001 (96-bit IV case); tag mask = E(J0).
    uint8_t j0[16] = {0};
    memcpy(j0, iv, kTDAesGcmIVLength);
    j0[15] = 1;
    uint8_t tagMask[16];
    if (!td_aes_ecb_block(key, keyLength, j0, tagMask)) {
        return nil;
    }

    // Payload keystream starts at inc32(J0) = IV || 0x00000002. Analytics payloads
    // are far smaller than 2^32 blocks, so the 32-bit counter never overflows the IV.
    uint8_t counter[16] = {0};
    memcpy(counter, iv, kTDAesGcmIVLength);
    counter[15] = 2;

    NSMutableData *cipherData = [NSMutableData dataWithLength:data.length];
    if (data.length > 0) {
        if (!td_aes_ctr(key, keyLength, counter, data.bytes, data.length, cipherData.mutableBytes)) {
            return nil;
        }
    }

    uint8_t s[16];
    td_ghash(H, cipherData.bytes, cipherData.length, s);
    uint8_t tag[kTDAesGcmTagLength];
    for (int i = 0; i < (int)kTDAesGcmTagLength; i++) {
        tag[i] = s[i] ^ tagMask[i];
    }

    // Payload bytes: IV || ciphertext || tag (same layout as Android SDK).
    NSMutableData *combined = [NSMutableData dataWithCapacity:kTDAesGcmIVLength + cipherData.length + kTDAesGcmTagLength];
    [combined appendBytes:iv length:kTDAesGcmIVLength];
    [combined appendData:cipherData];
    [combined appendBytes:tag length:kTDAesGcmTagLength];
    return combined;
}

- (NSData *)decryptData:(NSData *)data {
    if (!data || data.length <= kTDAesGcmIVLength + kTDAesGcmTagLength) {
        return nil;
    }

    NSData *keyData = [self keyBytes];
    if (!keyData) {
        return nil;
    }
    const uint8_t *key = keyData.bytes;
    size_t keyLength = keyData.length;

    const uint8_t *bytes = data.bytes;
    size_t cipherLength = data.length - kTDAesGcmIVLength - kTDAesGcmTagLength;
    const uint8_t *iv = bytes;
    const uint8_t *cipherBytes = bytes + kTDAesGcmIVLength;
    const uint8_t *tag = bytes + kTDAesGcmIVLength + cipherLength;

    uint8_t H[16];
    uint8_t zeroBlock[16] = {0};
    if (!td_aes_ecb_block(key, keyLength, zeroBlock, H)) {
        return nil;
    }

    uint8_t j0[16] = {0};
    memcpy(j0, iv, kTDAesGcmIVLength);
    j0[15] = 1;
    uint8_t tagMask[16];
    if (!td_aes_ecb_block(key, keyLength, j0, tagMask)) {
        return nil;
    }

    // Verify the authentication tag before producing any plaintext.
    uint8_t s[16];
    td_ghash(H, cipherBytes, cipherLength, s);
    uint8_t expectedTag[kTDAesGcmTagLength];
    for (int i = 0; i < (int)kTDAesGcmTagLength; i++) {
        expectedTag[i] = s[i] ^ tagMask[i];
    }
    if (!td_constant_time_equal(expectedTag, tag, kTDAesGcmTagLength)) {
        return nil;
    }

    uint8_t counter[16] = {0};
    memcpy(counter, iv, kTDAesGcmIVLength);
    counter[15] = 2;

    NSMutableData *plainData = [NSMutableData dataWithLength:cipherLength];
    if (cipherLength > 0) {
        if (!td_aes_ctr(key, keyLength, counter, cipherBytes, cipherLength, plainData.mutableBytes)) {
            return nil;
        }
    }
    return plainData;
}

@end
