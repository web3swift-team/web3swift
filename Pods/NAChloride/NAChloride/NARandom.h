//
//  NARandom.h
//  NAChloride
//
//  Created by Gabriel on 6/16/15.
//  Copyright (c) 2015 Gabriel Handford. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NASecureData.h"

@interface NARandom : NSObject

/*!
 Random data of length bytes.
 */
+ (NSData *)randomData:(NSUInteger)length;

/*!
 Random & secure data of length bytes.
 */
+ (NASecureData *)randomSecureReadOnlyData:(NSUInteger)length;

@end
