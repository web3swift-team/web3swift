//
//  BIP39Tests.swift
//
//
//  Created by Daniel Bell on 11/26/22.
//

import XCTest
@testable import Web3Core
@testable import web3swift

final class BIP39Tests: XCTestCase {

    func testBIP39() throws {
        var entropy = Data.fromHex("00000000000000000000000000000000")!
        var phrase = BIP39.generateMnemonicsFromEntropy(entropy: entropy)
        XCTAssert( phrase == "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about")
        var seed = BIP39.seedFromMmemonics(phrase!, password: "TREZOR")
        XCTAssert(seed?.toHexString() == "c55257c360c07c72029aebc1b53c05ed0362ada38ead3e3e9efa3708e53495531f09a6987599d18264c1e1c92f2cf141630c7a3c4ab7c81b2f001698e7463b04")
        entropy = Data.fromHex("68a79eaca2324873eacc50cb9c6eca8cc68ea5d936f98787c60c7ebc74e6ce7c")!
        phrase = BIP39.generateMnemonicsFromEntropy(entropy: entropy)
        XCTAssert( phrase == "hamster diagram private dutch cause delay private meat slide toddler razor book happy fancy gospel tennis maple dilemma loan word shrug inflict delay length")
        seed = BIP39.seedFromMmemonics(phrase!, password: "TREZOR")
        XCTAssert(seed?.toHexString() == "64c87cde7e12ecf6704ab95bb1408bef047c22db4cc7491c4271d170a1b213d20b385bc1588d9c7b38f1b39d415665b8a9030c9ec653d75e65f847d8fc1fc440")
    }

    func testBIP39SeedAndMnemConversions() throws {
        let seed = Data.randomBytes(length: 32)!
        let mnemonics = BIP39.generateMnemonicsFromEntropy(entropy: seed)
        let recoveredSeed = BIP39.mnemonicsToEntropy(mnemonics!, language: .english)
        XCTAssert(seed == recoveredSeed)
    }

    /// Test cases were borrowed from https://github.com/trezor/python-mnemonic/blob/master/vectors.json
    func testBIP39MnemonicIsMultipleOfThree() {
        // https://github.com/trezor/python-mnemonic/blob/master/vectors.json#L95
        let mnemonic_12 = "scheme spot photo card baby mountain device kick cradle pact join borrow"
        let entropy_12 = BIP39.mnemonicsToEntropy(mnemonic_12, language: .english)
        XCTAssertEqual(entropy_12!.toHexString(), "c0ba5a8e914111210f2bd131f3d5e08d")

        let mnemonic_15 = "foster muscle start pluck when army tool surprise essay monitor impulse hello segment garage twenty"
        let entropy_15 = BIP39.mnemonicsToEntropy(mnemonic_15, language: .english)
        XCTAssertEqual(entropy_15!.toHexString(), "5c123352d35fa218392ed34d31e1c8b56c32befa")

        // https://github.com/trezor/python-mnemonic/blob/master/vectors.json#L101
        let mnemonic_18 = "horn tenant knee talent sponsor spell gate clip pulse soap slush warm silver nephew swap uncle crack brave"
        let entropy_18 = BIP39.mnemonicsToEntropy(mnemonic_18, language: .english)
        XCTAssertEqual(entropy_18!.toHexString(), "6d9be1ee6ebd27a258115aad99b7317b9c8d28b6d76431c3")

        let mnemonic_21 = "weird change toe upper damp panel unaware long noise resource grant prevent file live travel price cry danger fix manage base"
        let entropy_21 = BIP39.mnemonicsToEntropy(mnemonic_21, language: .english)
        XCTAssertEqual(entropy_21!.toHexString(), "f924c78e7783733f3b1c1e95d6f196d525630579e5533526ed604371")

        // https://github.com/trezor/python-mnemonic/blob/master/vectors.json#L107
        let mnemonic_24 = "panda eyebrow bullet gorilla call smoke muffin taste mesh discover soft ostrich alcohol speed nation flash devote level hobby quick inner drive ghost inside"
        let entropy_24 = BIP39.mnemonicsToEntropy(mnemonic_24, language: .english)
        XCTAssertEqual(entropy_24!.toHexString(), "9f6a2878b2520799a44ef18bc7df394e7061a224d2c33cd015b157d746869863")

        // Invalid mnemonics

        let mnemonic_9 = "initial repeat scout eye october lucky rabbit enact unfair"
        XCTAssertNil(BIP39.mnemonicsToEntropy(mnemonic_9, language: .english))

        let mnemonic_16 = "success drip spoon lunar effort unfold clinic seminar custom protect orchard correct pledge cousin slab visa"
        XCTAssertNil(BIP39.mnemonicsToEntropy(mnemonic_16, language: .english))

        let mnemonic_27 = "clock venue style demise net float differ click object poet afraid october hurry organ faint inject cart trade test immense gentle speak almost rude success drip spoon"
        XCTAssertNil(BIP39.mnemonicsToEntropy(mnemonic_27, language: .english))
    }

