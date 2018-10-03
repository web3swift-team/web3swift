//
//  Web3+ObjectiveC.swift
//  web3swift
//
//  Created by Alexander Vlasov on 08.08.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation

@objc(Web3)
public final class _ObjCWeb3: NSObject {
    public static func InfuraMainnetWeb3() -> _ObjCweb3 {
        let web3 = Web3.InfuraMainnetWeb3()
        return _ObjCweb3(web3: web3)
    }
    
    public static func InfuraRinkebyWeb3() -> _ObjCweb3 {
        let web3 = Web3.InfuraRinkebyWeb3()
        return _ObjCweb3(web3: web3)
    }
    
    public static func new(providerURL: NSURL, error: NSErrorPointer) -> _ObjCweb3? {
        guard let web3 = Web3.new(providerURL as URL) else {
            error?.pointee = Web3Error.inputError(desc: "Wrong URL") as NSError
            return nil
        }
        return _ObjCweb3(web3: web3)
    }
}


