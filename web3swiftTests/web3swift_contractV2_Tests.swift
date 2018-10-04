//
//  web3swift_contractV2_Tests.swift
//  web3swift-iOS_Tests
//
//  Created by Антон Григорьев on 02.07.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import XCTest
import CryptoSwift
import BigInt
import Result

@testable import web3swift_iOS

class web3swift_contractV2_Tests: XCTestCase {
    
    func testDecodeInputData() {
        let contract = ContractV2.init(Web3.Utils.erc20ABI)!
        let dataToDecode = Data.fromHex("0xa9059cbb000000000000000000000000cdd45864e794fe5e3e1b0045b77e62f4c43b8bd9000000000000000000000000000000000000000000000224b5f018c3e30142d5")!
        let decoded = contract.decodeInputData("transfer", data: dataToDecode)
        XCTAssert(decoded!["_to"] as? EthereumAddress == EthereumAddress("0xcdd45864e794fe5e3e1b0045b77e62f4c43b8bd9")!)
    }
    
    func testDecodeInputDataWithoutMethodName() {
        let contract = ContractV2.init(Web3.Utils.erc20ABI)!
        let dataToDecode = Data.fromHex("0xa9059cbb000000000000000000000000cdd45864e794fe5e3e1b0045b77e62f4c43b8bd9000000000000000000000000000000000000000000000224b5f018c3e30142d5")!
        let decoded = contract.decodeInputData(dataToDecode)
        XCTAssert(decoded!["_to"] as? EthereumAddress == EthereumAddress("0xcdd45864e794fe5e3e1b0045b77e62f4c43b8bd9")!)
    }
    
}
