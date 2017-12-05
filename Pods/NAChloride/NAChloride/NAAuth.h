//
//  NAAuth.h
//  NAChloride
//
//  Created by Gabriel on 6/16/15.
//  Copyright (c) 2015 Gabriel Handford. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 Computes an authentication tag for a message and a secret key, and provides a way to verify that a given tag is valid for a given message and a key.
 */
@interface NAAuth : NSObject

- (NSData *)auth:(NSData *)data key:(NSData *)key error:(NSError **)error;

/*!
 Returns YES if verifies OK.
 */
- (BOOL)verify:(NSData *)auth data:(NSData *)data key:(NSData *)key error:(NSError **)error;


@end
