//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import XCTest
import CryptoSwift
import BigInt

@testable import web3swift

class web3swiftTransactionsTests: XCTestCase {

  // reference transaction json and rlp created with ethers.js
  // test a fallback legacy transaction chainID not part of the signing process
  func testLegacyFallbackEncoding() throws {
    let JSON = """
    {
      "nonce": "0x2a",
      "gasPrice": "0x40",
      "gasLimit": "0x0186a0",
      "to": "0xff00000000000000000000000000000000000002",
      "value": "0x3b9aca00",
      "data": "0xdeadbeef",
      "v": "0x1c",
      "r": "0xe3ce5fe71d1ffff0e8474a5b67f83f303abbaf3ab254780ebdd34e88dc4adfb8",
      "s": "0x4201dc12e81c9a6b5c024f535d4643279cbfd115c95a940aefbdb4d4557758a8"
    }
    """
    let RLP = "0xf8682a40830186a094ff00000000000000000000000000000000000002843b9aca0084deadbeef1ca0e3ce5fe71d1ffff0e8474a5b67f83f303abbaf3ab254780ebdd34e88dc4adfb8a04201dc12e81c9a6b5c024f535d4643279cbfd115c95a940aefbdb4d4557758a8"
    let expectedHash = "0x69bbbe14944547e1d5166968566232f67e2f1f9970ad59dd3f431860e247ca64"

    let expectedAddress = EthereumAddress("0xFD47742fE83cDc97883CD0c364B095fF4c03EE7F")!
    let jsonData = JSON.data(using: .utf8)!
    let rlpData = Data.fromHex(RLP)!

    do {
      let jsonTxn: EthereumTransaction = try JSONDecoder().decode(EthereumTransaction.self, from: jsonData)
      guard let rlpTxn = EthereumTransaction(rawValue: rlpData) else {
        return XCTFail("Decoding RLP encoded transaction failed")
      }

      print(jsonTxn)
      print(rlpTxn)

      // check the hash, if they match everything was parsed, and re-encoded correctly
      XCTAssert(jsonTxn.hash!.toHexString().addHexPrefix() == expectedHash)
      XCTAssert(rlpTxn.hash!.toHexString().addHexPrefix() == expectedHash)
      // check that we recovered the address correctly
      XCTAssert(jsonTxn.sender!.address == expectedAddress.address)
      XCTAssert(rlpTxn.sender!.address == expectedAddress.address)
    } catch {
      print(error)
      return XCTFail(String(describing: error))
    }
  }

  // reference transaction json and rlp created with ethers.js
  // test a normal legacy transaction conforming to EIP155 for signing
  func testLegacyEIP155Encoding() throws {
    let JSON = """
    {
      "chainId": "0x4",
      "nonce": "0x2a",
      "gasPrice": "0x40",
      "gasLimit": "0x0186a0",
      "to": "0xff00000000000000000000000000000000000002",
      "value": "0x3b9aca00",
      "data": "0xdeadbeef",
      "v": "0x2c",
      "r": "0x16851e9fad597e741499fe12911103c1c96acacd2636368eb71c0981a8324cff",
      "s": "0x44666e3f81fc3367e5e6babcccca0149a625835f9e2fe1fd19707544f0930429"
    }
    """
    let RLP = "0xf8682a40830186a094ff00000000000000000000000000000000000002843b9aca0084deadbeef2ca016851e9fad597e741499fe12911103c1c96acacd2636368eb71c0981a8324cffa044666e3f81fc3367e5e6babcccca0149a625835f9e2fe1fd19707544f0930429"
    let expectedHash = "0x8180d948cfe0aa928d95374efe8231c956666f3a65dfe6bcd8388b024863afa3"

    let expectedAddress = EthereumAddress("0xFD47742fE83cDc97883CD0c364B095fF4c03EE7F")!
    let jsonData = JSON.data(using: .utf8)!
    let rlpData = Data.fromHex(RLP)!

    do {
      let jsonTxn: EthereumTransaction = try JSONDecoder().decode(EthereumTransaction.self, from: jsonData)
      guard let rlpTxn = EthereumTransaction(rawValue: rlpData) else {
        return XCTFail("Decoding RLP encoded transaction failed")
      }
      // check the hash, if they match everything was parsed, and re-encoded correctly
      XCTAssert(jsonTxn.hash!.toHexString().addHexPrefix() == expectedHash)
      XCTAssert(rlpTxn.hash!.toHexString().addHexPrefix() == expectedHash)
      // check that we recovered the address correctly
      XCTAssert(jsonTxn.sender!.address == expectedAddress.address)
      XCTAssert(rlpTxn.sender!.address == expectedAddress.address)
    } catch {
      print(error)
      return XCTFail(String(describing: error))
    }
  }

