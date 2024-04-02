//
//  BIP32MnemonicPhraseStringTests.swift
//
//
//  Created by Daniel Bell on 11/26/22.
//

import XCTest
@testable import Web3Core
@testable import web3swift

/// This test suite is focused on testing the ability of `BIP32Keystore`
/// to be able to parse and work with mnemonic phrase that is of type `String`.
final class BIP32MnemonicPhraseStringTests: XCTestCase {

    let mnemonic = "fruit wave dwarf banana earth journey tattoo true farm silk olive fence"

    func testBIP32keystoreExportPrivateKey() throws {
        let keystore = try BIP32Keystore(mnemonics: mnemonic, password: "", mnemonicsPassword: "")
        XCTAssertNotNil(keystore)
        let account = keystore!.addresses![0]
        let key = try keystore!.UNSAFE_getPrivateKeyData(password: "", account: account)
        XCTAssertNotNil(key)
    }

    func testBIP32keystoreMatching() throws {
        let keystore = try BIP32Keystore(mnemonics: mnemonic, password: "", mnemonicsPassword: "banana")
        XCTAssertNotNil(keystore)
        let account = keystore!.addresses![0]
        let key = try keystore!.UNSAFE_getPrivateKeyData(password: "", account: account)
        let pubKey = Utilities.privateToPublic(key, compressed: true)
        XCTAssert(pubKey?.toHexString() == "027160bd3a4d938cac609ff3a11fe9233de7b76c22a80d2b575e202cbf26631659")
    }

    func testBIP32keystoreMatchingRootNode() throws {
        let keystore = try BIP32Keystore(mnemonics: mnemonic, password: "", mnemonicsPassword: "banana")
        XCTAssertNotNil(keystore)
        let rootNode = try keystore!.serializeRootNodeToString(password: "")
        XCTAssert(rootNode == "xprvA2KM71v838kPwE8Lfr12m9DL939TZmPStMnhoFcZkr1nBwDXSG7c3pjYbMM9SaqcofK154zNSCp7W7b4boEVstZu1J3pniLQJJq7uvodfCV")
    }

    func testBIP32keystoreCustomPathMatching() throws {
        let keystore = try BIP32Keystore(mnemonics: mnemonic, password: "", mnemonicsPassword: "banana", prefixPath: "m/44'/60'/0'/0")
        XCTAssertNotNil(keystore)
        let account = keystore!.addresses![0]
        let key = try keystore!.UNSAFE_getPrivateKeyData(password: "", account: account)
        let pubKey = Utilities.privateToPublic(key, compressed: true)
        XCTAssert(pubKey?.toHexString() == "027160bd3a4d938cac609ff3a11fe9233de7b76c22a80d2b575e202cbf26631659")
    }

    func testByBIP32keystoreCreateChildAccount() throws {
        let keystore = try BIP32Keystore(mnemonics: mnemonic, password: "", mnemonicsPassword: "")
        XCTAssertNotNil(keystore)
        XCTAssertEqual(keystore!.addresses?.count, 1)
        try keystore?.createNewChildAccount(password: "")
        XCTAssertEqual(keystore?.addresses?.count, 2)
        let account = keystore!.addresses![0]
        let key = try keystore!.UNSAFE_getPrivateKeyData(password: "", account: account)
        XCTAssertNotNil(key)
    }

    func testByBIP32keystoreCreateCustomChildAccount() throws {
        let keystore = try BIP32Keystore(mnemonics: mnemonic, password: "", mnemonicsPassword: "")
        XCTAssertNotNil(keystore)
        XCTAssertEqual(keystore!.addresses?.count, 1)
        try keystore?.createNewCustomChildAccount(password: "", path: "/42/1")
        XCTAssertEqual(keystore?.addresses?.count, 2)
        let account = keystore!.addresses![1]
        let key = try keystore!.UNSAFE_getPrivateKeyData(password: "", account: account)
        XCTAssertNotNil(key)
        print(keystore!.addressStorage.paths)
    }

    func testByBIP32keystoreSaveAndDerive() throws {
        let keystore = try BIP32Keystore(mnemonics: mnemonic, password: "", mnemonicsPassword: "", prefixPath: "m/44'/60'/0'")
        XCTAssertNotNil(keystore)
        XCTAssertEqual(keystore!.addresses?.count, 1)
        try keystore?.createNewCustomChildAccount(password: "", path: "/0/1")
        XCTAssertEqual(keystore?.addresses?.count, 2)
        let data = try keystore?.serialize()
        let recreatedStore = BIP32Keystore(data!)
        XCTAssert(keystore?.addresses?.count == recreatedStore?.addresses?.count)
        XCTAssert(keystore?.rootPrefix == recreatedStore?.rootPrefix)
        print(keystore!.addresses![0].address)
        print(keystore!.addresses![1].address)
        print(recreatedStore!.addresses![0].address)
        print(recreatedStore!.addresses![1].address)
        XCTAssert(keystore?.addresses![0] == recreatedStore?.addresses![0])
        XCTAssert(keystore?.addresses![1] == recreatedStore?.addresses![1])
    }

}
