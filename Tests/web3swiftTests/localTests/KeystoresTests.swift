//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import XCTest
import CryptoSwift
import Web3Core

@testable import web3swift

class KeystoresTests: LocalTestCase {

    let mnemonic = "fruit wave dwarf banana earth journey tattoo true farm silk olive fence"

    func testBIP39 () throws {
        var entropy = Data.fromHex("00000000000000000000000000000000")!
        var phrase = BIP39.generateMnemonicsFromEntropy(entropy: entropy)
        XCTAssert(phrase == "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about")
        var seed = BIP39.seedFromMmemonics(phrase!, password: "TREZOR")
        XCTAssert(seed?.toHexString() == "c55257c360c07c72029aebc1b53c05ed0362ada38ead3e3e9efa3708e53495531f09a6987599d18264c1e1c92f2cf141630c7a3c4ab7c81b2f001698e7463b04")
        entropy = Data.fromHex("68a79eaca2324873eacc50cb9c6eca8cc68ea5d936f98787c60c7ebc74e6ce7c")!
        phrase = BIP39.generateMnemonicsFromEntropy(entropy: entropy)
        XCTAssert(phrase == "hamster diagram private dutch cause delay private meat slide toddler razor book happy fancy gospel tennis maple dilemma loan word shrug inflict delay length")
        seed = BIP39.seedFromMmemonics(phrase!, password: "TREZOR")
        XCTAssert(seed?.toHexString() == "64c87cde7e12ecf6704ab95bb1408bef047c22db4cc7491c4271d170a1b213d20b385bc1588d9c7b38f1b39d415665b8a9030c9ec653d75e65f847d8fc1fc440")
    }

    func testBIP39SeedAndMnemConversions() throws {
        let seed = Data.randomBytes(length: 32)!
        let mnemonics = BIP39.generateMnemonicsFromEntropy(entropy: seed)
        let recoveredSeed = BIP39.mnemonicsToEntropy(mnemonics!, language: .english)
        XCTAssert(seed == recoveredSeed)
    }

    // https://github.com/trezor/python-mnemonic/blob/master/vectors.json
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

    func testHMAC() throws {
        let seed = Data.fromHex("0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b")!
        let data = Data.fromHex("4869205468657265")!
        let hmac = try! HMAC.init(key: seed.bytes, variant: HMAC.Variant.sha2(.sha512)).authenticate(data.bytes)
        XCTAssert(Data(hmac).toHexString() == "87aa7cdea5ef619d4ff0b4241a1d6cb02379f4e2ce4ec2787ad0b30545e17cdedaa833b7d6b8a702038b274eaea3f4e4be9d914eeb61f1702e696c203a126854")
    }

    func testV3keystoreExportPrivateKey() throws {
        let keystore = try! EthereumKeystoreV3(password: "")
        XCTAssertNotNil(keystore)
        let account = keystore!.addresses![0]

        let data = try! keystore!.serialize()
        let key = try! keystore!.UNSAFE_getPrivateKeyData(password: "", account: account)
        XCTAssertNotNil(key)
    }

    func testV3keystoreSerialization() throws {
        let keystore = try! EthereumKeystoreV3(password: "")
        XCTAssertNotNil(keystore)
        let account = keystore!.addresses![0]
        let data = try! keystore!.serialize()
        let key = try! keystore!.UNSAFE_getPrivateKeyData(password: "", account: account)
        XCTAssertNotNil(key)

        let restored = EthereumKeystoreV3(data!)
        XCTAssertNotNil(restored)
        XCTAssertEqual(keystore!.addresses!.first!, restored!.addresses!.first!)
        let restoredKey = try! restored!.UNSAFE_getPrivateKeyData(password: "", account: account)
        XCTAssertNotNil(restoredKey)
        XCTAssertEqual(key, restoredKey)
    }

    func testNewBIP32keystore() throws {
        let mnemonic = try! BIP39.generateMnemonics(bitsOfEntropy: 256)!
        let keystore = try! BIP32Keystore(mnemonics: mnemonic, password: "", mnemonicsPassword: "")
        XCTAssert(keystore != nil)
    }

