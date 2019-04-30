//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import XCTest
import CryptoSwift
import BigInt
//import secp256k1_swift
//import EthereumAddress

@testable import web3swift

class web3swift_rinkeby_personalSignature_Tests: XCTestCase {
    
    
    func testPersonalSignature() throws {
        let web3 = Web3.InfuraRinkebyWeb3()
        let tempKeystore = try! EthereumKeystoreV3(password: "")
        let keystoreManager = KeystoreManager([tempKeystore!])
        web3.addKeystoreManager(keystoreManager)
        let message = "Hello World"
        let expectedAddress = keystoreManager.addresses![0]
        print(expectedAddress)
        let signature = try web3.personal.signPersonalMessage(message: message.data(using: .utf8)!, from: expectedAddress, password: "")
        let unmarshalledSignature = SECP256K1.unmarshalSignature(signatureData: signature)!
        print("V = " + String(unmarshalledSignature.v))
        print("R = " + Data(unmarshalledSignature.r).toHexString())
        print("S = " + Data(unmarshalledSignature.s).toHexString())
        print("Personal hash = " + Web3.Utils.hashPersonalMessage(message.data(using: .utf8)!)!.toHexString())
        let signer = try web3.personal.ecrecover(personalMessage: message.data(using: .utf8)!, signature: signature)
        XCTAssert(expectedAddress == signer, "Failed to sign personal message")
    }
    
    func testPersonalSignatureOnContract() throws {
        let web3 = Web3.InfuraRinkebyWeb3()
        let tempKeystore = try! EthereumKeystoreV3(password: "")
        let keystoreManager = KeystoreManager([tempKeystore!])
        web3.addKeystoreManager(keystoreManager)
        let message = "Hello World"
        let expectedAddress = keystoreManager.addresses![0]
        print(expectedAddress)
        let signature = try web3.personal.signPersonalMessage(message: message.data(using: .utf8)!, from: expectedAddress, password: "")
        let unmarshalledSignature = SECP256K1.unmarshalSignature(signatureData: signature)!
        print("V = " + String(unmarshalledSignature.v))
        print("R = " + Data(unmarshalledSignature.r).toHexString())
        print("S = " + Data(unmarshalledSignature.s).toHexString())
        print("Personal hash = " + Web3.Utils.hashPersonalMessage(message.data(using: .utf8)!)!.toHexString())
        let jsonString = "[{\"inputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"constructor\"},{\"constant\":true,\"inputs\":[{\"name\":\"_message\",\"type\":\"string\"}],\"name\":\"hashPersonalMessage\",\"outputs\":[{\"name\":\"hash\",\"type\":\"bytes32\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_message\",\"type\":\"string\"},{\"name\":\"v\",\"type\":\"uint8\"},{\"name\":\"r\",\"type\":\"bytes32\"},{\"name\":\"s\",\"type\":\"bytes32\"}],\"name\":\"recoverSigner\",\"outputs\":[{\"name\":\"signer\",\"type\":\"address\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"}]"
        let contract = web3.contract(jsonString, at: EthereumAddress("0x6f1745a39059268e8e4572e97897b50e4aab62a8"), abiVersion: 2)
        var tx = contract?.read("hashPersonalMessage", parameters: [message as AnyObject])
        tx?.transactionOptions.from = expectedAddress
        var result = try tx!.call()
        guard let hash = result["hash"]! as? Data else {return XCTFail()}
        XCTAssert(Web3.Utils.hashPersonalMessage(message.data(using: .utf8)!)! == hash)
        
        tx = contract?.read("recoverSigner", parameters: [message, unmarshalledSignature.v, Data(unmarshalledSignature.r), Data(unmarshalledSignature.s)] as [AnyObject])
        tx?.transactionOptions.from = expectedAddress
        result = try tx!.call()
        guard let signer = result["signer"]! as? EthereumAddress else {return XCTFail()}
        XCTAssert(signer == expectedAddress)
    }
    
}
