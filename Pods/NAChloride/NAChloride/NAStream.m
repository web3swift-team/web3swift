//
//  NAStream.m
//  NAChloride
//
//  Created by Gabriel on 6/18/15.
//  Copyright (c) 2015 Gabriel Handford. All rights reserved.
//

#import "NAStream.h"

#import "NAInterface.h"

#import "sodium.h"

@implementation NAStream

+ (void)initialize { NAChlorideInit(); }

- (NSData *)xor:(NSData *)data nonce:(NSData *)nonce key:(NSData *)key error:(NSError **)error {
  if (!nonce || [nonce length] < NAStreamNonceSize) {
    if (error) *error = NAError(NAErrorCodeInvalidNonce, @"Invalid stream nonce");
    return nil;
  }

  if (!key || [key length] != NAStreamKeySize) {
    if (error) *error = NAError(NAErrorCodeInvalidKey, @"Invalid stream key");
    return nil;
  }

  NSMutableData *outData = [NSMutableData dataWithLength:[data length]];

  int retval = crypto_stream_xor([outData mutableBytes], [data bytes], [data length], [nonce bytes], [key bytes]);
  if (retval != 0) {
    if (error) *error = NAError(NAErrorCodeFailure, @"Stream failed");
    return nil;
  }

  return outData;
}

@end
