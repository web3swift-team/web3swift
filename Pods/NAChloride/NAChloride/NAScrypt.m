//
//  NAScrypt.m
//  NAChloride
//
//  Created by Gabriel on 6/19/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import "NAScrypt.h"
#import "NAInterface.h"

#import "sodium.h"

@implementation NAScrypt

+ (void)initialize { NAChlorideInit(); }

+ (NSData *)scrypt:(NSData *)password salt:(NSData *)salt error:(NSError **)error {
  if (!salt || [salt length] != NAScryptSaltSize) {
    if (error) *error = NAError(NAErrorCodeInvalidSalt, @"Invalid salt")
    return nil;
  }

  NSMutableData *key = [NSMutableData dataWithLength:crypto_box_SEEDBYTES];

  int retval = crypto_pwhash_scryptsalsa208sha256([key mutableBytes], key.length, password.bytes, password.length, salt.bytes, crypto_pwhash_scryptsalsa208sha256_OPSLIMIT_INTERACTIVE, crypto_pwhash_scryptsalsa208sha256_MEMLIMIT_INTERACTIVE);

  if (retval != 0) {
    if (error) *error = NAError(NAErrorCodeFailure, @"Scrypt failed");
    return nil;
  }

  return key;
}

+ (NSData *)scrypt:(NSData *)password salt:(NSData *)salt N:(uint64_t)N r:(uint32_t)r p:(uint32_t)p length:(size_t)length error:(NSError **)error {
  NSMutableData *outData = [NSMutableData dataWithLength:length];
  
  int retval = crypto_pwhash_scryptsalsa208sha256_ll((uint8_t *)password.bytes, password.length, (uint8_t *)salt.bytes, salt.length, N, r, p, [outData mutableBytes], outData.length);
  
  if (retval != 0) {
    if (error) *error = NAError(NAErrorCodeFailure, @"Scrypt failed");
    return nil;
  }
  
  NSAssert([outData length] == length, @"Mismatched output length");
  
  return outData;
}

@end
