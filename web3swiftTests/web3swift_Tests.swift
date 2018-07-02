//
//  web3swiftTests.swift
//  web3swiftTests
//
//  Created by Alexander Vlasov on 04.12.2017.
//  Copyright © 2017 Alexander Vlasov. All rights reserved.
//


import XCTest
import CryptoSwift
import BigInt
import Result
import secp256k1_ios


@testable import web3swift_iOS

class web3swiftTests: XCTestCase {
    
    func testBitFunctions () {
        let data = Data([0xf0, 0x02, 0x03])
        let firstBit = data.bitsInRange(0,1)
        XCTAssert(firstBit == 1)
        let first4bits = data.bitsInRange(0,4)
        XCTAssert(first4bits == 0x0f)
    }
    
    func testCombiningPublicKeys() {
        let priv1 = Data(repeating: 0x01, count: 32)
        let pub1 = Web3.Utils.privateToPublic(priv1, compressed: true)!
        let priv2 = Data(repeating: 0x02, count: 32)
        let pub2 = Web3.Utils.privateToPublic(priv2, compressed: true)!
        let combined = SECP256K1.combineSerializedPublicKeys(keys: [pub1, pub2], outputCompressed: true)
        let compinedPriv = Data(repeating: 0x03, count: 32)
        let compinedPub = Web3.Utils.privateToPublic(compinedPriv, compressed: true)
        XCTAssert(compinedPub == combined)
    }
    
    func testChecksumAddress() {
        let input = "0xfb6916095ca1df60bb79ce92ce3ea74c37c5d359"
        let output = EthereumAddress.toChecksumAddress(input);
        XCTAssert(output == "0xfB6916095ca1df60bB79Ce92cE3Ea74c37c5d359", "Failed to checksum address")
    }
    
    func testChecksumAddressParsing() {
        let input = "0xfB6916095ca1df60bB79Ce92cE3Ea74c37c5d359"
        let addr = EthereumAddress(input);
        XCTAssert(addr != nil);
        let invalidInput = "0xfb6916095ca1df60bB79Ce92cE3Ea74c37c5d359"
        let invalidAddr = EthereumAddress(invalidInput);
        XCTAssert(invalidAddr == nil);
    }
    
    func testBigUIntFromHex() {
        let hexRepresentation = "0x1c31de57e49fc00".stripHexPrefix()
        let biguint = BigUInt(hexRepresentation, radix: 16)!
        XCTAssert(biguint == BigUInt("126978086000000000"))
    }
    
    func testBloom() {
        let positive = [
                "testtest",
                "test",
                "hallo",
                "other",
            ]
        let negative = [
                "tes",
                "lo",
            ]
        var bloom = EthereumBloomFilter()
        for str in positive {
            let data = str.data(using: .utf8)!
            let oldBytes = bloom.bytes
            bloom.add(BigUInt(data))
            let newBytes = bloom.bytes
            if (newBytes != oldBytes) {
                print("Added new bits")
            }
        }
        for str in positive {
            let data = str.data(using: .utf8)!
            XCTAssert(bloom.lookup(data), "Failed")
        }
        for str in negative {
            let data = str.data(using: .utf8)!
            XCTAssert(bloom.lookup(data) == false, "Failed")
        }
    }

