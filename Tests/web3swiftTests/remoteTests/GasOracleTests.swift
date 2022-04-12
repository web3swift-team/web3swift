//
//  OracleTests.swift
//  Web3swift
//
//  Created by Yaroslav on 11.04.2022.
//

import XCTest
import BigInt

@testable import web3swift

// MARK: Works only with network connection
class OracleTests: XCTestCase {

    let web3 = Web3.InfuraMainnetWeb3(accessToken: Constants.infuraToken)

    lazy var oracle: Web3.Oracle = .init(web3, block: "0xde5910", blockCount: 20, percentiles: [10, 40, 60, 90])

    func testPretictBaseFee() throws {
        let etalonPercentiles: [BigUInt] = [
            71456911562,    // 10 percentile
            92735433497,    // 40 percentile
            105739785122,   // 60 percentile
            118929912191    // 90 percentile
        ]

        let baseFeePercentiles = oracle.baseFeePercentiles
        print("baseFeePercentiles: \(baseFeePercentiles)")
        XCTAssertEqual(baseFeePercentiles, etalonPercentiles, "Arrays should be equal")
    }

    func testPredictTip() throws {
        let etalonPercentiles: [BigUInt] = [
            1251559157,     // 10 percentile
            1594062500,     // 40 percentile
            2268157275,     // 60 percentile
            11394017894     // 90 percentile
        ]

        let predictTip = oracle.tipFeePercentiles
        print("predictTip: \(predictTip)")
        XCTAssertEqual(predictTip, etalonPercentiles, "Arrays should be equal")
    }

    func testPredictGasPrice() throws {
        
    }
}
