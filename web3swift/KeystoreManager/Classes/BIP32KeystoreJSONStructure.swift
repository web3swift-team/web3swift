//
//  BIP32KeystoreJSONStructure.swift
//  web3swift
//
//  Created by Alexander Vlasov on 11.01.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation

public struct KeystoreParamsBIP32: Decodable, Encodable {
    var address: String?
    var crypto: CryptoParamsV3
    var id: String?
    var version: Int = 32
    var isHDWallet: Bool
    var pathsToGenerate: [String]
    
    public init(address ad: String?, crypto cr: CryptoParamsV3, id i: String, version ver: Int) {
        address = ad
        crypto = cr
        id = i
        version = ver
        isHDWallet = true
        pathsToGenerate = [HDNode.defaultPath]
    }
    
}
