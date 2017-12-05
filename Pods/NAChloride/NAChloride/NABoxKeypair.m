//
//  NABoxKeypair.m
//  NAChloride
//
//  Created by Gabriel on 6/18/15.
//  Copyright (c) 2015 Gabriel Handford. All rights reserved.
//

#import "NABoxKeypair.h"

#import "NAInterface.h"
#import "NASecureData.h"

#import "sodium.h"

@interface NABoxKeypair ()
@property NSData *publicKey;
@property NASecureData *secretKey;
@end

@implementation NABoxKeypair

+ (void)initialize { NAChlorideInit(); }

- (instancetype)initWithPublicKey:(NSData *)publicKey secretKey:(NASecureData *)secretKey error:(NSError **)error {
  if ((self = [super init])) {

    if (!publicKey || [publicKey length] != NABoxPublicKeySize) {
      if (error) *error = NAError(NAErrorCodeInvalidKey, @"Invalid public key");
      return nil;
    }

    if (!secretKey) {
      if (error) *error = NAError(NAErrorCodeInvalidKey, @"No secret key");
      return nil;
    }

    if ([secretKey length] != NABoxPublicKeySize) {
      if (error) *error = NAError(NAErrorCodeInvalidKey, @"Invalid secret key length");
      return nil;
    }

    _publicKey = publicKey;
    _secretKey = secretKey;
  }
  return self;
}

+ (instancetype)generate:(NSError **)error {
  NSMutableData *publicKey = [NSMutableData dataWithLength:NABoxPublicKeySize];
  __block int retval = -1;
  NASecureData *secretKey = [NASecureData secureReadOnlyDataWithLength:NABoxSecretKeySize completion:^(void *bytes, NSUInteger length) {
    retval = crypto_box_keypair([publicKey mutableBytes], bytes);
  }];
  if (retval != 0) {
    if (error) *error = NAError(NAErrorCodeFailure, @"Keypair generate failed");
    return nil;
  }
  return [[NABoxKeypair alloc] initWithPublicKey:publicKey secretKey:secretKey error:error];
}

@end
