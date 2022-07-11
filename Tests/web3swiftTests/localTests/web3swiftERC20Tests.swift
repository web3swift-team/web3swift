//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import XCTest
import BigInt
import Core

@testable import web3swift

class web3swiftERC20Tests: XCTestCase {
    
    func testERC20name() async throws {
        let (web3, _, receipt, _) = try await web3swiftHelpers.localDeployERC20()
        
        let parameters = [] as [AnyObject]
        let contract = web3.contract(Web3.Utils.erc20ABI, at: receipt.contractAddress!)!
        let readTX = contract.read("name", parameters:parameters)!
        readTX.transactionOptions.from = EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901")
        let response = try await readTX.decodedData()
        let name = response["0"] as? String
        XCTAssert(name == "web3swift", "Failed to create ERC20 name transaction")
    }
    
    func testERC20tokenBalance() async throws {
        let (web3, _, receipt, _) = try await web3swiftHelpers.localDeployERC20()
        
        let addressOfUser = EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901")!
        let contract = web3.contract(Web3.Utils.erc20ABI, at: receipt.contractAddress!, abiVersion: 2)!
        guard let readTX = contract.read("balanceOf", parameters: [addressOfUser] as [AnyObject]) else {return XCTFail()}
        readTX.transactionOptions.from = addressOfUser
        let tokenBalance = try await readTX.decodedData()
        guard let bal = tokenBalance["0"] as? BigUInt else {return XCTFail()}
        print(String(bal))
    }
    
}
