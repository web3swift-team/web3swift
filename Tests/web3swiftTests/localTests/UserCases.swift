//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import XCTest
import BigInt
import Web3Core

@testable import web3swift

class UserCases: XCTestCase {

    func getKeystoreData() -> Data? {
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.path(forResource: "key", ofType: "json") else { return nil }
        guard let data = NSData(contentsOfFile: path) else { return nil }
        return data as Data
    }

    func testUserCase1() async throws {
        let (web3, _, receipt, abiString) = try await TestHelpers.localDeployERC20()
        let account = EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901")!
        let contract = web3.contract(abiString, at: receipt.contractAddress!)!
        let readTransaction = contract.createReadOperation("balanceOf", parameters: [account])!
        readTransaction.transaction.from = account
        let response = try await readTransaction.callContractMethod()
        let balance = response["0"] as? BigUInt

    }

    func testUserCase2() async {
        let url = LocalTestCase.url
        let web3 = try? await Web3.new(url)
        XCTAssert(web3 != nil, "Failed to create web3 for custom provider")
    }
    // FIXME: Temporary deleted method `sendETH` should be restored.
    //    func testProperGasLimit() async throws {
    //        let web3 = try await Web3.new(LocalTestCase.url)
    //        let allAddresses = try await web3.eth.ownedAccounts()
    //        let gasPrice = try await web3.eth.gasPrice()
    //        let sendToAddress = EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901")!
    //        guard let writeTX = web3.eth.sendETH(to: sendToAddress, amount: "0.001") else {return XCTFail()}
    //        writeTX.transaction.from = allAddresses[0]
    //        writeTX.transaction.gasPricePolicy = .manual(gasPrice)
    //        let gasEstimate = try await writeTX.estimateGas(with: nil)
    //        writeTX.transaction.gasLimitPolicy = .manual(gasEstimate + 1234)
    //        let assembled = try await writeTX.assembleTransaction()
    //        XCTAssert(assembled.gasLimit == gasEstimate + 1234)
    //    }
    // FIXME: Temporary deleted method `sendETH` should be restored.
    //    func testProperGasPrice() async throws {
    //        let web3 = try await Web3.new(LocalTestCase.url)
    //        let allAddresses = try await web3.eth.ownedAccounts()
    //        let gasPrice = try await web3.eth.gasPrice()
    //        let sendToAddress = EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901")!
    //        guard let writeTX = web3.eth.sendETH(to: sendToAddress, amount: "0.001") else {
    //            return XCTFail()
    //        }
    //        writeTX.transaction.from = allAddresses[0]
    //        writeTX.transaction.gasPricePolicy = .manual(gasPrice * 2)
    //        let gasEstimate = try await writeTX.estimateGas(with: nil)
    //        writeTX.transaction.gasLimitPolicy = .manual(gasEstimate + 1234)
    //        let assembled = try await writeTX.assembleTransaction()
    //        let txnGasLimit = assembled.parameters.gasLimit
    //        let txnGasPrice = assembled.parameters.gasPrice
    //
    //        XCTAssert(txnGasLimit == gasEstimate + 1234)
    //        XCTAssert(txnGasPrice == gasPrice * 2)
    //    }

    func testParseTransactionDetailsForContractCreation() async throws {// Deploy contract
        let bytecode = Data.fromHex("0x608060405234801561001057600080fd5b50610100806100206000396000f30060806040526004361060525763ffffffff7c01000000000000000000000000000000000000000000000000000000006000350416630dbe671f8114605757806329e99f0714607b5780634df7e3d0146092575b600080fd5b348015606257600080fd5b50606960a4565b60408051918252519081900360200190f35b348015608657600080fd5b50609060043560aa565b005b348015609d57600080fd5b50606960ce565b60005481565b803a111560ba57600160005560cb565b803a101560cb576001600081905580555b50565b600154815600a165627a7a723058200327a504a24f70cf740239fad2ad203f21caf0ef05f7870bd88482f6fa3cf1080029")!

        let web3 = try await Web3.new(LocalTestCase.url)
        let allAddresses = try await web3.eth.ownedAccounts()
        let contract = web3.contract(Web3.Utils.estimateGasTestABI, at: nil, abiVersion: 2)!

        let parameters = [Any]()
        let deployTx = contract.prepareDeploy(bytecode: bytecode, parameters: parameters)!
        deployTx.transaction.from = allAddresses[0]
        let policies = Policies(gasLimitPolicy: .manual(3000000))
        let result = try await deployTx.writeToChain(password: "web3swift", policies: policies, sendRaw: false)
        let txHash = Data.fromHex(result.hash.stripHexPrefix())!

        Thread.sleep(forTimeInterval: 1.0)

        let receipt = try await web3.eth.transactionReceipt(txHash)

        XCTAssert(receipt.contractAddress != nil)

        switch receipt.status {
        case .notYetProcessed:
            return
        default:
            break
        }

        let details = try await web3.eth.transactionDetails(txHash)

        XCTAssert(details.transaction.to == .contractDeploymentAddress())
    }

    func testNonBatchedRequest() async throws {
        let web3 = try await Web3.new(LocalTestCase.url)
        let address = EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901")!
        let balanceResult = try await web3.eth.getBalance(for: address)

    }
}
