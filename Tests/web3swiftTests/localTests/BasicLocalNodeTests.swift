//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//
// TODO: Replace `XCTAssert` with more explicit `XCTAssertEqual`, where Applicable
import XCTest
import CryptoSwift
import BigInt
import Web3Core

@testable import web3swift

class BasicLocalNodeTests: LocalTestCase {

    func testDeployWithRemoteSigning() async throws {
        let web3 = try await Web3.new(LocalTestCase.url)
        let allAddresses = try await web3.eth.ownedAccounts()

        let abiString =  "[{\"constant\":true,\"inputs\":[],\"name\":\"getFlagData\",\"outputs\":[{\"name\":\"data\",\"type\":\"string\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"data\",\"type\":\"string\"}],\"name\":\"setFlagData\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"}]"
        let bytecode = Data.fromHex("6060604052341561000f57600080fd5b6103358061001e6000396000f30060606040526004361061004c576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff168063a16e94bf14610051578063a46b5b6b146100df575b600080fd5b341561005c57600080fd5b61006461013c565b6040518080602001828103825283818151815260200191508051906020019080838360005b838110156100a4578082015181840152602081019050610089565b50505050905090810190601f1680156100d15780820380516001836020036101000a031916815260200191505b509250505060405180910390f35b34156100ea57600080fd5b61013a600480803590602001908201803590602001908080601f0160208091040260200160405190810160405280939291908181526020018383808284378201915050505050509190505061020d565b005b610144610250565b6000808073ffffffffffffffffffffffffffffffffffffffff1681526020019081526020016000206000018054600181600116156101000203166002900480601f0160208091040260200160405190810160405280929190818152602001828054600181600116156101000203166002900480156102035780601f106101d857610100808354040283529160200191610203565b820191906000526020600020905b8154815290600101906020018083116101e657829003601f168201915b5050505050905090565b806000808073ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020600001908051906020019061024c929190610264565b5050565b602060405190810160405280600081525090565b828054600181600116156101000203166002900490600052602060002090601f016020900481019282601f106102a557805160ff19168380011785556102d3565b828001600101855582156102d3579182015b828111156102d25782518255916020019190600101906102b7565b5b5090506102e091906102e4565b5090565b61030691905b808211156103025760008160009055506001016102ea565b5090565b905600a165627a7a7230582017359d063cd7fdf56f19ca186a54863ce855c8f070acece905d8538fbbc4d1bf0029")!

        let contract = web3.contract(abiString, at: nil, abiVersion: 2)!

        let parameters: [Any] = []
        let deployTx = contract.prepareDeploy(bytecode: bytecode, parameters: parameters)!
        deployTx.transaction.from = allAddresses[0]
        let policies = Policies(gasLimitPolicy: .manual(3000000))
        let result = try await deployTx.writeToChain(password: "web3swift", policies: policies, sendRaw: false)
        let txHash = result.hash.stripHexPrefix()

        while true {
            let receipt = try await web3.eth.transactionReceipt(Data.fromHex(txHash)!)
            switch receipt.status {
            case .notYetProcessed:
                continue
            case .failed:
                XCTFail("Failed to deploy a contract!")
            case .ok:
                XCTAssertNotNil(receipt.contractAddress)
                return
            }
        }
    }

    func testEthSendExampleWithRemoteSigning() async throws {
        let web3 = try await Web3.new(LocalTestCase.url)
        let allAddresses = try await web3.eth.ownedAccounts()
        let sendToAddress = EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901")!
        let contract = web3.contract(Web3.Utils.coldWalletABI, at: sendToAddress, abiVersion: 2)!

        let parameters: [Any] = []
        let sendTx = contract.createWriteOperation("fallback", parameters: parameters)!

        let valueToSend = try XCTUnwrap(Utilities.parseToBigUInt("1.0", units: .ether))
        sendTx.transaction.value = valueToSend
        sendTx.transaction.from = allAddresses[0]

        let balanceBeforeTo = try await web3.eth.getBalance(for: sendToAddress)
        let balanceBeforeFrom = try await web3.eth.getBalance(for: allAddresses[0])

        let result = try await sendTx.writeToChain(password: "web3swift", sendRaw: false)
        let txHash = Data.fromHex(result.hash.stripHexPrefix())!

        Thread.sleep(forTimeInterval: 1.0)

        let receipt = try await web3.eth.transactionReceipt(txHash)

        switch receipt.status {
        case .notYetProcessed:
            return
        default:
            break
        }

        let details = try await web3.eth.transactionDetails(txHash)

        let balanceAfterTo = try await web3.eth.getBalance(for: sendToAddress)
        let balanceAfterFrom = try await web3.eth.getBalance(for: allAddresses[0])

        XCTAssertEqual(balanceAfterTo - balanceBeforeTo, valueToSend)
        let txnGasPrice = details.transaction.meta?.gasPrice ?? 0
        XCTAssertEqual(balanceBeforeFrom - (balanceAfterFrom + receipt.gasUsed * txnGasPrice), valueToSend)
    }
}
