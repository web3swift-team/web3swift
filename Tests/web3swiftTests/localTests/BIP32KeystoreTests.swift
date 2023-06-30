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
        /// Arrange
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

        /// Act
        let addresses = try keystore.getAddressForAccount(password: password,
                                                          number: addressesCount)

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

        /// Assert
        XCTAssertEqual(UInt(addresses.count), addressesCount)
        XCTAssertNotEqual(addresses[11], addresses[1])
        XCTAssertEqual(addresses.last?.address, address)
        XCTAssertEqual("0xEF22ebb8Bb5CDa4EaCc98b280c94Cbaa3828566F", addresses.last?.address)
        XCTAssertEqual("0xdc69CBFE39c46B104875DF9602dFdCDB9b862a16", addresses.first?.address)
        XCTAssertEqual("0xdc69CBFE39c46B104875DF9602dFdCDB9b862a16", sameKeystore.addresses?.first?.address)
        XCTAssertEqual("0x971CF293b46162CD03DD9Cc39E89B592988DD6C4", addresses[Int(addressesCount / 2)].address)
        XCTAssertEqual("0x3B565482a93CE4adA9dE0fD3c118bd41E24CC23C", addresses[10].address)
    }
}
