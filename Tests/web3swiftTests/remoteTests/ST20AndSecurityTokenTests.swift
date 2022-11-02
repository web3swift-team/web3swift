//
//  web3swift_ST20_Tests.swift
//  web3swift-iOS_Tests
//
//  Created by Anton on 15/03/2019.
//  Copyright © 2019 The Matter Inc. All rights reserved.
//
import XCTest
import BigInt
import web3swift
import Core

@testable import web3swift

// MARK: Works only with network connection
class ST20AndSecurityTokenTests: XCTestCase {

    func testERC20TokenCreation() async throws {
        let web3 = await Web3.InfuraGoerliWeb3(accessToken: Constants.infuraToken)
        let w3sTokenAddress = EthereumAddress("0x33d191db2486e0d245b44fde3fae5ed667d5694b")!
        let st20token = ST20.init(web3: web3, provider: web3.provider, address: w3sTokenAddress)
        try await st20token.readProperties()
        XCTAssertEqual(st20token.symbol(), "MIMI")
        XCTAssertEqual(st20token.name(), "Mimi")
        XCTAssertEqual(st20token.decimals(), 18)
    }

    func testST20tokenBalanceAndAllowance() async throws {
        let web3 = await Web3.InfuraGoerliWeb3(accessToken: Constants.infuraToken)
        let w3sTokenAddress = EthereumAddress("0x2dD33957C90880bE4Ee9fd5F703110BDA2E579EC")!
        let st20token = ST20.init(web3: web3, provider: web3.provider, address: w3sTokenAddress)
        let userAddress = EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901")!
        let balance = try await st20token.getBalance(account: userAddress)
        let allowance = try await st20token.getAllowance(originalOwner: userAddress, delegate: userAddress)
        XCTAssertEqual(String(balance), "0")
        XCTAssertEqual(allowance, 0)
    }

    func testSecurityTokenInvestors() async throws {
        let web3 = await Web3.InfuraGoerliWeb3(accessToken: Constants.infuraToken)
        let w3sTokenAddress = EthereumAddress("0x2dD33957C90880bE4Ee9fd5F703110BDA2E579EC")!
        let stoken = SecurityToken.init(web3: web3, provider: web3.provider, address: w3sTokenAddress)
        let investorsCount = try await stoken.investorCount()
        let stringInvestorsCount = String(investorsCount)
        XCTAssertEqual(stringInvestorsCount, "0")
    }

    // FIXME: Enable me back again
//    func testSecurityTokenGranularity() async throws {
//        let web3 = await Web3.InfuraGoerliWeb3(accessToken: Constants.infuraToken)
//        let w3sTokenAddress = EthereumAddress("0x2dD33957C90880bE4Ee9fd5F703110BDA2E579EC")!
//        let stoken = SecurityToken.init(web3: web3, provider: web3.provider, address: w3sTokenAddress)
//        let granularity = try await stoken.getGranularity()
//        let stringGranularity = String(granularity)
//        XCTAssertEqual(stringGranularity, "1000000000000000000")
//    }
}
