//
//  EventFilterTests.swift
//
//
//  Created by liugang zhang on 2023/8/24.
//

import XCTest
import Web3Core
import BigInt
import CryptoSwift
@testable import web3swift

class EventFilerTests: XCTestCase {

    /// This test tx can be found at here:
    /// https://etherscan.io/tx/0x1a1daac5b3158f16399baec9abba2c8a4b4b7ffea5992490079b6bfc4ce70004
    func testErc20Transfer() async throws {
        let web3 = try await Web3.InfuraMainnetWeb3(accessToken: Constants.infuraToken)
        let address = EthereumAddress("0xdac17f958d2ee523a2206206994597c13d831ec7")!
        let erc20 = ERC20(web3: web3, provider: web3.provider, address: address)

        let topics = erc20.contract.contract.event("Transfer", parameters: [
            "0x003e36550908907c2a2da960fd19a419b9a774b7"
        ])

        let parameters = EventFilterParameters(fromBlock: .exact(17983395), toBlock: .exact(17983395), address: [address], topics: topics)
        let result = try await web3.eth.getLogs(eventFilter: parameters)

        XCTAssertEqual(result.count, 1)

        let log = result.first!
        XCTAssertEqual(log.address.address.lowercased(), "0xdac17f958d2ee523a2206206994597c13d831ec7")
        XCTAssertEqual(log.transactionHash.toHexString().lowercased(), "1a1daac5b3158f16399baec9abba2c8a4b4b7ffea5992490079b6bfc4ce70004")

        let logTopics = log.topics.map { $0.toHexString() }
        topics.compactMap { t -> String? in
            if let t = t, case EventFilterParameters.Topic.string(let topic) = t {
                return topic
            }
            return nil
        }.forEach { t in
            XCTAssertTrue(logTopics.contains(t.stripHexPrefix()))
        }
    }
}
