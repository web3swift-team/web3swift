////
////  Created by Alex Vlasov.
////  Copyright © 2018 Alex Vlasov. All rights reserved.
////
//
// import XCTest
// import Web3Core
// import BigInt
//
// @testable import web3swift
//
// class web3swiftPromisesTests: XCTestCase {
//    var urlSession : URLSession?
//
//    func testGetBalancePromise() async throws {
//        let web3 = try await Web3.new(LocalTestCase.url)
//        let balance = try await web3.eth.getBalance(for: EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901")!)
//
//    }
//
//    func testEstimateGasPromise() async throws {
//        let web3 = try await Web3.new(LocalTestCase.url)
//        let sendToAddress = EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901")
//        let tempKeystore = try! EthereumKeystoreV3(password: "")
//        let keystoreManager = KeystoreManager([tempKeystore!])
//        web3.addKeystoreManager(keystoreManager)
//        let contract = web3.contract(Web3.Utils.coldWalletABI, at: sendToAddress, abiVersion: 2)
//        guard let writeTX = contract?.write("fallback") else {return XCTFail()}
//        writeTX.transaction.from = tempKeystore!.addresses?.first
//        writeTX.transaction.value = BigUInt("1.0", Utilities.Units.eth)!
//        let estimate = try await writeTX.estimateGas(with: nil)
//
//        XCTAssertEqual(estimate, 21000)
//    }
//
//    func testEstimateGasFixPromise() async throws {
//        // Deploy contract
//        let bytecode = Data.fromHex("0x608060405234801561001057600080fd5b50610100806100206000396000f30060806040526004361060525763ffffffff7c01000000000000000000000000000000000000000000000000000000006000350416630dbe671f8114605757806329e99f0714607b5780634df7e3d0146092575b600080fd5b348015606257600080fd5b50606960a4565b60408051918252519081900360200190f35b348015608657600080fd5b50609060043560aa565b005b348015609d57600080fd5b50606960ce565b60005481565b803a111560ba57600160005560cb565b803a101560cb576001600081905580555b50565b600154815600a165627a7a723058200327a504a24f70cf740239fad2ad203f21caf0ef05f7870bd88482f6fa3cf1080029")!
//
//        let web3 = try await Web3.new(LocalTestCase.url)
//        let allAddresses = try await web3.eth.ownedAccounts()
//        let contract = web3.contract(Web3.Utils.estimateGasTestABI, at: nil, abiVersion: 2)!
//
//        let parameters = []
//        let deployTx = contract.deploy(bytecode: bytecode, parameters: parameters)!
//        deployTx.transaction.from = allAddresses[0]
//        deployTx.transaction.gasLimitPolicy = .manual(3000000)
//        let result = try await deployTx.send(password: "web3swift")
//        let txHash = result.hash
//
//
//        Thread.sleep(forTimeInterval: 1.0)
//
//        let receipt = try await web3.eth.transactionReceipt(txHash)
//
//
//        switch receipt.status {
//        case .notYetProcessed:
//            return
//        default:
//            break
//        }
//
//        let tempKeystore = try! EthereumKeystoreV3(password: "")
//        let keystoreManager = KeystoreManager([tempKeystore!])
//        web3.addKeystoreManager(keystoreManager)
//
//        guard let contractAddress = receipt.contractAddress,
//              let contract = web3.contract(Web3.Utils.estimateGasTestABI,
//                                           at: contractAddress,
//                                           abiVersion: 2) else {
//            return
//        }
//
//        var options = CodableTransaction.emptyTransaction
//        let fromAddress = tempKeystore!.addresses?.first
//        options.from = fromAddress
//
//        let amount1 = Utilities.parseToBigUInt("0.000000000000000001", units: Utilities.Units.eth) // 1 wei
//
//        // MARK: Writing Data flow
//        guard let tx1 = contract.write("test",
//                                       parameters: [amount1],
//                                       extraData: Data(),
//                                       transaction: options) else {
//            return
//        }
//        // MARK: Writing Data flow
//        let estimate1 = try await tx1.estimateGas(with: nil)
//
//
//        let amount2 = Utilities.parseToBigUInt("0.00000005", units: .eth) // 50 gwei
//
//        // MARK: Writing Data flow
//        guard let tx2 = contract.write("test",
//                                       parameters: [amount2],
//                                       extraData: Data(),
//                                       transaction: options) else {
//            return
//        }
//        // MARK: Writing Data flow
//        let estimate2 = try await tx2.estimateGas(with: nil)
//
//        XCTAssertLessThanOrEqual(estimate2 - estimate1, 22000)
//    }
//    // FIXME: Temporary deleted method `sendETH` should be restored.
//    //    func testSendETHPromise() async throws {
//    //        let web3 = try await Web3.new(LocalTestCase.url)
//    //        let allAddresses = try await web3.eth.ownedAccounts()
//    //        let gasPrice = try await web3.eth.gasPrice()
//    //        let sendToAddress = EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901")!
//    //        guard let writeTX = web3.eth.sendETH(to: sendToAddress, amount: "0.001") else {return XCTFail()}
//    //        writeTX.transaction.from = allAddresses[0]
//    //        writeTX.transaction.gasPricePolicy = .manual(gasPricePolicy)
//    //        let result = try await writeTX.send()
//    //
//    //    }
//    //
//    func testERC20tokenBalancePromise() async throws {
//        let (web3, _, receipt, _) = try await TestHelpers.localDeployERC20()
//
//        let token = web3.contract(Web3.Utils.erc20ABI, at: receipt.contractAddress, abiVersion: 2)!
//
//        let userAddress = EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901")!
//        let tokenBalance = try await token.read("balanceOf", parameters: [userAddress])!.decodedData()
//        guard let bal = tokenBalance["0"] as? BigUInt else {return XCTFail()}
//        )
//    }
// }
