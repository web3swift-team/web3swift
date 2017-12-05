//
//  NAAEAD.h
//  NAChloride
//
//  Created by Gabriel on 6/18/15.
//  Copyright (c) 2015 Gabriel Handford. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NAAEAD : NSObject

@property (getter=isSecureDataEnabled) BOOL secureDataEnabled;

- (NSData *)encryptChaCha20Poly1305:(NSData *)data nonce:(NSData *)nonce key:(NSData *)key additionalData:(NSData *)additionalData error:(NSError **)error;

- (NSData *)decryptChaCha20Poly1305:(NSData *)data nonce:(NSData *)nonce key:(NSData *)key additionalData:(NSData *)additionalData error:(NSError **)error;

@end
