//
//  BIP44Tests.swift
//  Created by Alberto Penas Amor on 15/12/22.
//

import XCTest
import Web3Core
@testable import web3swift

final class BIP44Tests: LocalTestCase {
    
    private let mnemonic = "fruit wave dwarf banana earth journey tattoo true farm silk olive fence"

    func testBIP44DeriveWithoutWarningIfChildNodeHasPreviousChildsWithTransactions() async throws {
        let seed = try XCTUnwrap(BIP39.seedFromMmemonics(mnemonic, password: ""))
        let rootNode = try XCTUnwrap(HDNode(seed: seed))
        
        let optChildNode = try await rootNode.derive(path: "m/44'/60'/1'/0/1", warns: false)
        let childNode = try XCTUnwrap(optChildNode)
                
        XCTAssertEqual(childNode.publicKey.toHexString(), "03fe5fad1740a0c749c3c976c9b37f337204bf3df1d73d78da282dd365a7d47ad9")
        XCTAssertEqual(Utilities.publicToAddress(childNode.publicKey)?.address, "0x73C13e421eF367c4F55BBC02a8e2a2b12e82f717")
    }
}
