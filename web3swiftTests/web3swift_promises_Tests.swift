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
    
    func testEstimateGasPromise() {
        do {
            let web3 = Web3.InfuraMainnetWeb3()
            let sendToAddress = EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B")
            let tempKeystore = try! EthereumKeystoreV3(password: "")
            let keystoreManager = KeystoreManager([tempKeystore!])
            web3.addKeystoreManager(keystoreManager)
            let contract = web3.contract(Web3.Utils.coldWalletABI, at: sendToAddress, abiVersion: 2)
            var options = Web3Options.defaultOptions()
            options.value = Web3.Utils.parseToBigUInt("1.0", units: .eth)
            options.from = keystoreManager.addresses?.first
            let intermediate = contract?.method("fallback", options: options)
            let esimate = try web3.eth.estimateGasPromise(intermediate!.transaction, options: intermediate!.options!).wait()
            print(esimate)
            XCTAssert(esimate == 21000)
        } catch{
            print(error)
        }
    }
    
    func testSendETHPromise() {
        do {
            guard let keystoreData = getKeystoreData() else {return}
            guard let keystoreV3 = EthereumKeystoreV3.init(keystoreData) else {return XCTFail()}
            let web3Rinkeby = Web3.InfuraRinkebyWeb3()
            let keystoreManager = KeystoreManager.init([keystoreV3])
            web3Rinkeby.addKeystoreManager(keystoreManager)
            guard case .success(let gasPriceRinkeby) = web3Rinkeby.eth.getGasPrice() else {return}
            let sendToAddress = EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B")!
            guard let intermediate = web3Rinkeby.eth.sendETH(to: sendToAddress, amount: "0.001") else {return XCTFail()}
            var options = Web3Options.defaultOptions()
            options.from = keystoreV3.addresses?.first
            options.gasPrice = gasPriceRinkeby
            let result = try intermediate.sendPromise(options: options).wait()
            print(result)
        } catch {
            print(error)
        }
    }
    
    func getKeystoreData() -> Data? {
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.path(forResource: "key", ofType: "json") else {return nil}
        guard let data = NSData(contentsOfFile: path) else {return nil}
        return data as Data
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
