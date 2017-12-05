//
//  NAInterface.m
//  NACL
//
//  Created by Gabriel Handford on 1/16/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import "NAInterface.h"

#import "sodium.h"

const size_t NASecretBoxKeySize = crypto_secretbox_KEYBYTES;
const size_t NASecretBoxNonceSize = crypto_secretbox_NONCEBYTES;
const size_t NASecretBoxMACSize = crypto_secretbox_MACBYTES;

const size_t NABoxPublicKeySize = crypto_box_PUBLICKEYBYTES;
const size_t NABoxSecretKeySize = crypto_box_SECRETKEYBYTES;
const size_t NABoxNonceSize = crypto_box_NONCEBYTES;
const size_t NABoxMACSize = crypto_box_MACBYTES;

const size_t NAAuthKeySize = crypto_auth_KEYBYTES;
const size_t NAAuthSize = crypto_auth_BYTES;

const size_t NAOneTimeAuthKeySize = crypto_onetimeauth_KEYBYTES;
const size_t NAOneTimeAuthSize = crypto_onetimeauth_BYTES;

const size_t NAScryptSaltSize = crypto_pwhash_scryptsalsa208sha256_SALTBYTES;

const size_t NAStreamKeySize = crypto_stream_KEYBYTES;
const size_t NAStreamNonceSize = crypto_stream_NONCEBYTES;

const size_t NAXSalsaKeySize = crypto_stream_xsalsa20_KEYBYTES;
const size_t NAXSalsaNonceSize = crypto_stream_xsalsa20_NONCEBYTES;

const size_t NAAEADKeySize = crypto_aead_chacha20poly1305_KEYBYTES;
const size_t NAAEADNonceSize = crypto_aead_chacha20poly1305_NPUBBYTES;
const size_t NAAEADASize = crypto_aead_chacha20poly1305_ABYTES;


void NAChlorideInit(void) {
  static dispatch_once_t sodiumInit;
  dispatch_once(&sodiumInit, ^{ NASodiumInit(); });
}

int NASodiumInit(void) {
  return sodium_init();
}

void NADispatch(dispatch_queue_t queue, NAWork work, NACompletion completion) {
  dispatch_async(queue, ^{

    NSError *error = nil;
    id output = work(&error);

    dispatch_async(dispatch_get_main_queue(), ^{
      completion(error, output);
    });
  });
}
