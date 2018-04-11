//
//  web3swiftTests.swift
//  web3swiftTests
//
//  Created by Alexander Vlasov on 04.12.2017.
//  Copyright © 2017 Alexander Vlasov. All rights reserved.
//


import XCTest
import CryptoSwift
import BigInt
import Result


@testable import web3swift_iOS

class web3swiftTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testRealABI() {
        let jsonString = "[{\"constant\":true,\"inputs\":[],\"name\":\"getUsers\",\"outputs\":[{\"name\":\"\",\"type\":\"address[]\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"handle\",\"type\":\"string\"},{\"name\":\"city\",\"type\":\"bytes32\"},{\"name\":\"state\",\"type\":\"bytes32\"},{\"name\":\"country\",\"type\":\"bytes32\"}],\"name\":\"registerNewUser\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"SHA256notaryHash\",\"type\":\"bytes32\"}],\"name\":\"getImage\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"},{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"userAddress\",\"type\":\"address\"}],\"name\":\"getUser\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"},{\"name\":\"\",\"type\":\"bytes32\"},{\"name\":\"\",\"type\":\"bytes32\"},{\"name\":\"\",\"type\":\"bytes32\"},{\"name\":\"\",\"type\":\"bytes32[]\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"getAllImages\",\"outputs\":[{\"name\":\"\",\"type\":\"bytes32[]\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"imageURL\",\"type\":\"string\"},{\"name\":\"SHA256notaryHash\",\"type\":\"bytes32\"}],\"name\":\"addImageToUser\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"userAddress\",\"type\":\"address\"}],\"name\":\"getUserImages\",\"outputs\":[{\"name\":\"\",\"type\":\"bytes32[]\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"}]"
        do {
            let jsonData = jsonString.data(using: .utf8)
            let abi = try JSONDecoder().decode([ABIRecord].self, from: jsonData!)
            let abiNative = try abi.map({ (record) -> ABIElement in
                return try record.parse()
            })
            print(abiNative)
            XCTAssert(abiNative.count > 0, "Can't parse some real-world ABI")
        } catch {
            XCTFail()
            print(error)
        }
    }
    
    func testRealABIv2() {
        let jsonString = "[{\"constant\":true,\"inputs\":[],\"name\":\"getUsers\",\"outputs\":[{\"name\":\"\",\"type\":\"address[]\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"handle\",\"type\":\"string\"},{\"name\":\"city\",\"type\":\"bytes32\"},{\"name\":\"state\",\"type\":\"bytes32\"},{\"name\":\"country\",\"type\":\"bytes32\"}],\"name\":\"registerNewUser\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"SHA256notaryHash\",\"type\":\"bytes32\"}],\"name\":\"getImage\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"},{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"userAddress\",\"type\":\"address\"}],\"name\":\"getUser\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"},{\"name\":\"\",\"type\":\"bytes32\"},{\"name\":\"\",\"type\":\"bytes32\"},{\"name\":\"\",\"type\":\"bytes32\"},{\"name\":\"\",\"type\":\"bytes32[]\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"getAllImages\",\"outputs\":[{\"name\":\"\",\"type\":\"bytes32[]\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"imageURL\",\"type\":\"string\"},{\"name\":\"SHA256notaryHash\",\"type\":\"bytes32\"}],\"name\":\"addImageToUser\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"userAddress\",\"type\":\"address\"}],\"name\":\"getUserImages\",\"outputs\":[{\"name\":\"\",\"type\":\"bytes32[]\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"}]"
        do {
            let jsonData = jsonString.data(using: .utf8)
            let abi = try JSONDecoder().decode([ABIv2.Record].self, from: jsonData!)
            let abiNative = try abi.map({ (record) -> ABIv2.Element in
                return try record.parse()
            })
            print(abiNative)
            XCTAssert(abiNative.count > 0, "Can't parse some real-world ABI")
        } catch {
            XCTFail()
            print(error)
        }
    }
    
    func testABIv2Parsing () {
        let jsonString = "[{\"name\":\"f\",\"type\":\"function\",\"inputs\":[{\"name\":\"s\",\"type\":\"tuple\",\"components\":[{\"name\":\"a\",\"type\":\"uint256\"},{\"name\":\"b\",\"type\":\"uint256[]\"},{\"name\":\"c\",\"type\":\"tuple[]\",\"components\":[{\"name\":\"x\",\"type\":\"uint256\"},{\"name\":\"y\",\"type\":\"uint256\"}]}]},{\"name\":\"t\",\"type\":\"tuple\",\"components\":[{\"name\":\"x\",\"type\":\"uint256\"},{\"name\":\"y\",\"type\":\"uint256\"}]},{\"name\":\"a\",\"type\":\"uint256\"},{\"name\":\"z\",\"type\":\"uint256[3]\"}],\"outputs\":[]}]"
        do {
            let jsonData = jsonString.data(using: .utf8)
            let abi = try JSONDecoder().decode([ABIv2.Record].self, from: jsonData!)
            let abiNative = try abi.map({ (record) -> ABIv2.Element in
                return try record.parse()
            })
            print(abiNative)
            XCTAssert(abiNative.count > 0, "Can't parse some real-world ABI")
        } catch {
            XCTFail()
            print(error)
        }
    }
    
    func testBitFunctions () {
        let data = Data([0xf0, 0x02, 0x03])
        let firstBit = data.bitsInRange(0,1)
        XCTAssert(firstBit == 1)
        let first4bits = data.bitsInRange(0,4)
        XCTAssert(first4bits == 0x0f)
    }
    
    func testBIP39 () {
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
    
    func testHMAC() {
        let seed = Data.fromHex("0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b")!
        let data = Data.fromHex("4869205468657265")!
        let hmac = try! HMAC.init(key: seed.bytes, variant: HMAC.Variant.sha512).authenticate(data.bytes)
        XCTAssert(Data(hmac).toHexString() == "87aa7cdea5ef619d4ff0b4241a1d6cb02379f4e2ce4ec2787ad0b30545e17cdedaa833b7d6b8a702038b274eaea3f4e4be9d914eeb61f1702e696c203a126854")
    }
    
    func testV3keystoreExportPrivateKey() {
        let keystore = try! EthereumKeystoreV3(password: "");
        XCTAssertNotNil(keystore)
        let account = keystore!.addresses![0]
        let key = try! keystore!.UNSAFE_getPrivateKeyData(password: "", account: account)
        XCTAssertNotNil(key)
    }
    
    func testNewBIP32keystore() {
        let mnemonic = try! BIP39.generateMnemonics(bitsOfEntropy: 256)!
        let keystore = try! BIP32Keystore(mnemonics: mnemonic, password: "", mnemonicsPassword: "")
        XCTAssert(keystore != nil)
    }
    
    func testBIP32keystoreExportPrivateKey() {
        let mnemonic = "normal dune pole key case cradle unfold require tornado mercy hospital buyer"
        let keystore = try! BIP32Keystore(mnemonics: mnemonic, password: "", mnemonicsPassword: "")
        XCTAssertNotNil(keystore)
        let account = keystore!.addresses![0]
        let key = try! keystore!.UNSAFE_getPrivateKeyData(password: "", account: account)
        XCTAssertNotNil(key)
    }
    
    func testByBIP32keystoreCreateChildAccount() {
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
    
    func testByBIP32keystoreCreateCustomChildAccount() {
        let mnemonic = "normal dune pole key case cradle unfold require tornado mercy hospital buyer"
        let keystore = try! BIP32Keystore(mnemonics: mnemonic, password: "", mnemonicsPassword: "")
        XCTAssertNotNil(keystore)
        XCTAssertEqual(keystore!.addresses?.count, 1)
        try! keystore?.createNewCustomChildAccount(password: "", path: "/42/1")
        XCTAssertEqual(keystore?.addresses?.count, 2)
        let account = keystore!.addresses![1]
        let key = try! keystore!.UNSAFE_getPrivateKeyData(password: "", account: account)
        XCTAssertNotNil(key)
        print(keystore!.paths)
    }
    
//    func testPBKDF2() {
//        let pass = "passDATAb00AB7YxDTTl".data(using: .utf8)!
//        let salt = "saltKEYbcTcXHCBxtjD2".data(using: .utf8)!
//        let dataArray = try? PKCS5.PBKDF2(password: pass.bytes, salt: salt.bytes, iterations: 100000, keyLength: 65, variant: HMAC.Variant.sha512).calculate()
//        XCTAssert(Data(dataArray!).toHexString().addHexPrefix().lowercased() == "0x594256B0BD4D6C9F21A87F7BA5772A791A10E6110694F44365CD94670E57F1AECD797EF1D1001938719044C7F018026697845EB9AD97D97DE36AB8786AAB5096E7".lowercased())
//    }
    
    func testRIPEMD() {
        let data = "message digest".data(using: .ascii)
        let hash = RIPEMD160.hash(message: data!)
        XCTAssert(hash.toHexString() == "5d0689ef49d2fae572b881b123a85ffa21595f36")
    }
    
    func testHD32() {
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
    
    func testABIdecoding() {
        let jsonString = "[{\"type\":\"constructor\",\"payable\":false,\"stateMutability\":\"nonpayable\",\"inputs\":[{\"name\":\"testInt\",\"type\":\"uint256\"}]},{\"type\":\"function\",\"name\":\"foo\",\"constant\":false,\"payable\":false,\"stateMutability\":\"nonpayable\",\"inputs\":[{\"name\":\"b\",\"type\":\"uint256\"},{\"name\":\"c\",\"type\":\"bytes32\"}],\"outputs\":[{\"name\":\"\",\"type\":\"address\"}]},{\"type\":\"event\",\"name\":\"Event\",\"inputs\":[{\"indexed\":true,\"name\":\"b\",\"type\":\"uint256\"},{\"indexed\":false,\"name\":\"c\",\"type\":\"bytes32\"}],\"anonymous\":false},{\"type\":\"event\",\"name\":\"Event2\",\"inputs\":[{\"indexed\":true,\"name\":\"b\",\"type\":\"uint256\"},{\"indexed\":false,\"name\":\"c\",\"type\":\"bytes32\"}],\"anonymous\":false}]"
        do {
            let jsonData = jsonString.data(using: .utf8)
            let abi = try JSONDecoder().decode([ABIRecord].self, from: jsonData!)
            let abiNative = try abi.map({ (record) -> ABIElement in
                return try record.parse()
            })
            print(abiNative)
            XCTAssert(true, "Failed to parse ABI")
        } catch {
            print(error)
            XCTFail()
        }
    }

    func testABIdecoding2() {
        let jsonString = "[{\"type\":\"function\",\"name\":\"balance\",\"constant\":true},{\"type\":\"function\",\"name\":\"send\",\"constant\":false,\"inputs\":[{\"name\":\"amount\",\"type\":\"uint256\"}]},{\"type\":\"function\",\"name\":\"test\",\"constant\":false,\"inputs\":[{\"name\":\"number\",\"type\":\"uint32\"}]},{\"type\":\"function\",\"name\":\"string\",\"constant\":false,\"inputs\":[{\"name\":\"inputs\",\"type\":\"string\"}]},{\"type\":\"function\",\"name\":\"bool\",\"constant\":false,\"inputs\":[{\"name\":\"inputs\",\"type\":\"bool\"}]},{\"type\":\"function\",\"name\":\"address\",\"constant\":false,\"inputs\":[{\"name\":\"inputs\",\"type\":\"address\"}]},{\"type\":\"function\",\"name\":\"uint64[2]\",\"constant\":false,\"inputs\":[{\"name\":\"inputs\",\"type\":\"uint64[2]\"}]},{\"type\":\"function\",\"name\":\"uint64[]\",\"constant\":false,\"inputs\":[{\"name\":\"inputs\",\"type\":\"uint64[]\"}]},{\"type\":\"function\",\"name\":\"foo\",\"constant\":false,\"inputs\":[{\"name\":\"inputs\",\"type\":\"uint32\"}]},{\"type\":\"function\",\"name\":\"bar\",\"constant\":false,\"inputs\":[{\"name\":\"inputs\",\"type\":\"uint32\"},{\"name\":\"string\",\"type\":\"uint16\"}]},{\"type\":\"function\",\"name\":\"slice\",\"constant\":false,\"inputs\":[{\"name\":\"inputs\",\"type\":\"uint32[2]\"}]},{\"type\":\"function\",\"name\":\"slice256\",\"constant\":false,\"inputs\":[{\"name\":\"inputs\",\"type\":\"uint256[2]\"}]},{\"type\":\"function\",\"name\":\"sliceAddress\",\"constant\":false,\"inputs\":[{\"name\":\"inputs\",\"type\":\"address[]\"}]},{\"type\":\"function\",\"name\":\"sliceMultiAddress\",\"constant\":false,\"inputs\":[{\"name\":\"a\",\"type\":\"address[]\"},{\"name\":\"b\",\"type\":\"address[]\"}]}]"
        do {
            let jsonData = jsonString.data(using: .utf8)
            let abi = try JSONDecoder().decode([ABIRecord].self, from: jsonData!)
            let abiNative = try abi.map({ (record) -> ABIElement in
                return try record.parse()
            })
            print(abiNative)
            XCTAssert(true, "Failed to parse ABI")
        } catch {
            print(error)
            XCTFail()
        }
    }
    
    func testABIv2decoding() {
        let jsonString = "[{\"type\":\"constructor\",\"payable\":false,\"stateMutability\":\"nonpayable\",\"inputs\":[{\"name\":\"testInt\",\"type\":\"uint256\"}]},{\"type\":\"function\",\"name\":\"foo\",\"constant\":false,\"payable\":false,\"stateMutability\":\"nonpayable\",\"inputs\":[{\"name\":\"b\",\"type\":\"uint256\"},{\"name\":\"c\",\"type\":\"bytes32\"}],\"outputs\":[{\"name\":\"\",\"type\":\"address\"}]},{\"type\":\"event\",\"name\":\"Event\",\"inputs\":[{\"indexed\":true,\"name\":\"b\",\"type\":\"uint256\"},{\"indexed\":false,\"name\":\"c\",\"type\":\"bytes32\"}],\"anonymous\":false},{\"type\":\"event\",\"name\":\"Event2\",\"inputs\":[{\"indexed\":true,\"name\":\"b\",\"type\":\"uint256\"},{\"indexed\":false,\"name\":\"c\",\"type\":\"bytes32\"}],\"anonymous\":false}]"
        do {
            let jsonData = jsonString.data(using: .utf8)
            let abi = try JSONDecoder().decode([ABIv2.Record].self, from: jsonData!)
            let abiNative = try abi.map({ (record) -> ABIv2.Element in
                return try record.parse()
            })
            print(abiNative)
            XCTAssert(true, "Failed to parse ABI")
        } catch {
            print(error)
            XCTFail()
        }
    }
    
    func testABIv2decoding2() {
        let jsonString = "[{\"type\":\"function\",\"name\":\"balance\",\"constant\":true},{\"type\":\"function\",\"name\":\"send\",\"constant\":false,\"inputs\":[{\"name\":\"amount\",\"type\":\"uint256\"}]},{\"type\":\"function\",\"name\":\"test\",\"constant\":false,\"inputs\":[{\"name\":\"number\",\"type\":\"uint32\"}]},{\"type\":\"function\",\"name\":\"string\",\"constant\":false,\"inputs\":[{\"name\":\"inputs\",\"type\":\"string\"}]},{\"type\":\"function\",\"name\":\"bool\",\"constant\":false,\"inputs\":[{\"name\":\"inputs\",\"type\":\"bool\"}]},{\"type\":\"function\",\"name\":\"address\",\"constant\":false,\"inputs\":[{\"name\":\"inputs\",\"type\":\"address\"}]},{\"type\":\"function\",\"name\":\"uint64[2]\",\"constant\":false,\"inputs\":[{\"name\":\"inputs\",\"type\":\"uint64[2]\"}]},{\"type\":\"function\",\"name\":\"uint64[]\",\"constant\":false,\"inputs\":[{\"name\":\"inputs\",\"type\":\"uint64[]\"}]},{\"type\":\"function\",\"name\":\"foo\",\"constant\":false,\"inputs\":[{\"name\":\"inputs\",\"type\":\"uint32\"}]},{\"type\":\"function\",\"name\":\"bar\",\"constant\":false,\"inputs\":[{\"name\":\"inputs\",\"type\":\"uint32\"},{\"name\":\"string\",\"type\":\"uint16\"}]},{\"type\":\"function\",\"name\":\"slice\",\"constant\":false,\"inputs\":[{\"name\":\"inputs\",\"type\":\"uint32[2]\"}]},{\"type\":\"function\",\"name\":\"slice256\",\"constant\":false,\"inputs\":[{\"name\":\"inputs\",\"type\":\"uint256[2]\"}]},{\"type\":\"function\",\"name\":\"sliceAddress\",\"constant\":false,\"inputs\":[{\"name\":\"inputs\",\"type\":\"address[]\"}]},{\"type\":\"function\",\"name\":\"sliceMultiAddress\",\"constant\":false,\"inputs\":[{\"name\":\"a\",\"type\":\"address[]\"},{\"name\":\"b\",\"type\":\"address[]\"}]}]"
        do {
            let jsonData = jsonString.data(using: .utf8)
            let abi = try JSONDecoder().decode([ABIv2.Record].self, from: jsonData!)
            let abiNative = try abi.map({ (record) -> ABIv2.Element in
                return try record.parse()
            })
            print(abiNative)
            XCTAssert(true, "Failed to parse ABI")
        } catch {
            print(error)
            XCTFail()
        }
    }
    
    
    func testRLPencodeShortString() {
        let testString = "dog"
        let encoded = RLP.encode(testString)
        var expected = Data([UInt8(0x83)])
        expected.append(testString.data(using: .ascii)!)
        XCTAssert(encoded == expected, "Failed to RLP encode short string")
    }
    
    func testRLPencodeListOfShortStrings() {
        let testInput = ["cat","dog"]
        let encoded = RLP.encode(testInput)
        var expected = Data()
        expected.append(Data([UInt8(0xc8)]))
        expected.append(Data([UInt8(0x83)]))
        expected.append("cat".data(using: .ascii)!)
        expected.append(Data([UInt8(0x83)]))
        expected.append("dog".data(using: .ascii)!)
        XCTAssert(encoded == expected, "Failed to RLP encode list of short strings")
    }
    
    func testRLPdecodeListOfShortStrings() {
        let testInput = ["cat","dog"]
        var expected = Data()
        expected.append(Data([UInt8(0xc8)]))
        expected.append(Data([UInt8(0x83)]))
        expected.append("cat".data(using: .ascii)!)
        expected.append(Data([UInt8(0x83)]))
        expected.append("dog".data(using: .ascii)!)
        var result = RLP.decode(expected)!
        XCTAssert(result.isList, "Failed to RLP decode list of short strings") // we got something non-empty
        XCTAssert(result.count == 1, "Failed to RLP decode list of short strings") // we got something non-empty
        result = result[0]!
        XCTAssert(result.isList, "Failed to RLP decode list of short strings") // we got something non-empty
        XCTAssert(result.count == 2, "Failed to RLP decode list of short strings") // we got something non-empty
        XCTAssert(result[0]!.data == testInput[0].data(using: .ascii), "Failed to RLP decode list of short strings")
        XCTAssert(result[1]!.data == testInput[1].data(using: .ascii), "Failed to RLP decode list of short strings")
    }
    
    func testRLPencodeLongString() {
        let testInput = "Lorem ipsum dolor sit amet, consectetur adipisicing elit"
        let encoded = RLP.encode(testInput)
        var expected = Data()
        expected.append(Data([UInt8(0xb8)]))
        expected.append(Data([UInt8(0x38)]))
        expected.append("Lorem ipsum dolor sit amet, consectetur adipisicing elit".data(using: .ascii)!)
        XCTAssert(encoded == expected, "Failed to RLP encode long string")
    }
    
    func testRLPdecodeLongString() {
        let testInput = "Lorem ipsum dolor sit amet, consectetur adipisicing elit"
        var expected = Data()
        expected.append(Data([UInt8(0xb8)]))
        expected.append(Data([UInt8(0x38)]))
        expected.append(testInput.data(using: .ascii)!)
        let result = RLP.decode(expected)!
        XCTAssert(result.count == 1, "Failed to RLP decode long string")
        XCTAssert(result[0]!.data == testInput.data(using: .ascii), "Failed to RLP decode long string")
    }
    
    func testRLPencodeEmptyString() {
        let testInput = ""
        let encoded = RLP.encode(testInput)
        var expected = Data()
        expected.append(Data([UInt8(0x80)]))
        XCTAssert(encoded == expected, "Failed to RLP encode empty string")
    }
    
    func testRLPdecodeEmptyString() {
        let testInput = ""
        var expected = Data()
        expected.append(Data([UInt8(0x80)]))
        let result = RLP.decode(expected)!
        XCTAssert(result.count == 1, "Failed to RLP decode empty string")
        XCTAssert(result[0]!.data == testInput.data(using: .ascii), "Failed to RLP decode empty string")
    }
    
    func testRLPencodeEmptyArray() {
        let testInput = [Data]()
        let encoded = RLP.encode(testInput)
        var expected = Data()
        expected.append(Data([UInt8(0xc0)]))
        XCTAssert(encoded == expected, "Failed to RLP encode empty array")
    }
    
    func testRLPdecodeEmptyArray() {
//        let testInput = [Data]()
        var expected = Data()
        expected.append(Data([UInt8(0xc0)]))
        var result = RLP.decode(expected)!
        XCTAssert(result.count == 1, "Failed to RLP decode empty array")
        result = result[0]!
        guard case .noItem = result.content else {return XCTFail()}
    }
    
    func testRLPencodeShortInt() {
        let testInput = 15
        let encoded = RLP.encode(testInput)
        let expected = Data([UInt8(0x0f)])
        XCTAssert(encoded == expected, "Failed to RLP encode short int")
    }
    
    func testRLPdecodeShortInt() {
        let testInput = 15
        let expected = Data([UInt8(0x0f)])
        let result = RLP.decode(expected)!

        XCTAssert(result.count == 1, "Failed to RLP decode short int")
        XCTAssert(BigUInt(result[0]!.data!) == testInput, "Failed to RLP decode short int")
    }
    
    func testRLPencodeLargeInt() {
        let testInput = 1024
        let encoded = RLP.encode(testInput)
        var expected = Data()
        expected.append(Data([UInt8(0x82)]))
        expected.append(Data([UInt8(0x04)]))
        expected.append(Data([UInt8(0x00)]))
        XCTAssert(encoded == expected, "Failed to RLP encode large int")
    }
    
    func testRLPdecodeLargeInt() {
        let testInput = 1024
        var expected = Data()
        expected.append(Data([UInt8(0x82)]))
        expected.append(Data([UInt8(0x04)]))
        expected.append(Data([UInt8(0x00)]))
        let result = RLP.decode(expected)!
        
        XCTAssert(result.count == 1, "Failed to RLP decode large int")
        XCTAssert(BigUInt(result[0]!.data!) == testInput, "Failed to RLP decode large int")
    }
    
    func testRLPdecodeTransaction() {
        let input = Data.fromHex("0xf90890558504e3b292008309153a8080b9083d6060604052336000806101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff160217905550341561004f57600080fd5b60405160208061081d83398101604052808051906020019091905050600073ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff16141515156100a757600080fd5b80600160006101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff16021790555050610725806100f86000396000f300606060405260043610610062576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff1680638da5cb5b14610067578063b2b2c008146100bc578063d59ba0df146101eb578063d8ffdcc414610247575b600080fd5b341561007257600080fd5b61007a61029c565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b34156100c757600080fd5b61019460048080359060200190820180359060200190808060200260200160405190810160405280939291908181526020018383602002808284378201915050505050509190803590602001908201803590602001908080602002602001604051908101604052809392919081815260200183836020028082843782019150505050505091908035906020019082018035906020019080806020026020016040519081016040528093929190818152602001838360200280828437820191505050505050919050506102c1565b6040518080602001828103825283818151815260200191508051906020019060200280838360005b838110156101d75780820151818401526020810190506101bc565b505050509050019250505060405180910390f35b34156101f657600080fd5b61022d600480803573ffffffffffffffffffffffffffffffffffffffff169060200190919080351515906020019091905050610601565b604051808215151515815260200191505060405180910390f35b341561025257600080fd5b61025a6106bf565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b6000809054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b6102c96106e5565b6102d16106e5565b6000806000600260003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060009054906101000a900460ff16151561032e57600080fd5b8651885114151561033e57600080fd5b875160405180591061034d5750595b9080825280602002602001820160405250935060009250600091505b87518210156105f357600160009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff166323b872dd87848151811015156103be57fe5b906020019060200201518a858151811015156103d657fe5b906020019060200201518a868151811015156103ee57fe5b906020019060200201516000604051602001526040518463ffffffff167c0100000000000000000000000000000000000000000000000000000000028152600401808473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020018373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020018281526020019350505050602060405180830381600087803b15156104b857600080fd5b6102c65a03f115156104c957600080fd5b50505060405180519050905080156105e65787828151811015156104e957fe5b90602001906020020151848481518110151561050157fe5b9060200190602002019073ffffffffffffffffffffffffffffffffffffffff16908173ffffffffffffffffffffffffffffffffffffffff16815250508280600101935050868281518110151561055357fe5b90602001906020020151888381518110151561056b57fe5b9060200190602002015173ffffffffffffffffffffffffffffffffffffffff16878481518110151561059957fe5b9060200190602002015173ffffffffffffffffffffffffffffffffffffffff167f334b3b1d4ad406523ee8e24beb689f5adbe99883a662c37d43275de52389da1460405160405180910390a45b8180600101925050610369565b839450505050509392505050565b60008060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff1614151561065e57600080fd5b81600260008573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060006101000a81548160ff0219169083151502179055506001905092915050565b600160009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b6020604051908101604052806000815250905600a165627a7a723058200618093d895b780d4616f24638637da0e0f9767e6d3675a9525fee1d6ed7f431002900000000000000000000000045245bc59219eeaaf6cd3f382e078a461ff9de7b25a0d1efc3c97d1aa9053aa0f59bf148d73f59764343bf3cae576c8769a14866948da0613d0265634fddd436397bc858e2672653833b57a05cfc8b93c14a6c05166e4a")!
        let transaction = EthereumTransaction.fromRaw(input)
        print(transaction)
    }
    
    func testChecksumAddress() {
        let input = "0xfb6916095ca1df60bb79ce92ce3ea74c37c5d359"
        let output = EthereumAddress.toChecksumAddress(input);
        XCTAssert(output == "0xfB6916095ca1df60bB79Ce92cE3Ea74c37c5d359", "Failed to checksum address")
    }

    func testTransaction() {
        do {
            var transaction = EthereumTransaction(nonce: BigUInt(9),
                                                  gasPrice: BigUInt(20000000000),
                                                  gasLimit: BigUInt(21000),
                                                  to: EthereumAddress("0x3535353535353535353535353535353535353535"),
                                                  value: BigUInt("1000000000000000000")!,
                                                  data: Data(),
                                                  v: BigUInt(0),
                                                  r: BigUInt(0),
                                                  s: BigUInt(0))
            let privateKeyData = Data.fromHex("0x4646464646464646464646464646464646464646464646464646464646464646")!
            let publicKey = Web3.Utils.privateToPublic(privateKeyData, compressed: false)
            let sender = Web3.Utils.publicToAddress(publicKey!)
            transaction.chainID = BigUInt(1)
            print(transaction)
            let hash = transaction.hashForSignature(chainID: BigUInt(1))
            let expectedHash = "0xdaf5a779ae972f972197303d7b574746c7ef83eadac0f2791ad23db92e4c8e53".stripHexPrefix()
            XCTAssert(hash!.toHexString() == expectedHash, "Transaction signature failed")
            try Web3Signer.EIP155Signer.sign(transaction: &transaction, privateKey: privateKeyData)
            print(transaction)
            XCTAssert(transaction.v == UInt8(37), "Transaction signature failed")
            XCTAssert(sender == transaction.sender)
        }
        catch {
            print(error)
            XCTFail()
        }
    }
    
    func testEthSendExample() {
        let web3 = Web3.InfuraMainnetWeb3()
        let sendToAddress = EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B")
        let tempKeystore = try! EthereumKeystoreV3(password: "")
        let keystoreManager = KeystoreManager([tempKeystore!])
        web3.addKeystoreManager(keystoreManager)
        let contract = web3.contract(Web3.Utils.coldWalletABI, at: sendToAddress, abiVersion: 2)
        var options = Web3Options.defaultOptions()
        options.value = Web3.Utils.parseToBigUInt("1.0", units: .eth)
        options.from = keystoreManager.addresses?.first
        let intermediate = contract?.method("fallback", options: options)
        guard let result = intermediate?.send(password: "") else {return XCTFail()}
        switch result {
        case .success(_):
            return XCTFail()
        case .failure(let error):
            guard case .unknownError = error else {return XCTFail()}
        }
    }
    
    func testEthSendExampleWithRemoteSigning() {
        let web3 = Web3.new(URL.init(string: "http://127.0.0.1:8545")!)!
        guard case .success(let allAddresses) = web3.eth.getAccounts() else {return XCTFail()}
        let sendToAddress = EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B")
        let contract = web3.contract(Web3.Utils.coldWalletABI, at: sendToAddress, abiVersion: 2)
        var options = Web3Options.defaultOptions()
        options.value = Web3.Utils.parseToBigUInt("1.0", units: .eth)
        options.from = allAddresses[0]
        let intermediate = contract?.method("fallback", options: options)
        guard let result = intermediate?.send(password: "") else {return XCTFail()}
        switch result {
        case .success(let res):
            print(res)
            return
        case .failure(let error):
            print(error)
            return XCTFail()
        }
    }
    
    func testDeployWithRemoteSigning() {
        let web3 = Web3.new(URL.init(string: "http://127.0.0.1:8545")!)!
        guard case .success(let allAddresses) = web3.eth.getAccounts() else {return XCTFail()}
        let abiString =  "[{\"constant\":true,\"inputs\":[],\"name\":\"getFlagData\",\"outputs\":[{\"name\":\"data\",\"type\":\"string\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"data\",\"type\":\"string\"}],\"name\":\"setFlagData\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"}]"
        guard let bytecode = Data.fromHex("6060604052341561000f57600080fd5b6103358061001e6000396000f30060606040526004361061004c576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff168063a16e94bf14610051578063a46b5b6b146100df575b600080fd5b341561005c57600080fd5b61006461013c565b6040518080602001828103825283818151815260200191508051906020019080838360005b838110156100a4578082015181840152602081019050610089565b50505050905090810190601f1680156100d15780820380516001836020036101000a031916815260200191505b509250505060405180910390f35b34156100ea57600080fd5b61013a600480803590602001908201803590602001908080601f0160208091040260200160405190810160405280939291908181526020018383808284378201915050505050509190505061020d565b005b610144610250565b6000808073ffffffffffffffffffffffffffffffffffffffff1681526020019081526020016000206000018054600181600116156101000203166002900480601f0160208091040260200160405190810160405280929190818152602001828054600181600116156101000203166002900480156102035780601f106101d857610100808354040283529160200191610203565b820191906000526020600020905b8154815290600101906020018083116101e657829003601f168201915b5050505050905090565b806000808073ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020600001908051906020019061024c929190610264565b5050565b602060405190810160405280600081525090565b828054600181600116156101000203166002900490600052602060002090601f016020900481019282601f106102a557805160ff19168380011785556102d3565b828001600101855582156102d3579182015b828111156102d25782518255916020019190600101906102b7565b5b5090506102e091906102e4565b5090565b61030691905b808211156103025760008160009055506001016102ea565b5090565b905600a165627a7a7230582017359d063cd7fdf56f19ca186a54863ce855c8f070acece905d8538fbbc4d1bf0029") else {return XCTFail()}
        let contract = web3.contract(abiString, at: nil, abiVersion: 2)
        var options = Web3Options.defaultOptions()
        options.from = allAddresses[0]
        options.gasLimit = BigUInt(3000000)
        let intermediate = contract?.deploy(bytecode: bytecode, options: options)
        guard let result = intermediate?.send(password: "") else {return XCTFail()}
        switch result {
        case .success(let res):
            let txHash = res["txhash"]!
            print("Transaction with hash " + txHash)
            Thread.sleep(forTimeInterval: 1.0)
            let receipt = web3.eth.getTransactionReceipt(txHash)
            print(receipt)
            let details = web3.eth.getTransactionDetails(txHash)
            print(details)
            return
        case .failure(let error):
            print(error)
            return XCTFail()
        }
    }
    
    func testERC20Encode() {
        let jsonString = "[{\"constant\":true,\"inputs\":[],\"name\":\"name\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"approve\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"totalSupply\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_from\",\"type\":\"address\"},{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transferFrom\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"decimals\",\"outputs\":[{\"name\":\"\",\"type\":\"uint8\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"version\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"}],\"name\":\"balanceOf\",\"outputs\":[{\"name\":\"balance\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"symbol\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transfer\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"},{\"name\":\"_extraData\",\"type\":\"bytes\"}],\"name\":\"approveAndCall\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"},{\"name\":\"_spender\",\"type\":\"address\"}],\"name\":\"allowance\",\"outputs\":[{\"name\":\"remaining\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"inputs\":[{\"name\":\"_initialAmount\",\"type\":\"uint256\"},{\"name\":\"_tokenName\",\"type\":\"string\"},{\"name\":\"_decimalUnits\",\"type\":\"uint8\"},{\"name\":\"_tokenSymbol\",\"type\":\"string\"}],\"type\":\"constructor\"},{\"payable\":false,\"type\":\"fallback\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_from\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_to\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Transfer\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_owner\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_spender\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Approval\",\"type\":\"event\"},]"
        do {
            let jsonData = jsonString.data(using: .utf8)
            let abi = try JSONDecoder().decode([ABIRecord].self, from: jsonData!)
            let abiNative = try abi.map({ (record) -> ABIElement in
                return try record.parse()
            })
            let method = abiNative.filter({ (element) -> Bool in
                switch element {
                case .function(let function):
                    return function.name == "transfer"
                default:
                    return false
                }
            })
            let address = "0xE6877A4d8806e9A9F12eB2e8561EA6c1db19978d"
            let amount = BigUInt(10).power(18)
            let parameters = [address, amount] as [AnyObject]
            let result = method[0].encodeParameters(parameters)
            print(abiNative)
            let hex = result!.toHexString()
            print(hex)
            XCTAssert(hex == "a9059cbb000000000000000000000000e6877a4d8806e9a9f12eb2e8561ea6c1db19978d0000000000000000000000000000000000000000000000000de0b6b3a7640000", "Failed to encode ERC20")
            let dummyTrue = BigUInt(1).abiEncode(bits: 256)
            let data = dummyTrue!
            let decoded = method[0].decodeReturnData(data)
            let ret1 = decoded!["0"] as? Bool
            let ret2 = decoded!["success"] as? Bool
            XCTAssert(ret1 == true, "Failed to encode ERC20")
            XCTAssert(ret2 == true, "Failed to encode ERC20")
        } catch {
            print(error)
            XCTFail()
        }
    }
    
    func testERC20EncodeUsingABIv2() {
        let jsonString = "[{\"constant\":true,\"inputs\":[],\"name\":\"name\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"approve\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"totalSupply\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_from\",\"type\":\"address\"},{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transferFrom\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"decimals\",\"outputs\":[{\"name\":\"\",\"type\":\"uint8\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"version\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"}],\"name\":\"balanceOf\",\"outputs\":[{\"name\":\"balance\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"symbol\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transfer\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"},{\"name\":\"_extraData\",\"type\":\"bytes\"}],\"name\":\"approveAndCall\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"},{\"name\":\"_spender\",\"type\":\"address\"}],\"name\":\"allowance\",\"outputs\":[{\"name\":\"remaining\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"inputs\":[{\"name\":\"_initialAmount\",\"type\":\"uint256\"},{\"name\":\"_tokenName\",\"type\":\"string\"},{\"name\":\"_decimalUnits\",\"type\":\"uint8\"},{\"name\":\"_tokenSymbol\",\"type\":\"string\"}],\"type\":\"constructor\"},{\"payable\":false,\"type\":\"fallback\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_from\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_to\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Transfer\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_owner\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_spender\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Approval\",\"type\":\"event\"},]"
        do {
            let jsonData = jsonString.data(using: .utf8)
            let abi = try JSONDecoder().decode([ABIv2.Record].self, from: jsonData!)
            let abiNative = try abi.map({ (record) -> ABIv2.Element in
                return try record.parse()
            })
            let method = abiNative.filter({ (element) -> Bool in
                switch element {
                case .function(let function):
                    return function.name == "transfer"
                default:
                    return false
                }
            })
            let address = "0xE6877A4d8806e9A9F12eB2e8561EA6c1db19978d"
            let amount = BigUInt(10).power(18)
            let parameters = [address, amount] as [AnyObject]
            let result = method[0].encodeParameters(parameters)
            print(abiNative)
            let hex = result!.toHexString()
            print(hex)
            XCTAssert(hex == "a9059cbb000000000000000000000000e6877a4d8806e9a9f12eb2e8561ea6c1db19978d0000000000000000000000000000000000000000000000000de0b6b3a7640000", "Failed to encode ERC20")
            let dummyTrue = BigUInt(1).abiEncode(bits: 256)
            let data = dummyTrue!
            let decoded = method[0].decodeReturnData(data)
            let ret1 = decoded!["0"] as? Bool
            let ret2 = decoded!["success"] as? Bool
            XCTAssert(ret1 == true, "Failed to encode ERC20")
            XCTAssert(ret2 == true, "Failed to encode ERC20")
        } catch {
            print(error)
            XCTFail()
        }
    }

    func testPlasmaFundingTransaction() {
        let abiString = "[{\"constant\":false,\"inputs\":[{\"name\":\"_plasmaBlockNumber\",\"type\":\"uint32\"},{\"name\":\"_plasmaTxNumInBlock\",\"type\":\"uint32\"},{\"name\":\"_plasmaTransaction\",\"type\":\"bytes\"},{\"name\":\"_merkleProof\",\"type\":\"bytes\"}],\"name\":\"proveFundingWithoutDeposit\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"\",\"type\":\"address\"}],\"name\":\"operators\",\"outputs\":[{\"name\":\"\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"\",\"type\":\"uint256\"},{\"name\":\"\",\"type\":\"uint256\"}],\"name\":\"depositRecords\",\"outputs\":[{\"name\":\"from\",\"type\":\"address\"},{\"name\":\"status\",\"type\":\"uint8\"},{\"name\":\"amount\",\"type\":\"uint256\"},{\"name\":\"index\",\"type\":\"uint256\"},{\"name\":\"withdrawStartedTime\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"lastBlockNumber\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_user\",\"type\":\"address\"}],\"name\":\"depositRecordsForUser\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256[]\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"\",\"type\":\"uint256\"},{\"name\":\"\",\"type\":\"uint256\"}],\"name\":\"doubleFundingRecords\",\"outputs\":[{\"name\":\"prooved\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_plasmaBlockNumber1\",\"type\":\"uint32\"},{\"name\":\"_plasmaTxNumInBlock1\",\"type\":\"uint32\"},{\"name\":\"_inputNumber1\",\"type\":\"uint8\"},{\"name\":\"_plasmaTransaction1\",\"type\":\"bytes\"},{\"name\":\"_merkleProof1\",\"type\":\"bytes\"},{\"name\":\"_plasmaBlockNumber2\",\"type\":\"uint32\"},{\"name\":\"_plasmaTxNumInBlock2\",\"type\":\"uint32\"},{\"name\":\"_inputNumber2\",\"type\":\"uint8\"},{\"name\":\"_plasmaTransaction2\",\"type\":\"bytes\"},{\"name\":\"_merkleProof2\",\"type\":\"bytes\"}],\"name\":\"checkActualDoubleSpendProof\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"lastEthBlockNumber\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_blockNumber\",\"type\":\"uint32\"},{\"name\":\"_txNumberInBlock\",\"type\":\"uint32\"},{\"name\":\"_outputNumberInTX\",\"type\":\"uint8\"}],\"name\":\"makeTransactionIndex\",\"outputs\":[{\"name\":\"index\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"root\",\"type\":\"bytes32\"},{\"name\":\"data\",\"type\":\"bytes\"},{\"name\":\"proof\",\"type\":\"bytes\"},{\"name\":\"convertToMessageHash\",\"type\":\"bool\"}],\"name\":\"checkProof\",\"outputs\":[{\"name\":\"\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_plasmaBlockNumber1\",\"type\":\"uint32\"},{\"name\":\"_plasmaTxNumInBlock1\",\"type\":\"uint32\"},{\"name\":\"_inputNumber1\",\"type\":\"uint8\"},{\"name\":\"_plasmaTransaction1\",\"type\":\"bytes\"},{\"name\":\"_merkleProof1\",\"type\":\"bytes\"},{\"name\":\"_plasmaBlockNumber2\",\"type\":\"uint32\"},{\"name\":\"_plasmaTxNumInBlock2\",\"type\":\"uint32\"},{\"name\":\"_inputNumber2\",\"type\":\"uint8\"},{\"name\":\"_plasmaTransaction2\",\"type\":\"bytes\"},{\"name\":\"_merkleProof2\",\"type\":\"bytes\"}],\"name\":\"proveDoubleSpend\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_user\",\"type\":\"address\"}],\"name\":\"withdrawRecordsForUser\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256[]\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_op\",\"type\":\"address\"},{\"name\":\"_status\",\"type\":\"bool\"}],\"name\":\"setOperator\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"name\":\"headers\",\"outputs\":[{\"name\":\"blockNumber\",\"type\":\"uint32\"},{\"name\":\"numTransactions\",\"type\":\"uint32\"},{\"name\":\"v\",\"type\":\"uint8\"},{\"name\":\"previousBlockHash\",\"type\":\"bytes32\"},{\"name\":\"merkleRootHash\",\"type\":\"bytes32\"},{\"name\":\"r\",\"type\":\"bytes32\"},{\"name\":\"s\",\"type\":\"bytes32\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"blockHeaderLength\",\"outputs\":[{\"name\":\"\",\"type\":\"uint32\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"\",\"type\":\"uint256\"},{\"name\":\"\",\"type\":\"uint256\"}],\"name\":\"fundingWithoutDepositRecords\",\"outputs\":[{\"name\":\"prooved\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_plasmaBlockNumber1\",\"type\":\"uint32\"},{\"name\":\"_plasmaTxNumInBlock1\",\"type\":\"uint32\"},{\"name\":\"_plasmaTransaction1\",\"type\":\"bytes\"},{\"name\":\"_merkleProof1\",\"type\":\"bytes\"},{\"name\":\"_plasmaBlockNumber2\",\"type\":\"uint32\"},{\"name\":\"_plasmaTxNumInBlock2\",\"type\":\"uint32\"},{\"name\":\"_plasmaTransaction2\",\"type\":\"bytes\"},{\"name\":\"_merkleProof2\",\"type\":\"bytes\"}],\"name\":\"proveDoubleFunding\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"owner\",\"outputs\":[{\"name\":\"\",\"type\":\"address\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"signer1\",\"type\":\"address\"},{\"name\":\"depositIndex1\",\"type\":\"uint256\"},{\"name\":\"transactionIndex1\",\"type\":\"uint256\"},{\"name\":\"signer2\",\"type\":\"address\"},{\"name\":\"depositIndex2\",\"type\":\"uint256\"},{\"name\":\"transactionIndex2\",\"type\":\"uint256\"}],\"name\":\"checkDoubleFundingFromInternal\",\"outputs\":[{\"name\":\"\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"header\",\"type\":\"bytes\"}],\"name\":\"submitBlockHeader\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"depositCounterInBlock\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_plasmaBlockNumber\",\"type\":\"uint32\"},{\"name\":\"_plasmaTxNumInBlock\",\"type\":\"uint32\"},{\"name\":\"_inputNumber\",\"type\":\"uint8\"},{\"name\":\"_plasmaTransaction\",\"type\":\"bytes\"},{\"name\":\"_merkleProof\",\"type\":\"bytes\"},{\"name\":\"_withdrawIndex\",\"type\":\"uint256\"}],\"name\":\"proveSpendAndWithdraw\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"\",\"type\":\"uint256\"},{\"name\":\"\",\"type\":\"uint256\"}],\"name\":\"withdrawRecords\",\"outputs\":[{\"name\":\"index\",\"type\":\"uint256\"},{\"name\":\"blockNumber\",\"type\":\"uint32\"},{\"name\":\"txNumberInBlock\",\"type\":\"uint32\"},{\"name\":\"outputNumberInTX\",\"type\":\"uint8\"},{\"name\":\"beneficiary\",\"type\":\"address\"},{\"name\":\"isExpress\",\"type\":\"bool\"},{\"name\":\"status\",\"type\":\"uint8\"},{\"name\":\"amount\",\"type\":\"uint256\"},{\"name\":\"timeStarted\",\"type\":\"uint256\"},{\"name\":\"timeEnded\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"\",\"type\":\"uint256\"},{\"name\":\"\",\"type\":\"uint256\"}],\"name\":\"doubleSpendRecords\",\"outputs\":[{\"name\":\"prooved\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[],\"name\":\"deposit\",\"outputs\":[{\"name\":\"idx\",\"type\":\"uint256\"}],\"payable\":true,\"stateMutability\":\"payable\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_plasmaBlockNumber\",\"type\":\"uint32\"},{\"name\":\"_plasmaTxNumInBlock\",\"type\":\"uint32\"},{\"name\":\"_plasmaTransaction\",\"type\":\"bytes\"},{\"name\":\"_merkleProof\",\"type\":\"bytes\"}],\"name\":\"makeWithdrawExpress\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"},{\"name\":\"withdrawIndex\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"\",\"type\":\"uint256\"},{\"name\":\"\",\"type\":\"uint256\"}],\"name\":\"spendAndWithdrawRecords\",\"outputs\":[{\"name\":\"prooved\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"constructor\"},{\"payable\":true,\"stateMutability\":\"payable\",\"type\":\"fallback\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_success\",\"type\":\"bool\"},{\"indexed\":true,\"name\":\"_b\",\"type\":\"bytes32\"},{\"indexed\":true,\"name\":\"_signer\",\"type\":\"address\"}],\"name\":\"Debug\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_1\",\"type\":\"uint256\"},{\"indexed\":true,\"name\":\"_2\",\"type\":\"uint256\"},{\"indexed\":true,\"name\":\"_3\",\"type\":\"uint256\"}],\"name\":\"DebugUint\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_signer\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_r\",\"type\":\"bytes32\"},{\"indexed\":true,\"name\":\"_s\",\"type\":\"bytes32\"}],\"name\":\"SigEvent\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_signer\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_blockNumber\",\"type\":\"uint32\"},{\"indexed\":true,\"name\":\"_blockHash\",\"type\":\"bytes32\"}],\"name\":\"HeaderSubmittedEvent\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_from\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_amount\",\"type\":\"uint256\"},{\"indexed\":true,\"name\":\"_depositIndex\",\"type\":\"uint256\"}],\"name\":\"DepositEvent\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_depositIndex\",\"type\":\"uint256\"}],\"name\":\"DepositWithdrawStartedEvent\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_depositIndex\",\"type\":\"uint256\"}],\"name\":\"DepositWithdrawChallengedEvent\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_depositIndex\",\"type\":\"uint256\"}],\"name\":\"DepositWithdrawCompletedEvent\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_blockNumber\",\"type\":\"uint32\"},{\"indexed\":true,\"name\":\"_txNumberInBlock\",\"type\":\"uint32\"},{\"indexed\":true,\"name\":\"_outputNumberInTX\",\"type\":\"uint8\"}],\"name\":\"WithdrawStartedEvent\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_from\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_withdrawIndex\",\"type\":\"uint256\"}],\"name\":\"WithdrawRequestAcceptedEvent\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_blockNumber\",\"type\":\"uint32\"},{\"indexed\":true,\"name\":\"_txNumberInBlock\",\"type\":\"uint32\"},{\"indexed\":true,\"name\":\"_outputNumberInTX\",\"type\":\"uint8\"}],\"name\":\"WithdrawFinalizedEvent\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_withdrawTxBlockNumber\",\"type\":\"uint32\"},{\"indexed\":true,\"name\":\"_withdrawTxNumberInBlock\",\"type\":\"uint32\"},{\"indexed\":true,\"name\":\"_from\",\"type\":\"address\"}],\"name\":\"ExpressWithdrawMadeEvent\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_txIndex1\",\"type\":\"uint256\"},{\"indexed\":true,\"name\":\"_txIndex2\",\"type\":\"uint256\"}],\"name\":\"DoubleSpendProovedEvent\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_txIndex\",\"type\":\"uint256\"},{\"indexed\":true,\"name\":\"_withdrawIndex\",\"type\":\"uint256\"}],\"name\":\"SpendAndWithdrawProovedEvent\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_txIndex\",\"type\":\"uint256\"},{\"indexed\":true,\"name\":\"_depositIndex\",\"type\":\"uint256\"}],\"name\":\"FundingWithoutDepositEvent\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_txIndex1\",\"type\":\"uint256\"},{\"indexed\":true,\"name\":\"_txIndex2\",\"type\":\"uint256\"}],\"name\":\"DoubleFundingEvent\",\"type\":\"event\"}]"
        do {
            let jsonData = abiString.data(using: .utf8)
            let abi = try JSONDecoder().decode([ABIRecord].self, from: jsonData!)
            let abiNative = try abi.map({ (record) -> ABIElement in
                return try record.parse()
            })
            let address = EthereumAddress("0x158cb5485ea2e7fe03845d45c40c63469814bd9a")
            let amount = BigUInt(10).power(18)
            let contract = Contract(abi: abiNative, at: address)
            var options = Web3Options()
            options.gasLimit = BigUInt(250000)
            options.gasPrice = BigUInt(0)
            options.value = amount
            let transaction = contract.method("deposit", options: options)
            XCTAssert(transaction != nil, "Failed plasma funding transaction")
            let requestDictionary = transaction?.encodeAsDictionary(from: EthereumAddress("0xE6877A4d8806e9A9F12eB2e8561EA6c1db19978d"))
            print(requestDictionary)
            XCTAssert(requestDictionary != nil, "Failed plasma funding transaction")
        } catch {
            print(error)
            XCTFail()
        }
    }
    
    func testERC20balance() {
        let jsonString = "[{\"constant\":true,\"inputs\":[],\"name\":\"name\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"approve\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"totalSupply\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_from\",\"type\":\"address\"},{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transferFrom\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"decimals\",\"outputs\":[{\"name\":\"\",\"type\":\"uint8\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"version\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"}],\"name\":\"balanceOf\",\"outputs\":[{\"name\":\"balance\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"symbol\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transfer\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"},{\"name\":\"_extraData\",\"type\":\"bytes\"}],\"name\":\"approveAndCall\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"},{\"name\":\"_spender\",\"type\":\"address\"}],\"name\":\"allowance\",\"outputs\":[{\"name\":\"remaining\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"inputs\":[{\"name\":\"_initialAmount\",\"type\":\"uint256\"},{\"name\":\"_tokenName\",\"type\":\"string\"},{\"name\":\"_decimalUnits\",\"type\":\"uint8\"},{\"name\":\"_tokenSymbol\",\"type\":\"string\"}],\"type\":\"constructor\"},{\"payable\":false,\"type\":\"fallback\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_from\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_to\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Transfer\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_owner\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_spender\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Approval\",\"type\":\"event\"},]"
        do {
            let jsonData = jsonString.data(using: .utf8)
            let abi = try JSONDecoder().decode([ABIRecord].self, from: jsonData!)
            let abiNative = try abi.map({ (record) -> ABIElement in
                return try record.parse()
            })
            let constractAddress = EthereumAddress("0x86fa049857e0209aa7d9e616f7eb3b3b78ecfdb0")
            let contract = Contract(abi: abiNative, at: constractAddress)
            let options = Web3Options.defaultOptions()
            let address = "0xd0a6e6c54dbc68db5db3a091b171a77407ff7ccf"
            let parameters = [address] as [AnyObject]
            let transaction = contract.method("balanceOf", parameters:parameters,  options: options)
            XCTAssert(transaction != nil, "Failed plasma funding transaction")
            let requestDictionary = transaction!.encodeAsDictionary(from: EthereumAddress("0xE6877A4d8806e9A9F12eB2e8561EA6c1db19978d"))
            XCTAssert(requestDictionary != nil, "Can't read ERC20 balance")
        } catch {
            print(error)
        }
    }
    
    func testERC20balanceUsingABIv2() {
        let jsonString = "[{\"constant\":true,\"inputs\":[],\"name\":\"name\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"approve\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"totalSupply\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_from\",\"type\":\"address\"},{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transferFrom\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"decimals\",\"outputs\":[{\"name\":\"\",\"type\":\"uint8\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"version\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"}],\"name\":\"balanceOf\",\"outputs\":[{\"name\":\"balance\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"symbol\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transfer\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"},{\"name\":\"_extraData\",\"type\":\"bytes\"}],\"name\":\"approveAndCall\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"},{\"name\":\"_spender\",\"type\":\"address\"}],\"name\":\"allowance\",\"outputs\":[{\"name\":\"remaining\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"inputs\":[{\"name\":\"_initialAmount\",\"type\":\"uint256\"},{\"name\":\"_tokenName\",\"type\":\"string\"},{\"name\":\"_decimalUnits\",\"type\":\"uint8\"},{\"name\":\"_tokenSymbol\",\"type\":\"string\"}],\"type\":\"constructor\"},{\"payable\":false,\"type\":\"fallback\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_from\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_to\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Transfer\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_owner\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_spender\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Approval\",\"type\":\"event\"},]"
        do {
            let jsonData = jsonString.data(using: .utf8)
            let abi = try JSONDecoder().decode([ABIv2.Record].self, from: jsonData!)
            let abiNative = try abi.map({ (record) -> ABIv2.Element in
                return try record.parse()
            })
            let constractAddress = EthereumAddress("0x86fa049857e0209aa7d9e616f7eb3b3b78ecfdb0")
            let contract = ContractV2(abi: abiNative, at: constractAddress)
            let options = Web3Options.defaultOptions()
            let address = "0xd0a6e6c54dbc68db5db3a091b171a77407ff7ccf"
            let parameters = [address] as [AnyObject]
            let transaction = contract.method("balanceOf", parameters:parameters,  options: options)
            XCTAssert(transaction != nil, "Failed plasma funding transaction")
            let requestDictionary = transaction!.encodeAsDictionary(from: EthereumAddress("0xE6877A4d8806e9A9F12eB2e8561EA6c1db19978d"))
            XCTAssert(requestDictionary != nil, "Can't read ERC20 balance")
        } catch {
            print(error)
        }
    }
//
//    
    func testERC20name() {
        let jsonString = "[{\"constant\":true,\"inputs\":[],\"name\":\"name\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"approve\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"totalSupply\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_from\",\"type\":\"address\"},{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transferFrom\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"decimals\",\"outputs\":[{\"name\":\"\",\"type\":\"uint8\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"version\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"}],\"name\":\"balanceOf\",\"outputs\":[{\"name\":\"balance\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"symbol\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transfer\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"},{\"name\":\"_extraData\",\"type\":\"bytes\"}],\"name\":\"approveAndCall\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"},{\"name\":\"_spender\",\"type\":\"address\"}],\"name\":\"allowance\",\"outputs\":[{\"name\":\"remaining\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"inputs\":[{\"name\":\"_initialAmount\",\"type\":\"uint256\"},{\"name\":\"_tokenName\",\"type\":\"string\"},{\"name\":\"_decimalUnits\",\"type\":\"uint8\"},{\"name\":\"_tokenSymbol\",\"type\":\"string\"}],\"type\":\"constructor\"},{\"payable\":false,\"type\":\"fallback\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_from\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_to\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Transfer\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_owner\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_spender\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Approval\",\"type\":\"event\"},]"
        do {
            let jsonData = jsonString.data(using: .utf8)
            let abi = try JSONDecoder().decode([ABIRecord].self, from: jsonData!)
            let abiNative = try abi.map({ (record) -> ABIElement in
                return try record.parse()
            })
            let constractAddress = EthereumAddress("0x86fa049857e0209aa7d9e616f7eb3b3b78ecfdb0")
            let contract = Contract(abi: abiNative, at: constractAddress)
            let options = Web3Options.defaultOptions()
            let parameters = [] as [AnyObject]
            let transaction = contract.method("name", parameters:parameters,  options: options)
            XCTAssert(transaction != nil, "Failed to create ERC20 name transaction")
            let requestDictionary = transaction!.encodeAsDictionary(from: EthereumAddress("0xE6877A4d8806e9A9F12eB2e8561EA6c1db19978d"))
            XCTAssert(requestDictionary != nil, "Failed to create ERC20 name transaction")
            let resultData  = Data.fromHex("0x0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000a534f4e4d20546f6b656e00000000000000000000000000000000000000000000")
            let method = contract.methods["name"]
            let result = method!.decodeReturnData(resultData!)
            let res = result!["0"] as! String
            XCTAssert(res == "SONM Token", "Failed to create ERC20 name transaction")
        } catch {
            XCTFail()
            print(error)
        }
    }
    
    func testERC20nameUsingABIv2() {
        let jsonString = "[{\"constant\":true,\"inputs\":[],\"name\":\"name\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"approve\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"totalSupply\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_from\",\"type\":\"address\"},{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transferFrom\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"decimals\",\"outputs\":[{\"name\":\"\",\"type\":\"uint8\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"version\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"}],\"name\":\"balanceOf\",\"outputs\":[{\"name\":\"balance\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"symbol\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transfer\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"},{\"name\":\"_extraData\",\"type\":\"bytes\"}],\"name\":\"approveAndCall\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"},{\"name\":\"_spender\",\"type\":\"address\"}],\"name\":\"allowance\",\"outputs\":[{\"name\":\"remaining\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"inputs\":[{\"name\":\"_initialAmount\",\"type\":\"uint256\"},{\"name\":\"_tokenName\",\"type\":\"string\"},{\"name\":\"_decimalUnits\",\"type\":\"uint8\"},{\"name\":\"_tokenSymbol\",\"type\":\"string\"}],\"type\":\"constructor\"},{\"payable\":false,\"type\":\"fallback\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_from\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_to\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Transfer\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_owner\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_spender\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Approval\",\"type\":\"event\"},]"
        do {
            let jsonData = jsonString.data(using: .utf8)
            let abi = try JSONDecoder().decode([ABIv2.Record].self, from: jsonData!)
            let abiNative = try abi.map({ (record) -> ABIv2.Element in
                return try record.parse()
            })
            let method = abiNative.filter({ (element) -> Bool in
                switch element {
                case .function(let function):
                    return function.name == "name"
                default:
                    return false
                }
            })
            let resultData  = Data.fromHex("0x0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000a534f4e4d20546f6b656e00000000000000000000000000000000000000000000")
            let result = method[0].decodeReturnData(resultData!)
            let res = result!["0"] as! String
            XCTAssert(res == "SONM Token", "Failed to create ERC20 name transaction")
        } catch {
            XCTFail()
            print(error)
        }
    }
    
    func testBigUIntFromHex() {
        let hexRepresentation = "0x1c31de57e49fc00".stripHexPrefix()
        let biguint = BigUInt(hexRepresentation, radix: 16)!
        XCTAssert(biguint == BigUInt("126978086000000000"))
    }
    
    func testInfuraERC20name() {
        let jsonString = "[{\"constant\":true,\"inputs\":[],\"name\":\"name\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"approve\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"totalSupply\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_from\",\"type\":\"address\"},{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transferFrom\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"decimals\",\"outputs\":[{\"name\":\"\",\"type\":\"uint8\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"version\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"}],\"name\":\"balanceOf\",\"outputs\":[{\"name\":\"balance\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"symbol\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transfer\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"},{\"name\":\"_extraData\",\"type\":\"bytes\"}],\"name\":\"approveAndCall\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"},{\"name\":\"_spender\",\"type\":\"address\"}],\"name\":\"allowance\",\"outputs\":[{\"name\":\"remaining\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"inputs\":[{\"name\":\"_initialAmount\",\"type\":\"uint256\"},{\"name\":\"_tokenName\",\"type\":\"string\"},{\"name\":\"_decimalUnits\",\"type\":\"uint8\"},{\"name\":\"_tokenSymbol\",\"type\":\"string\"}],\"type\":\"constructor\"},{\"payable\":false,\"type\":\"fallback\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_from\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_to\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Transfer\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_owner\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_spender\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Approval\",\"type\":\"event\"},]"
            let web3 = Web3.InfuraMainnetWeb3()
            let contractAddress = EthereumAddress("0x45245bc59219eeaaf6cd3f382e078a461ff9de7b")
            let contract = web3.contract(jsonString, at: contractAddress)
            XCTAssert(contract != nil, "Failed to create ERC20 contract from ABI")
            var options = Web3Options.defaultOptions()
            options.from = EthereumAddress("0xE6877A4d8806e9A9F12eB2e8561EA6c1db19978d")
            let parameters = [] as [AnyObject]
            let transactionIntermediate = contract?.method("name", parameters:parameters,  options: options)
            let result = transactionIntermediate!.call(options: options)
            switch result {
            case .failure(let error):
                print(error)
                XCTFail()
            case .success(let response):
                let name = response["0"] as? String
                XCTAssert(name == "\"BANKEX\" project utility token", "Failed to create ERC20 name transaction")
        }
    }
    
    func testInfuraERC20nameUsingABIv2() {
        let jsonString = "[{\"constant\":true,\"inputs\":[],\"name\":\"name\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"approve\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"totalSupply\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_from\",\"type\":\"address\"},{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transferFrom\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"decimals\",\"outputs\":[{\"name\":\"\",\"type\":\"uint8\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"version\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"}],\"name\":\"balanceOf\",\"outputs\":[{\"name\":\"balance\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"symbol\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transfer\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"},{\"name\":\"_extraData\",\"type\":\"bytes\"}],\"name\":\"approveAndCall\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"},{\"name\":\"_spender\",\"type\":\"address\"}],\"name\":\"allowance\",\"outputs\":[{\"name\":\"remaining\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"inputs\":[{\"name\":\"_initialAmount\",\"type\":\"uint256\"},{\"name\":\"_tokenName\",\"type\":\"string\"},{\"name\":\"_decimalUnits\",\"type\":\"uint8\"},{\"name\":\"_tokenSymbol\",\"type\":\"string\"}],\"type\":\"constructor\"},{\"payable\":false,\"type\":\"fallback\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_from\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_to\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Transfer\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_owner\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_spender\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Approval\",\"type\":\"event\"},]"
        let web3 = Web3.InfuraMainnetWeb3()
        let contractAddress = EthereumAddress("0x45245bc59219eeaaf6cd3f382e078a461ff9de7b")
        let contract = web3.contract(jsonString, at: contractAddress,abiVersion: 2)
        XCTAssert(contract != nil, "Failed to create ERC20 contract from ABI")
        var options = Web3Options.defaultOptions()
        options.from = EthereumAddress("0xE6877A4d8806e9A9F12eB2e8561EA6c1db19978d")
        let parameters = [] as [AnyObject]
        let transactionIntermediate = contract?.method("name", parameters:parameters,  options: options)
        let result = transactionIntermediate!.call(options: options)
        switch result {
        case .failure(let error):
            print(error)
            XCTFail()
        case .success(let response):
            let name = response["0"] as? String
            XCTAssert(name == "\"BANKEX\" project utility token", "Failed to create ERC20 name transaction")
            print("Token name = " + name!)
        }
    }
    
    func testTransactionReceipt() {
        let web3 = Web3.InfuraMainnetWeb3()
        let result = web3.eth.getTransactionReceipt("0x83b2433606779fd756417a863f26707cf6d7b2b55f5d744a39ecddb8ca01056e")
        switch result {
        case .failure(let error):
            print(error)
            XCTFail()
        case .success(let response):
            print(response)
            XCTAssert(response.status == .ok)
        }
    }
    
    func testTransactionDetails() {
        let web3 = Web3.InfuraMainnetWeb3()
        let result = web3.eth.getTransactionDetails("0x127519412cefd773b952a5413a4467e9119654f59a34eca309c187bd9f3a195a")
        switch result {
        case .failure(let error):
            print(error)
            XCTFail()
        case .success(let response):
            print(response)
            XCTAssert(response.transaction.gasLimit == BigUInt(78423))
        }
    }
    
    func testABIencoding1()
    {
//        var a = abi.methodID('baz', [ 'uint32', 'bool' ]).toString('hex') + abi.rawEncode([ 'uint32', 'bool' ], [ 69, 1 ]).toString('hex')
//        var b = 'cdcd77c000000000000000000000000000000000000000000000000000000000000000450000000000000000000000000000000000000000000000000000000000000001'
//
        
        let data = TypesEncoder.encode(types: [ABIElement.ParameterType.staticABIType(.uint(bits: 32)), ABIElement.ParameterType.staticABIType(.bool)], parameters: [BigUInt(69), true] as [AnyObject])
        XCTAssert(data != nil, "failed to encode")
        let expected = "0x00000000000000000000000000000000000000000000000000000000000000450000000000000000000000000000000000000000000000000000000000000001"
        XCTAssert(data?.toHexString().lowercased().addHexPrefix() == expected, "failed to encode")
    }
    
    func testABIencoding2()
    {
        let data = TypesEncoder.encode(types: [ABIElement.ParameterType.dynamicABIType(.string)], parameters: ["dave"] as [AnyObject])
        XCTAssert(data != nil, "failed to encode")
        let expected = "0x000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000046461766500000000000000000000000000000000000000000000000000000000"
        print(data?.toHexString().lowercased().addHexPrefix())
        XCTAssert(data?.toHexString().lowercased().addHexPrefix() == expected, "failed to encode")
    }
    
    func testABIencoding3()
    {
//        var a = abi.methodID('sam', [ 'bytes', 'bool', 'uint256[]' ]).toString('hex') + abi.rawEncode([ 'bytes', 'bool', 'uint256[]' ], [ 'dave', true, [ 1, 2, 3 ] ]).toString('hex')
//        var b = 'a5643bf20000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000a0000000000000000000000000000000000000000000000000000000000000000464617665000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000003'

        
        let data = TypesEncoder.encode(types: [ABIElement.ParameterType.dynamicABIType(.bytes), ABIElement.ParameterType.staticABIType(.bool),
                                               ABIElement.ParameterType.dynamicABIType(.dynamicArray(.uint(bits: 256)))], parameters: ["dave".data(using: .utf8)!, true, [BigUInt(1), BigUInt(2), BigUInt(3)] ] as [AnyObject])
        XCTAssert(data != nil, "failed to encode")
        let expected = "0x0000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000a0000000000000000000000000000000000000000000000000000000000000000464617665000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000003"
        print(data?.toHexString().lowercased().addHexPrefix())
        XCTAssert(data?.toHexString().lowercased().addHexPrefix() == expected, "failed to encode")
    }
    
    func testABIencoding4()
    {
//        var a = abi.rawEncode([ 'int256' ], [ new BN('-19999999999999999999999999999999999999999999999999999999999999', 10) ]).toString('hex')
//        var b = 'fffffffffffff38dd0f10627f5529bdb2c52d4846810af0ac000000000000001'
        
        let number = BigInt("-19999999999999999999999999999999999999999999999999999999999999", radix: 10)
        let data = TypesEncoder.encode(types: [ABIElement.ParameterType.staticABIType(.int(bits: 256))],
                                       parameters: [number!] as [AnyObject])
        XCTAssert(data != nil, "failed to encode")
        let expected = "0xfffffffffffff38dd0f10627f5529bdb2c52d4846810af0ac000000000000001"
        print(data?.toHexString().lowercased().addHexPrefix())
        XCTAssert(data?.toHexString().lowercased().addHexPrefix() == expected, "failed to encode")
    }
    
    func testABIencoding5()
    {
//        var a = abi.rawEncode([ 'string' ], [ ' hello world hello world hello world hello world  hello world hello world hello world hello world  hello world hello world hello world hello world hello world hello world hello world hello world' ]).toString('hex')
//        var b = '000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000c22068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c64202068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c64202068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c64000000000000000000000000000000000000000000000000000000000000'
        
        let string = " hello world hello world hello world hello world  hello world hello world hello world hello world  hello world hello world hello world hello world hello world hello world hello world hello world"
        let data = TypesEncoder.encode(types: [ABIElement.ParameterType.dynamicABIType(.string)],
                                       parameters: [string] as [AnyObject])
        XCTAssert(data != nil, "failed to encode")
        let expected = "0x000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000c22068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c64202068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c64202068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c64000000000000000000000000000000000000000000000000000000000000"
        print(data?.toHexString().lowercased().addHexPrefix())
        XCTAssert(data?.toHexString().lowercased().addHexPrefix() == expected, "failed to encode")
    }
    
    func testABIencoding6()
    {
//        var a = abi.methodID('f', [ 'uint', 'uint32[]', 'bytes10', 'bytes' ]).toString('hex') + abi.rawEncode([ 'uint', 'uint32[]', 'bytes10', 'bytes' ], [ 0x123, [ 0x456, 0x789 ], '1234567890', 'Hello, world!' ]).toString('hex')
//        var b = '8be6524600000000000000000000000000000000000000000000000000000000000001230000000000000000000000000000000000000000000000000000000000000080313233343536373839300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e0000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000004560000000000000000000000000000000000000000000000000000000000000789000000000000000000000000000000000000000000000000000000000000000d48656c6c6f2c20776f726c642100000000000000000000000000000000000000'
        
        let data = TypesEncoder.encode(types: [ABIElement.ParameterType.staticABIType(.uint(bits: 256)),
                                               ABIElement.ParameterType.dynamicABIType(.dynamicArray(.uint(bits: 32))),
                                               ABIElement.ParameterType.staticABIType(.bytes(length: 10)),
                                               ABIElement.ParameterType.dynamicABIType(.bytes)],
                                       parameters: [BigUInt("123", radix: 16)!,
                                                    [BigUInt("456", radix: 16)!, BigUInt("789", radix: 16)!] as [AnyObject],
                                                    "1234567890",
                                                    "Hello, world!"] as [AnyObject])
        XCTAssert(data != nil, "failed to encode")
        let expected = "0x00000000000000000000000000000000000000000000000000000000000001230000000000000000000000000000000000000000000000000000000000000080313233343536373839300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e0000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000004560000000000000000000000000000000000000000000000000000000000000789000000000000000000000000000000000000000000000000000000000000000d48656c6c6f2c20776f726c642100000000000000000000000000000000000000"
        print(data?.toHexString().lowercased().addHexPrefix())
        XCTAssert(data?.toHexString().lowercased().addHexPrefix() == expected, "failed to encode")
    }

    func testABIencoding7()
    {
//        uint128[2][3] it's three arrays of arrays of length 2
        var data: Data?
        let subarrayOfLength2 = ABIElement.ParameterType.staticABIType(.array(.uint(bits: 256), length: 2))
        switch subarrayOfLength2 {
        case .staticABIType(let type):
            let arrayOfLength3OfSubarrays = ABIElement.ParameterType.staticABIType(.array(type, length: 3))
            data = TypesEncoder.encode(types: [arrayOfLength3OfSubarrays], parameters: [[[BigUInt("1"),
                                                                                             BigUInt("2")] as [AnyObject],
                                                                                            [BigUInt("3"),
                                                                                             BigUInt("4")] as [AnyObject],
                                                                                            [BigUInt("5"),
                                                                                             BigUInt("6")] as [AnyObject]]] as [AnyObject])
        default:
            XCTFail()
        }
        XCTAssert(data != nil, "failed to encode")
        let expected = "0x000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000000000000000000000000000006"
        print(data?.toHexString().lowercased().addHexPrefix())
        XCTAssert(data?.toHexString().lowercased().addHexPrefix() == expected, "failed to encode")
    }

    func testABIv2encoding1()
    {
        //        var a = abi.methodID('baz', [ 'uint32', 'bool' ]).toString('hex') + abi.rawEncode([ 'uint32', 'bool' ], [ 69, 1 ]).toString('hex')
        //        var b = 'cdcd77c000000000000000000000000000000000000000000000000000000000000000450000000000000000000000000000000000000000000000000000000000000001'
        //
        let types = [
            ABIv2.Element.InOut(name: "1", type: ABIv2.Element.ParameterType.uint(bits: 32)),
            ABIv2.Element.InOut(name: "2", type: ABIv2.Element.ParameterType.bool)
        ]
        let data = ABIv2Encoder.encode(types: types, values: [BigUInt(69), true] as [AnyObject])
        XCTAssert(data != nil, "failed to encode")
        let expected = "0x00000000000000000000000000000000000000000000000000000000000000450000000000000000000000000000000000000000000000000000000000000001"
        print(data!.toHexString().lowercased())
        XCTAssert(data?.toHexString().lowercased().addHexPrefix() == expected, "failed to encode")
    }
    
    func testABIv2encoding2()
    {
        let types = [
            ABIv2.Element.InOut(name: "1", type: ABIv2.Element.ParameterType.string)
        ]
        let data = ABIv2Encoder.encode(types: types, values: ["dave"] as [AnyObject])
        XCTAssert(data != nil, "failed to encode")
        let expected = "0x000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000046461766500000000000000000000000000000000000000000000000000000000"
        print(data!.toHexString().lowercased())
        XCTAssert(data?.toHexString().lowercased().addHexPrefix() == expected, "failed to encode")
    }

    func testABIv2encoding3()
    {
        //        var a = abi.methodID('sam', [ 'bytes', 'bool', 'uint256[]' ]).toString('hex') + abi.rawEncode([ 'bytes', 'bool', 'uint256[]' ], [ 'dave', true, [ 1, 2, 3 ] ]).toString('hex')
        //        var b = 'a5643bf20000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000a0000000000000000000000000000000000000000000000000000000000000000464617665000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000003'
        let types = [
            ABIv2.Element.InOut(name: "1", type: ABIv2.Element.ParameterType.dynamicBytes),
            ABIv2.Element.InOut(name: "2", type: ABIv2.Element.ParameterType.bool),
            ABIv2.Element.InOut(name: "3", type: ABIv2.Element.ParameterType.array(type: .uint(bits: 256), length: 0))
        ]
        
        let data = ABIv2Encoder.encode(types: types, values: ["dave".data(using: .utf8)!, true, [BigUInt(1), BigUInt(2), BigUInt(3)] ] as [AnyObject])
        XCTAssert(data != nil, "failed to encode")
        let expected = "0x0000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000a0000000000000000000000000000000000000000000000000000000000000000464617665000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000003"
        print(data!.toHexString().lowercased())
        XCTAssert(data?.toHexString().lowercased().addHexPrefix() == expected, "failed to encode")
    }

    func testABIv2encoding4()
    {
        //        var a = abi.rawEncode([ 'int256' ], [ new BN('-19999999999999999999999999999999999999999999999999999999999999', 10) ]).toString('hex')
        //        var b = 'fffffffffffff38dd0f10627f5529bdb2c52d4846810af0ac000000000000001'
        
        let types = [ABIv2.Element.InOut(name: "1", type: ABIv2.Element.ParameterType.int(bits: 256))]
        let number = BigInt("-19999999999999999999999999999999999999999999999999999999999999", radix: 10)
        let data = ABIv2Encoder.encode(types: types,
                                       values: [number!] as [AnyObject])
        XCTAssert(data != nil, "failed to encode")
        let expected = "0xfffffffffffff38dd0f10627f5529bdb2c52d4846810af0ac000000000000001"
        print(data?.toHexString().lowercased().addHexPrefix())
        XCTAssert(data?.toHexString().lowercased().addHexPrefix() == expected, "failed to encode")
    }

    func testABIv2encoding5()
    {
        //        var a = abi.rawEncode([ 'string' ], [ ' hello world hello world hello world hello world  hello world hello world hello world hello world  hello world hello world hello world hello world hello world hello world hello world hello world' ]).toString('hex')
        //        var b = '000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000c22068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c64202068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c64202068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c64000000000000000000000000000000000000000000000000000000000000'
        
        let string = " hello world hello world hello world hello world  hello world hello world hello world hello world  hello world hello world hello world hello world hello world hello world hello world hello world"
        let types = [ABIv2.Element.InOut(name: "1", type: ABIv2.Element.ParameterType.string)]
        let data = ABIv2Encoder.encode(types: types,
                                       values: [string] as [AnyObject])
        XCTAssert(data != nil, "failed to encode")
        let expected = "0x000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000c22068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c64202068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c64202068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c64000000000000000000000000000000000000000000000000000000000000"
        print(data?.toHexString().lowercased().addHexPrefix())
        XCTAssert(data?.toHexString().lowercased().addHexPrefix() == expected, "failed to encode")
    }

    func testABIv2encoding6()
    {
        //        var a = abi.methodID('f', [ 'uint', 'uint32[]', 'bytes10', 'bytes' ]).toString('hex') + abi.rawEncode([ 'uint', 'uint32[]', 'bytes10', 'bytes' ], [ 0x123, [ 0x456, 0x789 ], '1234567890', 'Hello, world!' ]).toString('hex')
        //        var b = '8be6524600000000000000000000000000000000000000000000000000000000000001230000000000000000000000000000000000000000000000000000000000000080313233343536373839300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e0000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000004560000000000000000000000000000000000000000000000000000000000000789000000000000000000000000000000000000000000000000000000000000000d48656c6c6f2c20776f726c642100000000000000000000000000000000000000'
        let types = [ABIv2.Element.InOut(name: "1", type: ABIv2.Element.ParameterType.uint(bits: 256)),
                     ABIv2.Element.InOut(name: "2", type: ABIv2.Element.ParameterType.array(type: .uint(bits: 32), length: 0)),
                     ABIv2.Element.InOut(name: "3", type: ABIv2.Element.ParameterType.bytes(length: 10)),
                     ABIv2.Element.InOut(name: "1", type: ABIv2.Element.ParameterType.dynamicBytes)
                     ]
        let data = ABIv2Encoder.encode(types: types,
                                       values: [BigUInt("123", radix: 16)!,
                                                    [BigUInt("456", radix: 16)!, BigUInt("789", radix: 16)!] as [AnyObject],
                                                    "1234567890",
                                                    "Hello, world!"] as [AnyObject])
        XCTAssert(data != nil, "failed to encode")
        let expected = "0x00000000000000000000000000000000000000000000000000000000000001230000000000000000000000000000000000000000000000000000000000000080313233343536373839300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e0000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000004560000000000000000000000000000000000000000000000000000000000000789000000000000000000000000000000000000000000000000000000000000000d48656c6c6f2c20776f726c642100000000000000000000000000000000000000"
        print(data!.toHexString().lowercased())
        XCTAssert(data?.toHexString().lowercased().addHexPrefix() == expected, "failed to encode")
    }
    
    func testABIv2encoding7()
    {
        let types = [
                     ABIv2.Element.InOut(name: "2", type: ABIv2.Element.ParameterType.array(type: .string, length: 0))
        ]
        let data = ABIv2Encoder.encode(types: types,
                                       values: [["Hello", "World"]] as [AnyObject])
        XCTAssert(data != nil, "failed to encode")
        let expected = "0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000548656c6c6f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005576f726c64000000000000000000000000000000000000000000000000000000"
        print(data!.toHexString().lowercased())
        XCTAssert(data?.toHexString().lowercased() == expected, "failed to encode")
    }
    
    func testABIv2encoding8()
    {
        let types = [
            ABIv2.Element.InOut(name: "2", type: ABIv2.Element.ParameterType.array(type: .string, length: 2))
        ]
        let data = ABIv2Encoder.encode(types: types,
                                       values: [["Hello", "World"]] as [AnyObject])
        XCTAssert(data != nil, "failed to encode")
        let expected = "000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000548656c6c6f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005576f726c64000000000000000000000000000000000000000000000000000000"
        print(data!.toHexString().lowercased())
        XCTAssert(data?.toHexString().lowercased() == expected, "failed to encode")
    }
    
    
    
    func testABIv2Decoding1() {
        let data = "0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000005c0000000000000000000000000000000000000000000000000000000000000003"
        let types = [ABIv2.Element.InOut(name: "1", type: ABIv2.Element.ParameterType.array(type: .uint(bits: 256), length: 2)),
                     ABIv2.Element.InOut(name: "2", type: ABIv2.Element.ParameterType.uint(bits: 256))]
        let res = ABIv2Decoder.decode(types: types, data: Data.fromHex(data)!)
        guard let result = res else {return XCTFail()}
        XCTAssert(result.count == 2)
        guard let firstElement = result[0] as? [BigUInt] else {return XCTFail()}
        XCTAssert(firstElement.count == 2)
        guard let secondElement = result[1] as? BigUInt else {return XCTFail()}
        XCTAssert(firstElement[0] == BigUInt(1))
        XCTAssert(firstElement[1] == BigUInt(92))
        XCTAssert(secondElement == BigUInt(3))
     }
    
    func testABIv2Decoding2() {
        let data = "00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000003"
        let types = [ABIv2.Element.InOut(name: "1", type: ABIv2.Element.ParameterType.array(type: .uint(bits: 256), length: 0))]
        let res = ABIv2Decoder.decode(types: types, data: Data.fromHex(data)!)
        guard let result = res else {return XCTFail()}
        XCTAssert(result.count == 1)
        guard let firstElement = result[0] as? [BigUInt] else {return XCTFail()}
        XCTAssert(firstElement.count == 3)
        XCTAssert(firstElement[0] == BigUInt(1))
        XCTAssert(firstElement[1] == BigUInt(2))
        XCTAssert(firstElement[2] == BigUInt(3))
    }
    
    func testABIv2Decoding3() {
        let data = "0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000b68656c6c6f20776f726c64000000000000000000000000000000000000000000"
        let types = [ABIv2.Element.InOut(name: "1", type: ABIv2.Element.ParameterType.dynamicBytes)]
        let res = ABIv2Decoder.decode(types: types, data: Data.fromHex(data)!)
        guard let result = res else {return XCTFail()}
        XCTAssert(result.count == 1)
        guard let firstElement = result[0] as? Data else {return XCTFail()}
        XCTAssert(firstElement.count == 11)
    }
    
    func testABIv2Decoding4() {
        let data = "0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000b68656c6c6f20776f726c64000000000000000000000000000000000000000000"
        let types = [ABIv2.Element.InOut(name: "1", type: ABIv2.Element.ParameterType.string)]
        let res = ABIv2Decoder.decode(types: types, data: Data.fromHex(data)!)
        guard let result = res else {return XCTFail()}
        XCTAssert(result.count == 1)
        guard let firstElement = result[0] as? String else {return XCTFail()}
        XCTAssert(firstElement == "hello world")
    }
    
    func testABIv2Decoding5() {
        let data = "fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe"
        let types = [ABIv2.Element.InOut(name: "1", type: ABIv2.Element.ParameterType.int(bits: 32))]
        let res = ABIv2Decoder.decode(types: types, data: Data.fromHex(data)!)
        guard let result = res else {return XCTFail()}
        XCTAssert(result.count == 1)
        guard let firstElement = result[0] as? BigInt else {return XCTFail()}
        XCTAssert(firstElement == BigInt(-2))
    }
    
    func testABIv2Decoding6() {
        let data = "ffffffffffffffffffffffffffffffffffffffffffffffffffffb29c26f344fe"
        let types = [ABIv2.Element.InOut(name: "1", type: ABIv2.Element.ParameterType.int(bits: 64))]
        let res = ABIv2Decoder.decode(types: types, data: Data.fromHex(data)!)
        guard let result = res else {return XCTFail()}
        XCTAssert(result.count == 1)
        guard let firstElement = result[0] as? BigInt else {return XCTFail()}
        XCTAssert(firstElement == BigInt(-85091238591234))
    }
    
    func testABIv2Decoding7() {
        let data = "0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000002a"
        let types = [ABIv2.Element.InOut(name: "1", type: ABIv2.Element.ParameterType.bool),
            ABIv2.Element.InOut(name: "1", type: ABIv2.Element.ParameterType.uint(bits: 32))]
        let res = ABIv2Decoder.decode(types: types, data: Data.fromHex(data)!)
        guard let result = res else {return XCTFail()}
        XCTAssert(result.count == types.count)
        guard let firstElement = result[0] as? Bool else {return XCTFail()}
        XCTAssert(firstElement == true)
        guard let secondElement = result[1] as? BigUInt else {return XCTFail()}
        XCTAssert(secondElement == 42)
    }
    
    func testABIv2Decoding8() {
        let data = "000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000002a"
        let types = [ABIv2.Element.InOut(name: "1", type: ABIv2.Element.ParameterType.bool),
                     ABIv2.Element.InOut(name: "1", type: ABIv2.Element.ParameterType.array(type: .uint(bits: 256), length: 0))]
        let res = ABIv2Decoder.decode(types: types, data: Data.fromHex(data)!)
        guard let result = res else {return XCTFail()}
        XCTAssert(result.count == types.count)
        guard let firstElement = result[0] as? Bool else {return XCTFail()}
        XCTAssert(firstElement == true)
        guard let secondElement = result[1] as? [BigUInt] else {return XCTFail()}
        XCTAssert(secondElement.count == 1)
        XCTAssert(secondElement[0] == 42)
    }
    
    func testABIv2Decoding9() {
        let data = "0000000000000000000000000000000000000000000000000000000000000020" +
            "0000000000000000000000000000000000000000000000000000000000000002" +
            "000000000000000000000000407d73d8a49eeb85d32cf465507dd71d507100c1" +
        "000000000000000000000000407d73d8a49eeb85d32cf465507dd71d507100c3"
        let types = [ABIv2.Element.InOut(name: "1", type: ABIv2.Element.ParameterType.array(type: .address, length: 0))]
        let res = ABIv2Decoder.decode(types: types, data: Data.fromHex(data)!)
        guard let result = res else {return XCTFail()}
        XCTAssert(result.count == types.count)
        guard let firstElement = result[0] as? [EthereumAddress] else {return XCTFail()}
        XCTAssert(firstElement.count == 2)
        XCTAssert(firstElement[0].address.lowercased().stripHexPrefix() == "407d73d8a49eeb85d32cf465507dd71d507100c1")
        XCTAssert(firstElement[1].address.lowercased().stripHexPrefix() == "407d73d8a49eeb85d32cf465507dd71d507100c3")
    }
    

    
    func testABIparsing1()
    {
        let typeString = "uint256[2][3]"
        let type = try! ABITypeParser.parseTypeString(typeString)
        switch type {
        case .staticABIType(let unwrappedType):
            switch unwrappedType{
            case .array(_, length: let length):
                XCTAssert(length == 3, "Failed to parse")
            default:
                XCTFail()
            }
        case .dynamicABIType(_):
            XCTFail()
            
        }
    }
    
    func testABIparsing2()
    {
        let typeString = "uint256[2][]"
        let type = try! ABITypeParser.parseTypeString(typeString)
        switch type {
        case .staticABIType(_):
            XCTFail()
        case .dynamicABIType(let unwrappedType):
            switch unwrappedType{
            case .dynamicArray(_):
                XCTAssert(true)
            default:
                XCTFail()
            }
        }
    }
    
    func testBloom() {
        let positive = [
                "testtest",
                "test",
                "hallo",
                "other",
            ]
        let negative = [
                "tes",
                "lo",
            ]
        var bloom = EthereumBloomFilter()
        for str in positive {
            let data = str.data(using: .utf8)!
            let oldBytes = bloom.bytes
            bloom.add(BigUInt(data))
            let newBytes = bloom.bytes
            if (newBytes != oldBytes) {
                print("Added new bits")
            }
        }
        for str in positive {
            let data = str.data(using: .utf8)!
            XCTAssert(bloom.lookup(data), "Failed")
        }
        for str in negative {
            let data = str.data(using: .utf8)!
            XCTAssert(bloom.lookup(data) == false, "Failed")
        }
    }

    func testGetBlockByHash() {
        let web3 = Web3.InfuraMainnetWeb3()
        let response = web3.eth.getBlockByHash("0x6d05ba24da6b7a1af22dc6cc2a1fe42f58b2a5ea4c406b19c8cf672ed8ec0695", fullTransactions: true)
        switch response {
        case .failure(_):
            XCTFail()
        case .success(let result):
            print(result)
        }
    }
    
    func testGetBlockByNumber1() {
        let web3 = Web3.InfuraMainnetWeb3()
        let response = web3.eth.getBlockByNumber("latest", fullTransactions: true)
        switch response {
        case .failure(_):
            XCTFail()
        case .success(let result):
            print(result)
        }
    }
    
    func testGetBlockByNumber2() {
        let web3 = Web3.InfuraMainnetWeb3()
        let response = web3.eth.getBlockByNumber(UInt64(5184323), fullTransactions: true)
        switch response {
        case .failure(_):
            XCTFail()
        case .success(let result):
            print(result)
            let transactions = result.transactions
            for transaction in transactions {
                switch transaction {
                case .transaction(let tx):
                    print(String(describing: tx))
                default:
                    break
                }
            }
        }
    }
    
    func testGetBlockByNumber3() {
        let web3 = Web3.InfuraMainnetWeb3()
        let response = web3.eth.getBlockByNumber(UInt64(1000000000), fullTransactions: true)
        switch response {
        case .failure(_):
            break
        case .success(_):
            XCTFail()
        }
    }
    
    func testEventParsing1() {
        let jsonString = "[{\"constant\":true,\"inputs\":[],\"name\":\"name\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"approve\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"totalSupply\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_from\",\"type\":\"address\"},{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transferFrom\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"decimals\",\"outputs\":[{\"name\":\"\",\"type\":\"uint8\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"version\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"}],\"name\":\"balanceOf\",\"outputs\":[{\"name\":\"balance\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"symbol\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transfer\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"},{\"name\":\"_extraData\",\"type\":\"bytes\"}],\"name\":\"approveAndCall\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"},{\"name\":\"_spender\",\"type\":\"address\"}],\"name\":\"allowance\",\"outputs\":[{\"name\":\"remaining\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"inputs\":[{\"name\":\"_initialAmount\",\"type\":\"uint256\"},{\"name\":\"_tokenName\",\"type\":\"string\"},{\"name\":\"_decimalUnits\",\"type\":\"uint8\"},{\"name\":\"_tokenSymbol\",\"type\":\"string\"}],\"type\":\"constructor\"},{\"payable\":false,\"type\":\"fallback\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_from\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_to\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Transfer\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_owner\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_spender\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Approval\",\"type\":\"event\"},]"
        let web3 = Web3.InfuraMainnetWeb3()
        let response = web3.eth.getBlockByNumber(UInt64(5200088), fullTransactions: true)
        switch response {
        case .failure(_):
            XCTFail()
        case .success(let result):
            print(result)
            let contractAddress = EthereumAddress("0x45245bc59219eeaaf6cd3f382e078a461ff9de7b")
            let contract = Contract(jsonString, at: contractAddress)
            let event = contract?.events["Transfer"]
            let parser = EventParser(web3: web3, event: event!,  contract: contract!, filter: nil, forAddress: contractAddress)
            let present = parser!.parseBlock(result)
            guard case .success(let pres) = present else {return XCTFail()}
            print(pres)
            XCTAssert(pres.count == 1)
            let decoded = pres[0].decodedResult
            XCTAssert(decoded["name"] as! String == "Transfer")
            XCTAssert(decoded["_to"] as! EthereumAddress == EthereumAddress("0xa5dcf6e0fee38f635c4a8d50d90e24400ed547d2"))
            XCTAssert(decoded["_from"] as! EthereumAddress == EthereumAddress("0xdbf493e8d7db835192c02b992bd1ab72e96fd2e3"))
            XCTAssert(decoded["_value"] as! BigUInt == BigUInt("3946fe37ffce3a0000", radix: 16)!)
        }
    }
    
    func testEventParsing2() {
        let jsonString = "[{\"constant\":true,\"inputs\":[],\"name\":\"name\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"approve\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"totalSupply\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_from\",\"type\":\"address\"},{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transferFrom\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"decimals\",\"outputs\":[{\"name\":\"\",\"type\":\"uint8\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"version\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"}],\"name\":\"balanceOf\",\"outputs\":[{\"name\":\"balance\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"symbol\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transfer\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"},{\"name\":\"_extraData\",\"type\":\"bytes\"}],\"name\":\"approveAndCall\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"},{\"name\":\"_spender\",\"type\":\"address\"}],\"name\":\"allowance\",\"outputs\":[{\"name\":\"remaining\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"inputs\":[{\"name\":\"_initialAmount\",\"type\":\"uint256\"},{\"name\":\"_tokenName\",\"type\":\"string\"},{\"name\":\"_decimalUnits\",\"type\":\"uint8\"},{\"name\":\"_tokenSymbol\",\"type\":\"string\"}],\"type\":\"constructor\"},{\"payable\":false,\"type\":\"fallback\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_from\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_to\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Transfer\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_owner\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_spender\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Approval\",\"type\":\"event\"},]"
        let web3 = Web3.InfuraMainnetWeb3()
        let response = web3.eth.getBlockByNumber(UInt64(5200120), fullTransactions: false)
        switch response {
        case .failure(_):
            XCTFail()
        case .success(let result):
            print(result)
            let contractAddress = EthereumAddress("0x45245bc59219eeaaf6cd3f382e078a461ff9de7b")
            let contract = Contract(jsonString, at: contractAddress)
            let event = contract?.events["Transfer"]
            let parser = EventParser(web3: web3, event: event!,  contract: contract!, filter: nil, forAddress: nil)
            let present = parser!.parseBlock(result)
            guard case .success(let pres) = present else {return XCTFail()}
            print(pres)
            XCTAssert(pres.count == 81)
        }
    }
    
    func testEventParsing3() {
        let jsonString = "[{\"constant\":true,\"inputs\":[],\"name\":\"name\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"approve\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"totalSupply\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_from\",\"type\":\"address\"},{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transferFrom\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"decimals\",\"outputs\":[{\"name\":\"\",\"type\":\"uint8\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"version\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"}],\"name\":\"balanceOf\",\"outputs\":[{\"name\":\"balance\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"symbol\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transfer\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"},{\"name\":\"_extraData\",\"type\":\"bytes\"}],\"name\":\"approveAndCall\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"},{\"name\":\"_spender\",\"type\":\"address\"}],\"name\":\"allowance\",\"outputs\":[{\"name\":\"remaining\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"inputs\":[{\"name\":\"_initialAmount\",\"type\":\"uint256\"},{\"name\":\"_tokenName\",\"type\":\"string\"},{\"name\":\"_decimalUnits\",\"type\":\"uint8\"},{\"name\":\"_tokenSymbol\",\"type\":\"string\"}],\"type\":\"constructor\"},{\"payable\":false,\"type\":\"fallback\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_from\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_to\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Transfer\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_owner\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_spender\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Approval\",\"type\":\"event\"},]"
        let web3 = Web3.InfuraMainnetWeb3()
        let blockNumber = web3.eth.getBlockNumber()
        guard case .success(let currentBlock) = blockNumber else {return XCTFail()}
        let currentBlockAsInt = UInt64(currentBlock)
        for i in currentBlockAsInt-3 ... currentBlockAsInt {
            let response = web3.eth.getBlockByNumber(i, fullTransactions: false)
            switch response {
            case .failure(_):
                XCTFail()
            case .success(let result):
//                print(result)
                let contractAddress = EthereumAddress("0x45245bc59219eeaaf6cd3f382e078a461ff9de7b")
                let contract = Contract(jsonString, at: contractAddress)
                let event = contract?.events["Transfer"]
                let parser = EventParser(web3: web3, event: event!,  contract: contract!, filter: nil, forAddress: nil)
                let present = parser!.parseBlock(result)
                guard case .success(let pres) = present else {return XCTFail()}
                for p in pres {
                    print("Block " + String(i) + "\n")
                    print("From " + (p.decodedResult["_from"] as! EthereumAddress).address + "\n")
                    print("From " + (p.decodedResult["_to"] as! EthereumAddress).address + "\n")
                    print("Value " + String(p.decodedResult["_value"] as! BigUInt) + "\n")
                }
            }
        }
    }
    
    func testEventParsing1usingABIv2() {
        let jsonString = "[{\"constant\":true,\"inputs\":[],\"name\":\"name\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"approve\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"totalSupply\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_from\",\"type\":\"address\"},{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transferFrom\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"decimals\",\"outputs\":[{\"name\":\"\",\"type\":\"uint8\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"version\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"}],\"name\":\"balanceOf\",\"outputs\":[{\"name\":\"balance\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"symbol\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transfer\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"},{\"name\":\"_extraData\",\"type\":\"bytes\"}],\"name\":\"approveAndCall\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"},{\"name\":\"_spender\",\"type\":\"address\"}],\"name\":\"allowance\",\"outputs\":[{\"name\":\"remaining\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"inputs\":[{\"name\":\"_initialAmount\",\"type\":\"uint256\"},{\"name\":\"_tokenName\",\"type\":\"string\"},{\"name\":\"_decimalUnits\",\"type\":\"uint8\"},{\"name\":\"_tokenSymbol\",\"type\":\"string\"}],\"type\":\"constructor\"},{\"payable\":false,\"type\":\"fallback\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_from\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_to\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Transfer\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_owner\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_spender\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Approval\",\"type\":\"event\"},]"
        let contractAddress = EthereumAddress("0x45245bc59219eeaaf6cd3f382e078a461ff9de7b")
        let web3 = Web3.InfuraMainnetWeb3()
        let contract = web3.contract(jsonString, at: contractAddress, abiVersion: 2)
        guard let eventParser = contract?.createEventParser("Transfer", filter: nil) else {return XCTFail()}
        let present = eventParser.parseBlockByNumber(UInt64(5200088))
        guard case .success(let pres) = present else {return XCTFail()}
        print(pres)
        XCTAssert(pres.count == 1)
        let decoded = pres[0].decodedResult
        XCTAssert(decoded["name"] as! String == "Transfer")
        XCTAssert(decoded["_to"] as! EthereumAddress == EthereumAddress("0xa5dcf6e0fee38f635c4a8d50d90e24400ed547d2"))
        XCTAssert(decoded["_from"] as! EthereumAddress == EthereumAddress("0xdbf493e8d7db835192c02b992bd1ab72e96fd2e3"))
        XCTAssert(decoded["_value"] as! BigUInt == BigUInt("3946fe37ffce3a0000", radix: 16)!)
        XCTAssert(pres[0].contractAddress == EthereumAddress("0x45245bc59219eeaaf6cd3f382e078a461ff9de7b"))
        XCTAssert(pres[0].transactionReceipt.transactionHash.toHexString().addHexPrefix() == "0xcb235e8c6ecda032bc82c1084d2159ab82e7e4de35be703da6e80034bc577673")
    }
    
    func testEventParsing2usingABIv2() {
        let jsonString = "[{\"constant\":true,\"inputs\":[],\"name\":\"name\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"approve\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"totalSupply\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_from\",\"type\":\"address\"},{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transferFrom\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"decimals\",\"outputs\":[{\"name\":\"\",\"type\":\"uint8\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"version\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"}],\"name\":\"balanceOf\",\"outputs\":[{\"name\":\"balance\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"symbol\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transfer\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"},{\"name\":\"_extraData\",\"type\":\"bytes\"}],\"name\":\"approveAndCall\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"},{\"name\":\"_spender\",\"type\":\"address\"}],\"name\":\"allowance\",\"outputs\":[{\"name\":\"remaining\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"inputs\":[{\"name\":\"_initialAmount\",\"type\":\"uint256\"},{\"name\":\"_tokenName\",\"type\":\"string\"},{\"name\":\"_decimalUnits\",\"type\":\"uint8\"},{\"name\":\"_tokenSymbol\",\"type\":\"string\"}],\"type\":\"constructor\"},{\"payable\":false,\"type\":\"fallback\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_from\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_to\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Transfer\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_owner\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_spender\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Approval\",\"type\":\"event\"},]"
        let web3 = Web3.InfuraMainnetWeb3()
        let contract = web3.contract(jsonString, at: nil, abiVersion: 2)
        guard let eventParser = contract?.createEventParser("Transfer", filter: nil) else {return XCTFail()}
        let present = eventParser.parseBlockByNumber(UInt64(5200120))
        guard case .success(let pres) = present else {return XCTFail()}
        print(pres)
        XCTAssert(pres.count == 81)
    }

    func testEventParsing3usingABIv2() {
        let jsonString = "[{\"constant\":true,\"inputs\":[],\"name\":\"name\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"approve\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"totalSupply\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_from\",\"type\":\"address\"},{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transferFrom\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"decimals\",\"outputs\":[{\"name\":\"\",\"type\":\"uint8\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"version\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"}],\"name\":\"balanceOf\",\"outputs\":[{\"name\":\"balance\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"symbol\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transfer\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"},{\"name\":\"_extraData\",\"type\":\"bytes\"}],\"name\":\"approveAndCall\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"},{\"name\":\"_spender\",\"type\":\"address\"}],\"name\":\"allowance\",\"outputs\":[{\"name\":\"remaining\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"inputs\":[{\"name\":\"_initialAmount\",\"type\":\"uint256\"},{\"name\":\"_tokenName\",\"type\":\"string\"},{\"name\":\"_decimalUnits\",\"type\":\"uint8\"},{\"name\":\"_tokenSymbol\",\"type\":\"string\"}],\"type\":\"constructor\"},{\"payable\":false,\"type\":\"fallback\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_from\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_to\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Transfer\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_owner\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_spender\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Approval\",\"type\":\"event\"},]"
        let web3 = Web3.InfuraMainnetWeb3()
        let contract = web3.contract(jsonString, at: nil, abiVersion: 2)
        guard let eventParser = contract?.createEventParser("Transfer", filter: nil) else {return XCTFail()}
        let blockNumber = web3.eth.getBlockNumber()
        guard case .success(let currentBlock) = blockNumber else {return XCTFail()}
        let currentBlockAsInt = UInt64(currentBlock)
        for i in currentBlockAsInt-3 ... currentBlockAsInt {
            let present = eventParser.parseBlockByNumber(i)
            guard case .success(let pres) = present else {return XCTFail()}
            for p in pres {
                print("Block " + String(i) + "\n")
                print("Emitted by contract " + p.contractAddress.address + "\n")
                print("TX hash " + p.transactionReceipt.transactionHash.toHexString().addHexPrefix() + "\n")
                print("From " + (p.decodedResult["_from"] as! EthereumAddress).address + "\n")
                print("From " + (p.decodedResult["_to"] as! EthereumAddress).address + "\n")
                print("Value " + String(p.decodedResult["_value"] as! BigUInt) + "\n")
            }
        }
    }
    

    func testMakePrivateKey()
    {
        let privKey = SECP256K1.generatePrivateKey()
        XCTAssert(privKey != nil, "Failed to create new private key")
    }
    
    func testConcurrency1()
    {
        let semaphore = DispatchSemaphore(value: 0)
        var fail = true;
        let web3 = Web3.InfuraMainnetWeb3()
        let address = EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B")
        var request = JSONRPCrequest()
        request.method = JSONRPCmethod.getTransactionCount
        let params = [address.address.lowercased(), "latest"] as Array<Encodable>
        let pars = JSONRPCparams(params: params)
        request.params = pars
        let operation = DataFetchOperation(web3, queue: web3.queue)
        let callback = { (res: Result<AnyObject, Web3Error>) -> () in
            switch res {
            case .success(let result):
                print(result)
                fail = false
            case .failure(_):
                XCTFail()
                fatalError()
            }
            semaphore.signal()
        }
        operation.next = OperationChainingType.callback(callback, web3.queue)
        operation.inputData = request as AnyObject
        web3.queue.addOperation(operation)
        let _ = semaphore.wait(timeout: .distantFuture)
        XCTAssert(!fail)
    }
    
    func testConcurrency2()
    {
        let semaphore = DispatchSemaphore(value: 0)
        var fail = true;
        let web3 = Web3.InfuraMainnetWeb3()
        let queue = OperationQueue.init()
        queue.maxConcurrentOperationCount = 16
        queue.underlyingQueue = DispatchQueue.global(qos: .userInteractive)
        let hash = "0x2c6a803416ee1118ffc3b62a3344de768c86952bcf0376bdf1e49c0fc21a062f"
        let operation = GetTransactionReceiptOperation(web3, queue: queue)
        let callback = { (res: Result<AnyObject, Web3Error>) -> () in
            switch res {
            case .success(let result):
                print(result)
                fail = false
            case .failure(_):
                XCTFail()
                fatalError()
            }
            semaphore.signal()
        }
        operation.next = OperationChainingType.callback(callback, queue)
        operation.inputData = hash as AnyObject
        queue.addOperation(operation)
        let _ = semaphore.wait(timeout: .distantFuture)
        XCTAssert(!fail)
    }
    
    func testConcurrency3()
    {
        let semaphore = DispatchSemaphore(value: 0)
        var fail = true;
        let web3 = Web3.InfuraMainnetWeb3()
        let tempKeystore = try! EthereumKeystoreV3(password: "")
        let keystoreManager = KeystoreManager([tempKeystore!])
        web3.addKeystoreManager(keystoreManager)
        let queue = OperationQueue.init()
        queue.maxConcurrentOperationCount = 16
        queue.underlyingQueue = DispatchQueue.global(qos: .userInteractive)
        let operation = GetAccountsOperation(web3, queue: queue)
        let callback = { (res: Result<AnyObject, Web3Error>) -> () in
            switch res {
            case .success(let result):
                print(result)
                guard let accounts = result as? [EthereumAddress] else {return XCTFail()}
                XCTAssert(accounts.count == 1)
                XCTAssert(accounts.first == keystoreManager.addresses?.first)
                fail = false
            case .failure(_):
                XCTFail()
                fatalError()
            }
            semaphore.signal()
        }
        operation.next = OperationChainingType.callback(callback, queue)
        queue.addOperation(operation)
        let _ = semaphore.wait(timeout: .distantFuture)
        XCTAssert(!fail)
    }
    
    func testConcurrency4()
    {
        let semaphore = DispatchSemaphore(value: 0)
        var fail = true;
        let web3 = Web3.InfuraMainnetWeb3()
        let queue = OperationQueue.init()
        queue.maxConcurrentOperationCount = 16
        queue.underlyingQueue = DispatchQueue.global(qos: .userInteractive)
        let operation = GetBlockByNumberOperation(web3, queue: queue, blockNumber: "latest", fullTransactions: false)
        let callback = { (res: Result<AnyObject, Web3Error>) -> () in
            switch res {
            case .success(let result):
                print(result)
                fail = false
            case .failure(_):
                XCTFail()
                fatalError()
            }
            semaphore.signal()
        }
        operation.next = OperationChainingType.callback(callback, queue)
        queue.addOperation(operation)
        let _ = semaphore.wait(timeout: .distantFuture)
        XCTAssert(!fail)
    }
    
    func testConcurrency5()
    {
        let semaphore = DispatchSemaphore(value: 0)
        var fail = true;
        let address = EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B")
        let web3 = Web3.InfuraMainnetWeb3()
        let queue = OperationQueue.init()
        queue.maxConcurrentOperationCount = 16
        queue.underlyingQueue = DispatchQueue.global(qos: .userInteractive)
        let operation = GetTransactionCountOperation(web3, queue: queue, address: address, onBlock: "latest")
        let callback = { (res: Result<AnyObject, Web3Error>) -> () in
            switch res {
            case .success(let result):
                print(result)
                fail = false
            case .failure(_):
                XCTFail()
                fatalError()
            }
            semaphore.signal()
        }
        operation.next = OperationChainingType.callback(callback, queue)
        queue.addOperation(operation)
        let _ = semaphore.wait(timeout: .distantFuture)
        XCTAssert(!fail)
    }
    
    func testConcurrency6()
    {
        let semaphore = DispatchSemaphore(value: 0)
        var fail = true;
        let address = EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B")
        let web3 = Web3.InfuraMainnetWeb3()
        let queue = OperationQueue.init()
        queue.maxConcurrentOperationCount = 16
        queue.underlyingQueue = DispatchQueue.global(qos: .userInteractive)
        let operation = GetBalanceOperation(web3, queue: queue, address: address, onBlock: "latest")
        let callback = { (res: Result<AnyObject, Web3Error>) -> () in
            switch res {
            case .success(let result):
                let balance = result as! BigUInt
                let balString = Web3.Utils.formatToEthereumUnits(balance, toUnits: .eth, decimals: 3)
                print(balString)
                fail = false
            case .failure(_):
                XCTFail()
                fatalError()
            }
            semaphore.signal()
        }
        operation.next = OperationChainingType.callback(callback, queue)
        queue.addOperation(operation)
        let _ = semaphore.wait(timeout: .distantFuture)
        XCTAssert(!fail)
    }
    
    func testConcurrency7()
    {
        let semaphore = DispatchSemaphore(value: 0)
        var fail = true;
        let address = EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B")
        let web3 = Web3.InfuraMainnetWeb3()
        let queue = OperationQueue.init()
        queue.maxConcurrentOperationCount = 16
        queue.underlyingQueue = DispatchQueue.global(qos: .userInteractive)
        let operation = GetGasPriceOperation(web3, queue: queue)
        let callback = { (res: Result<AnyObject, Web3Error>) -> () in
            switch res {
            case .success(let result):
                let balance = result as! BigUInt
                let balString = Web3.Utils.formatToEthereumUnits(balance, toUnits: .Gwei, decimals: 1)
                print(balString)
                fail = false
            case .failure(_):
                XCTFail()
                fatalError()
            }
            semaphore.signal()
        }
        operation.next = OperationChainingType.callback(callback, queue)
        queue.addOperation(operation)
        let _ = semaphore.wait(timeout: .distantFuture)
        XCTAssert(!fail)
    }
    
    func testConcurrency8()
    {
        let semaphore = DispatchSemaphore(value: 0)
        var fail = true;
        let web3 = Web3.InfuraMainnetWeb3()
        let sendToAddress = EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B")
        let tempKeystore = try! EthereumKeystoreV3(password: "")
        let keystoreManager = KeystoreManager([tempKeystore!])
        web3.addKeystoreManager(keystoreManager)
        let contract = web3.contract(Web3.Utils.coldWalletABI, at: sendToAddress, abiVersion: 2)
        var options = Web3Options.defaultOptions()
        options.value = Web3.Utils.parseToBigUInt("1.0", units: .eth)
        options.from = keystoreManager.addresses?.first
        let intermediate = contract?.method("fallback", options: options)
        let queue = OperationQueue.init()
        queue.maxConcurrentOperationCount = 16
        queue.underlyingQueue = DispatchQueue.global(qos: .userInteractive)
        let operation = EstimateGasOperation(web3, queue: queue, transactionIntermediate: intermediate!)
        let callback = { (res: Result<AnyObject, Web3Error>) -> () in
            switch res {
            case .success(let result):
                let balance = result as! BigUInt
                XCTAssert(balance == BigUInt(21000))
                fail = false
            case .failure(_):
                XCTFail()
                fatalError()
            }
            semaphore.signal()
        }
        operation.next = OperationChainingType.callback(callback, queue)
        queue.addOperation(operation)
        let _ = semaphore.wait(timeout: .distantFuture)
        XCTAssert(!fail)
    }
    
    func testConcurrency9()
    {
        let semaphore = DispatchSemaphore(value: 0)
        var fail = true;
        let web3 = Web3.InfuraMainnetWeb3()
        let queue = OperationQueue.init()
        queue.maxConcurrentOperationCount = 16
        queue.underlyingQueue = DispatchQueue.global(qos: .userInteractive)
        let blockHash = "0xae6a4fb3bf690b71f2c4bc5a0ab46987fdc2c3519d1e6585b26a44b101f2166c"
        let operation = GetBlockByHashOperation(web3, queue: queue, hash: blockHash, fullTransactions: false)
        let callback = { (res: Result<AnyObject, Web3Error>) -> () in
            switch res {
            case .success(let result):
                print(result)
                fail = false
            case .failure(_):
                XCTFail()
                fatalError()
            }
            semaphore.signal()
        }
        operation.next = OperationChainingType.callback(callback, queue)
        queue.addOperation(operation)
        let _ = semaphore.wait(timeout: .distantFuture)
        XCTAssert(!fail)
    }
    
    func testConcurrency10()
    {
        let semaphore = DispatchSemaphore(value: 0)
        var fail = true;
        let web3 = Web3.InfuraMainnetWeb3()
        let contractAddress = EthereumAddress("0x45245bc59219eeaaf6cd3f382e078a461ff9de7b")
        let contract = web3.contract(Web3.Utils.erc20ABI, at: contractAddress, abiVersion: 2)
        var options = Web3Options.defaultOptions()
        options.from = EthereumAddress("0xE6877A4d8806e9A9F12eB2e8561EA6c1db19978d")
        let parameters = [] as [AnyObject]
        let intermediate = contract?.method("name", parameters:parameters,  options: options)
        let queue = OperationQueue.init()
        queue.maxConcurrentOperationCount = 16
        queue.underlyingQueue = DispatchQueue.global(qos: .userInteractive)
        let operation = CallOperation(web3, queue: queue, transactionIntermediate: intermediate!)
        let callback = { (res: Result<AnyObject, Web3Error>) -> () in
            switch res {
            case .success(let result):
                print(result)
                fail = false
            case .failure(_):
                XCTFail()
                fatalError()
            }
            semaphore.signal()
        }
        operation.next = OperationChainingType.callback(callback, queue)
        queue.addOperation(operation)
        let _ = semaphore.wait(timeout: .distantFuture)
        XCTAssert(!fail)
    }
    
    func testConcurrency11()
    {
        let semaphore = DispatchSemaphore(value: 0)
        let max = 100
        var i = max
        var fail = true;
        let web3 = Web3.InfuraMainnetWeb3()
        let contractAddress = EthereumAddress("0x45245bc59219eeaaf6cd3f382e078a461ff9de7b")
        let contract = web3.contract(Web3.Utils.erc20ABI, at: contractAddress, abiVersion: 2)
        var options = Web3Options.defaultOptions()
        options.from = EthereumAddress("0xE6877A4d8806e9A9F12eB2e8561EA6c1db19978d")
        for _ in 0 ... max {
            guard let operation = ContractCallOperation.init(web3, contract: contract!, method: "name", options: options, onBlock: web3.defaultBlock) else {return XCTFail()}
            let callback = { (res: Result<AnyObject, Web3Error>) -> () in
                switch res {
                case .success(let result):
                    print(result)
                    fail = false
                case .failure(_):
                    XCTFail()
                    fatalError()
                }
                i = i - 1;
                if i == 0 {
                    print("All done")
                    semaphore.signal()
                }
            }
            operation.next = OperationChainingType.callback(callback, web3.queue)
            web3.queue.addOperation(operation)
        }
        
        
        let _ = semaphore.wait(timeout: .distantFuture)
        XCTAssert(!fail)
    }
    
    func testConcurrency12()
    {
        let semaphore = DispatchSemaphore(value: 0)
        var fail = true;
        let web3 = Web3.InfuraMainnetWeb3()
        let contract = web3.contract(Web3.Utils.erc20ABI, at: nil, abiVersion: 2)
        guard let operation = ParseBlockForEventsOperation.init(web3, queue: web3.queue, contract: contract!.contract, eventName: "Transfer", filter: nil, block: UInt64(5200120)) else {return XCTFail()}
        let callback = { (res: Result<AnyObject, Web3Error>) -> () in
            switch res {
            case .success(let result):
                print(result)
                XCTAssert((result as! [AnyObject]).count == 81)
                fail = false
            case .failure(let error):
                print(error)
                XCTFail()
                fatalError()
            }
            semaphore.signal()
        }
        operation.next = OperationChainingType.callback(callback, web3.queue)
        web3.queue.addOperation(operation)
        
        
        let _ = semaphore.wait(timeout: .distantFuture)
        XCTAssert(!fail)
    }
    
    func testConcurrency13()
    {
        let semaphore = DispatchSemaphore(value: 0)
        var fail = true;
        let web3 = Web3.InfuraMainnetWeb3()
        let contract = web3.contract(Web3.Utils.erc20ABI, at: nil, abiVersion: 2)
        guard let operation = ParseBlockForEventsOperation.init(web3, queue: web3.queue, contract: contract!.contract, eventName: "Transfer", filter: nil, block: "latest") else {return XCTFail()}
        let callback = { (res: Result<AnyObject, Web3Error>) -> () in
            switch res {
            case .success(let result):
                print(result)
                fail = false
            case .failure(let error):
                print(error)
                XCTFail()
                fatalError()
            }
            semaphore.signal()
        }
        operation.next = OperationChainingType.callback(callback, web3.queue)
        web3.queue.addOperation(operation)
        
        
        let _ = semaphore.wait(timeout: .distantFuture)
        XCTAssert(!fail)
    }
    
    func testAdvancedABIv2() {
        let abiString = "[{\"constant\":true,\"inputs\":[],\"name\":\"testDynOfDyn\",\"outputs\":[{\"name\":\"ts\",\"type\":\"string[]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testStOfDyn\",\"outputs\":[{\"name\":\"ts\",\"type\":\"string[2]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testDynArray\",\"outputs\":[{\"components\":[{\"name\":\"number\",\"type\":\"uint256\"},{\"name\":\"someText\",\"type\":\"string\"},{\"name\":\"staticArray\",\"type\":\"uint256[2]\"},{\"name\":\"dynamicArray\",\"type\":\"uint256[]\"},{\"name\":\"anotherDynamicArray\",\"type\":\"string[2]\"}],\"name\":\"ts\",\"type\":\"tuple[]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testStaticArray\",\"outputs\":[{\"components\":[{\"name\":\"number\",\"type\":\"uint256\"},{\"name\":\"someText\",\"type\":\"string\"},{\"name\":\"staticArray\",\"type\":\"uint256[2]\"},{\"name\":\"dynamicArray\",\"type\":\"uint256[]\"},{\"name\":\"anotherDynamicArray\",\"type\":\"string[2]\"}],\"name\":\"ts\",\"type\":\"tuple[2]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testSingle\",\"outputs\":[{\"components\":[{\"name\":\"number\",\"type\":\"uint256\"},{\"name\":\"someText\",\"type\":\"string\"},{\"name\":\"staticArray\",\"type\":\"uint256[2]\"},{\"name\":\"dynamicArray\",\"type\":\"uint256[]\"},{\"name\":\"anotherDynamicArray\",\"type\":\"string[2]\"}],\"name\":\"t\",\"type\":\"tuple\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"inputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"constructor\"}]"
        let contractAddress = EthereumAddress("0xd14630167f878e92a40a1c12db4532f29cb3065e")
        let web3 = Web3.InfuraRinkebyWeb3()
        let contract = web3.contract(abiString, at: contractAddress, abiVersion: 2)
        var options = Web3Options.defaultOptions()
        options.from = contractAddress
        XCTAssert(contract != nil)
        print(contract?.contract.allMethods)
        let rawContract = contract?.contract as! ContractV2
        print(rawContract)
        let intermediate = contract?.method("testSingle", options: options)
        XCTAssertNotNil(intermediate)
        let result = intermediate!.call(options: nil)
        switch result {
        case .success(let payload):
            print(payload)
        case .failure(let error):
            print(error)
            XCTFail()
        }
    }
    
    func testAdvancedABIv2staticArray() {
        let abiString = "[{\"constant\":true,\"inputs\":[],\"name\":\"testDynOfDyn\",\"outputs\":[{\"name\":\"ts\",\"type\":\"string[]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testStOfDyn\",\"outputs\":[{\"name\":\"ts\",\"type\":\"string[2]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testDynArray\",\"outputs\":[{\"components\":[{\"name\":\"number\",\"type\":\"uint256\"},{\"name\":\"someText\",\"type\":\"string\"},{\"name\":\"staticArray\",\"type\":\"uint256[2]\"},{\"name\":\"dynamicArray\",\"type\":\"uint256[]\"},{\"name\":\"anotherDynamicArray\",\"type\":\"string[2]\"}],\"name\":\"ts\",\"type\":\"tuple[]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testStaticArray\",\"outputs\":[{\"components\":[{\"name\":\"number\",\"type\":\"uint256\"},{\"name\":\"someText\",\"type\":\"string\"},{\"name\":\"staticArray\",\"type\":\"uint256[2]\"},{\"name\":\"dynamicArray\",\"type\":\"uint256[]\"},{\"name\":\"anotherDynamicArray\",\"type\":\"string[2]\"}],\"name\":\"ts\",\"type\":\"tuple[2]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testSingle\",\"outputs\":[{\"components\":[{\"name\":\"number\",\"type\":\"uint256\"},{\"name\":\"someText\",\"type\":\"string\"},{\"name\":\"staticArray\",\"type\":\"uint256[2]\"},{\"name\":\"dynamicArray\",\"type\":\"uint256[]\"},{\"name\":\"anotherDynamicArray\",\"type\":\"string[2]\"}],\"name\":\"t\",\"type\":\"tuple\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"inputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"constructor\"}]"
        let contractAddress = EthereumAddress("0xd14630167f878e92a40a1c12db4532f29cb3065e")
        let web3 = Web3.InfuraRinkebyWeb3()
        let contract = web3.contract(abiString, at: contractAddress, abiVersion: 2)
        var options = Web3Options.defaultOptions()
        options.from = contractAddress
        XCTAssert(contract != nil)
        print(contract?.contract.allMethods)
        let rawContract = contract?.contract as! ContractV2
        print(rawContract)
        let intermediate = contract?.method("testStaticArray", options: options)
        XCTAssertNotNil(intermediate)
        let result = intermediate!.call(options: nil)
        switch result {
        case .success(let payload):
            print(payload)
        case .failure(let error):
            print(error)
            XCTFail()
        }
    }
    
    func testAdvancedABIv2dynamicArray() {
        let abiString = "[{\"constant\":true,\"inputs\":[],\"name\":\"testDynOfDyn\",\"outputs\":[{\"name\":\"ts\",\"type\":\"string[]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testStOfDyn\",\"outputs\":[{\"name\":\"ts\",\"type\":\"string[2]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testDynArray\",\"outputs\":[{\"components\":[{\"name\":\"number\",\"type\":\"uint256\"},{\"name\":\"someText\",\"type\":\"string\"},{\"name\":\"staticArray\",\"type\":\"uint256[2]\"},{\"name\":\"dynamicArray\",\"type\":\"uint256[]\"},{\"name\":\"anotherDynamicArray\",\"type\":\"string[2]\"}],\"name\":\"ts\",\"type\":\"tuple[]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testStaticArray\",\"outputs\":[{\"components\":[{\"name\":\"number\",\"type\":\"uint256\"},{\"name\":\"someText\",\"type\":\"string\"},{\"name\":\"staticArray\",\"type\":\"uint256[2]\"},{\"name\":\"dynamicArray\",\"type\":\"uint256[]\"},{\"name\":\"anotherDynamicArray\",\"type\":\"string[2]\"}],\"name\":\"ts\",\"type\":\"tuple[2]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testSingle\",\"outputs\":[{\"components\":[{\"name\":\"number\",\"type\":\"uint256\"},{\"name\":\"someText\",\"type\":\"string\"},{\"name\":\"staticArray\",\"type\":\"uint256[2]\"},{\"name\":\"dynamicArray\",\"type\":\"uint256[]\"},{\"name\":\"anotherDynamicArray\",\"type\":\"string[2]\"}],\"name\":\"t\",\"type\":\"tuple\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"inputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"constructor\"}]"
        let contractAddress = EthereumAddress("0xd14630167f878e92a40a1c12db4532f29cb3065e")
        let web3 = Web3.InfuraRinkebyWeb3()
        let contract = web3.contract(abiString, at: contractAddress, abiVersion: 2)
        var options = Web3Options.defaultOptions()
        options.from = contractAddress
        XCTAssert(contract != nil)
        print(contract?.contract.allMethods)
        let rawContract = contract?.contract as! ContractV2
        print(rawContract)
        let intermediate = contract?.method("testDynArray", options: options)
        XCTAssertNotNil(intermediate)
        let result = intermediate!.call(options: nil)
        switch result {
        case .success(let payload):
            print(payload)
        case .failure(let error):
            print(error)
            XCTFail()
        }
    }
    
    func testAdvancedABIv2dynamicArrayOfStrings() {
        let abiString = "[{\"constant\":true,\"inputs\":[],\"name\":\"testDynOfDyn\",\"outputs\":[{\"name\":\"ts\",\"type\":\"string[]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testStOfDyn\",\"outputs\":[{\"name\":\"ts\",\"type\":\"string[2]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testDynArray\",\"outputs\":[{\"components\":[{\"name\":\"number\",\"type\":\"uint256\"},{\"name\":\"someText\",\"type\":\"string\"},{\"name\":\"staticArray\",\"type\":\"uint256[2]\"},{\"name\":\"dynamicArray\",\"type\":\"uint256[]\"},{\"name\":\"anotherDynamicArray\",\"type\":\"string[2]\"}],\"name\":\"ts\",\"type\":\"tuple[]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testStaticArray\",\"outputs\":[{\"components\":[{\"name\":\"number\",\"type\":\"uint256\"},{\"name\":\"someText\",\"type\":\"string\"},{\"name\":\"staticArray\",\"type\":\"uint256[2]\"},{\"name\":\"dynamicArray\",\"type\":\"uint256[]\"},{\"name\":\"anotherDynamicArray\",\"type\":\"string[2]\"}],\"name\":\"ts\",\"type\":\"tuple[2]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testSingle\",\"outputs\":[{\"components\":[{\"name\":\"number\",\"type\":\"uint256\"},{\"name\":\"someText\",\"type\":\"string\"},{\"name\":\"staticArray\",\"type\":\"uint256[2]\"},{\"name\":\"dynamicArray\",\"type\":\"uint256[]\"},{\"name\":\"anotherDynamicArray\",\"type\":\"string[2]\"}],\"name\":\"t\",\"type\":\"tuple\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"inputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"constructor\"}]"
        let contractAddress = EthereumAddress("0xd14630167f878e92a40a1c12db4532f29cb3065e")
        let web3 = Web3.InfuraRinkebyWeb3()
        let contract = web3.contract(abiString, at: contractAddress, abiVersion: 2)
        var options = Web3Options.defaultOptions()
        options.from = contractAddress
        XCTAssert(contract != nil)
        print(contract?.contract.allMethods)
        let rawContract = contract?.contract as! ContractV2
        print(rawContract)
        let intermediate = contract?.method("testDynOfDyn", options: options)
        XCTAssertNotNil(intermediate)
        let result = intermediate!.call(options: nil)
        switch result {
        case .success(let payload):
            print(payload)
        case .failure(let error):
            print(error)
            XCTFail()
        }
    }
    
    func testAdvancedABIv2staticArrayOfStrings() {
        let abiString = "[{\"constant\":true,\"inputs\":[],\"name\":\"testDynOfDyn\",\"outputs\":[{\"name\":\"ts\",\"type\":\"string[]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testStOfDyn\",\"outputs\":[{\"name\":\"ts\",\"type\":\"string[2]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testDynArray\",\"outputs\":[{\"components\":[{\"name\":\"number\",\"type\":\"uint256\"},{\"name\":\"someText\",\"type\":\"string\"},{\"name\":\"staticArray\",\"type\":\"uint256[2]\"},{\"name\":\"dynamicArray\",\"type\":\"uint256[]\"},{\"name\":\"anotherDynamicArray\",\"type\":\"string[2]\"}],\"name\":\"ts\",\"type\":\"tuple[]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testStaticArray\",\"outputs\":[{\"components\":[{\"name\":\"number\",\"type\":\"uint256\"},{\"name\":\"someText\",\"type\":\"string\"},{\"name\":\"staticArray\",\"type\":\"uint256[2]\"},{\"name\":\"dynamicArray\",\"type\":\"uint256[]\"},{\"name\":\"anotherDynamicArray\",\"type\":\"string[2]\"}],\"name\":\"ts\",\"type\":\"tuple[2]\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"testSingle\",\"outputs\":[{\"components\":[{\"name\":\"number\",\"type\":\"uint256\"},{\"name\":\"someText\",\"type\":\"string\"},{\"name\":\"staticArray\",\"type\":\"uint256[2]\"},{\"name\":\"dynamicArray\",\"type\":\"uint256[]\"},{\"name\":\"anotherDynamicArray\",\"type\":\"string[2]\"}],\"name\":\"t\",\"type\":\"tuple\"}],\"payable\":false,\"stateMutability\":\"pure\",\"type\":\"function\"},{\"inputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"constructor\"}]"
        let contractAddress = EthereumAddress("0xd14630167f878e92a40a1c12db4532f29cb3065e")
        let web3 = Web3.InfuraRinkebyWeb3()
        let contract = web3.contract(abiString, at: contractAddress, abiVersion: 2)
        var options = Web3Options.defaultOptions()
        options.from = contractAddress
        XCTAssert(contract != nil)
        print(contract?.contract.allMethods)
        let rawContract = contract?.contract as! ContractV2
        print(rawContract)
        let intermediate = contract?.method("testStOfDyn", options: options)
        XCTAssertNotNil(intermediate)
        let result = intermediate!.call(options: nil)
        switch result {
        case .success(let payload):
            print(payload)
        case .failure(let error):
            print(error)
            XCTFail()
        }
    }
    
    func testUserCase() {
        let abiString =  "[{\"constant\":true,\"inputs\":[],\"name\":\"getFlagData\",\"outputs\":[{\"name\":\"data\",\"type\":\"string\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"data\",\"type\":\"string\"}],\"name\":\"setFlagData\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"}]"
        let contractAddress = EthereumAddress("0x811411e3cdfd4750cdd3552feb3b89a46ddb612e")
        let web3 = Web3.InfuraRinkebyWeb3()
        let contract = web3.contract(abiString, at: contractAddress, abiVersion: 2)
        var options = Web3Options.defaultOptions()
        options.from = contractAddress
        XCTAssert(contract != nil)
        print(contract?.contract.allMethods)
        let intermediate = contract?.method("getFlagData", options: options)
        XCTAssertNotNil(intermediate)
        let result = intermediate!.call(options: nil)
        switch result {
        case .success(let payload):
            print(payload)
        case .failure(let error):
            print(error)
            XCTFail()
        }
    }
    
    func testEIP67encoding() {
        var eip67Data = Web3.EIP67Code.init(address: EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B"))
        eip67Data.gasLimit = BigUInt(21000)
        eip67Data.amount = BigUInt("1000000000000000000")
//        eip67Data.data =
        let encoding = eip67Data.toString()
        print(encoding)
    }
    
    func testEIP67codeGeneration() {
        var eip67Data = Web3.EIP67Code.init(address: EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B"))
        eip67Data.gasLimit = BigUInt(21000)
        eip67Data.amount = BigUInt("1000000000000000000")
        //        eip67Data.data =
        let encoding = eip67Data.toImage(scale: 5.0)
        XCTAssert(encoding != CIImage())
    }
    
    func testEIP67decoding() {
        var eip67Data = Web3.EIP67Code.init(address: EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B"))
        eip67Data.gasLimit = BigUInt(21000)
        eip67Data.amount = BigUInt("1000000000000000000")
        //        eip67Data.data =
        let encoding = eip67Data.toString()
        guard let code = Web3.EIP67CodeParser.parse(encoding) else {return XCTFail()}
        XCTAssert(code.address == eip67Data.address)
        XCTAssert(code.gasLimit == eip67Data.gasLimit)
        XCTAssert(code.amount == eip67Data.amount)
    }
    
    func testConcurrenctGetTransactionCount()
    {
        let semaphore = DispatchSemaphore(value: 0)
        var fail = true;
        let web3 = Web3.InfuraMainnetWeb3()
        let address = EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B")
        let callback = { (res: Result<AnyObject, Web3Error>) -> () in
            switch res {
            case .success(let result):
                print(result)
                fail = false
            case .failure(let error):
                print(error)
                XCTFail()
                fatalError()
            }
            semaphore.signal()
        }
        web3.eth.getTransactionCount(address: address, onBlock: "latest", callback: callback, queue: web3.queue) // queue should be .main here, but can not test in this case with a simple semaphore (getting a deadlock)
        let _ = semaphore.wait(timeout: .distantFuture)
        XCTAssert(!fail)
    }
    
    func testGetAllTokenBalances()
    {
        //        let semaphore = DispatchSemaphore(value: 0)
        let url = URL.init(string: "https://raw.githubusercontent.com/kvhnuke/etherwallet/mercury/app/scripts/tokens/ethTokens.json")
        let tokensData = try! Data.init(contentsOf: url!)
        let tokensJSON = try! JSONSerialization.jsonObject(with: tokensData, options: []) as! [[String: Any]]
        let jsonString = "[{\"constant\":true,\"inputs\":[],\"name\":\"name\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"approve\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"totalSupply\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_from\",\"type\":\"address\"},{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transferFrom\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"decimals\",\"outputs\":[{\"name\":\"\",\"type\":\"uint8\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"version\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"}],\"name\":\"balanceOf\",\"outputs\":[{\"name\":\"balance\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"symbol\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transfer\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"},{\"name\":\"_extraData\",\"type\":\"bytes\"}],\"name\":\"approveAndCall\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"},{\"name\":\"_spender\",\"type\":\"address\"}],\"name\":\"allowance\",\"outputs\":[{\"name\":\"remaining\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"inputs\":[{\"name\":\"_initialAmount\",\"type\":\"uint256\"},{\"name\":\"_tokenName\",\"type\":\"string\"},{\"name\":\"_decimalUnits\",\"type\":\"uint8\"},{\"name\":\"_tokenSymbol\",\"type\":\"string\"}],\"type\":\"constructor\"},{\"payable\":false,\"type\":\"fallback\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_from\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_to\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Transfer\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_owner\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_spender\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Approval\",\"type\":\"event\"},]"
        let web3 = Web3.InfuraMainnetWeb3()
        let userAddress = EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B")
        var expected = tokensJSON.count
        print(String(expected) + " tokens to update")
        let semaphore = DispatchSemaphore(value: 0)
        for token in tokensJSON {
            let tokenSymbol = token["symbol"] as! String
            let tokenAddress = EthereumAddress(token["address"] as! String)
            let contract = web3.contract(jsonString, at: tokenAddress, abiVersion: 2)
            XCTAssert(contract != nil, "Failed to create ERC20 contract from ABI")
            var options = Web3Options.defaultOptions()
            options.from = userAddress
            let parameters = [userAddress] as [AnyObject]
            let transactionIntermediate = contract?.method("balanceOf", parameters:parameters, options: options)
            let callback = { (res: Result<AnyObject, Web3Error>) -> () in
                switch res {
                case .success(let balanceResult):
                    guard let result = balanceResult as? [String: Any] else {
                        XCTFail()
                        break
                    }
                    guard let bal = result["balance"] as? BigUInt else {
                        XCTFail()
                        break
                    }
                    print("Balance of " + tokenSymbol + " is " + String(bal))
                case .failure(let error):
                    print(error)
                    XCTFail()
                    fatalError()
                }
                OperationQueue.current?.underlyingQueue?.async {
                    expected = expected - 1
                    print(String(expected) + " tokens left to update")
                    if expected == 0 {
                        semaphore.signal()
                    }
                }
                
            }
            transactionIntermediate?.call(options: options, onBlock: "latest", callback: callback, queue: web3.queue)
        }
        let _ = semaphore.wait(timeout: .distantFuture)
    }
    
    func testEthSendOperationsExample() {
        let semaphore = DispatchSemaphore(value: 0)
        var fail = true;
        let web3 = Web3.InfuraRinkebyWeb3()
        let sendToAddress = EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B")
        let tempKeystore = try! EthereumKeystoreV3(password: "")
        let keystoreManager = KeystoreManager([tempKeystore!])
        web3.addKeystoreManager(keystoreManager)
        let contract = web3.contract(Web3.Utils.coldWalletABI, at: sendToAddress, abiVersion: 2)
        var options = Web3Options.defaultOptions()
        options.value = Web3.Utils.parseToBigUInt("1.0", units: .eth)
        options.from = keystoreManager.addresses?.first
        let intermediate = contract?.method("fallback", options: options)
        let callback = { (res: Result<AnyObject, Web3Error>) -> () in
            switch res {
            case .success(let result):
                print(result)
                fail = false
            case .failure(let error):
                print(error)
                if case .nodeError(_) = error {
                    fail = false
                }
//                XCTFail()
//                fatalError()
            }
            semaphore.signal()
        }
        intermediate?.send(password: "", options: options, callback: callback, queue: web3.queue)
        
        let _ = semaphore.wait(timeout: .distantFuture)
        XCTAssertTrue(!fail)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}

