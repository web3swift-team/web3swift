//
//  Contract.swift
//  web3swift
//
//  Created by Alexander Vlasov on 10.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt

struct Contract {
    var chainID : BigUInt = BigUInt(1)
    var address : EthereumAddress
    var abi : [ABIElement]
    var methods : [String: ABIElement]
}
