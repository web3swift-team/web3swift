//
//  NAInterface.h
//  NAChloride
//
//  Created by Gabriel on 6/25/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, NAErrorCode) {
  NAErrorCodeFailure = 1, // Generic failure

  NAErrorCodeInvalidNonce = 100,
  NAErrorCodeInvalidKey = 101,
  NAErrorCodeInvalidData = 102,
  NAErrorCodeInvalidSalt = 103,
  NAErrorCodeInvalidAdditionalData = 104, // For AEAD

  NAErrorCodeVerificationFailed = 205, // Verification failed

  NAErrorSecureDataAccessFailed = 500,
};

extern const size_t NASecretBoxKeySize;
extern const size_t NASecretBoxNonceSize;
extern const size_t NASecretBoxMACSize;

extern const size_t NABoxPublicKeySize;
extern const size_t NABoxSecretKeySize;
extern const size_t NABoxNonceSize;
extern const size_t NABoxMACSize;

extern const size_t NAAuthKeySize;
extern const size_t NAAuthSize;

extern const size_t NAOneTimeAuthKeySize;
extern const size_t NAOneTimeAuthSize;

extern const size_t NAScryptSaltSize;

extern const size_t NAStreamKeySize;
extern const size_t NAStreamNonceSize;

extern const size_t NAXSalsaKeySize;
extern const size_t NAXSalsaNonceSize;

extern const size_t NAAEADKeySize;
extern const size_t NAAEADNonceSize;
extern const size_t NAAEADASize;


// Thread safe libsodium init
void NAChlorideInit(void);

// Don't call this directly (use NAChlorideInit). This is made accessible for testing.
int NASodiumInit(void);


typedef id (^NAWork)(NSError **error);
typedef void (^NACompletion)(NSError *error, id output);
void NADispatch(dispatch_queue_t queue, NAWork work, NACompletion completion);

#define NAError(CODE, DESC) [NSError errorWithDomain:@"NAChloride" code:CODE userInfo:@{NSLocalizedDescriptionKey: DESC}];

typedef void (^NADataCompletion)(void *bytes, NSUInteger length);
