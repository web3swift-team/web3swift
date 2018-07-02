//
//  web3swiftTransactionsTests.swift
//  web3swift-iOS_Tests
//
//  Created by Георгий Фесенко on 02/07/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import XCTest
import BigInt

@testable import web3swift_iOS


class web3swiftTransactionsTests: XCTestCase {
    
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
    
    
    
}
