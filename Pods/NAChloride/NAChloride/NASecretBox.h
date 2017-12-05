//
//  NASecretBox.h
//  NACL
//
//  Created by Gabriel Handford on 1/16/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 Encrypts and authenticates a message using a shared key and nonce.
 */
@interface NASecretBox : NSObject

@property (getter=isSecureDataEnabled) BOOL secureDataEnabled;

- (NSData *)encrypt:(NSData *)data nonce:(NSData *)nonce key:(NSData *)key error:(NSError **)error;

- (NSData *)decrypt:(NSData *)data nonce:(NSData *)nonce key:(NSData *)key error:(NSError **)error;

@end
