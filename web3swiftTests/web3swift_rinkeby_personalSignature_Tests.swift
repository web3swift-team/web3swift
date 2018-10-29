//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import XCTest
import CryptoSwift
import BigInt
import secp256k1_swift

@testable import web3swift_iOS

class web3swift_rinkeby_personalSignature_Tests: XCTestCase {
    
    
    func testPersonalSignature() {
        let web3 = Web3.InfuraRinkebyWeb3()
        let tempKeystore = try! EthereumKeystoreV3(password: "")
        let keystoreManager = KeystoreManager([tempKeystore!])
        web3.addKeystoreManager(keystoreManager)
        let message = "Hello World"
        let expectedAddress = keystoreManager.addresses![0]
        print(expectedAddress)
        let signRes = web3.personal.signPersonalMessage(message: message.data(using: .utf8)!, from: expectedAddress, password: "")
        guard case .success(let signature) = signRes else {return XCTFail()}
        let unmarshalledSignature = SECP256K1.unmarshalSignature(signatureData: signature)!
        print("V = " + String(unmarshalledSignature.v))
        print("R = " + Data(unmarshalledSignature.r).toHexString())
        print("S = " + Data(unmarshalledSignature.s).toHexString())
        print("Personal hash = " + Web3.Utils.hashPersonalMessage(message.data(using: .utf8)!)!.toHexString())
        let recoveredSigner = web3.personal.ecrecover(personalMessage: message.data(using: .utf8)!, signature: signature)
        guard case .success(let signer) = recoveredSigner else {return XCTFail()}
        XCTAssert(expectedAddress == signer, "Failed to sign personal message")
    }
    
    func testPersonalSignatureOnContract() {
        let web3 = Web3.InfuraRinkebyWeb3()
        let tempKeystore = try! EthereumKeystoreV3(password: "")
        let keystoreManager = KeystoreManager([tempKeystore!])
        web3.addKeystoreManager(keystoreManager)
        let message = "Hello World"
        let expectedAddress = keystoreManager.addresses![0]
        print(expectedAddress)
        let signRes = web3.personal.signPersonalMessage(message: message.data(using: .utf8)!, from: expectedAddress, password: "")
        guard case .success(let signature) = signRes else {return XCTFail()}
        let unmarshalledSignature = SECP256K1.unmarshalSignature(signatureData: signature)!
        print("V = " + String(unmarshalledSignature.v))
        print("R = " + Data(unmarshalledSignature.r).toHexString())
        print("S = " + Data(unmarshalledSignature.s).toHexString())
        print("Personal hash = " + Web3.Utils.hashPersonalMessage(message.data(using: .utf8)!)!.toHexString())
        let jsonString = "[{\"inputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"constructor\"},{\"constant\":true,\"inputs\":[{\"name\":\"_message\",\"type\":\"string\"}],\"name\":\"hashPersonalMessage\",\"outputs\":[{\"name\":\"hash\",\"type\":\"bytes32\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_message\",\"type\":\"string\"},{\"name\":\"v\",\"type\":\"uint8\"},{\"name\":\"r\",\"type\":\"bytes32\"},{\"name\":\"s\",\"type\":\"bytes32\"}],\"name\":\"recoverSigner\",\"outputs\":[{\"name\":\"signer\",\"type\":\"address\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"}]"
        let contract = web3.contract(jsonString, at: EthereumAddress("0x6f1745a39059268e8e4572e97897b50e4aab62a8"), abiVersion: 2)
        var options = Web3Options.defaultOptions()
        options.from = expectedAddress
        var intermediate = contract?.method("hashPersonalMessage", parameters: [message as AnyObject], options: options)
        var result = intermediate!.call(options: nil)
        switch result {
        case .success(let res):
            guard let hash = res["hash"]! as? Data else {return XCTFail()}
            XCTAssert(Web3.Utils.hashPersonalMessage(message.data(using: .utf8)!)! == hash)
        case .failure(let error):
            print(error)
            XCTFail()
        }
        
        intermediate = contract?.method("recoverSigner", parameters: [message, unmarshalledSignature.v, Data(unmarshalledSignature.r), Data(unmarshalledSignature.s)] as [AnyObject], options: options)
        result = intermediate!.call(options: nil)
        switch result {
        case .success(let res):
            guard let signer = res["signer"]! as? EthereumAddress else {return XCTFail()}
            print(signer)
            XCTAssert(signer == expectedAddress)
        case .failure(let error):
            print(error)
            XCTFail()
        }
    }
    
}
