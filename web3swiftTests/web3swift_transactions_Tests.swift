//
//  web3swiftTransactionsTests.swift
//  web3swift-iOS_Tests
//
//  Created by Георгий Фесенко on 02/07/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import XCTest
import CryptoSwift
import BigInt
import Result
import secp256k1_ios

@testable import web3swift_iOS

class web3swift_transactions_Tests: XCTestCase {
    
    func testTransaction() {
        do {
            var transaction = EthereumTransaction(nonce: BigUInt(9),
                                                  gasPrice: BigUInt(20000000000),
                                                  gasLimit: BigUInt(21000),
                                                  to: EthereumAddress("0x3535353535353535353535353535353535353535")!,
                                                  value: BigUInt("1000000000000000000")!,
                                                  data: Data(),
                                                  v: BigUInt(0),
                                                  r: BigUInt(0),
                                                  s: BigUInt(0))
            let privateKeyData = Data.fromHex("0x4646464646464646464646464646464646464646464646464646464646464646")!
            let publicKey = Web3.Utils.privateToPublic(privateKeyData, compressed: false)
            let sender = Web3.Utils.publicToAddress(publicKey!)
            transaction.chainID = BigUInt(1)
            print(transaction)
            let hash = transaction.hashForSignature(chainID: BigUInt(1))
            let expectedHash = "0xdaf5a779ae972f972197303d7b574746c7ef83eadac0f2791ad23db92e4c8e53".stripHexPrefix()
            XCTAssert(hash!.toHexString() == expectedHash, "Transaction signature failed")
            try Web3Signer.EIP155Signer.sign(transaction: &transaction, privateKey: privateKeyData, useExtraEntropy: false)
            print(transaction)
            XCTAssert(transaction.v == UInt8(37), "Transaction signature failed")
            XCTAssert(sender == transaction.sender)
        }
        catch {
            print(error)
            XCTFail()
        }
    }
    
    func testEthSendExample() {
        let web3 = Web3.InfuraMainnetWeb3()
        let sendToAddress = EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B")!
        let tempKeystore = try! EthereumKeystoreV3(password: "")
        let keystoreManager = KeystoreManager([tempKeystore!])
        web3.addKeystoreManager(keystoreManager)
        let contract = web3.contract(Web3.Utils.coldWalletABI, at: sendToAddress, abiVersion: 2)
        var options = Web3Options.defaultOptions()
        options.value = Web3.Utils.parseToBigUInt("1.0", units: .eth)
        options.from = keystoreManager.addresses?.first
        let intermediate = contract?.method("fallback", options: options)
        guard let result = intermediate?.send(password: "") else {return XCTFail()}
        switch result {
        case .success(_):
            return XCTFail()
        case .failure(let error):
            print(error)
            guard case .nodeError(let descr) = error else {return XCTFail()}
            guard descr == "insufficient funds for gas * price + value" else {return XCTFail()}
        }
    }
    
    func testTransactionReceipt() {
        let web3 = Web3.InfuraMainnetWeb3()
        let result = web3.eth.getTransactionReceipt("0x83b2433606779fd756417a863f26707cf6d7b2b55f5d744a39ecddb8ca01056e")
        switch result {
        case .failure(let error):
            print(error)
            XCTFail()
        case .success(let response):
            print(response)
            XCTAssert(response.status == .ok)
        }
    }
    
    func testTransactionDetails() {
        let web3 = Web3.InfuraMainnetWeb3()
        let result = web3.eth.getTransactionDetails("0x127519412cefd773b952a5413a4467e9119654f59a34eca309c187bd9f3a195a")
        switch result {
        case .failure(let error):
            print(error)
            XCTFail()
        case .success(let response):
            print(response)
            XCTAssert(response.transaction.gasLimit == BigUInt(78423))
        }
    }
    
    
    func getKeystoreData() -> Data? {
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.path(forResource: "key", ofType: "json") else {return nil}
        guard let data = NSData(contentsOfFile: path) else {return nil}
        return data as Data
    }
    
    func testSendETH() {
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
        let result = intermediate.send(password: "BANKEXFOUNDATION", options: options)
        switch result {
        case .success(let res):
            print(res)
        case .failure(let error):
            print(error)
            XCTFail()
        }
    }
    
    func testTokenBalanceTransferOnMainNet() {
        // BKX TOKEN
        let web3 = Web3.InfuraMainnetWeb3()
        let coldWalletAddress = EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B")!
        let contractAddress = EthereumAddress("0x45245bc59219eeaaf6cd3f382e078a461ff9de7b")!
        var options = Web3Options()
        options.from = coldWalletAddress
        let tempKeystore = try! EthereumKeystoreV3(password: "")
        let keystoreManager = KeystoreManager([tempKeystore!])
        web3.addKeystoreManager(keystoreManager)
        let contract = web3.contract(Web3.Utils.erc20ABI, at: contractAddress, abiVersion: 2)!
        let bkxBalanceSend = contract.method("transfer", parameters: [coldWalletAddress, BigUInt(1)] as [AnyObject], options: options)!.call(options: nil)
        switch bkxBalanceSend {
        case .success(let result):
            print(result)
        case .failure(let error):
            print(error)
            XCTFail()
        }
    }
    
    func testTokenBalanceTransferOnMainNetUsingConvenience() {
        // BKX TOKEN
        let web3 = Web3.InfuraMainnetWeb3()
        let coldWalletAddress = EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B")!
        let contractAddress = EthereumAddress("0x45245bc59219eeaaf6cd3f382e078a461ff9de7b")!
        let tempKeystore = try! EthereumKeystoreV3(password: "")
        let keystoreManager = KeystoreManager([tempKeystore!])
        web3.addKeystoreManager(keystoreManager)
        let intermediate = web3.eth.sendERC20tokensWithNaturalUnits(tokenAddress:contractAddress, from: coldWalletAddress, to: coldWalletAddress, amount: "1.0")
        let gasEstimate = intermediate!.estimateGas(options: nil)
        switch gasEstimate {
        case .success(let result):
            print(result)
        case .failure(let error):
            print(error)
            XCTFail()
        }
        var options = Web3Options();
        options.gasLimit = gasEstimate.value!
        let bkxBalanceSend = intermediate!.call(options: options)
        switch bkxBalanceSend {
        case .success(let result):
            print(result)
        case .failure(let error):
            print(error)
            XCTFail()
        }
    }
}
