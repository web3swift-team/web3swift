//
//  NARandom.m
//  NAChloride
//
//  Created by Gabriel on 6/16/15.
//  Copyright (c) 2015 Gabriel Handford. All rights reserved.
//

#import "NARandom.h"

#import "NAInterface.h"

#import "sodium.h"

@implementation NARandom

+ (void)initialize { NAChlorideInit(); }

+ (NSData *)randomData:(NSUInteger)length {
  NSMutableData *outData = [NSMutableData dataWithLength:length];
  randombytes_buf([outData mutableBytes], length);
  return outData;
}

+ (NASecureData *)randomSecureReadOnlyData:(NSUInteger)length {
  NASecureData *secureData = [NASecureData secureReadOnlyDataWithLength:length completion:^(void *bytes, NSUInteger length) {
    randombytes_buf(bytes, length);
  }];
  return secureData;
}

@end
