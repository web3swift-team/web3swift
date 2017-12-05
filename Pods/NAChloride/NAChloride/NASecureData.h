//
//  NASecureData.h
//  NAChloride
//
//  Created by Gabriel on 6/19/15.
//  Copyright (c) 2015 Gabriel Handford. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NAInterface.h"

typedef NS_ENUM (NSInteger, NASecureDataProtection) {
  NASecureDataProtectionReadWrite = 0, // Default no protection
  NASecureDataProtectionReadOnly,
  NASecureDataProtectionNoAccess,
};

/*!
 Secure memory using libsodium.
 */
@interface NASecureData : NSMutableData // Subclassing for convienience

@property (readonly, nonatomic) NASecureDataProtection protection;

/*!
 Secure and read only data.
 */
+ (instancetype)secureReadOnlyDataWithLength:(NSUInteger)length completion:(NADataCompletion)completion;

/*!
 Secure data is has read/write protection in this block.
 */
- (BOOL)readWrite:(void (^)(NSError *error, NASecureData *secureData))completion;

/*!
 Truncate.
 */
- (NASecureData *)truncate:(NSUInteger)length;

/*!
 Set protection.
 @return NO if unable to set protection
 */
- (BOOL)setProtection:(NASecureDataProtection)protection error:(NSError **)error;

@end


// Optional building of secure NSData
NSMutableData *NAData(BOOL secure, NSUInteger length, NADataCompletion completion);


@interface NSMutableData (NASecureData)

- (NSData *)na_truncate:(NSUInteger)length;

@end
