//
//  TransactionPollingTaskRemoteTest.swift
//
//
//  Created by Jann Driessen on 13.03.23.
//

import XCTest

@testable import web3swift
@testable import Web3Core

final class TransactionPollingTaskRemoteTest: XCTestCase {

    func testTransactionPolling() async throws {
        let web3 = try await Web3.InfuraMainnetWeb3(accessToken: Constants.infuraToken)
        let txHash = Data.fromHex("0xb37cab767de85e734821f4b7b46f5093126658322a3f1b10bfef82b8009c8b82")!
        let transactionReceipt = try await TransactionPollingTask(transactionHash: txHash, web3Instance: web3).wait()
        XCTAssertEqual(transactionReceipt.status, .ok)
        XCTAssertEqual(transactionReceipt.blockHash, Data.fromHex("0xdac48e6612d3c5b21c0e4b8edd9d25687a97137c636ff57a8df9f1f01bdfd25d"))
        XCTAssertEqual(transactionReceipt.blockNumber, 16818367)
        XCTAssertEqual(transactionReceipt.gasUsed, "21000")
    }

}
