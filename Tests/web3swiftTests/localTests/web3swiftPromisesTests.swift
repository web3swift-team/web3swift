//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

// TODO: Replace `XCTAssert` with more explicite `XCTAssertEqual`, where Applicable

import XCTest
import PromiseKit
import BigInt

@testable import web3swift

class web3swiftPromisesTests: LocalTestCase {
    var urlSession: URLSession?

    func testGetBalancePromise() throws {
        let balance = try ganache.eth.getBalancePromise(address: "0xe22b8979739D724343bd002F9f432F5990879901").wait()
        print(balance)
    }

    func testGetTransactionDetailsPromise() throws {
        let gasLimit = BigUInt(78423)
        let sendToAddress = EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901")!
        let allAddresses = try ganache.eth.getAccounts()
        guard let writeTX = ganache.eth.sendETH(to: sendToAddress, amount: "0.001") else {return XCTFail()}
        writeTX.transactionOptions.from = allAddresses[0]
        writeTX.transactionOptions.gasLimit = .manual(gasLimit)
        let writeResult = try writeTX.sendPromise().wait()
        let txHash = writeResult.hash
        let result = try ganache.eth.getTransactionDetailsPromise(txHash).wait()
        print(result)
        XCTAssert(result.transaction.parameters.gasLimit == BigUInt(gasLimit))
    }

    func testEstimateGasPromise() throws {
        let sendToAddress = EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901")
        let tempKeystore = try! EthereumKeystoreV3(password: "")
        let keystoreManager = KeystoreManager([tempKeystore!])
        ganache.addKeystoreManager(keystoreManager)
        let contract = ganache.contract(Web3.Utils.coldWalletABI, at: sendToAddress, abiVersion: 2)
        guard let writeTX = contract?.write("fallback") else {return XCTFail()}
        writeTX.transactionOptions.from = tempKeystore!.addresses?.first
        writeTX.transactionOptions.value = BigUInt("1.0", .eth)
        let estimate = try writeTX.estimateGasPromise().wait()
        print(estimate)
        XCTAssert(estimate == 21000)
    }

    func testEstimateGasFixPromise() throws {
        // Deploy contract
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

        switch receipt.status {
        case .notYetProcessed:
            return
        default:
            break
        }

        let tempKeystore = try! EthereumKeystoreV3(password: "")
        let keystoreManager = KeystoreManager([tempKeystore!])
        ganache.addKeystoreManager(keystoreManager)

        guard let contractAddress = receipt.contractAddress,
            let contract = ganache.contract(Web3.Utils.estimateGasTestABI,
                                         at: contractAddress,
                                         abiVersion: 2) else {
                                            return
        }

        var options = TransactionOptions.defaultOptions
        let fromAddress = tempKeystore!.addresses?.first
        options.from = fromAddress

        let amount1 = Web3.Utils.parseToBigUInt("0.000000000000000001", units: .eth) // 1 wei

        guard let tx1 = contract.write("test",
                                       parameters: [amount1] as [AnyObject],
                                       extraData: Data(),
                                       transactionOptions: options) else {
                                        return
        }
        let estimate1 = try tx1.estimateGasPromise().wait()
        print(estimate1)

        let amount2 = Web3.Utils.parseToBigUInt("0.00000005", units: .eth) // 50 gwei
        guard let tx2 = contract.write("test",
                                       parameters: [amount2] as [AnyObject],
                                       extraData: Data(),
                                       transactionOptions: options) else {
                                        return
        }
        let estimate2 = try tx2.estimateGasPromise().wait()
        print(estimate2)
        XCTAssert(estimate2 - estimate1 <= 22000)
    }

    func testSendETHPromise() throws {
        let allAddresses = try ganache.eth.getAccounts()
        let gasPrice = try ganache.eth.getGasPrice()
        let sendToAddress = EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901")!
        guard let writeTX = ganache.eth.sendETH(to: sendToAddress, amount: "0.001") else { return XCTFail() }
        writeTX.transactionOptions.from = allAddresses[0]
        writeTX.transactionOptions.gasPrice = .manual(gasPrice)
        let result = try writeTX.sendPromise().wait()
        print(result)
    }

    func testERC20tokenBalancePromise() throws {
        let (_, receipt, _) = try web3swiftHelpers.localDeployERC20(ganache)

        let token = ganache.contract(Web3.Utils.erc20ABI, at: receipt.contractAddress, abiVersion: 2)!

        let userAddress = EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901")!
        let tokenBalance = try token.read("balanceOf", parameters: [userAddress] as [AnyObject])!.callPromise().wait()
        guard let bal = tokenBalance["0"] as? BigUInt else { return XCTFail() }
        print(String(bal))
    }
}
