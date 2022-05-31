//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import XCTest

@testable import web3swift

// MARK: Works only with network connection
class InfuraTests: XCTestCase {
    
    func testGetBalance() async throws {
        do {
            let web3 = await Web3.InfuraMainnetWeb3(accessToken: Constants.infuraToken)
            let address = EthereumAddress("0xd61b5ca425F8C8775882d4defefC68A6979DBbce")!
            let balance = try await web3.eth.getBalance(for: address)
            let balString = Web3.Utils.formatToEthereumUnits(balance, toUnits: .eth, decimals: 3)
            print(balString!)
        } catch {
            XCTFail()
        }
    }
    
    func testGetBlockByHash() async throws {
        let web3 = await Web3.InfuraMainnetWeb3(accessToken: Constants.infuraToken)
        let result = try await web3.eth.block(by: "0x6d05ba24da6b7a1af22dc6cc2a1fe42f58b2a5ea4c406b19c8cf672ed8ec0695", fullTransactions: false)

        print(result)
    }
    
    func testGetBlockByNumber1() async throws {
        let web3 = await Web3.InfuraMainnetWeb3(accessToken: Constants.infuraToken)
        let result = try await web3.eth.block(by: .latest, fullTransactions: false)
        print(result)
    }
    
    func testGetBlockByNumber2() async throws {
        let web3 = await Web3.InfuraMainnetWeb3(accessToken: Constants.infuraToken)
        let result = try await web3.eth.block(by: .exact(5184323), fullTransactions: true)
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
    
    func testGetBlockByNumber3() async throws {
        do {
            let web3 = await Web3.InfuraMainnetWeb3(accessToken: Constants.infuraToken)
            let _ = try await web3.eth.block(by: .exact(1000000000), fullTransactions: true)
            XCTFail()
        } catch {
            
        }
    }
    
    func testGasPrice() async throws {
        let web3 = await Web3.InfuraMainnetWeb3(accessToken: Constants.infuraToken)
        let response = try await web3.eth.gasPrice()
        print(response)
    }
    
    func testGetIndexedEventsPromise() async throws {
        let jsonString = "[{\"constant\":true,\"inputs\":[],\"name\":\"name\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"approve\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"totalSupply\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_from\",\"type\":\"address\"},{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transferFrom\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"decimals\",\"outputs\":[{\"name\":\"\",\"type\":\"uint8\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"version\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"}],\"name\":\"balanceOf\",\"outputs\":[{\"name\":\"balance\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"symbol\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transfer\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"},{\"name\":\"_extraData\",\"type\":\"bytes\"}],\"name\":\"approveAndCall\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"},{\"name\":\"_spender\",\"type\":\"address\"}],\"name\":\"allowance\",\"outputs\":[{\"name\":\"remaining\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"inputs\":[{\"name\":\"_initialAmount\",\"type\":\"uint256\"},{\"name\":\"_tokenName\",\"type\":\"string\"},{\"name\":\"_decimalUnits\",\"type\":\"uint8\"},{\"name\":\"_tokenSymbol\",\"type\":\"string\"}],\"type\":\"constructor\"},{\"payable\":false,\"type\":\"fallback\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_from\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_to\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Transfer\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_owner\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_spender\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Approval\",\"type\":\"event\"},]"
        let web3 = await Web3.InfuraMainnetWeb3(accessToken: Constants.infuraToken)
        let contract = web3.contract(jsonString, at: nil, abiVersion: 2)
        var filter = EventFilter()
        filter.fromBlock = .blockNumber(UInt(5200120))
        filter.toBlock = .blockNumber(UInt(5200120))
        filter.addresses = [EthereumAddress("0x53066cddbc0099eb6c96785d9b3df2aaeede5da3")!]
        filter.parameterFilters = [([EthereumAddress("0xefdcf2c36f3756ce7247628afdb632fa4ee12ec5")!] as [EventFilterable]), (nil as [EventFilterable]?)]
        let eventParserResult = try await contract!.getIndexedEvents(eventName: "Transfer", filter: filter, joinWithReceipts: true)
        print(eventParserResult)
        XCTAssert(eventParserResult.count == 2)
        XCTAssert(eventParserResult.first?.transactionReceipt != nil)
        XCTAssert(eventParserResult.first?.eventLog != nil)
    }
    
//    func testEventParsingBlockByNumberPromise() throws {
//        let jsonString = "[{\"constant\":true,\"inputs\":[],\"name\":\"name\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"approve\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"totalSupply\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_from\",\"type\":\"address\"},{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transferFrom\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"decimals\",\"outputs\":[{\"name\":\"\",\"type\":\"uint8\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"version\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"}],\"name\":\"balanceOf\",\"outputs\":[{\"name\":\"balance\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"symbol\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transfer\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"},{\"name\":\"_extraData\",\"type\":\"bytes\"}],\"name\":\"approveAndCall\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"},{\"name\":\"_spender\",\"type\":\"address\"}],\"name\":\"allowance\",\"outputs\":[{\"name\":\"remaining\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"inputs\":[{\"name\":\"_initialAmount\",\"type\":\"uint256\"},{\"name\":\"_tokenName\",\"type\":\"string\"},{\"name\":\"_decimalUnits\",\"type\":\"uint8\"},{\"name\":\"_tokenSymbol\",\"type\":\"string\"}],\"type\":\"constructor\"},{\"payable\":false,\"type\":\"fallback\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_from\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_to\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Transfer\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_owner\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_spender\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Approval\",\"type\":\"event\"},]"
//        let web3 = Web3.InfuraMainnetWeb3(accessToken: Constants.infuraToken)
//        let contract = web3.contract(jsonString, at: nil, abiVersion: 2)
//        var filter = EventFilter()
//        filter.addresses = [EthereumAddress("0x53066cddbc0099eb6c96785d9b3df2aaeede5da3")!]
//        filter.parameterFilters = [([EthereumAddress("0xefdcf2c36f3756ce7247628afdb632fa4ee12ec5")!] as [EventFilterable]), ([EthereumAddress("0xd5395c132c791a7f46fa8fc27f0ab6bacd824484")!] as [EventFilterable])]
//        guard let eventParser = contract?.createEventParser("Transfer", filter: filter) else {return XCTFail()}
//        let present = try eventParser.parseBlockByNumberPromise(UInt64(5200120)).wait()
//        print(present)
//        XCTAssert(present.count == 1)
//    }
//    
//    func testUserCaseEventParsing() throws {
//        let contractAddress = EthereumAddress("0x7ff546aaccd379d2d1f241e1d29cdd61d4d50778")
//        let jsonString = "[{\"constant\":false,\"inputs\":[{\"name\":\"_id\",\"type\":\"string\"}],\"name\":\"deposit\",\"outputs\":[],\"payable\":true,\"stateMutability\":\"payable\",\"type\":\"function\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_from\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_id\",\"type\":\"string\"},{\"indexed\":true,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Deposit\",\"type\":\"event\"}]"
//        let web3 = Web3.InfuraRinkebyWeb3(accessToken: Constants.infuraToken)
//        let contract = web3.contract(jsonString, at: contractAddress, abiVersion: 2)
//        guard let eventParser = contract?.createEventParser("Deposit", filter: nil) else {return XCTFail()}
//        let pres = try eventParser.parseBlockByNumber(UInt64(2138657))
//        XCTAssert(pres.count == 1)
//    }
}
