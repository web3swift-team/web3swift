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

class web3swiftTransactionsTests: XCTestCase {
    
    func testTransaction() throws {
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
    
    func testEthSendExampleAndGetTransactionReceiptAndDetails() {
        do {
            let web3 = try Web3.new(URL.init(string: "http://127.0.0.1:8545")!)
            let sendToAddress = EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901")!
            let allAddresses = try web3.eth.getAccounts()
            let contract = web3.contract(Web3.Utils.coldWalletABI, at: sendToAddress, abiVersion: 2)
            let value = Web3.Utils.parseToBigUInt("1.0", units: .eth)
            let from = allAddresses[0]
            let writeTX = contract!.write("fallback")!
            writeTX.transactionOptions.from = from
            writeTX.transactionOptions.value = value
            writeTX.transactionOptions.gasLimit = .manual(78423)
            let result = try writeTX.sendPromise(password: "").wait()
            let txHash = result.hash
            print("Transaction with hash " + txHash)
            
            Thread.sleep(forTimeInterval: 1.0)
            
            let receipt = try web3.eth.getTransactionReceipt(txHash)
            print(receipt)
            XCTAssert(receipt.status == .ok)
            
            switch receipt.status {
            case .notYetProcessed:
                return
            default:
                break
            }
            
            let details = try web3.eth.getTransactionDetails(txHash)
            print(details)
            
            XCTAssert(details.transaction.gasLimit == BigUInt(78423))
        } catch Web3Error.nodeError(let descr) {
            guard descr == "insufficient funds for gas * price + value" else {return XCTFail()}
        } catch {
            print(error)
            XCTFail()
        }
    }
    
    func testGenerateDummyKeystore() throws {
        let keystore = try! EthereumKeystoreV3.init(password: "web3swift")
        let dump = try! keystore!.serialize()
        let jsonString = String.init(data: dump!, encoding: .ascii)
        print(jsonString!)
    }
}
