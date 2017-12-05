//
//  NASecureData.m
//  NAChloride
//
//  Created by Gabriel on 6/19/15.
//  Copyright (c) 2015 Gabriel Handford. All rights reserved.
//

#import "NASecureData.h"

#import "NAInterface.h"

#import "sodium.h"

@interface NASecureData ()
@property void *secureBytes;
@property NSUInteger secureLength;
@end

@implementation NASecureData

+ (void)initialize {
  NAChlorideInit();
#ifndef HAVE_MPROTECT
  assert(false);
#endif
}

- (instancetype)initWithLength:(NSUInteger)length {
  if ((self = [super init])) {
    NAChlorideInit(); // It's already init'ed, but just to be safe
    _secureLength = length;
    _secureBytes = sodium_malloc(length);
  }
  return self;
}

+ (instancetype)secureReadOnlyDataWithLength:(NSUInteger)length completion:(NADataCompletion)completion {
  NASecureData *secureData = [[NASecureData alloc] initWithLength:length];
  completion(secureData.secureBytes, secureData.length);
  if (![secureData setProtection:NASecureDataProtectionReadOnly error:nil]) {
    return nil;
  }
  return secureData;
}

- (void)dealloc {
  sodium_free(_secureBytes);
}

- (BOOL)setProtection:(NASecureDataProtection)protection error:(NSError **)error {
  int result = INT_MIN;
  switch (protection) {
    case NASecureDataProtectionReadWrite:
      result = sodium_mprotect_readwrite(_secureBytes);
      break;
    case NASecureDataProtectionReadOnly:
      result = sodium_mprotect_readonly(_secureBytes);
      break;
    case NASecureDataProtectionNoAccess:
      result = sodium_mprotect_noaccess(_secureBytes);
      break;
    default:
      return NO;
  }
  if (result != 0) {
    if (error) *error = NAError(NAErrorSecureDataAccessFailed, ([NSString stringWithFormat:@"Unable to set protection (%@)", @(result)]));
    return NO;
  }
  return YES;
}

- (NSUInteger)length {
  return _secureLength;
}

- (const void *)bytes {
  return _secureBytes;
}

- (void *)mutableBytes {
  return _secureBytes;
}

- (BOOL)readWrite:(void (^)(NSError *error, NASecureData *secureData))completion {
  NASecureDataProtection protection = self.protection;
  NSError *error = nil;
  [self setProtection:NASecureDataProtectionReadWrite error:&error];
  completion(error, self);
  return [self setProtection:protection error:&error];
}

- (NASecureData *)truncate:(NSUInteger)length {
  if (length == 0) return self;
  return [NASecureData secureReadOnlyDataWithLength:(self.length - length) completion:^(void *bytes, NSUInteger length) {
    memcpy(bytes, self.bytes, length);
  }];
}

- (NSData *)na_truncate:(NSUInteger)length { return [self truncate:length]; }

@end

NSMutableData *NAData(BOOL secure, NSUInteger length, NADataCompletion completion) {
  if (!secure) {
    NSMutableData *data = [NSMutableData dataWithLength:length];
    completion([data mutableBytes], length);
    return data;
  } else {
    return [NASecureData secureReadOnlyDataWithLength:length completion:completion];
  }
}

@implementation NSMutableData (NASecureData)

- (NSData *)na_truncate:(NSUInteger)length {
  if (length == 0) return self;
  return [NSData dataWithBytes:self.bytes length:self.length - length];
}

@end
