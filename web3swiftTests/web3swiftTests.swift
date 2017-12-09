//
//  web3swiftTests.swift
//  web3swiftTests
//
//  Created by Alexander Vlasov on 04.12.2017.
//  Copyright © 2017 Alexander Vlasov. All rights reserved.
//


import XCTest
import Sodium
import CryptoSwift
import BigInt
@testable import web3swift

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
    
    func testReadKeystoreV3Scrypt() {
        do {
            let ks = try EthereumKeystoreV3("{\"address\":\"008aeeda4d805471df9b2a5b0f38a0c3bcba786b\",\"Crypto\":{\"cipher\":\"aes-128-ctr\",\"ciphertext\":\"d172bf743a674da9cdad04534d56926ef8358534d458fffccd4e6ad2fbde479c\",\"cipherparams\":{\"iv\":\"83dbcc02d8ccb40e466191a123791e0e\"},\"mac\":\"2103ac29920d71da29f15d75b4a16dbe95cfd7ff8faea1056c33131d846e3097\",\"kdf\":\"scrypt\",\"kdfparams\":{\"n\":262144,\"r\":1,\"p\":8,\"dklen\":32,\"prf\":\"hmac-sha256\",\"salt\":\"ab0c7876052600dd703518d6fc3fe8984592145b591fc8fb5c6d43190334ba19\"}},\"id\":\"e13b209c-3b2f-4327-bab0-3bef2e51630d\",\"version\":3}")
            XCTAssert(ks != nil, "Can't read keystore JSON file")
            let sodium = Sodium()
            let key = try ks?.getKeyData("testpassword")
            let pk = sodium.utils.bin2hex(key!)
            XCTAssert(pk == "7a28b5ba57c53603b0b07b56bba752f7784bf506fa95edc395f5cf6c7514fe9d", "Key decryption failed")
            let pubKey = privateToPublic(key!)
            let address = sodium.utils.bin2hex(publicToAddress(pubKey!)!)
            XCTAssert(address == ks!.keystoreParams!.address! , "Address derivation failed")
        } catch{
            print(error);
            XCTAssert(false, "Key decryption failed")
            XCTFail()
        }
    }
    
    //    func testReadKeystoreV3PBKDF2() {
    //        do {
    //            let ks = try EthereumKeystoreV3("{\"address\":\"008aeeda4d805471df9b2a5b0f38a0c3bcba786b\",\"Crypto\":{\"cipher\":\"aes-128-ctr\",\"ciphertext\":\"5318b4d5bcd28de64ee5559e671353e16f075ecae9f99c7a79a38af5f869aa46\",\"cipherparams\":{\"iv\":\"6087dab2f9fdbbfaddc31a909735c1e6\"},\"mac\":\"517ead924a9d0dc3124507e3393d175ce3ff7c1e96529c6c555ce9e51205e9b2\",\"kdf\":\"pbkdf2\",\"kdfparams\":{\"c\":262144,\"dklen\":32,\"prf\":\"hmac-sha256\",\"salt\":\"ae3cd4e7013836a3df6bd7241b12db061dbe2c6785853cce422d148a624ce0bd\"}},\"id\":\"e13b209c-3b2f-4327-bab0-3bef2e51630d\",\"version\":3}")
    //            XCTAssert(ks != nil, "Can't read keystore JSON file")
    //            let sodium = Sodium()
    //            let key = try ks?.getKeyData("testpassword")
    //            let pk = sodium.utils.bin2hex(key!)
    //            XCTAssert(pk == "7a28b5ba57c53603b0b07b56bba752f7784bf506fa95edc395f5cf6c7514fe9d", "Key decryption failed")
    //            let pubKey = privateToPublic(key!)
    //            let address = sodium.utils.bin2hex(publicToAddress(pubKey!)!)
    //            XCTAssert(address == ks!.keystoreParams!.address! , "Address derivation failed")
    //        } catch{
    //            print(error);
    //            XCTAssert(false, "Key decryption failed")
    //        }
    //    }
    
    func testNewKeystoreV3(){
        let sodium = Sodium()
        do {
            var keystore = try EthereumKeystoreV3("{\"address\":\"008aeeda4d805471df9b2a5b0f38a0c3bcba786b\",\"Crypto\":{\"cipher\":\"aes-128-ctr\",\"ciphertext\":\"d172bf743a674da9cdad04534d56926ef8358534d458fffccd4e6ad2fbde479c\",\"cipherparams\":{\"iv\":\"83dbcc02d8ccb40e466191a123791e0e\"},\"mac\":\"2103ac29920d71da29f15d75b4a16dbe95cfd7ff8faea1056c33131d846e3097\",\"kdf\":\"scrypt\",\"kdfparams\":{\"n\":262144,\"r\":1,\"p\":8,\"dklen\":32,\"prf\":\"hmac-sha256\",\"salt\":\"ab0c7876052600dd703518d6fc3fe8984592145b591fc8fb5c6d43190334ba19\"}},\"id\":\"e13b209c-3b2f-4327-bab0-3bef2e51630d\",\"version\":3}")
            XCTAssert(keystore != nil , "Can't create keystore form private key")
            try keystore!.regenerate(oldPassword: "testpassword", newPassword: "testpassword2")
            let data = try! JSONEncoder().encode(keystore?.keystoreParams!)
            let ksString = String(data: data, encoding: .utf8)
            let newKeystore = try EthereumKeystoreV3(ksString!)
            let pk = try newKeystore?.getKeyData("testpassword2")
            let pkString = sodium.utils.bin2hex(pk!)
            XCTAssert(pkString == "7a28b5ba57c53603b0b07b56bba752f7784bf506fa95edc395f5cf6c7514fe9d", "Keystore creating failed")
        }
        catch {
            print(error)
            XCTFail()
        }
    }
    
    func testSignature(){
        let sodium = Sodium()
        do {
            let ks = try EthereumKeystoreV3("{\"address\":\"008aeeda4d805471df9b2a5b0f38a0c3bcba786b\",\"Crypto\":{\"cipher\":\"aes-128-ctr\",\"ciphertext\":\"d172bf743a674da9cdad04534d56926ef8358534d458fffccd4e6ad2fbde479c\",\"cipherparams\":{\"iv\":\"83dbcc02d8ccb40e466191a123791e0e\"},\"mac\":\"2103ac29920d71da29f15d75b4a16dbe95cfd7ff8faea1056c33131d846e3097\",\"kdf\":\"scrypt\",\"kdfparams\":{\"n\":262144,\"r\":1,\"p\":8,\"dklen\":32,\"prf\":\"hmac-sha256\",\"salt\":\"ab0c7876052600dd703518d6fc3fe8984592145b591fc8fb5c6d43190334ba19\"}},\"id\":\"e13b209c-3b2f-4327-bab0-3bef2e51630d\",\"version\":3}")
            XCTAssert(ks != nil , "Can't read keystore")
            let key = try ks?.getKeyData("testpassword")
            let signature = try EthereumKeystoreV3.signHashWithPrivateKey(hash: "test".data(using: .utf8)!.sha3(.keccak256), privateKey: key!)
            XCTAssert(signature != nil, "Keystore creating failed")
        }
        catch {
            print(error)
            XCTFail()
        }
    }
    
    func testScrypt() {
        let sodium = Sodium()
        let data = sodium.utils.hex2bin("""
            fd ba be 1c 9d 34 72 00 78 56 e7 19 0d 01 e9 fe
            7c 6a d7 cb c8 23 78 30 e7 73 76 63 4b 37 31 62
            2e af 30 d9 2e 22 a3 88 6f f1 09 27 9d 98 30 da
            c7 27 af b9 4a 83 ee 6d 83 60 cb df a2 cc 06 40
            """
            , ignore: " \t\n\r")
        let password = "password"
        let salt = "NaCl".data(using: .utf8)!
        let r = 8
        let n = 1024
        let p = 16
        let dklen = 64
        let hash = sodium.keyDerivation.scrypt(password: password, salt: salt, length: dklen, N: n, R: r, P: p)
        XCTAssert(data == hash, "Scrypt hash is wrong")
    }
    
    func testSHA3() {
        let data = "abc".data(using: .utf8)
        let hash = data?.sha3(.sha256)
        let hex = Sodium().utils.bin2hex(hash!)
        XCTAssert(hex == "3a985da74fe225b2045c172d6bd390bd855f086e3e9d525b46bfe24511431532", "SHA3 hash is wrong")
        var hex2: String
        do {
            var digest = SHA3(variant: .sha256)
            let _ = try digest.update(withBytes: "a".data(using: .utf8)!.bytes)
            let _ = try digest.update(withBytes: "b".data(using: .utf8)!.bytes)
            let _ = try digest.update(withBytes: "c".data(using: .utf8)!.bytes)
            let result = try digest.finish()
            hex2 = Sodium().utils.bin2hex(Data(bytes: result))!
            XCTAssert(hex2 == "3a985da74fe225b2045c172d6bd390bd855f086e3e9d525b46bfe24511431532", "SHA3 hash is wrong")
        } catch {
            XCTFail()
            print(error)
        }
    }
    
    func testAES128CBC() {
        //        COUNT = 22
        //        KEY = fffffe00000000000000000000000000
        //        IV = 00000000000000000000000000000000
        //        PLAINTEXT = 00000000000000000000000000000000
        //        CIPHERTEXT = 95b1703fc57ba09fe0c3580febdd7ed4
        let sodium = Sodium()
        let key = sodium.utils.hex2bin("fffffe00000000000000000000000000")
        let iv = sodium.utils.hex2bin("00000000000000000000000000000000")
        let plaintext = sodium.utils.hex2bin("00000000000000000000000000000000")
        let ciphertext = sodium.utils.hex2bin("95b1703fc57ba09fe0c3580febdd7ed4")
        do {
            let aesCipher = try AES(key: key!.bytes, blockMode: .CBC(iv: iv!.bytes), padding: .noPadding)
            let decrypted = try aesCipher.decrypt(ciphertext!.bytes)
            let encrypted = try aesCipher.encrypt(plaintext!.bytes);
            XCTAssert(Data(bytes:decrypted) == plaintext, "AES128 CBC decryption is wrong")
            XCTAssert(Data(bytes:encrypted) == ciphertext, "AES128 CBC encryption is wrong")
        } catch {
            XCTFail()
            print(error)
        }
    }
    
    func testAES128CTR() {
//        CTR-AES128.Encrypt
//        Key 2b7e151628aed2a6abf7158809cf4f3c
//        Init. Counter f0f1f2f3f4f5f6f7f8f9fafbfcfdfeff
//        Plaintext 6bc1bee22e409f96e93d7e117393172a
//        Ciphertext 874d6191b620e3261bef6864990db6ce

        let sodium = Sodium()
        let key = sodium.utils.hex2bin("2b7e151628aed2a6abf7158809cf4f3c", ignore: " ")
        let iv = sodium.utils.hex2bin("f0f1f2f3f4f5f6f7f8f9fafbfcfdfeff", ignore: " ")
        let plaintext = sodium.utils.hex2bin("6bc1bee22e409f96e93d7e117393172a", ignore: " ")
        let ciphertext = sodium.utils.hex2bin("874d6191b620e3261bef6864990db6ce", ignore: " ")
        var fullIV = Data()
        fullIV.append(iv!)
        do {
            let aesCipher = try AES(key: key!.bytes, blockMode: .CTR(iv: fullIV.bytes), padding: .noPadding)
            let decrypted = try aesCipher.decrypt(ciphertext!.bytes)
            let encrypted = try aesCipher.encrypt(plaintext!.bytes);
            XCTAssert(Data(bytes:decrypted) == plaintext, "AES128 CBC decryption is wrong")
            XCTAssert(Data(bytes:encrypted) == ciphertext, "AES128 CBC encryption is wrong")
        } catch {
            XCTFail()
            print(error)
        }
    }
    
    func testABIdecoding() {
        let jsonString = "[{\"type\":\"constructor\",\"payable\":false,\"stateMutability\":\"nonpayable\",\"inputs\":[{\"name\":\"testInt\",\"type\":\"uint256\"}]},{\"type\":\"function\",\"name\":\"foo\",\"constant\":false,\"payable\":false,\"stateMutability\":\"nonpayable\",\"inputs\":[{\"name\":\"b\",\"type\":\"uint256\"},{\"name\":\"c\",\"type\":\"bytes32\"}],\"outputs\":[{\"name\":\"\",\"type\":\"address\"}]},{\"type\":\"event\",\"name\":\"Event\",\"inputs\":[{\"indexed\":true,\"name\":\"b\",\"type\":\"uint256\"},{\"indexed\":false,\"name\":\"c\",\"type\":\"bytes32\"}],\"anonymous\":false},{\"type\":\"event\",\"name\":\"Event2\",\"inputs\":[{\"indexed\":true,\"name\":\"b\",\"type\":\"uint256\"},{\"indexed\":false,\"name\":\"c\",\"type\":\"bytes32\"}],\"anonymous\":false}]"
        do {
            let jsonData = jsonString.data(using: .utf8)
            let abi = try JSONDecoder().decode([ABIRecord].self, from: jsonData!)
//            let abi0 = try abi[0].parse()
//            let abi1 = try abi[1].parse()
//            let abi2 = try abi[2].parse()
//            let abi3 = try abi[3].parse()
            let abiNative = try abi.map({ (record) -> ABIElement in
                return try record.parse()
            })
            print(abiNative)
            XCTAssert(true, "Failed to parse ABI")
        } catch {
            print(error)
        }
    }
    
    func testABIdecoding2() {
        let jsonString = "[{\"type\":\"function\",\"name\":\"balance\",\"constant\":true},{\"type\":\"function\",\"name\":\"send\",\"constant\":false,\"inputs\":[{\"name\":\"amount\",\"type\":\"uint256\"}]},{\"type\":\"function\",\"name\":\"test\",\"constant\":false,\"inputs\":[{\"name\":\"number\",\"type\":\"uint32\"}]},{\"type\":\"function\",\"name\":\"string\",\"constant\":false,\"inputs\":[{\"name\":\"inputs\",\"type\":\"string\"}]},{\"type\":\"function\",\"name\":\"bool\",\"constant\":false,\"inputs\":[{\"name\":\"inputs\",\"type\":\"bool\"}]},{\"type\":\"function\",\"name\":\"address\",\"constant\":false,\"inputs\":[{\"name\":\"inputs\",\"type\":\"address\"}]},{\"type\":\"function\",\"name\":\"uint64[2]\",\"constant\":false,\"inputs\":[{\"name\":\"inputs\",\"type\":\"uint64[2]\"}]},{\"type\":\"function\",\"name\":\"uint64[]\",\"constant\":false,\"inputs\":[{\"name\":\"inputs\",\"type\":\"uint64[]\"}]},{\"type\":\"function\",\"name\":\"foo\",\"constant\":false,\"inputs\":[{\"name\":\"inputs\",\"type\":\"uint32\"}]},{\"type\":\"function\",\"name\":\"bar\",\"constant\":false,\"inputs\":[{\"name\":\"inputs\",\"type\":\"uint32\"},{\"name\":\"string\",\"type\":\"uint16\"}]},{\"type\":\"function\",\"name\":\"slice\",\"constant\":false,\"inputs\":[{\"name\":\"inputs\",\"type\":\"uint32[2]\"}]},{\"type\":\"function\",\"name\":\"slice256\",\"constant\":false,\"inputs\":[{\"name\":\"inputs\",\"type\":\"uint256[2]\"}]},{\"type\":\"function\",\"name\":\"sliceAddress\",\"constant\":false,\"inputs\":[{\"name\":\"inputs\",\"type\":\"address[]\"}]},{\"type\":\"function\",\"name\":\"sliceMultiAddress\",\"constant\":false,\"inputs\":[{\"name\":\"a\",\"type\":\"address[]\"},{\"name\":\"b\",\"type\":\"address[]\"}]}]"
        do {
            let jsonData = jsonString.data(using: .utf8)
            let abi = try JSONDecoder().decode([ABIRecord].self, from: jsonData!)
            //            let abi0 = try abi[0].parse()
            //            let abi1 = try abi[1].parse()
            //            let abi2 = try abi[2].parse()
            //            let abi3 = try abi[3].parse()
            let abiNative = try abi.map({ (record) -> ABIElement in
                return try record.parse()
            })
            print(abiNative)
            XCTAssert(true, "Failed to parse ABI")
        } catch {
            print(error)
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
    
    func testRLPencodeLongString() {
        let bigUint = BigUInt(UInt(1024))
        let enc = bigUint.serialize()
        let len = bigUint.bitWidth;
        let testInput = "Lorem ipsum dolor sit amet, consectetur adipisicing elit"
        let encoded = RLP.encode(testInput)
        var expected = Data()
        expected.append(Data([UInt8(0xb8)]))
        expected.append(Data([UInt8(0x38)]))
        expected.append("Lorem ipsum dolor sit amet, consectetur adipisicing elit".data(using: .ascii)!)
        XCTAssert(encoded == expected, "Failed to RLP encode long string")
    }
    
    
    
    func testRLPencodeShortInt() {
        let testInput = 15
        let encoded = RLP.encode(testInput)
        let expected = Data([UInt8(0x0f)])
        XCTAssert(encoded == expected, "Failed to RLP encode short int")
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
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}