    func testNewBIP32keystore() throws {
        let mnemonic = try BIP39.generateMnemonics(bitsOfEntropy: 256)!
        let keystore = try BIP32Keystore(mnemonics: mnemonic, password: "", mnemonicsPassword: "")
        XCTAssert(keystore != nil)
    }

    func testSameAddressesFromTheSameMnemonics() throws {
        let mnemonic = try BIP39.generateMnemonics(bitsOfEntropy: 256)!
        let keystore1 = try BIP32Keystore(mnemonics: mnemonic, password: "", mnemonicsPassword: "")
        let keystore2 = try BIP32Keystore(mnemonics: mnemonic, password: "", mnemonicsPassword: "")
        XCTAssert(keystore1?.addresses?.first == keystore2?.addresses?.first)
    }

    func testBIP39Array() throws {
        var entropy = Data.fromHex("00000000000000000000000000000000")!
        var phrase = BIP39.generateMnemonicsFrom(entropy: entropy)
        XCTAssert( phrase == ["abandon", "abandon", "abandon", "abandon", "abandon", "abandon", "abandon", "abandon", "abandon", "abandon", "abandon", "about"])
        var seed = BIP39.seedFromMmemonics(phrase, password: "TREZOR")
        XCTAssert(seed?.toHexString() == "c55257c360c07c72029aebc1b53c05ed0362ada38ead3e3e9efa3708e53495531f09a6987599d18264c1e1c92f2cf141630c7a3c4ab7c81b2f001698e7463b04")
        entropy = Data.fromHex("68a79eaca2324873eacc50cb9c6eca8cc68ea5d936f98787c60c7ebc74e6ce7c")!
        phrase = BIP39.generateMnemonicsFrom(entropy: entropy)
        XCTAssert( phrase == ["hamster", "diagram", "private", "dutch", "cause", "delay", "private", "meat", "slide", "toddler", "razor", "book", "happy", "fancy", "gospel", "tennis", "maple", "dilemma", "loan", "word", "shrug", "inflict", "delay", "length"])
        seed = BIP39.seedFromMmemonics(phrase, password: "TREZOR")
        XCTAssert(seed?.toHexString() == "64c87cde7e12ecf6704ab95bb1408bef047c22db4cc7491c4271d170a1b213d20b385bc1588d9c7b38f1b39d415665b8a9030c9ec653d75e65f847d8fc1fc440")
    }

    func testBIP39SeedAndMnemConversionsArray() throws {
        let seed = Data.randomBytes(length: 32)!
        let mnemonics = BIP39.generateMnemonicsFrom(entropy: seed)
        let recoveredSeed = BIP39.mnemonicsToEntropy(mnemonics, language: .english)
        XCTAssert(seed == recoveredSeed)
    }

