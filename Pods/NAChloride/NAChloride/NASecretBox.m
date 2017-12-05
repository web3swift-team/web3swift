//
//  NASecretBox.m
//  NACL
//
//  Created by Gabriel Handford on 1/16/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import "NASecretBox.h"

#import "NAInterface.h"
#import "NASecureData.h"

#import "sodium.h"

@implementation NASecretBox

+ (void)initialize { NAChlorideInit(); }

- (NSData *)encrypt:(NSData *)data nonce:(NSData *)nonce key:(NSData *)key error:(NSError **)error {
  if (!nonce || [nonce length] != NASecretBoxNonceSize) {
    if (error) *error = NAError(NAErrorCodeInvalidNonce, @"Invalid nonce");
    return nil;
  }
    
  if (!data) {
    if (error) *error = NAError(NAErrorCodeInvalidData, @"Invalid data");
    return nil;
  }
    
  if (!key || [key length] != NASecretBoxKeySize) {
    if (error) *error = NAError(NAErrorCodeInvalidKey, @"Invalid key");
    return nil;
  }
    
  // Add space for authentication tag of size MACBYTES
  NSMutableData *outData = [NSMutableData dataWithLength:[data length] + NASecretBoxMACSize];
    
  int retval = crypto_secretbox_easy([outData mutableBytes],
                                     [data bytes], [data length],
                                     [nonce bytes],
                                     [key bytes]);
    
  if (retval != 0) {
    if (error) *error = NAError(NAErrorCodeFailure, @"Encrypt (secret box) failed");
    return nil;
  }
    
  return outData;
}

- (NSData *)decrypt:(NSData *)data nonce:(NSData *)nonce key:(NSData *)key error:(NSError **)error {
  if (!nonce || [nonce length] != NASecretBoxNonceSize) {
    if (error) *error = NAError(NAErrorCodeInvalidNonce, @"Invalid nonce");
    return nil;
  }

  if (!data) {
    if (error) *error = NAError(NAErrorCodeInvalidData, @"Invalid data");
    return nil;
  }

  if (!key || [key length] != NASecretBoxKeySize) {
    if (error) *error = NAError(NAErrorCodeInvalidKey, @"Invalid key");
    return nil;
  }

  __block int retval = -1;
  NSMutableData *outData = NAData(self.secureDataEnabled, data.length, ^(void *bytes, NSUInteger length) {
    retval = crypto_secretbox_open_easy(bytes,
                                        [data bytes], [data length],
                                        [nonce bytes], [key bytes]);
  });
  if (retval != 0) {
    if (error) *error = NAError(NAErrorCodeVerificationFailed, @"Verification failed");
    return nil;
  }

  // Remove MAC bytes from data
  return [outData na_truncate:NASecretBoxMACSize];
}


@end
