//
//  PlainKeystore.swift
//  web3swift
//
//  Created by Alexander Vlasov on 06.04.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation

public class PlainKeystore: AbstractKeystore {
    private var privateKey: Data
    
    public var addresses: [EthereumAddress]?
    
    public var isHDKeystore: Bool = false
    
    public func UNSAFE_getPrivateKeyData(password: String = "", account: EthereumAddress) throws -> Data {
        return self.privateKey
    }
    
    public convenience init?(privateKey: String) {
        guard let privateKeyData = Data.fromHex(privateKey) else {return nil}
        self.init(privateKey: privateKeyData)
    }
    
    public init?(privateKey: Data) {
        guard SECP256K1.verifyPrivateKey(privateKey: privateKey) else {return nil}
        guard let publicKey = Web3.Utils.privateToPublic(privateKey, compressed: false) else {return nil}
        guard let address = Web3.Utils.publicToAddress(publicKey) else {return nil}
        self.addresses = [address]
        self.privateKey = privateKey
    }

}