    func testSameAddressesFromTheSameMnemonics() throws {
        let mnemonic = try! BIP39.generateMnemonics(bitsOfEntropy: 256)!
        let keystore1 = try! BIP32Keystore(mnemonics: mnemonic, password: "", mnemonicsPassword: "")
        let keystore2 = try! BIP32Keystore(mnemonics: mnemonic, password: "", mnemonicsPassword: "")
        XCTAssert(keystore1?.addresses?.first == keystore2?.addresses?.first)
    }

    func testBIP32keystoreExportPrivateKey() throws {
        let mnemonic = "normal dune pole key case cradle unfold require tornado mercy hospital buyer"
        let keystore = try! BIP32Keystore(mnemonics: mnemonic, password: "", mnemonicsPassword: "")
        XCTAssertNotNil(keystore)
        let account = keystore!.addresses![0]
        let key = try! keystore!.UNSAFE_getPrivateKeyData(password: "", account: account)
        XCTAssertNotNil(key)
    }

    func testBIP32keystoreMatching() throws {
        let keystore = try! BIP32Keystore(mnemonics: mnemonic, password: "", mnemonicsPassword: "banana")
        XCTAssertNotNil(keystore)
        let account = keystore!.addresses![0]
        let key = try! keystore!.UNSAFE_getPrivateKeyData(password: "", account: account)
        let pubKey = Utilities.privateToPublic(key, compressed: true)
        XCTAssert(pubKey?.toHexString() == "027160bd3a4d938cac609ff3a11fe9233de7b76c22a80d2b575e202cbf26631659")
    }

    func testBIP32keystoreMatchingRootNode() throws {
        let keystore = try! BIP32Keystore(mnemonics: mnemonic, password: "", mnemonicsPassword: "banana")
        XCTAssertNotNil(keystore)
        let rootNode = try! keystore!.serializeRootNodeToString(password: "")
        XCTAssert(rootNode == "xprvA2KM71v838kPwE8Lfr12m9DL939TZmPStMnhoFcZkr1nBwDXSG7c3pjYbMM9SaqcofK154zNSCp7W7b4boEVstZu1J3pniLQJJq7uvodfCV")
    }

    func testBIP32keystoreCustomPathMatching() throws {
        let keystore = try! BIP32Keystore(mnemonics: mnemonic, password: "", mnemonicsPassword: "banana", prefixPath: "m/44'/60'/0'/0")
        XCTAssertNotNil(keystore)
        let account = keystore!.addresses![0]
        let key = try! keystore!.UNSAFE_getPrivateKeyData(password: "", account: account)
        let pubKey = Utilities.privateToPublic(key, compressed: true)
        XCTAssert(pubKey?.toHexString() == "027160bd3a4d938cac609ff3a11fe9233de7b76c22a80d2b575e202cbf26631659")
    }

    func testByBIP32keystoreCreateChildAccount() throws {
        let mnemonic = "normal dune pole key case cradle unfold require tornado mercy hospital buyer"
        let keystore = try! BIP32Keystore(mnemonics: mnemonic, password: "", mnemonicsPassword: "")
        XCTAssertNotNil(keystore)
        XCTAssertEqual(keystore!.addresses?.count, 1)
        try! keystore?.createNewChildAccount(password: "")
        XCTAssertEqual(keystore?.addresses?.count, 2)
        let account = keystore!.addresses![0]
        let key = try! keystore!.UNSAFE_getPrivateKeyData(password: "", account: account)
        XCTAssertNotNil(key)
    }

    func testByBIP32keystoreCreateCustomChildAccount() throws {
        let mnemonic = "normal dune pole key case cradle unfold require tornado mercy hospital buyer"
        let keystore = try! BIP32Keystore(mnemonics: mnemonic, password: "", mnemonicsPassword: "")
        XCTAssertNotNil(keystore)
        XCTAssertEqual(keystore!.addresses?.count, 1)
        try! keystore?.createNewCustomChildAccount(password: "", path: "/42/1")
        XCTAssertEqual(keystore?.addresses?.count, 2)
        let account = keystore!.addresses![1]
        let key = try! keystore!.UNSAFE_getPrivateKeyData(password: "", account: account)
        XCTAssertNotNil(key)

    }