  // reference transaction json and rlp created with ethers.js
  // test EIP-2930 encoding without an access list
  func testEIP2930Encoding() throws {
    let JSON = """
    {
      "type": "0x1",
      "chainId": "0x4",
      "nonce": "0x2a",
      "gasPrice": "0x40",
      "gasLimit": "0x0186a0",
      "to": "0xff00000000000000000000000000000000000002",
      "value": "0x3b9aca00",
      "data": "0xdeadbeef",
      "accessList": [],
      "v": "0x0",
      "r": "0x23fc8d46036df1881046a904c83dfc06b9372d31c4152ef764fc02ae6168c27f",
      "s": "0x5020e0ce845d036e1f5f6e331cdcbb6f0b681a42e3dab665f143961640de7572"
    }
    """
    let RLP = "0x01f86a042a40830186a094ff00000000000000000000000000000000000002843b9aca0084deadbeefc080a023fc8d46036df1881046a904c83dfc06b9372d31c4152ef764fc02ae6168c27fa05020e0ce845d036e1f5f6e331cdcbb6f0b681a42e3dab665f143961640de7572"
    let expectedHash = "0x7dcc8d36019095149c937961034dc647519c49f95dd1d7ee434789e0b2e3c028"

    let expectedAddress = EthereumAddress("0xFD47742fE83cDc97883CD0c364B095fF4c03EE7F")!
    let jsonData = JSON.data(using: .utf8)!
    let rlpData = Data.fromHex(RLP)!

    do {
      let jsonTxn: EthereumTransaction = try JSONDecoder().decode(EthereumTransaction.self, from: jsonData)
      guard let rlpTxn = EthereumTransaction(rawValue: rlpData) else {
        return XCTFail("Decoding RLP encoded transaction failed")
      }
      // check the hash, if they match everything was parsed, and re-encoded correctly
      XCTAssert(jsonTxn.hash!.toHexString().addHexPrefix() == expectedHash)
      XCTAssert(rlpTxn.hash!.toHexString().addHexPrefix() == expectedHash)
      // check that we recovered the address correctly
      XCTAssert(jsonTxn.sender!.address == expectedAddress.address)
      XCTAssert(rlpTxn.sender!.address == expectedAddress.address)
    } catch {
      print(error)
      return XCTFail(String(describing: error))
    }
  }

  // reference transaction json and rlp created with ethers.js
  // test EIP-2930 encoding with an access list
  func testEIP2930EncodingWithAccess() throws {
    let JSON = """
    {
      "type": "0x1",
      "chainId": "0x4",
      "nonce": "0x2a",
      "gasPrice": "0x40",
      "gasLimit": "0x0186a0",
      "to": "0xff00000000000000000000000000000000000002",
      "value": "0x3b9aca00",
      "data": "0xdeadbeef",
      "accessList": [
       {
         "address": "0xff00000000000000000000000000000000000003",
         "storageKeys": [
           "0xee00000000000000000000000000000000000000000000000000000000000031",
           "0xee00000000000000000000000000000000000000000000000000000000000032"
         ]
       },
       {
         "address": "0xff00000000000000000000000000000000000004",
         "storageKeys": [
           "0xee00000000000000000000000000000000000000000000000000000000000041"
         ]
       },
       {
         "address": "0xff00000000000000000000000000000000000005",
         "storageKeys": []
       }
      ],
      "v": "0x0",
      "r": "0x37cf9333c39860d1687ba76a2c738b9ce49f5dea94bb06a325991ab01a1f9e50",
      "s": "0x131b8c825de0e0a57244f5e445ce1c093421fcf6b5f60799209efe318bd08ed0"
    }
    """
    let RLP = "0x01f90115042a40830186a094ff00000000000000000000000000000000000002843b9aca0084deadbeeff8aaf85994ff00000000000000000000000000000000000003f842a0ee00000000000000000000000000000000000000000000000000000000000031a0ee00000000000000000000000000000000000000000000000000000000000032f794ff00000000000000000000000000000000000004e1a0ee00000000000000000000000000000000000000000000000000000000000041d694ff00000000000000000000000000000000000005c080a037cf9333c39860d1687ba76a2c738b9ce49f5dea94bb06a325991ab01a1f9e50a0131b8c825de0e0a57244f5e445ce1c093421fcf6b5f60799209efe318bd08ed0"
    let expectedHash = "0xc634e44fea83c91eabe79b051b143f56b1b39da6b63bf5baf38ae20730026783"

    let expectedAddress = EthereumAddress("0xFD47742fE83cDc97883CD0c364B095fF4c03EE7F")!
    let jsonData = JSON.data(using: .utf8)!
    let rlpData = Data.fromHex(RLP)!

    do {
      let jsonTxn: EthereumTransaction = try JSONDecoder().decode(EthereumTransaction.self, from: jsonData)
      guard let rlpTxn = EthereumTransaction(rawValue: rlpData) else {
        return XCTFail("Decoding RLP encoded transaction failed")
      }
      // check the hash, if they match everything was parsed, and re-encoded correctly
      XCTAssert(jsonTxn.hash!.toHexString().addHexPrefix() == expectedHash)
      XCTAssert(rlpTxn.hash!.toHexString().addHexPrefix() == expectedHash)
      // check that we recovered the address correctly
      XCTAssert(jsonTxn.sender!.address == expectedAddress.address)
      XCTAssert(rlpTxn.sender!.address == expectedAddress.address)
    } catch {
      print(error)
      return XCTFail(String(describing: error))
    }
  }

