//
//  ABIDecoder.swift
//  web3swift
//
//  Created by Alexander Vlasov on 05.12.2017.
//  Copyright © 2017 Alexander Vlasov. All rights reserved.
//

import Foundation

struct ABIInput: Decodable {
    var name: String?
    var type: String
    var indexed: Bool?
}

struct ABIOutput: Decodable {
    var name: String?
    var type: String
}

struct ABIRecord: Decodable {
    var name: String?
    var type: String?
    var payable: Bool?
    var constant: Bool?
    var stateMutability: String?
    var inputs: [ABIInput]?
    var outputs: [ABIOutput]?
    var anonymous: Bool?
}
