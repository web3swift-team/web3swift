//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import XCTest
import PromiseKit
import BigInt
//import EthereumAddress

@testable import web3swift

class web3swift_promises_Tests: XCTestCase {
    var urlSession : URLSession?
    
    func testGetBalancePromise() {
        do {
            let web3 = Web3.InfuraMainnetWeb3()
            let balance = try web3.eth.getBalancePromise(address: "0xe22b8979739D724343bd002F9f432F5990879901").wait()
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
            let sendToAddress = EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901")
            let tempKeystore = try! EthereumKeystoreV3(password: "")
            let keystoreManager = KeystoreManager([tempKeystore!])
            web3.addKeystoreManager(keystoreManager)
            let contract = web3.contract(Web3.Utils.coldWalletABI, at: sendToAddress, abiVersion: 2)
            guard let writeTX = contract?.write("fallback") else {return XCTFail()}
            writeTX.transactionOptions.from = tempKeystore!.addresses?.first
            writeTX.transactionOptions.value = BigUInt("1.0", .eth)
            let estimate = try writeTX.estimateGasPromise().wait()
            print(estimate)
            XCTAssert(estimate == 21000)
        } catch{
            print(error)
            XCTFail()
        }
    }
    
    func testEstimateGasFixPromise() {
        do {
            let web3 = Web3.InfuraMainnetWeb3()
            let tempKeystore = try! EthereumKeystoreV3(password: "")
            let keystoreManager = KeystoreManager([tempKeystore!])
            web3.addKeystoreManager(keystoreManager)
            
            guard let contractAddress = EthereumAddress("0x28a958cD020efeA3734a0bb36DDdc5F9B872cEa8"),
                let contract = web3.contract(Web3.Utils.estimateGasTestABI,
                                             at: contractAddress,
                                             abiVersion: 2) else {
                                                return
            }
            
            var options = TransactionOptions.defaultOptions
            let fromAddress = tempKeystore!.addresses?.first
            options.from = fromAddress
            
            let amount1 = Web3.Utils.parseToBigUInt("0.000000000000000001", units: .eth) // 1 wei
            
            guard let tx1 = contract.write("test",
                                           parameters: [amount1] as [AnyObject],
                                           extraData: Data(),
                                           transactionOptions: options) else {
                                            return
            }
            let estimate1 = try tx1.estimateGasPromise().wait()
            print(estimate1)
            
            let amount2 = Web3.Utils.parseToBigUInt("0.00000005", units: .eth) // 50 gwei
            guard let tx2 = contract.write("test",
                                           parameters: [amount2] as [AnyObject],
                                           extraData: Data(),
                                           transactionOptions: options) else {
                                            return
            }
            let estimate2 = try tx2.estimateGasPromise().wait()
            print(estimate2)
            XCTAssert(estimate2 - estimate1 <= 22000)
        } catch {
            print(error)
            XCTFail()
        }
    }
    
//    func testSendETHPromise() {
//        do {
//            guard let keystoreData = getKeystoreData() else {return}
//            guard let keystoreV3 = EthereumKeystoreV3.init(keystoreData) else {return XCTFail()}
//            let web3Rinkeby = Web3.InfuraRinkebyWeb3()
//            let keystoreManager = KeystoreManager.init([keystoreV3])
//            web3Rinkeby.addKeystoreManager(keystoreManager)
//            let gasPriceRinkeby = try web3Rinkeby.eth.getGasPrice()
//            let sendToAddress = EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901")!
//            guard let writeTX = web3Rinkeby.eth.sendETH(to: sendToAddress, amount: "0.001") else {return XCTFail()}
//            writeTX.transactionOptions.from = keystoreV3.addresses?.first
//            writeTX.transactionOptions.gasPrice = .manual(gasPriceRinkeby)
//            let result = try writeTX.sendPromise().wait()
//            print(result)
//        } catch {
//            print(error)
//            XCTFail()
//        }
//    }
    