  // reference transaction json and rlp created with ethers.js
  // test EIP-1559 encoding with empty access list
  func testEIP1559Encoding() throws {
    let JSON = """
    {
      "type": "0x2",
      "chainId": "0x4",
      "nonce": "0x2a",
      "maxPriorityFeePerGas": "0x7f",
      "maxFeePerGas": "0xff",
      "gasLimit": "0x0186a0",
      "to": "0xff00000000000000000000000000000000000002",
      "value": "0x3b9aca00",
      "data": "0xdeadbeef",
      "accessList": [],
      "v": "0x01",
      "r": "0xbbf3c84a77f74d7e394daf9a4a2d57081d099aac96000a87a6108386200ac4bc",
      "s": "0x40c06dec4423b2ffbd0817f8051783430fa9f5f42a3ea5b1a41fd801b1f09d8d"
    }
    """
    let RLP = "0x02f86c042a7f81ff830186a094ff00000000000000000000000000000000000002843b9aca0084deadbeefc001a0bbf3c84a77f74d7e394daf9a4a2d57081d099aac96000a87a6108386200ac4bca040c06dec4423b2ffbd0817f8051783430fa9f5f42a3ea5b1a41fd801b1f09d8d"
    let expectedHash = "0x64454572f4ffe417bb3161e3a1631b56e4e5f9c7c95064a445f6b25f94e6f97f"

    let expectedAddress = EthereumAddress("0xFD47742fE83cDc97883CD0c364B095fF4c03EE7F")!
    let jsonData = JSON.data(using: .utf8)!
    let rlpData = Data.fromHex(RLP)!

    do {
      let jsonTxn: EthereumTransaction = try JSONDecoder().decode(EthereumTransaction.self, from: jsonData)
      guard let rlpTxn = EthereumTransaction(rawValue: rlpData) else {
        return XCTFail("Decoding RLP encoded transaction failed")
      }
      // check the hash, if they match everything was parsed, and re-encoded correctly
      XCTAssert(jsonTxn.hash!.toHexString().addHexPrefix() == expectedHash)
      XCTAssert(rlpTxn.hash!.toHexString().addHexPrefix() == expectedHash)
      // check that we recovered the address correctly
      XCTAssert(jsonTxn.sender!.address == expectedAddress.address)
      XCTAssert(rlpTxn.sender!.address == expectedAddress.address)
    } catch {
      print(error)
      return XCTFail(String(describing: error))
    }
  }

