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
            let signature = try ks!.signHashWithPrivateKey(hash: "test".data(using: .utf8)!.sha3(.keccak256), privateKey: key!)
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
        let testInput = "Lorem ipsum dolor sit amet, consectetur adipisicing elit"
        let encoded = RLP.encode(testInput)
        var expected = Data()
        expected.append(Data([UInt8(0xb8)]))
        expected.append(Data([UInt8(0x38)]))
        expected.append("Lorem ipsum dolor sit amet, consectetur adipisicing elit".data(using: .ascii)!)
        XCTAssert(encoded == expected, "Failed to RLP encode long string")
    }
    
    func testRLPencodeEmptyString() {
        let testInput = ""
        let encoded = RLP.encode(testInput)
        var expected = Data()
        expected.append(Data([UInt8(0x80)]))
        XCTAssert(encoded == expected, "Failed to RLP encode empty string")
    }
    
    func testRLPencodeEmptyArray() {
        let testInput = [Data]()
        let encoded = RLP.encode(testInput)
        var expected = Data()
        expected.append(Data([UInt8(0xc0)]))
        XCTAssert(encoded == expected, "Failed to RLP encode empty array")
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
    
    func testChecksubAddress() {
        let input = "0xfb6916095ca1df60bb79ce92ce3ea74c37c5d359"
        let output = EthereumAddress.toChecksumAddress(input);
        XCTAssert(output == "0xfB6916095ca1df60bB79Ce92cE3Ea74c37c5d359", "Failed to checksum address")
    }
    
    func testTransaction1() {
        var transaction = EthereumTransaction(nonce: BigUInt(9),
                                              gasprice: BigUInt(20000000000),
                                              startgas: BigUInt(21000),
                                              to: EthereumAddress("0x3535353535353535353535353535353535353535"),
                                              value: BigUInt("1000000000000000000")!,
                                              data: Data(),
                                              v: BigUInt(0),
                                              r: BigUInt(0),
                                              s: BigUInt(0))
        let privateKeyData = Data(Array<UInt8>(hex: "0x4646464646464646464646464646464646464646464646464646464646464646"))
        let hash = transaction.hash(forSignature: true, chainID: BigUInt(1))
        let expectedHash = "0xdaf5a779ae972f972197303d7b574746c7ef83eadac0f2791ad23db92e4c8e53".stripHexPrefix()
        XCTAssert(hash!.toHexString() == expectedHash, "Transaction signature failed")
        let success = transaction.sign(privateKey: privateKeyData, chainID: BigUInt(1))
        XCTAssert(success)
        XCTAssert(transaction.v == UInt8(37), "Transaction signature failed")
        XCTAssert(transaction.r == BigUInt("18515461264373351373200002665853028612451056578545711640558177340181847433846"), "Transaction signature failed")
        XCTAssert(transaction.s == BigUInt("46948507304638947509940763649030358759909902576025900602547168820602576006531"), "Transaction signature failed")
    }
    
    func testERC20Encode() {
        let sodium = Sodium()
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
            let hex = sodium.utils.bin2hex(result!)
            print(hex)
            XCTAssert(hex == "a9059cbb000000000000000000000000e6877a4d8806e9a9f12eb2e8561ea6c1db19978d0000000000000000000000000000000000000000000000000de0b6b3a7640000", "Failed to encode ERC20")
            let dummyTrue = BigUInt(1).abiEncode(bits: 256)
            let data = dummyTrue.head!
            let decoded = method[0].decodeReturnData(data)
            print(decoded)
            let ret1 = decoded!["0"] as? Bool
            let ret2 = decoded!["success"] as? Bool
            XCTAssert(ret1 == true, "Failed to encode ERC20")
            XCTAssert(ret2 == true, "Failed to encode ERC20")
        } catch {
            print(error)
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
            options.gas = BigUInt(250000)
            options.gasPrice = BigUInt(0)
//            options.value = amount
            let transaction = contract.send(method: "deposit", options: options)
            XCTAssert(transaction != nil, "Failed plasma funding transaction")
            let requestDictionary = transaction!.encodeAsDictionary(from: EthereumAddress("0xE6877A4d8806e9A9F12eB2e8561EA6c1db19978d"))
            print(requestDictionary)
            XCTAssert(requestDictionary != nil, "Failed plasma funding transaction")
        } catch {
            print(error)
        }
    }
    
    func testMakePrivateKey()
    {
        let privKey = SECP256K1.generatePrivateKey()
        XCTAssert(privKey != nil, "Failed to create new private key")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}

