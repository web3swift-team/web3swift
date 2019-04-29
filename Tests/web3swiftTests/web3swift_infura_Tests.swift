//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import XCTest
//import EthereumAddress

@testable import web3swift

class web3swift_infura_Tests: XCTestCase {
    
    func testGetBalance() {
        do {
            let web3 = Web3.InfuraMainnetWeb3()
            let address = EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901")!
            let balance = try web3.eth.getBalance(address: address)
            let balString = Web3.Utils.formatToEthereumUnits(balance, toUnits: .eth, decimals: 3)
            print(balString!)
        } catch {
            XCTFail()
        }
    }
    
    func testGetBlockByHash() {
        do {
            let web3 = Web3.InfuraMainnetWeb3()
            let result = try web3.eth.getBlockByHash("0x6d05ba24da6b7a1af22dc6cc2a1fe42f58b2a5ea4c406b19c8cf672ed8ec0695", fullTransactions: true)
            print(result)
        } catch {
            XCTFail()
        }
    }
    
    func testGetBlockByNumber1() throws {
        let web3 = Web3.InfuraMainnetWeb3()
        let result = try web3.eth.getBlockByNumber("latest", fullTransactions: true)
        print(result)
    }
    
    func testGetBlockByNumber2() throws {
        let web3 = Web3.InfuraMainnetWeb3()
        let result = try web3.eth.getBlockByNumber(UInt64(5184323), fullTransactions: true)
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
    
    func testGetBlockByNumber3() {
        do {
            let web3 = Web3.InfuraMainnetWeb3()
            let _ = try web3.eth.getBlockByNumber(UInt64(1000000000), fullTransactions: true)
            XCTFail()
        } catch {
            
        }
    }
    
    func testGasPrice() throws {
        let web3 = Web3.InfuraMainnetWeb3()
        let response = try web3.eth.getGasPrice()
        print(response)
    }

    
}