  // reference transaction json and rlp created with ethers.js
  // test EIP-1559 encoding with an access list
  func testEIP1559EncodingWithAccess() throws {
    let JSON = """
    {
      "type": "0x2",
      "chainId": "0x4",
      "nonce": "0x2a",
      "maxPriorityFeePerGas": "0x7f",
      "maxFeePerGas": "0xff",
      "gasLimit": "0x0186a0",
      "to": "0xff00000000000000000000000000000000000002",
      "value": "0x3b9aca00",
      "data": "0xdeadbeef",
      "accessList": [
       {
         "address": "0xff00000000000000000000000000000000000003",
         "storageKeys": [
           "0xee00000000000000000000000000000000000000000000000000000000000031",
           "0xee00000000000000000000000000000000000000000000000000000000000032"
         ]
       },
       {
         "address": "0xff00000000000000000000000000000000000004",
         "storageKeys": [
           "0xee00000000000000000000000000000000000000000000000000000000000041"
         ]
       },
       {
         "address": "0xff00000000000000000000000000000000000005",
         "storageKeys": []
       }
      ],
      "v": "0x01",
      "r": "0x14017ab81272aa6a01c073cfeb2e058659988b44e46615de1b2ad032cd1a4eb3",
      "s": "0x62fbdf4abd06c2ce81dbc30a79124e6001ba029aa6423d9d3bd70971f8b8c868"
    }
    """
    let RLP = "0x02f90117042a7f81ff830186a094ff00000000000000000000000000000000000002843b9aca0084deadbeeff8aaf85994ff00000000000000000000000000000000000003f842a0ee00000000000000000000000000000000000000000000000000000000000031a0ee00000000000000000000000000000000000000000000000000000000000032f794ff00000000000000000000000000000000000004e1a0ee00000000000000000000000000000000000000000000000000000000000041d694ff00000000000000000000000000000000000005c001a014017ab81272aa6a01c073cfeb2e058659988b44e46615de1b2ad032cd1a4eb3a062fbdf4abd06c2ce81dbc30a79124e6001ba029aa6423d9d3bd70971f8b8c868"
    let expectedHash = "0xf97d84beadef20be5753ad8f0d39068cbe79d7381977adc3c7db599c434cb763"

    let expectedAddress = EthereumAddress("0xFD47742fE83cDc97883CD0c364B095fF4c03EE7F")!
    let jsonData = JSON.data(using: .utf8)!
    let rlpData = Data.fromHex(RLP)!

    do {
      let jsonTxn: EthereumTransaction = try JSONDecoder().decode(EthereumTransaction.self, from: jsonData)
      guard let rlpTxn = EthereumTransaction(rawValue: rlpData) else {
        return XCTFail("Decoding RLP encoded transaction failed")
      }
      // check the hash, if they match everything was parsed, and re-encoded correctly
      XCTAssert(jsonTxn.hash!.toHexString().addHexPrefix() == expectedHash)
      XCTAssert(rlpTxn.hash!.toHexString().addHexPrefix() == expectedHash)
      // check that we recovered the address correctly
      XCTAssert(jsonTxn.sender!.address == expectedAddress.address)
      XCTAssert(rlpTxn.sender!.address == expectedAddress.address)
    } catch {
      print(error)
      return XCTFail(String(describing: error))
    }
  }

    func testTransaction() throws {
        do {
          var options = TransactionOptions()
          options.gasPrice = .manual(20000000000)
          options.gasLimit = .manual(21000)
          var transaction = EthereumTransaction(
                                      to: EthereumAddress("0x3535353535353535353535353535353535353535")!,
                                      nonce: 9, value: 1000000000000000000, data: Data(),
                                      v: 0, r: 0, s: 0, options: options)
            let privateKeyData = Data.fromHex("0x4646464646464646464646464646464646464646464646464646464646464646")!
            let publicKey = Web3.Utils.privateToPublic(privateKeyData, compressed: false)
            let sender = Web3.Utils.publicToAddress(publicKey!)
            transaction.chainID = 1
            print(transaction)
            let hash = transaction.hashForSignature()
            let expectedHash = "0xdaf5a779ae972f972197303d7b574746c7ef83eadac0f2791ad23db92e4c8e53".stripHexPrefix()
            XCTAssert(hash!.toHexString() == expectedHash, "Transaction signature failed")
            try transaction.sign(privateKey: privateKeyData, useExtraEntropy: false)
            print(transaction)
            XCTAssert(transaction.v == 37, "Transaction signature failed")
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
            let options = details.transaction.getOptions()
            let txnGasLimit = options.resolveGasLimit(0)
            XCTAssert(txnGasLimit == BigUInt(78423))
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
