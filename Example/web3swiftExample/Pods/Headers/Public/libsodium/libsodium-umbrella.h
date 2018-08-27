#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "core.h"
#import "crypto_aead_aes256gcm.h"
#import "crypto_aead_chacha20poly1305.h"
#import "crypto_aead_xchacha20poly1305.h"
#import "crypto_auth.h"
#import "crypto_auth_hmacsha256.h"
#import "crypto_auth_hmacsha512.h"
#import "crypto_auth_hmacsha512256.h"
#import "crypto_box.h"
#import "crypto_box_curve25519xchacha20poly1305.h"
#import "crypto_box_curve25519xsalsa20poly1305.h"
#import "crypto_core_hchacha20.h"
#import "crypto_core_hsalsa20.h"
#import "crypto_core_salsa20.h"
#import "crypto_core_salsa2012.h"
#import "crypto_core_salsa208.h"
#import "crypto_generichash.h"
#import "crypto_generichash_blake2b.h"
#import "crypto_hash.h"
#import "crypto_hash_sha256.h"
#import "crypto_hash_sha512.h"
#import "crypto_kdf.h"
#import "crypto_kdf_blake2b.h"
#import "crypto_kx.h"
#import "crypto_onetimeauth.h"
#import "crypto_onetimeauth_poly1305.h"
#import "crypto_pwhash.h"
#import "crypto_pwhash_argon2i.h"
#import "crypto_pwhash_scryptsalsa208sha256.h"
#import "crypto_scalarmult.h"
#import "crypto_scalarmult_curve25519.h"
#import "crypto_secretbox.h"
#import "crypto_secretbox_xchacha20poly1305.h"
#import "crypto_secretbox_xsalsa20poly1305.h"
#import "crypto_shorthash.h"
#import "crypto_shorthash_siphash24.h"
#import "crypto_sign.h"
#import "crypto_sign_ed25519.h"
#import "crypto_sign_edwards25519sha512batch.h"
#import "crypto_stream.h"
#import "crypto_stream_aes128ctr.h"
#import "crypto_stream_chacha20.h"
#import "crypto_stream_salsa20.h"
#import "crypto_stream_salsa2012.h"
#import "crypto_stream_salsa208.h"
#import "crypto_stream_xchacha20.h"
#import "crypto_stream_xsalsa20.h"
#import "crypto_verify_16.h"
#import "crypto_verify_32.h"
#import "crypto_verify_64.h"
#import "export.h"
#import "common.h"
#import "curve25519_ref10.h"
#import "mutex.h"
#import "sse2_64_32.h"
#import "randombytes.h"
#import "randombytes_nativeclient.h"
#import "randombytes_salsa20_random.h"
#import "randombytes_sysrandom.h"
#import "runtime.h"
#import "utils.h"
#import "version.h"

FOUNDATION_EXPORT double libsodiumVersionNumber;
FOUNDATION_EXPORT const unsigned char libsodiumVersionString[];

