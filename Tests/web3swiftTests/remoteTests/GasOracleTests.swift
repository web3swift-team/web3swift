//
//  GasOracleTests.swift
//
//  Created by Yaroslav on 11.04.2022.
//

import XCTest
import BigInt
import Web3Core

@testable import web3swift

// MARK: Works only with network connection
class GasOracleTests: XCTestCase {

    let blockNumber: BigUInt = 14571792

    func testPretictBaseFee() async throws {
        let web3 = try await Web3.InfuraMainnetWeb3(accessToken: Constants.infuraToken)
        lazy var oracle: Oracle = .init(web3.provider, block: .exact(blockNumber), blockCount: 20, percentiles: [10, 40, 60, 90])
        let etalonPercentiles: [BigUInt] = [
            94217344703,    // 10 percentile
            105983352568,    // 40 percentile
            110561015933,   // 60 percentile
            124178275323    // 90 percentile
        ]

        let baseFeePercentiles = await oracle.baseFeePercentiles()
        XCTAssertEqual(baseFeePercentiles, etalonPercentiles, "Arrays should be equal")
    }

    func testPredictTip() async throws {
        let web3 = try await Web3.InfuraMainnetWeb3(accessToken: Constants.infuraToken)
        lazy var oracle: Oracle = .init(web3.provider, block: .exact(blockNumber), blockCount: 20, percentiles: [10, 40, 60, 90])
        let etalonPercentiles: [BigUInt] = [
            1217066957,     // 10 percentile
            1525000000,     // 40 percentile
            2047260024,     // 60 percentile
            9807181877      // 90 percentile
        ]

        let tipFeePercentiles = await oracle.tipFeePercentiles()
        XCTAssertEqual(tipFeePercentiles, etalonPercentiles, "Arrays should be equal")
    }

    func testPredictBothFee() async throws {
        let web3 = try await Web3.InfuraMainnetWeb3(accessToken: Constants.infuraToken)
        lazy var oracle: Oracle = .init(web3.provider, block: .exact(blockNumber), blockCount: 20, percentiles: [10, 40, 60, 90])
        let etalonPercentiles: ([BigUInt], [BigUInt]) = (
            baseFee: [
                94217344703,    // 10 percentile
                105983352568,    // 40 percentile
                110561015933,   // 60 percentile
                124178275323    // 90 percentile
            ],
            tip: [
                1217066957,     // 10 percentile
                1525000000,     // 40 percentile
                2047260024,     // 60 percentile
                9807181877     // 90 percentile
            ]
        )

        let bothFeesPercentiles = await oracle.bothFeesPercentiles()
        XCTAssertEqual(bothFeesPercentiles?.baseFee, etalonPercentiles.0, "Arrays should be equal")
        XCTAssertEqual(bothFeesPercentiles?.tip, etalonPercentiles.1, "Arrays should be equal")
    }

//    func testPredictLegacyGasPrice() async throws {
//        let web3 = try await Web3.InfuraMainnetWeb3(accessToken: Constants.infuraToken)
//        lazy var oracle: Web3.Oracle = .init(web3, block: .exact(blockNumber), blockCount: 20, percentiles: [10, 40, 60, 90])
//        let etalonPercentiles: [BigUInt] = [
//            93253857566,     // 10 percentile
//            106634912620,    // 40 percentile
//            111000000000,    // 60 percentile
//            127210686305     // 90 percentile
//        ]
//
//        let gasPriceLegacyPercentiles = await oracle.gasPriceLegacyPercentiles()
//        XCTAssertEqual(gasPriceLegacyPercentiles, etalonPercentiles, "Arrays should be equal")
//    }
//
//    func testAllTransactionInBlockDecodesWell() async throws {
//        let web3 = try await Web3.InfuraMainnetWeb3(accessToken: Constants.infuraToken)
//        lazy var oracle: Web3.Oracle = .init(web3, block: .exact(blockNumber), blockCount: 20, percentiles: [10, 40, 60, 90])
//        let blockWithTransaction = try await web3.eth.getBlockByNumber(blockNumber, fullTransactions: true)
//
//        let nullTransactions = blockWithTransaction.transactions.filter {
//            guard case .null = $0 else { return false }
//            return true
//        }
//
//        XCTAssert(nullTransactions.isEmpty, "This amount transaction fails to decode: \(nullTransactions.count)")
//    }

    // FIXME: Move it to external test suit.
//    func testBlockNumber() async throws {
//        let web3 = try await Web3.InfuraMainnetWeb3(accessToken: Constants.infuraToken)
//        let latestBlockNumber = try await web3.eth.getBlockNumber()
//
//    }
//
//    func testgetAccounts() async throws {
//        let web3 = try await Web3.InfuraMainnetWeb3(accessToken: Constants.infuraToken)
//        let accounts = try await web3.eth.getAccounts()
//
//    }
}
