//
//  EthereumAddress+ObjC.swift
//  web3swift
//
//  Created by Alexander Vlasov on 08.08.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation

@objc(EthereumAddress)
public final class _ObjCEthereumAddress: NSObject{
    private (set) var address: EthereumAddress?
    
    public init(address: String) {
        self.address = EthereumAddress(address)
    }
    
    public init(address: Data) {
        self.address = EthereumAddress(address)
    }
    
    init(address: EthereumAddress) {
        self.address = address
    }
    
    public static var contractDeploymentAddress: _ObjCEthereumAddress {
        return _ObjCEthereumAddress(address: EthereumAddress.contractDeploymentAddress())
    }
}
