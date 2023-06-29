//
//  BIP32KeystoreTests.swift
//  localTests
//
//  Created by 6od9i on 29.06.2023.
//

import Foundation
import XCTest
import Web3Core

@testable import web3swift

class BIP32KeystoreTests: XCTestCase {
    func testAddressGeneration() throws {
        /// Seed randomly generated for this test
        let mnemonic = "resource beyond merit enemy foot piece reveal eagle nothing luggage goose spot"
        let password = "test_password"
        
        let addressesCount: UInt = 101
        
        guard let keystore = try BIP32Keystore(
            mnemonics: mnemonic,
            password: password,
            mnemonicsPassword: "",
            language: .english,
            prefixPath: HDNode.defaultPathMetamaskPrefix) else {
            XCTFail("Keystore has not generated")
            throw NSError(domain: "0", code: 0)
        }
        
        let addresses = try keystore.getAddressForAccount(password: password,
                                                          number: addressesCount)
        XCTAssertEqual(UInt(addresses.count), addressesCount)
        XCTAssertNotEqual(addresses[11], addresses[1])
        
        guard let sameKeystore = try BIP32Keystore(
            mnemonics: mnemonic,
            password: password,
            mnemonicsPassword: "",
            language: .english,
            prefixPath: HDNode.defaultPathMetamaskPrefix) else {
            XCTFail("Keystore has not generated")
            throw NSError(domain: "0", code: 0)
        }
        
        let walletNumber = addressesCount - 1
        try sameKeystore.createNewCustomChildAccount(password: password,
                                                     path: HDNode.defaultPathMetamaskPrefix + "/\(walletNumber)")
        let address = sameKeystore.addresses?.last?.address
        XCTAssertEqual(addresses.last?.address, address)
    }
}
