//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import XCTest
import BigInt

@testable import web3swift

class web3swiftUserCases: LocalTestCase {

    func getKeystoreData() -> Data? {
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.path(forResource: "key", ofType: "json") else { return nil }
        guard let data = NSData(contentsOfFile: path) else { return nil }
        return data as Data
    }

    func testUserCase1() throws {
        let (_, receipt, abiString) = try web3swiftHelpers.localDeployERC20(ganache)
        let account = EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901")!
        let contract = ganache.contract(abiString, at: receipt.contractAddress!)!
        let readTransaction = contract.read("balanceOf", parameters: [account] as [AnyObject])!
        readTransaction.transactionOptions.from = account
        let response = try readTransaction.callPromise().wait()
        let balance = response["0"] as? BigUInt
        print(balance!.description)
    }

    func testUserCase2() {
        let web3 = try? Web3.new(LocalTestCase.url)
        XCTAssert(web3 != nil, "Failed to create web3 for custom provider")
    }

    func testProperGasLimit() throws {
        let allAddresses = try ganache.eth.getAccounts()
        let gasPrice = try ganache.eth.getGasPrice()
        let sendToAddress = EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901")!
        guard let writeTX = ganache.eth.sendETH(to: sendToAddress, amount: "0.001") else { return XCTFail() }
        writeTX.transactionOptions.from = allAddresses[0]
        writeTX.transactionOptions.gasPrice = .manual(gasPrice)
        let gasEstimate = try writeTX.estimateGasPromise().wait()
        writeTX.transactionOptions.gasLimit = .manual(gasEstimate + 1234)
        let assembled = try writeTX.assemblePromise().wait()
        let txnGasLimit = assembled.parameters.gasLimit
        XCTAssert(txnGasLimit == gasEstimate + 1234)
    }

    func testProperGasPrice() throws {
        let allAddresses = try ganache.eth.getAccounts()
        let gasPrice = try ganache.eth.getGasPrice()
        let sendToAddress = EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901")!
        guard let writeTX = ganache.eth.sendETH(to: sendToAddress, amount: "0.001") else { return XCTFail() }
        writeTX.transactionOptions.from = allAddresses[0]
        writeTX.transactionOptions.gasPrice = .manual(gasPrice * 2)
        let gasEstimate = try writeTX.estimateGasPromise().wait()
        writeTX.transactionOptions.gasLimit = .manual(gasEstimate + 1234)
        let assembled = try writeTX.assemblePromise().wait()
        let txnGasLimit = assembled.parameters.gasLimit
        let txnGasPrice = assembled.parameters.gasPrice

        XCTAssert(txnGasLimit == gasEstimate + 1234)
        XCTAssert(txnGasPrice == gasPrice * 2)
    }

    func testParseTransactionDetailsForContractCreation() throws { // Deploy contract
        let bytecode = Data.fromHex("0x608060405234801561001057600080fd5b50610100806100206000396000f30060806040526004361060525763ffffffff7c01000000000000000000000000000000000000000000000000000000006000350416630dbe671f8114605757806329e99f0714607b5780634df7e3d0146092575b600080fd5b348015606257600080fd5b50606960a4565b60408051918252519081900360200190f35b348015608657600080fd5b50609060043560aa565b005b348015609d57600080fd5b50606960ce565b60005481565b803a111560ba57600160005560cb565b803a101560cb576001600081905580555b50565b600154815600a165627a7a723058200327a504a24f70cf740239fad2ad203f21caf0ef05f7870bd88482f6fa3cf1080029")!

        let allAddresses = try ganache.eth.getAccounts()
        let contract = ganache.contract(Web3.Utils.estimateGasTestABI, at: nil, abiVersion: 2)!
        let deployTx = contract.deploy(bytecode: bytecode)!
        deployTx.transactionOptions.from = allAddresses[0]
        deployTx.transactionOptions.gasLimit = .manual(3000000)
        let result = try deployTx.sendPromise().wait()
        let txHash = result.hash
        print("Transaction with hash " + txHash)

        Thread.sleep(forTimeInterval: 1.0)

        let receipt = try ganache.eth.getTransactionReceipt(txHash)
        print(receipt)
        XCTAssert(receipt.contractAddress != nil)

        switch receipt.status {
        case .notYetProcessed:
            return
        default:
            break
        }

        let details = try ganache.eth.getTransactionDetails(txHash)
        print(details)
        XCTAssert(details.transaction.to == .contractDeploymentAddress())
    }

    func testNonBatchedRequest() throws {
        let address = EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901")!
        ganache.requestDispatcher.policy = .NoBatching
        let balanceResult = try ganache.eth.getBalance(address: address)
        print(balanceResult)
    }
}