    func testMakePrivateKey()
    {
        let privKey = SECP256K1.generatePrivateKey()
        XCTAssert(privKey != nil, "Failed to create new private key")
    }

    
//    func testConcurrenctGetTransactionCount()
//    {
//        let semaphore = DispatchSemaphore(value: 0)
//        var fail = true;
//        let web3 = Web3.InfuraMainnetWeb3()
//        let address = EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B")!
//        let callback = { (res: Result<AnyObject, Web3Error>) -> () in
//            switch res {
//            case .success(let result):
//                print(result)
//                fail = false
//            case .failure(let error):
//                print(error)
//                XCTFail()
//                fatalError()
//            }
//            semaphore.signal()
//        }
//        web3.eth.getTransactionCount(address: address, onBlock: "latest", callback: callback, queue: web3.queue) // queue should be .main here, but can not test in this case with a simple semaphore (getting a deadlock)
//        let _ = semaphore.wait(timeout: .distantFuture)
//        XCTAssert(!fail)
//    }
//
//    func testGetAllTokenBalances()
//    {
//        //        let semaphore = DispatchSemaphore(value: 0)
//        let url = URL.init(string: "https://raw.githubusercontent.com/kvhnuke/etherwallet/mercury/app/scripts/tokens/ethTokens.json")
//        let tokensData = try! Data.init(contentsOf: url!)
//        let tokensJSON = try! JSONSerialization.jsonObject(with: tokensData, options: []) as! [[String: Any]]
//        let jsonString = "[{\"constant\":true,\"inputs\":[],\"name\":\"name\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"approve\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"totalSupply\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_from\",\"type\":\"address\"},{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transferFrom\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"decimals\",\"outputs\":[{\"name\":\"\",\"type\":\"uint8\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"version\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"}],\"name\":\"balanceOf\",\"outputs\":[{\"name\":\"balance\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"symbol\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transfer\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"},{\"name\":\"_extraData\",\"type\":\"bytes\"}],\"name\":\"approveAndCall\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"},{\"name\":\"_spender\",\"type\":\"address\"}],\"name\":\"allowance\",\"outputs\":[{\"name\":\"remaining\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"inputs\":[{\"name\":\"_initialAmount\",\"type\":\"uint256\"},{\"name\":\"_tokenName\",\"type\":\"string\"},{\"name\":\"_decimalUnits\",\"type\":\"uint8\"},{\"name\":\"_tokenSymbol\",\"type\":\"string\"}],\"type\":\"constructor\"},{\"payable\":false,\"type\":\"fallback\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_from\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_to\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Transfer\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_owner\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_spender\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Approval\",\"type\":\"event\"},]"
//        let web3 = Web3.InfuraMainnetWeb3()
//        let userAddress = EthereumAddress("0xc011bf81e3f88931cf331856e45fab6b6450e54c")!
//        var expected = tokensJSON.count
//        print(String(expected) + " tokens to update")
//        let semaphore = DispatchSemaphore(value: 0)
//        for token in tokensJSON {
//            let tokenSymbol = token["symbol"] as! String
//            let tokenAddress = EthereumAddress(token["address"] as! String)
//            let contract = web3.contract(jsonString, at: tokenAddress, abiVersion: 2)
//            XCTAssert(contract != nil, "Failed to create ERC20 contract from ABI")
//            var options = Web3Options.defaultOptions()
//            options.from = userAddress
//            let parameters = [userAddress] as [AnyObject]
//            let transactionIntermediate = contract?.method("balanceOf", parameters:parameters, options: options)
//            let callback = { (res: Result<AnyObject, Web3Error>) -> () in
//                switch res {
//                case .success(let balanceResult):
//                    guard let result = balanceResult as? [String: Any] else {
//                        XCTFail()
//                        break
//                    }
//                    guard let bal = result["balance"] as? BigUInt else {
//                        XCTFail()
//                        break
//                    }
//                    print("Balance of " + tokenSymbol + " is " + String(bal))
//                case .failure(let error):
//                    print(error)
//                    XCTFail()
////                    fatalError()
//                }
//                OperationQueue.current?.underlyingQueue?.async {
//                    expected = expected - 1
////                    print(String(expected) + " tokens left to update")
//                    if expected == 0 {
//                        semaphore.signal()
//                    }
//                }
//
//            }
//            transactionIntermediate?.call(options: options, onBlock: "latest", callback: callback, queue: web3.queue)
//        }
//        let _ = semaphore.wait(timeout: .distantFuture)
//    }
//
//    func testGetAllTokenNames()
//    {
//        //        let semaphore = DispatchSemaphore(value: 0)
//        let url = URL.init(string: "https://raw.githubusercontent.com/kvhnuke/etherwallet/mercury/app/scripts/tokens/ethTokens.json")
//        let tokensData = try! Data.init(contentsOf: url!)
//        let tokensJSON = try! JSONSerialization.jsonObject(with: tokensData, options: []) as! [[String: Any]]
//        let jsonString = "[{\"constant\":true,\"inputs\":[],\"name\":\"name\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"approve\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"totalSupply\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_from\",\"type\":\"address\"},{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transferFrom\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"decimals\",\"outputs\":[{\"name\":\"\",\"type\":\"uint8\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"version\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"}],\"name\":\"balanceOf\",\"outputs\":[{\"name\":\"balance\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"symbol\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transfer\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"},{\"name\":\"_extraData\",\"type\":\"bytes\"}],\"name\":\"approveAndCall\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"},{\"name\":\"_spender\",\"type\":\"address\"}],\"name\":\"allowance\",\"outputs\":[{\"name\":\"remaining\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"inputs\":[{\"name\":\"_initialAmount\",\"type\":\"uint256\"},{\"name\":\"_tokenName\",\"type\":\"string\"},{\"name\":\"_decimalUnits\",\"type\":\"uint8\"},{\"name\":\"_tokenSymbol\",\"type\":\"string\"}],\"type\":\"constructor\"},{\"payable\":false,\"type\":\"fallback\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_from\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_to\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Transfer\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_owner\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_spender\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Approval\",\"type\":\"event\"},]"
//        let web3 = Web3.InfuraMainnetWeb3()
//        let userAddress = EthereumAddress("0xc011bf81e3f88931cf331856e45fab6b6450e54c")!
//        var expected = tokensJSON.count
//        print(String(expected) + " tokens to update")
//        let semaphore = DispatchSemaphore(value: 0)
//        for token in tokensJSON {
//            let tokenSymbol = token["symbol"] as! String
//            let tokenAddress = EthereumAddress(token["address"] as! String)
//            let contract = web3.contract(jsonString, at: tokenAddress, abiVersion: 2)
//            XCTAssert(contract != nil, "Failed to create ERC20 contract from ABI")
//            var options = Web3Options.defaultOptions()
//            options.from = userAddress
//            let transactionIntermediate = contract?.method("name", options: options)
//            let callback = { (res: Result<AnyObject, Web3Error>) -> () in
//                switch res {
//                case .success(let balanceResult):
//                    guard let result = balanceResult as? [String: Any] else {
//                        XCTFail()
//                        break
//                    }
//                    guard let bal = result["0"] as? String else {
//                        XCTFail()
//                        break
//                    }
//                    print("Name of " + tokenSymbol + " is " + String(bal))
//                case .failure(let error):
//                    print(error)
//                    print("Name of " + tokenSymbol + " is undefined")
////                    XCTFail()
////                    fatalError()
//                }
//                OperationQueue.current?.underlyingQueue?.async {
//                    expected = expected - 1
//                    if expected == 0 {
//                        semaphore.signal()
//                    }
//                }
//
//            }
//            transactionIntermediate?.call(options: options, onBlock: "latest", callback: callback, queue: web3.queue)
//        }
//        let _ = semaphore.wait(timeout: .distantFuture)
//    }
//
//    func testEthSendOperationsExample() {
//        let semaphore = DispatchSemaphore(value: 0)
//        var fail = true;
//        let web3 = Web3.InfuraRinkebyWeb3()
//        let sendToAddress = EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B")!
//        let tempKeystore = try! EthereumKeystoreV3(password: "")
//        let keystoreManager = KeystoreManager([tempKeystore!])
//        web3.addKeystoreManager(keystoreManager)
//        let contract = web3.contract(Web3.Utils.coldWalletABI, at: sendToAddress, abiVersion: 2)
//        var options = Web3Options.defaultOptions()
//        options.value = Web3.Utils.parseToBigUInt("1.0", units: .eth)
//        options.from = keystoreManager.addresses?.first
//        let intermediate = contract?.method("fallback", options: options)
//        let callback = { (res: Result<AnyObject, Web3Error>) -> () in
//            switch res {
//            case .success(let result):
//                print(result)
//                fail = false
//            case .failure(let error):
//                print(error)
//                if case .nodeError(_) = error {
//                    fail = false
//                    break
//                }
//                XCTFail()
////                fatalError()
//            }
//            semaphore.signal()
//        }
//        intermediate?.send(password: "", options: options, callback: callback, queue: web3.queue)
//
//        let _ = semaphore.wait(timeout: .distantFuture)
//        XCTAssertTrue(!fail)
//    }
    
