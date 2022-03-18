//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import XCTest
import BigInt

@testable import web3swift

class web3swift_ERC20_Class_Tests: XCTestCase {

    func testERC20TokenCreation() async throws {
        let (web3, _, receipt, _) = try await web3swift_helpers.localDeployERC20()
        let erc20token = ERC20(web3: web3, provider: web3.provider, address: receipt.contractAddress!)
        try await erc20token.readProperties()
        let symbol = try await erc20token.symbol()
        XCTAssert(symbol == "w3s")
        let name = try await erc20token.name()
        XCTAssert(name == "web3swift")
        let decimals = try await erc20token.decimals()
        XCTAssert(decimals == 18)
    }

    func testERC20tokenBalanceAndAllowance() async throws {
        let (web3, _, receipt, _) = try await web3swift_helpers.localDeployERC20()
        let erc20token = ERC20.init(web3: web3, provider: web3.provider, address: receipt.contractAddress!)

        let userAddress = EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901")!

        let balance = try await erc20token.getBalance(account: userAddress)
        let allowance = try await erc20token.getAllowance(originalOwner: userAddress, delegate: userAddress)
        XCTAssert(String(balance) == "1024")
        XCTAssert(allowance == 0)
    }
}
