//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import XCTest
@testable import web3swift

class web3swiftEIP681Tests: XCTestCase {
    
    //Custom payment
    //ethereum:0xfb6916095ca1df60bb79Ce92ce3ea74c37c5d359?value=2.014e18
    
    
    //ERC20 transfer
    //ethereum:0x8932404A197D84Ec3Ea55971AADE11cdA1dddff1/transfer?address=0x6891dC3962e710f0ff711B9c6acc26133Fd35Cb4&uint256=1
    
    func testEIP681Parsing() async throws {
        let parsed = await Web3.EIP681CodeParser.parse("ethereum:0x5ffc014343cd971b7eb70732021e26c35b744cc4?value=2.014e18")
        XCTAssert(parsed != nil)
    }
    
    func testEIP681Parsing2() async throws {
        let parsed = await Web3.EIP681CodeParser.parse("ethereum:0x8932404A197D84Ec3Ea55971AADE11cdA1dddff1/transfer?address=0x6891dC3962e710f0ff711B9c6acc26133Fd35Cb4&uint256=1")
        XCTAssert(parsed != nil)
    }
    
    func testEIP681ENSParsing() async throws {
        let parsed = await Web3.EIP681CodeParser.parse("ethereum:somename.eth/transfer?address=somename.eth&uint256=1")
        XCTAssert(parsed != nil)
    }
}
