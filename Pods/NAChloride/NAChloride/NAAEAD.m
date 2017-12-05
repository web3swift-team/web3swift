//
//  NAAEAD.m
//  NAChloride
//
//  Created by Gabriel on 6/18/15.
//  Copyright (c) 2015 Gabriel Handford. All rights reserved.
//

#import "NAAEAD.h"

#import "NAInterface.h"
#import "NASecureData.h"

#import "sodium.h"

@implementation NAAEAD

+ (void)initialize { NAChlorideInit(); }

- (NSData *)encryptChaCha20Poly1305:(NSData *)data nonce:(NSData *)nonce key:(NSData *)key additionalData:(NSData *)additionalData error:(NSError **)error {
  if (!nonce || [nonce length] != NAAEADNonceSize) {
    if (error) *error = NAError(NAErrorCodeInvalidNonce, @"Invalid nonce");
    return nil;
  }

  if (!data) {
    if (error) *error = NAError(NAErrorCodeInvalidData, @"Invalid data");
    return nil;
  }

  if (!additionalData) {
    if (error) *error = NAError(NAErrorCodeInvalidAdditionalData, @"Invalid additional data");
    return nil;
  }

  if (!key || [key length] != NAAEADKeySize) {
    if (error) *error = NAError(NAErrorCodeInvalidKey, @"Invalid key");
    return nil;
  }

  NSMutableData *outData = [NSMutableData dataWithLength:[data length] + NAAEADASize];

  unsigned long long outLength;
  int retval = crypto_aead_chacha20poly1305_encrypt([outData mutableBytes], &outLength,
                                                    [data bytes], [data length],
                                                    [additionalData bytes], [additionalData length],
                                                    NULL,
                                                    [nonce bytes],
                                                    [key bytes]);

  if (retval != 0) {
    if (error) *error = NAError(NAErrorCodeFailure, @"AEAD encrypt failed");
    return nil;
  }

  return outData;
}

- (NSData *)decryptChaCha20Poly1305:(NSData *)data nonce:(NSData *)nonce key:(NSData *)key additionalData:(NSData *)additionalData error:(NSError **)error {
  if (!nonce || [nonce length] != NAAEADNonceSize) {
    if (error) *error = NAError(NAErrorCodeInvalidNonce, @"Invalid nonce");
    return nil;
  }

  if (!data) {
    if (error) *error = NAError(NAErrorCodeInvalidData, @"Invalid data");
    return nil;
  }

  if (!additionalData) {
    if (error) *error = NAError(NAErrorCodeInvalidAdditionalData, @"Invalid additional data");
    return nil;
  }

  if (!key || [key length] != NAAEADKeySize) {
    if (error) *error = NAError(NAErrorCodeInvalidKey, @"Invalid key");
    return nil;
  }

  __block unsigned long long outLength;
  __block int retval = -1;
  NSMutableData *outData = NAData(self.secureDataEnabled, data.length, ^(void *bytes, NSUInteger length) {
    retval = crypto_aead_chacha20poly1305_decrypt(bytes, &outLength,
                                                  NULL,
                                                  [data bytes], [data length],
                                                  [additionalData bytes], [additionalData length],
                                                  [nonce bytes],
                                                  [key bytes]);
  });
  if (retval != 0) {
    if (error) *error = NAError(NAErrorCodeVerificationFailed, @"Verification failed");
    return nil;
  }

  return [outData na_truncate:outData.length - (NSUInteger)outLength];
}

@end
