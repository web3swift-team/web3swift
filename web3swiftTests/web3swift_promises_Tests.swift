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
            let esimate = try intermediate!.estimateGasPromise(options: nil).wait()
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
    
    func testERC20tokenBalancePromise() {
        do {
            let web3 = Web3.InfuraMainnetWeb3()
            let contract = web3.contract(Web3.Utils.erc20ABI, at: EthereumAddress("0x45245bc59219eeaaf6cd3f382e078a461ff9de7b")!, abiVersion: 2)
            let addressOfUser = EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B")!
            let tokenBalance = try contract!.method("balanceOf", parameters: [addressOfUser] as [AnyObject], options: nil)!.callPromise(options: nil).wait()
            guard let bal = tokenBalance["0"] as? BigUInt else {return XCTFail()}
            print(String(bal))
        } catch {
            print(error)
        }
    }
    
    func testGetIndexedEventsPromise() {
        do {
            let jsonString = "[{\"constant\":true,\"inputs\":[],\"name\":\"name\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"approve\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"totalSupply\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_from\",\"type\":\"address\"},{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transferFrom\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"decimals\",\"outputs\":[{\"name\":\"\",\"type\":\"uint8\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"version\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"}],\"name\":\"balanceOf\",\"outputs\":[{\"name\":\"balance\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"symbol\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transfer\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"},{\"name\":\"_extraData\",\"type\":\"bytes\"}],\"name\":\"approveAndCall\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"},{\"name\":\"_spender\",\"type\":\"address\"}],\"name\":\"allowance\",\"outputs\":[{\"name\":\"remaining\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"inputs\":[{\"name\":\"_initialAmount\",\"type\":\"uint256\"},{\"name\":\"_tokenName\",\"type\":\"string\"},{\"name\":\"_decimalUnits\",\"type\":\"uint8\"},{\"name\":\"_tokenSymbol\",\"type\":\"string\"}],\"type\":\"constructor\"},{\"payable\":false,\"type\":\"fallback\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_from\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_to\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Transfer\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_owner\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_spender\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Approval\",\"type\":\"event\"},]"
            let web3 = Web3.InfuraMainnetWeb3()
            let contract = web3.contract(jsonString, at: nil, abiVersion: 2)
            var filter = EventFilter()
            filter.fromBlock = .blockNumber(UInt64(5200120))
            filter.toBlock = .blockNumber(UInt64(5200120))
            filter.addresses = [EthereumAddress("0x53066cddbc0099eb6c96785d9b3df2aaeede5da3")!]
            filter.parameterFilters = [([EthereumAddress("0xefdcf2c36f3756ce7247628afdb632fa4ee12ec5")!] as [EventFilterable]), (nil as [EventFilterable]?)]
            let eventParserResult = try contract!.getIndexedEventsPromise(eventName: "Transfer", filter: filter, joinWithReceipts: true).wait()
            print(eventParserResult)
            XCTAssert(eventParserResult.count == 2)
            XCTAssert(eventParserResult[0].transactionReceipt != nil)
        }catch {
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