    /// Test cases were borrowed from https://github.com/trezor/python-mnemonic/blob/master/vectors.json
    func testBIP39MnemonicIsMultipleOfThreeArray() {
        // https://github.com/trezor/python-mnemonic/blob/master/vectors.json#L95
        let mnemonic_12 = ["scheme", "spot", "photo", "card", "baby", "mountain", "device", "kick", "cradle", "pact", "join", "borrow"]
        let entropy_12 = BIP39.mnemonicsToEntropy(mnemonic_12, language: .english)
        XCTAssertEqual(entropy_12!.toHexString(), "c0ba5a8e914111210f2bd131f3d5e08d")

        let mnemonic_15 = ["foster", "muscle", "start", "pluck", "when", "army", "tool", "surprise", "essay", "monitor", "impulse", "hello", "segment", "garage", "twenty"]
        let entropy_15 = BIP39.mnemonicsToEntropy(mnemonic_15, language: .english)
        XCTAssertEqual(entropy_15!.toHexString(), "5c123352d35fa218392ed34d31e1c8b56c32befa")

        // https://github.com/trezor/python-mnemonic/blob/master/vectors.json#L101
        let mnemonic_18 = ["horn", "tenant", "knee", "talent", "sponsor", "spell", "gate", "clip", "pulse", "soap", "slush", "warm", "silver", "nephew", "swap", "uncle", "crack", "brave"]
        let entropy_18 = BIP39.mnemonicsToEntropy(mnemonic_18, language: .english)
        XCTAssertEqual(entropy_18!.toHexString(), "6d9be1ee6ebd27a258115aad99b7317b9c8d28b6d76431c3")

        let mnemonic_21 = ["weird", "change", "toe", "upper", "damp", "panel", "unaware", "long", "noise", "resource", "grant", "prevent", "file", "live", "travel", "price", "cry", "danger", "fix", "manage", "base"]
        let entropy_21 = BIP39.mnemonicsToEntropy(mnemonic_21, language: .english)
        XCTAssertEqual(entropy_21!.toHexString(), "f924c78e7783733f3b1c1e95d6f196d525630579e5533526ed604371")

        // https://github.com/trezor/python-mnemonic/blob/master/vectors.json#L107
        let mnemonic_24 = ["panda", "eyebrow", "bullet", "gorilla", "call", "smoke", "muffin", "taste", "mesh", "discover", "soft", "ostrich", "alcohol", "speed", "nation", "flash", "devote", "level", "hobby", "quick", "inner", "drive", "ghost", "inside"]
        let entropy_24 = BIP39.mnemonicsToEntropy(mnemonic_24, language: .english)
        XCTAssertEqual(entropy_24!.toHexString(), "9f6a2878b2520799a44ef18bc7df394e7061a224d2c33cd015b157d746869863")

        // Invalid mnemonics

        let mnemonic_9 = ["initial", "repeat", "scout", "eye", "october", "lucky", "rabbit", "enact", "unfair"]
        XCTAssertNil(BIP39.mnemonicsToEntropy(mnemonic_9, language: .english))

        let mnemonic_16 = ["success", "drip", "spoon", "lunar", "effort", "unfold", "clinic", "seminar", "custom", "protect", "orchard", "correct", "pledge", "cousin", "slab", "visa"]
        XCTAssertNil(BIP39.mnemonicsToEntropy(mnemonic_16, language: .english))

        let mnemonic_27 = ["clock", "venue", "style", "demise", "net", "float", "differ", "click", "object", "poet", "afraid", "october", "hurry", "organ", "faint", "inject", "cart", "trade", "test", "immense", "gentle", "speak", "almost", "rude", "success", "drip", "spoon"]
        XCTAssertNil(BIP39.mnemonicsToEntropy(mnemonic_27, language: .english))
    }

    func testNewBIP32keystoreArray() throws {
        let mnemonic = try BIP39.generateMnemonics(entropy: 256)
        let keystore = try BIP32Keystore(mnemonicsPhrase: mnemonic, password: "", mnemonicsPassword: "")
        XCTAssert(keystore != nil)
    }

    func testSameAddressesFromTheSameMnemonicsArray() throws {
        let mnemonic = try BIP39.generateMnemonics(entropy: 256)
        let keystore1 = try BIP32Keystore(mnemonicsPhrase: mnemonic, password: "", mnemonicsPassword: "")
        let keystore2 = try BIP32Keystore(mnemonicsPhrase: mnemonic, password: "", mnemonicsPassword: "")
        XCTAssert(keystore1?.addresses?.first == keystore2?.addresses?.first)
    }

    func testWrongBitsOfEntropyMustThrow() throws {
        XCTAssertThrowsError(try BIP39.generateMnemonics(entropy: 127))
        XCTAssertThrowsError(try BIP39.generateMnemonics(entropy: 255))
        XCTAssertThrowsError(try BIP39.generateMnemonics(entropy: 32))
        XCTAssertThrowsError(try BIP39.generateMnemonics(entropy: 288))
    }

    func testCorrectBitsOfEntropy() throws {
        XCTAssertFalse(try BIP39.generateMnemonics(entropy: 128).isEmpty)
        XCTAssertFalse(try BIP39.generateMnemonics(entropy: 160).isEmpty)
        XCTAssertFalse(try BIP39.generateMnemonics(entropy: 192).isEmpty)
        XCTAssertFalse(try BIP39.generateMnemonics(entropy: 224).isEmpty)
        XCTAssertFalse(try BIP39.generateMnemonics(entropy: 256).isEmpty)
    }

}
