//
//  Web3+Eth+ObjC.swift
//  web3swift
//
//  Created by Alexander Vlasov on 08.08.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation

@objc(web3Eth)
public final class _ObjCweb3Eth: NSObject {
    private (set) weak var web3: web3?
    
    init(web3: _ObjCweb3?) {
        self.web3 = web3?._web3
    }
    
    public func getBalance(address: _ObjCEthereumAddress, onBlock: NSString = "latest", error: NSErrorPointer) -> _ObjCBigUInt? {
        guard let addr = address.address else {
            error?.pointee = Web3Error.inputError(desc: "Address is empty") as NSError
            return nil
        }
        guard let result = self.web3?.eth.getBalance(address: addr, onBlock: onBlock as String) else {
            error?.pointee = Web3Error.processingError(desc: "Web3 object was not properly initialized") as NSError
            return nil
        }
        switch result {
        case .success(let balance):
            let biguint = _ObjCBigUInt(value: balance)
            return biguint
        case .failure(let web3error):
            error?.pointee = web3error as NSError
            return nil
        }
    }
    
    public func getBlockNumber(error: NSErrorPointer) -> _ObjCBigUInt? {
        guard let result = self.web3?.eth.getBlockNumber() else {
            error?.pointee = Web3Error.inputError(desc: "Web3 object was not properly initialized") as NSError
            return nil
        }
        switch result {
        case .success(let blockNumber):
            let biguint = _ObjCBigUInt(value: blockNumber)
            return biguint
        case .failure(let web3error):
            error?.pointee = web3error as NSError
            return nil
        }
    }
    
    public func getGasPrice(error: NSErrorPointer) -> _ObjCBigUInt? {
        guard let result = self.web3?.eth.getGasPrice() else {
            error?.pointee = Web3Error.inputError(desc: "Web3 object was not properly initialized") as NSError
            return nil
        }
        switch result {
        case .success(let blockNumber):
            let biguint = _ObjCBigUInt(value: blockNumber)
            return biguint
        case .failure(let web3error):
            error?.pointee = web3error as NSError
            return nil
        }
    }
}
