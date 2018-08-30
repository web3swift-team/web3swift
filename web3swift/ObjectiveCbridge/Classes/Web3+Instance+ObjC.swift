//
//  Web3Instnace+ObjectiveC.swift
//  web3swift
//
//  Created by Alexander Vlasov on 08.08.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation

@objc(web3)
public final class _ObjCweb3: NSObject {
    private (set) var web3: web3?
    
    init(web3: web3?) {
        self.web3 = web3
    }
    
    public var web3Eth: _ObjCweb3Eth {
        return _ObjCweb3Eth(web3: self.web3)
    }
}
