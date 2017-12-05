//
//  NAAuth.m
//  NAChloride
//
//  Created by Gabriel on 6/16/15.
//  Copyright (c) 2015 Gabriel Handford. All rights reserved.
//

#import "NAAuth.h"

#import "NAInterface.h"

#import "sodium.h"

@implementation NAAuth

+ (void)initialize { NAChlorideInit(); }

- (NSData *)auth:(NSData *)data key:(NSData *)key error:(NSError **)error {
  if (!key || [key length] != NAAuthKeySize) {
    if (error) *error = NAError(NAErrorCodeInvalidKey, @"Invalid key");
    return nil;
  }

  NSMutableData *outData = [NSMutableData dataWithLength:NAAuthSize];

  crypto_auth([outData mutableBytes], [data bytes], [data length], [key bytes]);
  return outData;
}

- (BOOL)verify:(NSData *)auth data:(NSData *)data key:(NSData *)key error:(NSError **)error {
  if (!key || [key length] != NAAuthKeySize) {
    if (error) *error = NAError(NAErrorCodeInvalidKey, @"Invalid key");
    return NO;
  }

  if (!auth || [auth length] != NAAuthSize) {
    if (error) *error = NAError(NAErrorCodeInvalidData, @"Invalid data");
    return NO;
  }

  if (crypto_auth_verify([auth bytes], [data bytes], [data length], [key bytes]) != 0) {
    if (error) *error = NAError(NAErrorCodeVerificationFailed, @"Verification failed");
    return NO; // Message forged!
  }
  return YES;
}

@end

