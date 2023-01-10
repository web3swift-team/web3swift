//
//  TransactionReceiptTests.swift
//
//  Created by JeneaVranceanu on 10.01.2023.
//

import Foundation
import XCTest
import BigInt

@testable import Web3Core

class TransactionReceiptTests: XCTestCase {

    func testDecodeTransactionReceiptJson() throws {
        let transactionHash: Data = Data.fromHex("0xbe981126f05b4110d5bf4a22d474b6a7ef861ae79fc6939260bb2c3003367eed")!
        let blockHash: Data = Data.fromHex("0x0103a5759c39720ecd23d48281e32526ae50eaa3e651a5e8c86e47838e060cb8")!
        let blockNumber: BigUInt = 12
        let transactionIndex: BigUInt = 10
        let contractAddress = EthereumAddress("0xdf85ee41abbf15cdf1dbf89fb7af9a9557c5dd7e")!
        let cumulativeGasUsed: BigUInt = 789456132
        let gasUsed: BigUInt = 8857745
        let effectiveGasPrice: BigUInt = 123456
        /// This is not an EventLog decoding test so the array is empty
        let logs: [EventLog] = []
        let status = TransactionReceipt.TXStatus.ok
        let logsBloom = EthereumBloomFilter(12348880)!

        let transactionJson = "{\"transactionHash\":\"\(transactionHash.toHexString().addHexPrefix())\",\"transactionIndex\":\"\(transactionIndex.hexString)\",\"blockNumber\":\"\(blockNumber.hexString)\",\"blockHash\":\"\(blockHash.toHexString().addHexPrefix())\",\"from\":\"0xdf85ee41abbf15cdf1dbf89fb7af9a9557c5dd7e\",\"to\":\"0xe22b8979739d724343bd002f9f432f5990879901\",\"cumulativeGasUsed\":\"\(cumulativeGasUsed.hexString)\",\"gasUsed\":\"\(gasUsed.hexString)\",\"contractAddress\":\"\(contractAddress.address)\",\"logs\":[],\"logsBloom\":\"\(logsBloom.bytes.toHexString().addHexPrefix())\",\"status\":\"0x1\",\"effectiveGasPrice\":\"\(effectiveGasPrice.hexString)\",\"type\":\"0x2\"}"
        let transactionReceipt = try JSONDecoder().decode(TransactionReceipt.self, from: transactionJson.data(using: .utf8)!)

        XCTAssertEqual(blockHash, transactionReceipt.blockHash)
        XCTAssertEqual(blockNumber, transactionReceipt.blockNumber)
        XCTAssertEqual(transactionIndex, transactionReceipt.transactionIndex)
        XCTAssertEqual(contractAddress, transactionReceipt.contractAddress)
        XCTAssertEqual(cumulativeGasUsed, transactionReceipt.cumulativeGasUsed)
        XCTAssertEqual(gasUsed, transactionReceipt.gasUsed)
        XCTAssertEqual(effectiveGasPrice, transactionReceipt.effectiveGasPrice)
        XCTAssertEqual(logs.count, transactionReceipt.logs.count)
        XCTAssertEqual(status, transactionReceipt.status)
        XCTAssertEqual(logsBloom.bytes, transactionReceipt.logsBloom?.bytes)
    }

}
