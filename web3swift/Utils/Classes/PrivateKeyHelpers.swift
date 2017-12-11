//
//  PrivateKeyHelpers.swift
//  web3swift
//
//  Created by Alexander Vlasov on 05.12.2017.
//  Copyright © 2017 Alexander Vlasov. All rights reserved.
//

import Foundation
import Sodium
import CryptoSwift
import SECP256K1

func privateToPublic(_ privateKey: Data, compressed: Bool = false) -> Data? {
    guard let publicKey = SECP256K1.privateToPublic(privateKey:  privateKey, compressed: compressed) else {return nil}
    return publicKey
}

func publicToAddress(_ publicKey: Data) -> Data? {
    var stipped = publicKey
    if (stipped.count == 65) {
        if (stipped[0] != 4) {
            return nil
        }
        stipped = stipped[1...64]
    }
    if (stipped.count != 64) {
        return nil
    }
    let sha3 = stipped.sha3(.keccak256)
    let addressData = sha3[12...31]
    return addressData
}

func addressDataToString(_ addressData: Data) -> String {
    return addressData.toHexString()
}
