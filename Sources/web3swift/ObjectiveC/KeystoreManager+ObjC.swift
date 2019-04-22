//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
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
