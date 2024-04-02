//
//  TransactionPollingTaskTest.swift
//
//  Created by JeneaVranceanu on 10.03.2023.
//

import XCTest
import Foundation
@testable import web3swift
@testable import Web3Core

class TransactionPollingTaskTest: LocalTestCase {

    func testTransactionPolling() async throws {
        let web3 = try await Web3.new(LocalTestCase.url)
        let sendToAddress = EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901")!
        let allAddresses = try await web3.eth.ownedAccounts()
        let contract = web3.contract(Web3.Utils.coldWalletABI, at: sendToAddress)
        let writeTX = contract!.createWriteOperation("fallback")!
        writeTX.transaction.from = allAddresses[0]
        writeTX.transaction.value = 1

        let policies = Policies(gasLimitPolicy: .automatic)
        let result = try await writeTX.writeToChain(password: "", policies: policies, sendRaw: false)

        let txHash = Data.fromHex(result.hash.stripHexPrefix())!

        let transactionReceipt = try await TransactionPollingTask(transactionHash: txHash, web3Instance: web3).wait()

        XCTAssertEqual(transactionReceipt.status, .ok)
    }

}
