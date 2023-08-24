//
//  EventFilterTests.swift
//
//
//  Created by liugang zhang on 2023/8/24.
//

import XCTest
import Web3Core

@testable import web3swift

class EventFilerTests: XCTestCase {

    func testErc20Transfer() async throws {
        let web3 = try await Web3.InfuraMainnetWeb3(accessToken: Constants.infuraToken)
        let address = EthereumAddress("0xdac17f958d2ee523a2206206994597c13d831ec7")!
        let erc20 = ERC20(web3: web3, provider: web3.provider, address: address)

        let topics = erc20.contract.contract.event("Transfer", parameters: [
            "0x003e36550908907c2a2da960fd19a419b9a774b7"
        ])
        let block = try await web3.eth.block(by: .latest)
        let parameters = EventFilterParameters(fromBlock: .exact(block.number - 1000), address: [address], topics: topics)
        let result = try await web3.eth.getLogs(eventFilter: parameters)

        // result not always has a log in it.
        print(result)
    }
}
