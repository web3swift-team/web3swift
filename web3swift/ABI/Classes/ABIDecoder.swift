//
//  ABIDecoder.swift
//  web3swift
//
//  Created by Alexander Vlasov on 05.12.2017.
//  Copyright © 2017 Alexander Vlasov. All rights reserved.
//

import Foundation

//[{
//    "type":"constructor",
//    "payable":false,
//    "stateMutability":"nonpayable",
//    "inputs":[{"name":"testInt","type":"uint256"}]
//    },{
//        "type":"function",
//        "name":"foo",
//        "constant":false,
//        "payable":false,
//        "stateMutability":"nonpayable",
//        "inputs":[{"name":"b","type":"uint256"}, {"name":"c","type":"bytes32"}],
//        "outputs":[{"name":"","type":"address"}]
//    },{
//        "type":"event",
//        "name":"Event",
//        "inputs":[{"indexed":true,"name":"b","type":"uint256"}, {"indexed":false,"name":"c","type":"bytes32"}],
//        "anonymous":false
//    },{
//        "type":"event",
//        "name":"Event2",
//        "inputs":[{"indexed":true,"name":"b","type":"uint256"},{"indexed":false,"name":"c","type":"bytes32"}],
//        "anonymous":false
//    }]

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
