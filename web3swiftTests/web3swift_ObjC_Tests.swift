//
//  web3swift_ObjC_Tests.swift
//  web3swift-iOS_Tests
//
//  Created by Alexander Vlasov on 08.08.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import XCTest
@testable import web3swift_iOS

class web3swift_ObjC_Tests: XCTestCase {
    func testBalance() {
        let web3 = _ObjCWeb3.InfuraMainnetWeb3()
        let address = _ObjCEthereumAddress(address: "0x6394b37Cf80A7358b38068f0CA4760ad49983a1B")
        let err: NSErrorPointer = NSErrorPointer(nilLiteral: ())
        let balance = web3.web3Eth.getBalance(address: address, error: err)
        XCTAssert(err?.pointee == nil)
        XCTAssert(balance != nil)
    }
}
