//
//  web3swift_promises_Tests.swift
//  web3swift-iOS_Tests
//
//  Created by Alexander Vlasov on 17.06.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import XCTest
import PromiseKit
import BigInt

@testable import web3swift_iOS

class web3swift_promises_Tests: XCTestCase {
    var urlSession : URLSession?
    func testGetBalancePromise() {
        do {
            let web3 = Web3.InfuraMainnetWeb3()
            let balance = try web3.eth.getBalancePromise(address: "0x6394b37Cf80A7358b38068f0CA4760ad49983a1B").wait()
            print(balance)
        } catch {
            print(error)
        }
    }
    
    func testGetTransactionDetailsPromise() {
        do {
            let web3 = Web3.InfuraMainnetWeb3()
            let result = try web3.eth.getTransactionDetailsPromise("0x127519412cefd773b952a5413a4467e9119654f59a34eca309c187bd9f3a195a").wait()
            print(result)
            XCTAssert(result.transaction.gasLimit == BigUInt(78423))
        } catch {
            print(error)
        }
    }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
