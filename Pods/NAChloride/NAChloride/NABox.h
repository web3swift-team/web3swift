//
//  NABox.h
//  NAChloride
//
//  Created by Gabriel on 6/18/15.
//  Copyright (c) 2015 Gabriel Handford. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NABoxKeypair.h"

@interface NABox : NSObject

@property (getter=isSecureDataEnabled) BOOL secureDataEnabled;

- (NSData *)encrypt:(NSData *)data nonce:(NSData *)nonce keypair:(NABoxKeypair *)keypair error:(NSError **)error;

- (NSData *)decrypt:(NSData *)data nonce:(NSData *)nonce keypair:(NABoxKeypair *)keypair error:(NSError **)error;

@end
