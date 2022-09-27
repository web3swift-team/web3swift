//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//
import XCTest
import BigInt
import Core

@testable import web3swift

//TODO: refactor me
class ERC20Tests: LocalTestCase {

    func testERC20name() async throws {
        let (web3, _, receipt, _) = try await TestHelpers.localDeployERC20()
        let contract = web3.contract(Web3.Utils.erc20ABI, at: receipt.contractAddress!)!
        let readTX = contract.createReadOperation("name")!
        readTX.transaction.from = EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901")
        let response = try await readTX.callContractMethod()
        let name = response["0"] as? String
        XCTAssert(name == "web3swift", "Failed to create ERC20 name transaction")
    }

    func testERC20tokenBalance() async throws {
        let (web3, _, receipt, _) = try await TestHelpers.localDeployERC20()

        let addressOfUser = EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901")!
        let contract = web3.contract(Web3.Utils.erc20ABI, at: receipt.contractAddress!, abiVersion: 2)!
        guard let readTX = contract.createReadOperation("balanceOf", parameters: [addressOfUser] as [AnyObject]) else {return XCTFail()}
        readTX.transaction.from = addressOfUser
        let tokenBalance = try await readTX.callContractMethod()
        guard let bal = tokenBalance["0"] as? BigUInt else {return XCTFail()}
        print(String(bal))
    }

    // FIXME: Make me work
//    func testERC20TokenSend() async throws {
//        let web3 = Web3.
//        let value: String = "1.0" // In Tokens
//        let walletAddress = EthereumAddress(wallet.address)! // Your wallet address
//        let toAddress = EthereumAddress(toAddressString)!
//        let erc20ContractAddress = EthereumAddress(token.address)!
//        let contract = web3.contract(Web3.Utils.erc20ABI, at: erc20ContractAddress, abiVersion: 2)!
//        let amount = Web3.Utils.parseToBigUInt(value, units: .eth)
//        var options = CodableTransaction.emptyTransaction
//        options.value = amount
//        options.from = walletAddress
//        options.gasPricePolicy = .automatic
//        options.gasLimitPolicy = .automatic
//        let method = "transfer"
//        let tx = contract.write(
//          method,
//          parameters: [toAddress, amount] as [AnyObject],
//          extraData: Data(),
//          transaction: options)!
//    }
}