    func testByBIP32keystoreSaveAndDerive() throws {
        let mnemonic = "normal dune pole key case cradle unfold require tornado mercy hospital buyer"
        let keystore = try! BIP32Keystore(mnemonics: mnemonic, password: "", mnemonicsPassword: "", prefixPath: "m/44'/60'/0'")
        XCTAssertNotNil(keystore)
        XCTAssertEqual(keystore!.addresses?.count, 1)
        try! keystore?.createNewCustomChildAccount(password: "", path: "/0/1")
        XCTAssertEqual(keystore?.addresses?.count, 2)
        let data = try! keystore?.serialize()
        let recreatedStore = BIP32Keystore.init(data!)
        XCTAssert(keystore?.addresses?.count == recreatedStore?.addresses?.count)
        XCTAssert(keystore?.rootPrefix == recreatedStore?.rootPrefix)

        XCTAssert(keystore?.addresses![0] == recreatedStore?.addresses![0])
        XCTAssert(keystore?.addresses![1] == recreatedStore?.addresses![1])
    }

    // FIXME: Failed on async with 10_000 iterations
//    func testPBKDF2() throws {
//        let pass = "passDATAb00AB7YxDTTl".data(using: .utf8)!
//        let salt = "saltKEYbcTcXHCBxtjD2".data(using: .utf8)!
//        let pbkdf2 = try? PKCS5.PBKDF2(password: pass.bytes, salt: salt.bytes, iterations: 10_000, keyLength: 65, variant: HMAC.Variant.sha2(.sha512))
//        /// takes to loong to run test with `100_000` iterations drops to `10_000`
//        let dataArray = try? pbkdf2?.calculate()
//        XCTAssert(Data(dataArray!).toHexString().addHexPrefix().lowercased() == "0x594256B0BD4D6C9F21A87F7BA5772A791A10E6110694F44365CD94670E57F1AECD797EF1D1001938719044C7F018026697845EB9AD97D97DE36AB8786AAB5096E7".lowercased())
//    }

    func testRIPEMD() throws {
        let data = "message digest".data(using: .ascii)
        let hash = try! RIPEMD160.hash(message: data!)
        XCTAssert(hash.toHexString() == "5d0689ef49d2fae572b881b123a85ffa21595f36")
    }

