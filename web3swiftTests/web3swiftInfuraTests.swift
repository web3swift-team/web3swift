//
//  web3swiftInfuraTests.swift
//  web3swift-iOS_Tests
//
//  Created by Георгий Фесенко on 02/07/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import XCTest

@testable import web3swift_iOS
class web3swiftInfuraTests: XCTestCase {
    
    func testGetBalance() {
        let web3 = Web3.InfuraMainnetWeb3()
        let address = EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B")!
        let response = web3.eth.getBalance(address: address)
        switch response {
        case .failure(_):
            XCTFail()
        case .success(let result):
            let balance = result
            let balString = Web3.Utils.formatToEthereumUnits(balance, toUnits: .eth, decimals: 3)
            print(balString)
        }
    }
    
    func testGetBlockByHash() {
        let web3 = Web3.InfuraMainnetWeb3()
        let response = web3.eth.getBlockByHash("0x6d05ba24da6b7a1af22dc6cc2a1fe42f58b2a5ea4c406b19c8cf672ed8ec0695", fullTransactions: true)
        switch response {
        case .failure(_):
            XCTFail()
        case .success(let result):
            print(result)
        }
    }
    
    func testGetBlockByNumber1() {
        let web3 = Web3.InfuraMainnetWeb3()
        let response = web3.eth.getBlockByNumber("latest", fullTransactions: true)
        switch response {
        case .failure(_):
            XCTFail()
        case .success(let result):
            print(result)
        }
    }
    
    func testGetBlockByNumber2() {
        let web3 = Web3.InfuraMainnetWeb3()
        let response = web3.eth.getBlockByNumber(UInt64(5184323), fullTransactions: true)
        switch response {
        case .failure(_):
            XCTFail()
        case .success(let result):
            print(result)
            let transactions = result.transactions
            for transaction in transactions {
                switch transaction {
                case .transaction(let tx):
                    print(String(describing: tx))
                default:
                    break
                }
            }
        }
    }
    
    func testGetBlockByNumber3() {
        let web3 = Web3.InfuraMainnetWeb3()
        let response = web3.eth.getBlockByNumber(UInt64(1000000000), fullTransactions: true)
        switch response {
        case .failure(_):
            break
        case .success(_):
            XCTFail()
        }
    }
    
    func testGasPrice() {
        let web3 = Web3.InfuraMainnetWeb3()
        let result = web3.eth.getGasPrice()
        switch result {
        case .failure(let error):
            print(error)
            XCTFail()
        case .success(let response):
            print(response)
        }
    }

    
}
