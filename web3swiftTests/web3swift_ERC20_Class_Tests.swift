//
//  web3swift_ERC20_Class_Tests.swift
//  web3swift-iOS_Tests
//
//  Created by Alex Vlasov on 28.08.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import XCTest
import BigInt
import Result
import secp256k1_ios

@testable import web3swift_iOS

class web3swift_ERC20_Class_Tests: XCTestCase {
    
    func testERC20TokenCreation() {
        let web3 = Web3.InfuraMainnetWeb3()
        let SALTtokenAddress = EthereumAddress("0x4156D3342D5c385a87D264F90653733592000581")!
        let erc20token = ERC20.init(web3: web3, provider: web3.provider, address: SALTtokenAddress)
        erc20token.readProperties()
        XCTAssert(erc20token.symbol == "SALT")
        XCTAssert(erc20token.name == "Salt")
        XCTAssert(erc20token.decimals == 8)
    }
    
    func testERC20tokenBalanceAndAllowance() {
        let web3 = Web3.InfuraMainnetWeb3()
        let SALTtokenAddress = EthereumAddress("0x4156D3342D5c385a87D264F90653733592000581")!
        let erc20token = ERC20.init(web3: web3, provider: web3.provider, address: SALTtokenAddress)
        let userAddress = EthereumAddress("0x6394b37cf80a7358b38068f0ca4760ad49983a1b")!
        guard case .success(let balance) = erc20token.getBalance(account: userAddress) else {return XCTFail()}
        guard case .success(let allowance) = erc20token.getAllowance(originalOwner: userAddress, delegate: userAddress) else {return XCTFail()}
        XCTAssert(String(balance) == "28986212")
        XCTAssert(allowance == 0)
    }
}
