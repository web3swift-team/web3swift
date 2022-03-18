//
//  web3swift_ST20_Tests.swift
//  web3swift-iOS_Tests
//
//  Created by Anton on 15/03/2019.
//  Copyright © 2019 The Matter Inc. All rights reserved.
//
import XCTest
import BigInt

@testable import web3swift

// MARK: Works only with network connection
class web3swift_ST20AndSecurityToken_Tests: XCTestCase {

    func testERC20TokenCreation() async throws {
        let web3 = try Web3.InfuraKovanWeb3()
        let w3sTokenAddress = EthereumAddress("0x2dD33957C90880bE4Ee9fd5F703110BDA2E579EC")!
        let st20token = ST20.init(web3: web3, provider: web3.provider, address: w3sTokenAddress)
        try await st20token.readProperties()
        let symbol = try await st20token.symbol()
        let name = try await st20token.name()
        let decimals = try await st20token.decimals()
        XCTAssert(symbol == "MIMI")
        XCTAssert(name == "Mimi")
        XCTAssert(decimals == 18)
    }

    func testST20tokenBalanceAndAllowance() async throws {
        let web3 = try Web3.InfuraKovanWeb3()
        let w3sTokenAddress = EthereumAddress("0x2dD33957C90880bE4Ee9fd5F703110BDA2E579EC")!
        let st20token = ST20.init(web3: web3, provider: web3.provider, address: w3sTokenAddress)
        let userAddress = EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901")!
        let balance = try await st20token.getBalance(account: userAddress)
        let allowance = try await st20token.getAllowance(originalOwner: userAddress, delegate: userAddress)
        XCTAssert(String(balance) == "0")
        XCTAssert(allowance == 0)
    }

    func testSecurityTokenInvestors() async throws {
        let web3 = try Web3.InfuraKovanWeb3()
        let w3sTokenAddress = EthereumAddress("0x2dD33957C90880bE4Ee9fd5F703110BDA2E579EC")!
        let stoken = SecurityToken.init(web3: web3, provider: web3.provider, address: w3sTokenAddress)
        let investorsCount = try await stoken.investorCount()
        let stringInvestorsCount = String(investorsCount)
        XCTAssert(stringInvestorsCount == "0")
    }

    func testSecurityTokenGranularity() async throws {
        let web3 = try Web3.InfuraKovanWeb3()
        let w3sTokenAddress = EthereumAddress("0x2dD33957C90880bE4Ee9fd5F703110BDA2E579EC")!
        let stoken = SecurityToken.init(web3: web3, provider: web3.provider, address: w3sTokenAddress)
        let granularity = try await stoken.getGranularity()
        let stringGranularity = String(granularity)
        XCTAssert(stringGranularity == "1000000000000000000")
    }
}
