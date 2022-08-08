//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import XCTest
import BigInt

@testable import web3swift

class ERC20ClassTests: LocalTestCase {

    func testERC20TokenCreation() throws {
        let (_, receipt, _) = try TestHelpers.localDeployERC20(ganache)
        let erc20token = ERC20.init(web3: ganache, provider: ganache.provider, address: receipt.contractAddress!)
        erc20token.readProperties()
        XCTAssert(erc20token.symbol == "w3s")
        XCTAssert(erc20token.name == "web3swift")
        XCTAssert(erc20token.decimals == 18)
    }

    func testERC20tokenBalanceAndAllowance() throws {
        let (_, receipt, _) = try TestHelpers.localDeployERC20(ganache)
        let erc20token = ERC20.init(web3: ganache, provider: ganache.provider, address: receipt.contractAddress!)

        let userAddress = EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901")!

        let balance = try erc20token.getBalance(account: userAddress)
        let allowance = try erc20token.getAllowance(originalOwner: userAddress, delegate: userAddress)
        XCTAssert(String(balance) == "1024")
        XCTAssert(allowance == 0)
    }
}
