//
//  NAScrypt.h
//  NAChloride
//
//  Created by Gabriel on 6/19/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NAScrypt : NSObject

/*!
 Key derivation.
 
 @param password Password
 @param salt Must be NAScryptSaltSize

 Default opslimit is crypto_pwhash_scryptsalsa208sha256_OPSLIMIT_INTERACTIVE.
 Default memlimit is crypto_pwhash_scryptsalsa208sha256_MEMLIMIT_INTERACTIVE.
 */
+ (NSData *)scrypt:(NSData *)password salt:(NSData *)salt error:(NSError **)error;

/*!
 Use the default scrypt. This is for advanced use only.
 */
+ (NSData *)scrypt:(NSData *)password salt:(NSData *)salt N:(uint64_t)N r:(uint32_t)r p:(uint32_t)p length:(size_t)length error:(NSError **)error;

@end
