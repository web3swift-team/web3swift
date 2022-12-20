//
//  BIP44Tests.swift
//  Created by Alberto Penas Amor on 15/12/22.
//

import XCTest
import Web3Core
@testable import web3swift

final class BIP44Tests: LocalTestCase {

    func testDeriveNoWarn() async throws {
        let rootNode = try rootNode()
        
        let childNode = try await rootNode.derive(path: "m/44'/60'/8096'/0/1", warns: false)
                
        XCTAssertEqual(try XCTUnwrap(childNode).publicKey.toHexString(), "035785d4918449c87892371c0f9ccf6e4eda40a7fb0f773f1254c064d3bba64026")
    }
   
    func testAccountZeroCanBeDerived() async throws {
        let rootNode = try rootNode()
        
        let childNode = try await rootNode.derive(path: "m/44'/60'/0'/0/255", warns: true)
        
        XCTAssertEqual(try XCTUnwrap(childNode).publicKey.toHexString(), "0262fba1af8f149258123265318114066decf50d16c1222a9d657b7de2296c2734")
    }
    
    // MARK: - private
    
    private func rootNode() throws -> HDNode {
        let mnemonic = "fruit wave dwarf banana earth journey tattoo true farm silk olive fence"
        let seed = try XCTUnwrap(BIP39.seedFromMmemonics(mnemonic, password: ""))
        return try XCTUnwrap(HDNode(seed: seed))
    }
}
