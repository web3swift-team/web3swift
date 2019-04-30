//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import XCTest
import CryptoSwift
import BigInt
//import EthereumAddress

@testable import web3swift

class web3swift_transactions_Tests: XCTestCase {
    
    func testTransaction() {
        do {
            var transaction = EthereumTransaction(nonce: BigUInt(9),
                                                  gasPrice: BigUInt("20000000000"),
                                                  gasLimit: BigUInt(21000),
                                                  to: EthereumAddress("0x3535353535353535353535353535353535353535")!,
                                                  value: BigUInt("1000000000000000000"),
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
        do {
            let web3 = Web3.InfuraMainnetWeb3()
            let sendToAddress = EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901")!
            let tempKeystore = try! EthereumKeystoreV3(password: "")
            let keystoreManager = KeystoreManager([tempKeystore!])
            web3.addKeystoreManager(keystoreManager)
            let contract = web3.contract(Web3.Utils.coldWalletABI, at: sendToAddress, abiVersion: 2)
            let value = Web3.Utils.parseToBigUInt("1.0", units: .eth)
            let from = keystoreManager.addresses?.first
            let writeTX = contract!.write("fallback")!
            writeTX.transactionOptions.from = from
            writeTX.transactionOptions.value = value
            let _ = try writeTX.sendPromise(password: "").wait()
        } catch Web3Error.nodeError(let descr) {
            guard descr == "insufficient funds for gas * price + value" else {return XCTFail()}
        } catch {
            print(error)
            XCTFail()
        }
    }
    
    func testTransactionReceipt() throws {
        let web3 = Web3.InfuraMainnetWeb3()
        let response = try web3.eth.getTransactionReceipt("0x83b2433606779fd756417a863f26707cf6d7b2b55f5d744a39ecddb8ca01056e")
        XCTAssert(response.status == .ok)
    }
    
    func testTransactionDetails() throws {
        let web3 = Web3.InfuraMainnetWeb3()
        let response = try web3.eth.getTransactionDetails("0x127519412cefd773b952a5413a4467e9119654f59a34eca309c187bd9f3a195a")
        XCTAssert(response.transaction.gasLimit == BigUInt(78423))
    }
    
    
    func getKeystoreData() -> Data? {
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.path(forResource: "key", ofType: "json") else {return nil}
        guard let data = NSData(contentsOfFile: path) else {return nil}
        return data as Data
    }
    
    func testGenerateDummyKeystore() {
        let keystore = try! EthereumKeystoreV3.init(password: "web3swift")
        let dump = try! keystore!.serialize()
        let jsonString = String.init(data: dump!, encoding: .ascii)
        print(jsonString!)
    }
}