    func testERC20tokenBalancePromise() {
        do {
            let web3 = Web3.InfuraMainnetWeb3()
            let contract = web3.contract(Web3.Utils.erc20ABI, at: EthereumAddress("0x8932404A197D84Ec3Ea55971AADE11cdA1dddff1")!, abiVersion: 2)
            let addressOfUser = EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901")!
            let tokenBalance = try contract!.read("balanceOf", parameters: [addressOfUser] as [AnyObject])!.callPromise().wait()
            guard let bal = tokenBalance["0"] as? BigUInt else {return XCTFail()}
            print(String(bal))
        } catch {
            print(error)
            XCTFail()
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
            XCTAssert(eventParserResult[0].eventLog != nil)
        }catch {
            print(error)
            XCTFail()
        }
    }
    
    func testEventParsingBlockByNumberPromise() {
        do {
            let jsonString = "[{\"constant\":true,\"inputs\":[],\"name\":\"name\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"approve\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"totalSupply\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_from\",\"type\":\"address\"},{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transferFrom\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"decimals\",\"outputs\":[{\"name\":\"\",\"type\":\"uint8\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"version\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"}],\"name\":\"balanceOf\",\"outputs\":[{\"name\":\"balance\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"symbol\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transfer\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"},{\"name\":\"_extraData\",\"type\":\"bytes\"}],\"name\":\"approveAndCall\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"},{\"name\":\"_spender\",\"type\":\"address\"}],\"name\":\"allowance\",\"outputs\":[{\"name\":\"remaining\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"inputs\":[{\"name\":\"_initialAmount\",\"type\":\"uint256\"},{\"name\":\"_tokenName\",\"type\":\"string\"},{\"name\":\"_decimalUnits\",\"type\":\"uint8\"},{\"name\":\"_tokenSymbol\",\"type\":\"string\"}],\"type\":\"constructor\"},{\"payable\":false,\"type\":\"fallback\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_from\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_to\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Transfer\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_owner\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_spender\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Approval\",\"type\":\"event\"},]"
            let web3 = Web3.InfuraMainnetWeb3()
            let contract = web3.contract(jsonString, at: nil, abiVersion: 2)
            var filter = EventFilter()
            filter.addresses = [EthereumAddress("0x53066cddbc0099eb6c96785d9b3df2aaeede5da3")!]
            filter.parameterFilters = [([EthereumAddress("0xefdcf2c36f3756ce7247628afdb632fa4ee12ec5")!] as [EventFilterable]), ([EthereumAddress("0xd5395c132c791a7f46fa8fc27f0ab6bacd824484")!] as [EventFilterable])]
            guard let eventParser = contract?.createEventParser("Transfer", filter: filter) else {return XCTFail()}
            let present = try eventParser.parseBlockByNumberPromise(UInt64(5200120)).wait()
            print(present)
            XCTAssert(present.count == 1)
        } catch{
            print(error)
            XCTFail()
        }
    }
    
    func getKeystoreData() -> Data? {
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.path(forResource: "key", ofType: "json") else {return nil}
        guard let data = NSData(contentsOfFile: path) else {return nil}
        return data as Data
    }
    
//    func testRegenerateKeystore() {
//        let data = getKeystoreData()!
//        let ks = EthereumKeystoreV3.init(data)!
//        let _ = try! ks.UNSAFE_getPrivateKeyData(password: "BANKEXFOUNDATION", account: ks.addresses!.first!)
//        try! ks.regenerate(oldPassword: "BANKEXFOUNDATION", newPassword: "web3swift")
//        let newData = try! ks.serialize()
//        let bundle = Bundle(for: type(of: self))
//        guard let path = bundle.path(forResource: "key", ofType: "json") else {return}
//        let url = URL.init(fileURLWithPath: path)
//        try! newData?.write(to: url)
//    }
}


