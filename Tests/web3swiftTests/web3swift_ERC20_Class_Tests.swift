//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import XCTest
import BigInt
//import EthereumAddress

@testable import web3swift

class web3swift_ERC20_Class_Tests: XCTestCase {
    
    func testERC20TokenCreation() {
        let web3 = Web3.InfuraMainnetWeb3()
        let w3sTokenAddress = EthereumAddress("0x8932404A197D84Ec3Ea55971AADE11cdA1dddff1")!
        let erc20token = ERC20.init(web3: web3, provider: web3.provider, address: w3sTokenAddress)
        erc20token.readProperties()
        XCTAssert(erc20token.symbol == "w3s")
        XCTAssert(erc20token.name == "web3swift")
        XCTAssert(erc20token.decimals == 18)
    }
    
    func testERC20tokenBalanceAndAllowance() throws {
        let web3 = Web3.InfuraMainnetWeb3()
        let w3sTokenAddress = EthereumAddress("0x8932404A197D84Ec3Ea55971AADE11cdA1dddff1")!
        let erc20token = ERC20.init(web3: web3, provider: web3.provider, address: w3sTokenAddress)
        let userAddress = EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901")!
        let balance = try erc20token.getBalance(account: userAddress)
        let allowance = try erc20token.getAllowance(originalOwner: userAddress, delegate: userAddress)
        XCTAssert(String(balance) == "1024000000000000000000")
        XCTAssert(allowance == 0)
    }
}
