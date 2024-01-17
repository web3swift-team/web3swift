//
//  Web3HttpProviderTests.swift
//
//
//  Created by liugang zhang on 2023/9/2.
//

import XCTest
import Web3Core

@testable import web3swift

final class Web3HttpProviderTests: XCTestCase {

    /// if one of these rpc server lose efficacy, find a substitution from https://chainlist.org/
    func testGetNetwork() async throws {
        let requestURLstring = "https://" + Networks.Mainnet.name + Constants.infuraHttpScheme + Constants.infuraToken
        var web3 = try await Web3HttpProvider(url: URL(string: requestURLstring)!, network: nil)
        XCTAssertEqual(web3.network?.chainID, 1)

        web3 = try await Web3HttpProvider(url: URL(string: "https://arbitrum-one.publicnode.com")!, network: nil)
        XCTAssertEqual(web3.network?.chainID, 42161)

        web3 = try await Web3HttpProvider(url: URL(string: "https://rpc.ankr.com/bsc")!, network: nil)
        XCTAssertEqual(web3.network?.chainID, 56)

        web3 = try await Web3HttpProvider(url: URL(string: "https://rpc-mainnet.maticvigil.com/")!, network: nil)
        XCTAssertEqual(web3.network?.chainID, 137)

        web3 = try await Web3HttpProvider(url: URL(string: "https://optimism.gateway.tenderly.co")!, network: nil)
        XCTAssertEqual(web3.network?.chainID, 10)
    }
}
