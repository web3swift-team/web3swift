//
//  EthereumTransaction+ObjC.swift
//  web3swift-iOS
//
//  Created by Anton Grigorev on 17.10.2018.
//  Copyright © 2018 The Matter Inc. All rights reserved.
//

import Foundation
import BigInt

@objc(EthereumTransaction)
public final class _ObjCEthereumTransaction: NSObject{
    private (set) var transaction: EthereumTransaction?
    
    public init(gasPrice: _ObjCBigUInt, gasLimit: _ObjCBigUInt, to: _ObjCEthereumAddress, value: _ObjCBigUInt, data: NSData) {
        self.transaction = EthereumTransaction(gasPrice: gasPrice.biguint ?? 0,
                                               gasLimit: gasLimit.biguint ?? 0,
                                               to: to.address ?? EthereumAddress("")!,
                                               value: value.biguint ?? 0,
                                               data: data as Data)
    }
    
    public init(to: _ObjCEthereumAddress, data: NSData, options: _ObjCWeb3Options) {
        self.transaction = EthereumTransaction(to: to.address ?? EthereumAddress("")!,
                                               data: data as Data,
                                               options: options.options)
    }
    
    public init(to: _ObjCEthereumAddress, data: NSData, options: _ObjCWeb3Options) {
        self.transaction = EthereumTransaction(to: to.address ?? EthereumAddress("")!,
                                               data: data as Data,
                                               options: options.options)
    }
    
    public init(nonce: _ObjCBigUInt, gasPrice: _ObjCBigUInt, gasLimit: _ObjCBigUInt, to: _ObjCEthereumAddress, value: _ObjCBigUInt, data: NSData, v: _ObjCBigUInt, r: _ObjCBigUInt, s: _ObjCBigUInt) {
        self.transaction = EthereumTransaction(nonce: nonce.biguint ?? 0,
                                               gasPrice: gasPrice.biguint ?? 0,
                                               gasLimit: gasLimit.biguint ?? 0,
                                               to: to.address ?? EthereumAddress("")!,
                                               value: value.biguint ?? 0,
                                               data: data as Data,
                                               v: v.biguint ?? 0,
                                               r: r.biguint ?? 0,
                                               s: s.biguint ?? 0)
    }
    
}
