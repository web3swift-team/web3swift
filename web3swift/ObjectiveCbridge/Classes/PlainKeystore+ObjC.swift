//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation

@objc(PlainKeystore)
public final class _ObjCPlainKeystore: NSObject{
    private (set) var keystore: PlainKeystore?
    
    init(privateKey: String) {
        self.keystore = PlainKeystore(privateKey: privateKey)
    }
    
    init(privateKey: Data) {
        self.keystore = PlainKeystore(privateKey: privateKey)
    }
    
    init(privateKey: NSData) {
        self.keystore = PlainKeystore(privateKey: privateKey as Data)
    }
    
    init(keystore: PlainKeystore) {
        self.keystore = keystore
    }
}