    func testUserCaseEventParsing() {
        let contractAddress = EthereumAddress("0x7ff546aaccd379d2d1f241e1d29cdd61d4d50778")
        let jsonString = "[{\"constant\":false,\"inputs\":[{\"name\":\"_id\",\"type\":\"string\"}],\"name\":\"deposit\",\"outputs\":[],\"payable\":true,\"stateMutability\":\"payable\",\"type\":\"function\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_from\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_id\",\"type\":\"string\"},{\"indexed\":true,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Deposit\",\"type\":\"event\"}]"
        let web3 = Web3.InfuraRinkebyWeb3()
        let contract = web3.contract(jsonString, at: contractAddress, abiVersion: 2)
        guard let eventParser = contract?.createEventParser("Deposit", filter: nil) else {return XCTFail()}
        let present = eventParser.parseBlockByNumber(UInt64(2138657))
        guard case .success(let pres) = present else {return XCTFail()}
        print(pres)
        XCTAssert(pres.count == 1)
    }
    
    func testIBANcreation() {
        let iban = "XE7338O073KYGTWWZN0F2WZ0R8PX5ZPPZS"
        let native = Web3.Utils.Iban(iban)
        XCTAssert(native != nil)
        let expectedAddress = "0x00c5496aEe77C1bA1f0854206A26DdA82a81D6D8"
        let createdAddress = native?.toEthereumAddress()?.address
        XCTAssert(createdAddress == expectedAddress)
        
        let address = EthereumAddress("0x03c5496aee77c1ba1f0854206a26dda82a81d6d8")!
        let fromAddress = Web3.Utils.Iban(address)
        let ibn = fromAddress?.iban
        XCTAssert(ibn == "XE83FUTTUNPK7WZJSGGCWVEBARQWQ8YML4")
    }
    
