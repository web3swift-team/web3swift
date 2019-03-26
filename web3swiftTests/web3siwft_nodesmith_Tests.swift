//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import XCTest
import EthereumAddress

@testable import web3swift_iOS

class web3swift_nodesmith_Tests: XCTestCase {
    
    // Special API key for these integration tests
    let API_KEY = "WEB3_SWIFT_TESTS";
    
    func testGetBalance() {
        do {
            let web3 = Web3.NodesmithMainnetWeb3(apiKey: API_KEY)
            let address = EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901")!
            let balance = try web3.eth.getBalance(address: address)
            XCTAssert(balance >= 0)
        } catch {
            XCTFail()
        }
    }
    
    func testGetBlockByHash() {
        do {
            let web3 = Web3.NodesmithMainnetWeb3(apiKey: API_KEY)
            let result = try web3.eth.getBlockByHash("0x6d05ba24da6b7a1af22dc6cc2a1fe42f58b2a5ea4c406b19c8cf672ed8ec0695", fullTransactions: true)
            XCTAssertEqual(5184323, result.number)
        } catch {
            XCTFail()
        }
    }
    
    func testGetBlockByNumber1() throws {
        let web3 = Web3.NodesmithMainnetWeb3(apiKey: API_KEY)
        let result = try web3.eth.getBlockByNumber("latest", fullTransactions: true)
        XCTAssertNotNil(result)
    }
    
    func testGetBlockByNumber2() throws {
        let web3 = Web3.NodesmithMainnetWeb3(apiKey: API_KEY)
        let result = try web3.eth.getBlockByNumber(UInt64(7140801), fullTransactions: false)
        XCTAssertEqual(72, result.transactions.count)
    }
    
    func testGetBlockByNumber_ExpectedError() {
        do {
            let web3 = Web3.NodesmithMainnetWeb3(apiKey: API_KEY)
            let _ = try web3.eth.getBlockByNumber(UInt64(424242424242), fullTransactions: true)
            XCTFail() // Fail if we got here
        } catch {
            
        }
    }
    
    func testGetTransactionByHash() throws {
        let web3 = Web3.NodesmithMainnetWeb3(apiKey: API_KEY)
        let result = try web3.eth.getTransactionDetails("0x98ca2f92879b33e56b72f2b2cf250fe38e742f5dd4bea1da958da78d5985f3c0")
        XCTAssertNotNil(result)
        let amountString = Web3.Utils.formatToEthereumUnits(result.transaction.value, toUnits: .eth, decimals: 3)
        XCTAssertEqual("0.002", amountString)
        
    }
    
    func testGasPrice() throws {
        let web3 = Web3.NodesmithMainnetWeb3(apiKey: API_KEY)
        let response = try web3.eth.getGasPrice()
        XCTAssertNotNil(response)
        XCTAssertTrue(response > 0)
    }
}
