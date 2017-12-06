//
//  EthereumTransaction.swift
//  web3swift
//
//  Created by Alexander Vlasov on 05.12.2017.
//  Copyright © 2017 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt

struct Transaction {
    var nonce: BigInt
    var gasprice: BigInt
    var startgas: BigInt
    var to: Data
    var value: BigInt
    var data: Data
    var v: BigInt
    var r: BigInt
    var s: BigInt
}
