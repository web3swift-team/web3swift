//
//  NAOneTimeAuth.h
//  NAChloride
//
//  Created by Gabriel on 9/24/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 Generates a MAC for a given message and shared key using Poly1305 algorithm 
 (key may NOT be reused across messages).
 */
@interface NAOneTimeAuth : NSObject

- (NSData *)auth:(NSData *)data key:(NSData *)key error:(NSError **)error;

/*!
 Returns YES if verifies OK.
 */
- (BOOL)verify:(NSData *)auth data:(NSData *)data key:(NSData *)key error:(NSError **)error;

@end