    func testGenericRPCresponse() {
        let hex = "0x1"
        let rpcResponse = JSONRPCresponse(id: 1, jsonrpc: "2.0", result: hex, error: nil)
        let value: BigUInt? = rpcResponse.getValue()
        XCTAssert(value == 1)
    }
    
    func testPublicMappingsAccess() {
        do {
            let jsonString = "[{\"constant\":true,\"inputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"name\":\"users\",\"outputs\":[{\"name\":\"name\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"\",\"type\":\"address\"}],\"name\":\"userDeviceCount\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"totalUsers\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"}]"
            let web3 = Web3.InfuraRinkebyWeb3()
            guard let addr = EthereumAddress("0xdef61132a0c1259464b19e4590e33666aae38574") else {return XCTFail()}
            let contract = web3.contract(jsonString, at: addr, abiVersion: 2)
            XCTAssert(contract != nil)
            let allMethods = contract!.contract.allMethods
            let userDeviceCount = try contract!.method("userDeviceCount", parameters: [addr as AnyObject], options: nil)?.callPromise().wait()
            print(userDeviceCount)
            let totalUsers = try contract!.method("totalUsers", parameters: [], options: nil)?.callPromise().wait()
            print(totalUsers)
            let user = try contract!.method("users", parameters: [0 as AnyObject], options: nil)?.callPromise().wait()
            print(user)
            print(allMethods)
        } catch {
            print(error)
        }
    }

    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}

