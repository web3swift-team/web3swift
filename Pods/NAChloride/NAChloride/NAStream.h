//
//  NAStream.h
//  NAChloride
//
//  Created by Gabriel on 6/18/15.
//  Copyright (c) 2015 Gabriel Handford. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NAStream : NSObject

- (NSData *)xor:(NSData *)data nonce:(NSData *)nonce key:(NSData *)key error:(NSError **)error;

@end