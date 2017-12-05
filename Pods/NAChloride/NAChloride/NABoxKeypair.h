//
//  NABoxKeypair.h
//  NAChloride
//
//  Created by Gabriel on 6/18/15.
//  Copyright (c) 2015 Gabriel Handford. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NASecureData.h"

@interface NABoxKeypair : NSObject

@property (readonly) NSData *publicKey;
@property (readonly) NASecureData *secretKey;

- (instancetype)initWithPublicKey:(NSData *)publicKey secretKey:(NASecureData *)secretKey error:(NSError **)error;

+ (instancetype)generate:(NSError **)error;

@end