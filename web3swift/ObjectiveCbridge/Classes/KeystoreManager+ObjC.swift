//
//  KeystoreManager+ObjC.swift
//  web3swift
//
//  Created by Alexander Vlasov on 08.08.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation

@objc(KeystoreManager)
public final class _ObjCKeystoreManager: NSObject{
    private (set) var keystoreManager: KeystoreManager?
    
    init(plainKeystore: _ObjCPlainKeystore) {
        guard let ks = plainKeystore.keystore else {return}
        self.keystoreManager = KeystoreManager([ks])
    }
    
    init(plainKeystore: PlainKeystore) {
        self.keystoreManager = KeystoreManager([plainKeystore])
    }
}
