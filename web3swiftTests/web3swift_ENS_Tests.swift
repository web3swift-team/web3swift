//
//  web3swift_ENS_Tests.swift
//  web3swift-iOS_Tests
//
//  Created by Alex Vlasov on 08.09.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import XCTest
@testable import web3swift_iOS
class web3swift_ENS_Tests: XCTestCase {
    
    func testDomainNormalization() {
        let normalizedString = NameHash.normalizeDomainName("example.ens")
        print(normalizedString)
    }
    
    func testNameHash() {
        XCTAssertEqual(NameHash.nameHash(""), Data.fromHex("0x0000000000000000000000000000000000000000000000000000000000000000"))
        XCTAssertEqual(NameHash.nameHash("eth"), Data.fromHex("0x93cdeb708b7545dc668eb9280176169d1c33cfd8ed6f04690a0bcc88a93fc4ae"))
        XCTAssertEqual(NameHash.nameHash("foo.eth"), Data.fromHex("0xde9b09fd7c5f901e23a3f19fecc54828e9c848539801e86591bd9801b019f84f"))
    }
    
}
