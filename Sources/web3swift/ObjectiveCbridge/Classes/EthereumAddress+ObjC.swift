//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
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
