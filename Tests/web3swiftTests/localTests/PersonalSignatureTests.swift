//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import XCTest
import CryptoSwift
import BigInt
import Web3Core

@testable import web3swift

class PersonalSignatureTests: XCTestCase {

    func testPersonalSignature() async throws {
        let web3 = try await Web3.new(LocalTestCase.url)
        let tempKeystore = try! EthereumKeystoreV3(password: "")
        let keystoreManager = KeystoreManager([tempKeystore!])
        web3.addKeystoreManager(keystoreManager)
        let message = "Hello World"
        let expectedAddress = keystoreManager.addresses![0]

        let signature = try await web3.personal.signPersonalMessage(message: message.data(using: .utf8)!, from: expectedAddress, password: "")
        let unmarshalledSignature = SECP256K1.unmarshalSignature(signatureData: signature)!
        let signer = web3.personal.recoverAddress(message: message.data(using: .utf8)!, signature: signature)
        XCTAssert(expectedAddress == signer, "Failed to sign personal message")
    }

    // TODO: - write contract
    func testPersonalSignatureOnContract() async throws {
        let web3 = try await Web3.new(LocalTestCase.url)
        // Deploying contract
        let abiString = "[{\"inputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"constructor\"},{\"constant\":true,\"inputs\":[{\"name\":\"_message\",\"type\":\"string\"}],\"name\":\"hashPersonalMessage\",\"outputs\":[{\"name\":\"hash\",\"type\":\"bytes32\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_message\",\"type\":\"string\"},{\"name\":\"v\",\"type\":\"uint8\"},{\"name\":\"r\",\"type\":\"bytes32\"},{\"name\":\"s\",\"type\":\"bytes32\"}],\"name\":\"recoverSigner\",\"outputs\":[{\"name\":\"signer\",\"type\":\"address\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"}]"
        let bytecode = Data.fromHex("0x608060405234801561001057600080fd5b506105ba806100206000396000f30060806040526004361061004c576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff1680632785e93714610051578063d01ec9a514610123575b600080fd5b34801561005d57600080fd5b506100e1600480360381019080803590602001908201803590602001908080601f0160208091040260200160405190810160405280939291908181526020018383808284378201915050505050509192919290803560ff169060200190929190803560001916906020019092919080356000191690602001909291905050506101a8565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b34801561012f57600080fd5b5061018a600480360381019080803590602001908201803590602001908080601f0160208091040260200160405190810160405280939291908181526020018383808284378201915050505050509192919290505050610258565b60405180826000191660001916815260200191505060405180910390f35b6000806101b486610258565b9050601b8560ff1610156101c957601b850194505b600181868686604051600081526020016040526040518085600019166000191681526020018460ff1660ff1681526020018360001916600019168152602001826000191660001916815260200194505050505060206040516020810390808403906000865af1158015610240573d6000803e3d6000fd5b50505060206040510351915081915050949350505050565b600080825190506040805190810160405280601a81526020017f19457468657265756d205369676e6564204d6573736167653a0a00000000000081525061029e826103b4565b846040518084805190602001908083835b6020831015156102d457805182526020820191506020810190506020830392506102af565b6001836020036101000a03801982511681845116808217855250505050505090500183805190602001908083835b6020831015156103275780518252602082019150602081019050602083039250610302565b6001836020036101000a03801982511681845116808217855250505050505090500182805190602001908083835b60208310151561037a5780518252602082019150602081019050602083039250610355565b6001836020036101000a03801982511681845116808217855250505050505090500193505050506040518091039020915081915050919050565b606060006060600080600060649450846040519080825280601f01601f1916602001820160405280156103f65781602001602082028038833980820191505090505b509350600092505b60008714151561049557600a8781151561041457fe5b069150600a8781151561042357fe5b049650816030017f010000000000000000000000000000000000000000000000000000000000000002848480600101955081518110151561046057fe5b9060200101907effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1916908160001a9053506103fe565b826040519080825280601f01601f1916602001820160405280156104c85781602001602082028038833980820191505090505b509550600090505b8281101561058157838160018503038151811015156104eb57fe5b9060200101517f010000000000000000000000000000000000000000000000000000000000000090047f010000000000000000000000000000000000000000000000000000000000000002868281518110151561054457fe5b9060200101907effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1916908160001a90535080806001019150506104d0565b85955050505050509190505600a165627a7a723058204b567e6628d988bde2e19a4e9a457bf84bbeac15069a74fe993aba215fb024330029")!

        var contract = web3.contract(abiString, at: nil, abiVersion: 2)!
        let deployTx = contract.prepareDeploy(bytecode: bytecode)!
        let allAddresses = try await web3.eth.ownedAccounts()
        deployTx.transaction.from = allAddresses[0]
        let policies = Policies(gasLimitPolicy: .manual(3000000))
        let deployResult = try await deployTx.writeToChain(password: "web3swift", policies: policies, sendRaw: false)
        let txHash = Data.fromHex(deployResult.hash.stripHexPrefix())!

        Thread.sleep(forTimeInterval: 1.0)

        let receipt = try await web3.eth.transactionReceipt(txHash)

        switch receipt.status {
        case .notYetProcessed:
            return
        default:
            break
        }

        // Signing
        let tempKeystore = try! EthereumKeystoreV3(password: "")
        let keystoreManager = KeystoreManager([tempKeystore!])
        web3.addKeystoreManager(keystoreManager)
        let message = "Hello World"
        let expectedAddress = keystoreManager.addresses![0]

        let signature = try await web3.personal.signPersonalMessage(message: message.data(using: .utf8)!, from: expectedAddress, password: "")
        let unmarshalledSignature = SECP256K1.unmarshalSignature(signatureData: signature)!

        // Calling contract
        contract = web3.contract(abiString, at: receipt.contractAddress!)!
        var tx = contract.createReadOperation("hashPersonalMessage", parameters: [message])
        tx?.transaction.from = expectedAddress
        var result = try await tx!.callContractMethod()
        guard let hash = result["hash"]! as? Data else { return XCTFail() }
        XCTAssert(Utilities.hashPersonalMessage(message.data(using: .utf8)!)! == hash)

        tx = contract.createReadOperation("recoverSigner", parameters: [message, unmarshalledSignature.v, Data(unmarshalledSignature.r), Data(unmarshalledSignature.s)])
        tx?.transaction.from = expectedAddress
        result = try await tx!.callContractMethod()
        guard let signer = result["signer"]! as? EthereumAddress else { return XCTFail() }
        XCTAssert(signer == expectedAddress)
    }

}