    func testHD32() throws {
        let seed = Data.fromHex("000102030405060708090a0b0c0d0e0f")!
        let node = HDNode(seed: seed)!
        XCTAssert(node.chaincode == Data.fromHex("873dff81c02f525623fd1fe5167eac3a55a049de3d314bb42ee227ffed37d508"))
        let serialized = node.serializeToString()
        let serializedPriv = node.serializeToString(serializePublic: false)
        XCTAssert(serialized == "xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8")
        XCTAssert(serializedPriv == "xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi")

        let deserializedNode = HDNode(serializedPriv!)
        XCTAssert(deserializedNode != nil)
        XCTAssert(deserializedNode?.depth == 0)
        XCTAssert(deserializedNode?.index == UInt32(0))
        XCTAssert(deserializedNode?.isHardened == false)
        XCTAssert(deserializedNode?.parentFingerprint == Data.fromHex("00000000"))
        XCTAssert(deserializedNode?.privateKey == node.privateKey)
        XCTAssert(deserializedNode?.publicKey == node.publicKey)
        XCTAssert(deserializedNode?.chaincode == node.chaincode)

        let nextNode = node.derive(index: 0, derivePrivateKey: true)
        XCTAssert(nextNode?.depth == 1)
        XCTAssert(nextNode?.index == UInt32(0))
        XCTAssert(nextNode?.isHardened == false)
        XCTAssert(nextNode?.parentFingerprint == Data.fromHex("3442193e"))
        XCTAssert(nextNode?.publicKey.toHexString() == "027c4b09ffb985c298afe7e5813266cbfcb7780b480ac294b0b43dc21f2be3d13c")
        XCTAssert(nextNode?.serializeToString() == "xpub68Gmy5EVb2BdFbj2LpWrk1M7obNuaPTpT5oh9QCCo5sRfqSHVYWex97WpDZzszdzHzxXDAzPLVSwybe4uPYkSk4G3gnrPqqkV9RyNzAcNJ1")
        XCTAssert(nextNode?.serializeToString(serializePublic: false) == "xprv9uHRZZhbkedL37eZEnyrNsQPFZYRAvjy5rt6M1nbEkLSo378x1CQQLo2xxBvREwiK6kqf7GRNvsNEchwibzXaV6i5GcsgyjBeRguXhKsi4R")

        let nextNodeHardened = node.derive(index: 0, derivePrivateKey: true, hardened: true)
        XCTAssert(nextNodeHardened?.depth == 1)
        XCTAssert(nextNodeHardened?.index == UInt32(0))
        XCTAssert(nextNodeHardened?.isHardened == true)
        XCTAssert(nextNodeHardened?.parentFingerprint == Data.fromHex("3442193e"))
        XCTAssert(nextNodeHardened?.publicKey.toHexString() == "035a784662a4a20a65bf6aab9ae98a6c068a81c52e4b032c0fb5400c706cfccc56")
        XCTAssert(nextNodeHardened?.serializeToString() == "xpub68Gmy5EdvgibQVfPdqkBBCHxA5htiqg55crXYuXoQRKfDBFA1WEjWgP6LHhwBZeNK1VTsfTFUHCdrfp1bgwQ9xv5ski8PX9rL2dZXvgGDnw")
        XCTAssert(nextNodeHardened?.serializeToString(serializePublic: false) == "xprv9uHRZZhk6KAJC1avXpDAp4MDc3sQKNxDiPvvkX8Br5ngLNv1TxvUxt4cV1rGL5hj6KCesnDYUhd7oWgT11eZG7XnxHrnYeSvkzY7d2bhkJ7")

        let treeNode = node.derive(path: HDNode.defaultPath)
        XCTAssert(treeNode != nil)
        XCTAssert(treeNode?.depth == 4)
        XCTAssert(treeNode?.serializeToString() == "xpub6DZ3xpo1ixWwwNDQ7KFTamRVM46FQtgcDxsmAyeBpTHEo79E1n1LuWiZSMSRhqMQmrHaqJpek2TbtTzbAdNWJm9AhGdv7iJUpDjA6oJD84b")
        XCTAssert(treeNode?.serializeToString(serializePublic: false) == "xprv9zZhZKG7taxeit8w1HiTDdUko2Fm1RxkrjxANbEaG7kFvJp5UEh6MiQ5b5XvwWg8xdHMhueagettVG2AbfqSRDyNpxRDBLyMSbNq1KhZ8ai")
    }

    func testBIP32derivation2() throws {
        let seed = Data.fromHex("fffcf9f6f3f0edeae7e4e1dedbd8d5d2cfccc9c6c3c0bdbab7b4b1aeaba8a5a29f9c999693908d8a8784817e7b7875726f6c696663605d5a5754514e4b484542")!
        let node = HDNode(seed: seed)!
        let path = "m/0/2147483647'/1/2147483646'/2"
        let treeNode = node.derive(path: path)
        XCTAssert(treeNode != nil)
        XCTAssert(treeNode?.depth == 5)
        XCTAssert(treeNode?.serializeToString() == "xpub6FnCn6nSzZAw5Tw7cgR9bi15UV96gLZhjDstkXXxvCLsUXBGXPdSnLFbdpq8p9HmGsApME5hQTZ3emM2rnY5agb9rXpVGyy3bdW6EEgAtqt")
        XCTAssert(treeNode?.serializeToString(serializePublic: false) == "xprvA2nrNbFZABcdryreWet9Ea4LvTJcGsqrMzxHx98MMrotbir7yrKCEXw7nadnHM8Dq38EGfSh6dqA9QWTyefMLEcBYJUuekgW4BYPJcr9E7j")
    }

    func testKeystoreDerivationTime() throws {
        let privateKey = Data.randomBytes(length: 32)!
        measure {
            let ks = try! EthereumKeystoreV3(privateKey: privateKey, password: "TEST")!
            let account = ks.addresses!.first!
            _ = try! ks.UNSAFE_getPrivateKeyData(password: "TEST", account: account)
        }
    }

    func testSingleScryptDerivation() throws {
        let privateKey = Data.randomBytes(length: 32)!
        _ = try! EthereumKeystoreV3(privateKey: privateKey, password: "TEST")!
    }

}
