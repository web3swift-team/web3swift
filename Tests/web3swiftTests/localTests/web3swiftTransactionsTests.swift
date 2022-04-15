//  web3swift
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//
//  Test refactoring for new transaction types by Mark Loit March 2022

import Foundation
import XCTest
import CryptoSwift
import BigInt

// swiftlint:disable file_length
// swiftlint:disable type_body_length

@testable import web3swift

class web3swiftTransactionsTests: XCTestCase {

    enum TestCase: Int {
        case legacyFallback = 0
        case legacyEip155
        case eip2930
        case eip2930withAccessList
        case eip1559
        case eip1559withAccessList
    }

    struct TestVector {
        let JSON: String
        let RLP: String
        let hash: String
    }

    // reference transaction data created with ethers.js
    let testVector: [TestVector] = [
        TestVector(JSON: """
            {
                "nonce": "0x2a",
                "gasPrice": "0x40",
                "gasLimit": "0x0186a0",
                "to": "0xff00000000000000000000000000000000000002",
                "value": "0x3b9aca00",
                "data": "0xdeadbeef",
                "v": "0x1b",
                "r": "0x7c07c9dab35d81a1fa4ce5edf0849e31c60228a852b9957284d49580dceb8d45",
                "s": "0x05fac497338380b971124921b043a83c0cbd44e38b79a9e1f09ec539f0a6393c"
            }
            """,
            RLP: "0xf8682a40830186a094ff00000000000000000000000000000000000002843b9aca0084deadbeef1ba07c07c9dab35d81a1fa4ce5edf0849e31c60228a852b9957284d49580dceb8d45a005fac497338380b971124921b043a83c0cbd44e38b79a9e1f09ec539f0a6393c",
            hash: "0x42ec45f2aee07704d2e1133c6e399a4a2e95e16480cb39cf67ae8d03a89976d5"),
        TestVector(JSON: """
            {
                "chainId": "0x4",
                "nonce": "0x2a",
                "gasPrice": "0x40",
                "gasLimit": "0x0186a0",
                "to": "0xff00000000000000000000000000000000000002",
                "value": "0x3b9aca00",
                "data": "0xdeadbeef",
                "v": "0x2c",
                "r": "0x75ae03657de9cce47e8f12ab04536a5bcb7bc1f41e94691426f668530baab3bf",
                "s": "0x1b2d40a516f173f7e85fc2b58df9f05c4aea5ea754c5d7fdccd2b8a0a50fa271"
            }
            """,
            RLP: "0xf8682a40830186a094ff00000000000000000000000000000000000002843b9aca0084deadbeef2ca075ae03657de9cce47e8f12ab04536a5bcb7bc1f41e94691426f668530baab3bfa01b2d40a516f173f7e85fc2b58df9f05c4aea5ea754c5d7fdccd2b8a0a50fa271",
            hash: "0x8dcdbef8aca73475b1a19df91bb205bf23c122bb0dddb2ad16cab2a2e61dbb6c"),
        TestVector(JSON: """
            {
                "type": "0x1",
                "chainId": "0x4",
                "nonce": "0x2a",
                "gasPrice": "0x40",
                "gasLimit": "0x0186a0",
                "to": "0xff00000000000000000000000000000000000002",
                "value": "0x3b9aca00",
                "data": "0xdeadbeef",
                "accessList": [],
                "v": "0x0",
                "r": "0xb249e51f4281f57979b1f955d710eb081fd6e5ca6491cf049e6b5f21dd08f8fa",
                "s": "0x728489fd1b3c9e0484e27ab5160205a7f6b7b69f6fde86277280760a8c53c102"
            }
            """,
            RLP: "0x01f86a042a40830186a094ff00000000000000000000000000000000000002843b9aca0084deadbeefc080a0b249e51f4281f57979b1f955d710eb081fd6e5ca6491cf049e6b5f21dd08f8faa0728489fd1b3c9e0484e27ab5160205a7f6b7b69f6fde86277280760a8c53c102",
            hash: "0x7fdb18ec23eb419080bc21386cadf939291208ea40b942fb0085bb69fc4e8611"),
        TestVector(JSON: """
            {
                "type": "0x1",
                "chainId": "0x4",
                "nonce": "0x2a",
                "gasPrice": "0x40",
                "gasLimit": "0x0186a0",
                "to": "0xff00000000000000000000000000000000000002",
                "value": "0x3b9aca00",
                "data": "0xdeadbeef",
                "accessList": [
                {
                    "address": "0xff00000000000000000000000000000000000003",
                    "storageKeys": [
                        "0xee00000000000000000000000000000000000000000000000000000000000031",
                        "0xee00000000000000000000000000000000000000000000000000000000000032"
                    ]
                },
                {
                    "address": "0xff00000000000000000000000000000000000004",
                    "storageKeys": [
                        "0xee00000000000000000000000000000000000000000000000000000000000041"
                    ]
                },
                {
                    "address": "0xff00000000000000000000000000000000000005",
                    "storageKeys": []
                }
                ],
                "v": "0x0",
                "r": "0x9c2c3d22eed0b9d64bfa47ee3cef8928c04005c495bf8986d9ba8b27276ab9e7",
                "s": "0x48a8ebab30bf534c38d834010f999d25747dc207075c501cdb0c7354a4c35493"
            }
            """,
            RLP: "0x01f90115042a40830186a094ff00000000000000000000000000000000000002843b9aca0084deadbeeff8aaf85994ff00000000000000000000000000000000000003f842a0ee00000000000000000000000000000000000000000000000000000000000031a0ee00000000000000000000000000000000000000000000000000000000000032f794ff00000000000000000000000000000000000004e1a0ee00000000000000000000000000000000000000000000000000000000000041d694ff00000000000000000000000000000000000005c080a09c2c3d22eed0b9d64bfa47ee3cef8928c04005c495bf8986d9ba8b27276ab9e7a048a8ebab30bf534c38d834010f999d25747dc207075c501cdb0c7354a4c35493",
            hash: "0x027c8e600456c4ab43e08b83d6e9270c18cff3487d6760502c7554e68de8de07"),
        TestVector(JSON: """
            {
                "type": "0x2",
                "chainId": "0x4",
                "nonce": "0x2a",
                "maxPriorityFeePerGas": "0x7f",
                "maxFeePerGas": "0xff",
                "gasLimit": "0x0186a0",
                "to": "0xff00000000000000000000000000000000000002",
                "value": "0x3b9aca00",
                "data": "0xdeadbeef",
                "accessList": [],
                "v": "0x0",
                "r": "0xd1709fea33339a6ae2de8cab335edf3fe6531a20b4403826922e2c987a825f6d",
                "s": "0x213663e77c6b261fe080267314fcbc62fa4239e9ffd0fb37ff89277b3949965c"
            }
            """,
            RLP: "0x02f86c042a7f81ff830186a094ff00000000000000000000000000000000000002843b9aca0084deadbeefc080a0d1709fea33339a6ae2de8cab335edf3fe6531a20b4403826922e2c987a825f6da0213663e77c6b261fe080267314fcbc62fa4239e9ffd0fb37ff89277b3949965c",
            hash: "0x41dc0cd9b133e0d4e47e269988b0109c966db5220d57e2a7f3cdc6c2f8de6a72"),
        TestVector(JSON: """
            {
                "type": "0x2",
                "chainId": "0x4",
                "nonce": "0x2a",
                "maxPriorityFeePerGas": "0x7f",
                "maxFeePerGas": "0xff",
                "gasLimit": "0x0186a0",
                "to": "0xff00000000000000000000000000000000000002",
                "value": "0x3b9aca00",
                "data": "0xdeadbeef",
                "accessList": [
                {
                    "address": "0xff00000000000000000000000000000000000003",
                    "storageKeys": [
                        "0xee00000000000000000000000000000000000000000000000000000000000031",
                        "0xee00000000000000000000000000000000000000000000000000000000000032"
                    ]
                },
                {
                    "address": "0xff00000000000000000000000000000000000004",
                    "storageKeys": [
                        "0xee00000000000000000000000000000000000000000000000000000000000041"
                    ]
                },
                {
                    "address": "0xff00000000000000000000000000000000000005",
                    "storageKeys": []
                }
                ],
                "v": "0x01",
                "r": "0x36ed8549349d5ad166c06873b73b47bdb00a27d765ca50e56c12e4ac4262eed0",
                "s": "0x5fcdd49d62048c947bc29c00fd2dee2a3f98120a0d155c7d1c6a6245a3a9de43"
            }
            """,
            RLP: "0x02f90117042a7f81ff830186a094ff00000000000000000000000000000000000002843b9aca0084deadbeeff8aaf85994ff00000000000000000000000000000000000003f842a0ee00000000000000000000000000000000000000000000000000000000000031a0ee00000000000000000000000000000000000000000000000000000000000032f794ff00000000000000000000000000000000000004e1a0ee00000000000000000000000000000000000000000000000000000000000041d694ff00000000000000000000000000000000000005c001a036ed8549349d5ad166c06873b73b47bdb00a27d765ca50e56c12e4ac4262eed0a05fcdd49d62048c947bc29c00fd2dee2a3f98120a0d155c7d1c6a6245a3a9de43",
            hash: "0x48608120bd732b138771558453d87fd36dcded8e0b3c86dc3ba79bd18dc20e11")
    ]

    let testSenderAddress = "0x9d8A62f656a8d1615C1294fd71e9CFb3E4855A4F"
    let testSigningKey = "0x4646464646464646464646464646464646464646464646464646464646464646"

    // test a JSON fallback legacy transaction chainID not part of the signing process
    func testLegacyFallbackDecodeAndRecoverJSON() throws {
        let vector = testVector[TestCase.legacyFallback.rawValue]

        let expectedAddress = EthereumAddress(testSenderAddress)!
        let jsonData = vector.JSON.data(using: .utf8)!

        do {
            let jsonTxn: EthereumTransaction = try JSONDecoder().decode(EthereumTransaction.self, from: jsonData)
            // check that the transaction type is legacy
            XCTAssertEqual(jsonTxn.type, .legacy, "Transaction Type Mismatch")
            // check the hash, if they match everything was parsed, and re-encoded correctly
            XCTAssertEqual(jsonTxn.hash!.toHexString().addHexPrefix(), vector.hash, "Transaction Hash Mismatch")
            // check that we recovered the address correctly
            XCTAssertEqual(jsonTxn.sender!.address, expectedAddress.address, "Recovered Address Mismatch")
        } catch {
            print(error)
            return XCTFail(String(describing: error))
        }
    }

    // test a RLP fallback legacy transaction chainID not part of the signing process
    func testLegacyFallbackDecodeAndRecoverRLP() throws {
        let vector = testVector[TestCase.legacyFallback.rawValue]

        let expectedAddress = EthereumAddress(testSenderAddress)!
        let rlpData = Data.fromHex(vector.RLP)!

        guard let rlpTxn = EthereumTransaction(rawValue: rlpData) else {
            return XCTFail("Decoding RLP encoded transaction failed")
        }
        // check that the transaction type is legacy
        XCTAssertEqual(rlpTxn.type, .legacy, "Transaction Type Mismatch")
        // check the hash, if they match everything was parsed, and re-encoded correctly
        XCTAssertEqual(rlpTxn.hash!.toHexString().addHexPrefix(), vector.hash, "Transaction Hash Mismatch")
        // check that we recovered the address correctly
        XCTAssertEqual(rlpTxn.sender!.address, expectedAddress.address, "Recovered Address Mismatch")
    }

    // test signing a fallback legacy transaction (chainId not part of the signing process)
    func testLegacyFallbackSignAndEncodeRLP() throws {
        let vector = testVector[TestCase.legacyFallback.rawValue]

        let expectedAddress = EthereumAddress(testSenderAddress)!
        let privateKeyData = Data.fromHex(testSigningKey)!
        let jsonData = vector.JSON.data(using: .utf8)!

        do {
            var jsonTxn: EthereumTransaction = try JSONDecoder().decode(EthereumTransaction.self, from: jsonData)

            // unsign the input transaction
            jsonTxn.unsign()

            // now sign the transaction with the private key
            try jsonTxn.sign(privateKey: privateKeyData, useExtraEntropy: false)
            let rawTxn = jsonTxn.encode()!.toHexString().addHexPrefix()

            // check the hash, if they match everything was parsed, and re-encoded correctly
            XCTAssertEqual(rawTxn, vector.RLP, "Transaction Encoding Mismatch")
            // check the hash, if they match everything was parsed, and re-encoded correctly
            XCTAssertEqual(jsonTxn.hash!.toHexString().addHexPrefix(), vector.hash, "Transaction Hash Mismatch")
            // check that we recovered the address correctly
            XCTAssertEqual(jsonTxn.sender!.address, expectedAddress.address, "Recovered Address Mismatch")
        } catch {
            print(error)
            return XCTFail(String(describing: error))
        }
    }

    // test a normal JSON legacy transaction conforming to EIP155 for signing
    func testLegacyEIP155DecodeAndRecoverJSON() throws {
        let vector = testVector[TestCase.legacyEip155.rawValue]

        let expectedAddress = EthereumAddress(testSenderAddress)!
        let jsonData = vector.JSON.data(using: .utf8)!

        do {
            let jsonTxn: EthereumTransaction = try JSONDecoder().decode(EthereumTransaction.self, from: jsonData)
            // check that the transaction type is legacy
            XCTAssertEqual(jsonTxn.type, .legacy, "Transaction Type Mismatch")
            // check the hash, if they match everything was parsed, and re-encoded correctly
            XCTAssertEqual(jsonTxn.hash!.toHexString().addHexPrefix(), vector.hash, "Transaction Hash Mismatch")
            // check that we recovered the address correctly
            XCTAssertEqual(jsonTxn.sender!.address, expectedAddress.address, "Recovered Address Mismatch")
        } catch {
            print(error)
            return XCTFail(String(describing: error))
        }
    }

    // test a normal RLP legacy transaction conforming to EIP155 for signing
    func testLegacyEIP155DecodeAndRecoverRLP() throws {
        let vector = testVector[TestCase.legacyEip155.rawValue]

        let expectedAddress = EthereumAddress(testSenderAddress)!
        let rlpData = Data.fromHex(vector.RLP)!

        guard let rlpTxn = EthereumTransaction(rawValue: rlpData) else {
            return XCTFail("Decoding RLP encoded transaction failed")
        }
        // check that the transaction type is legacy
        XCTAssertEqual(rlpTxn.type, .legacy, "Transaction Type Mismatch")
        // check the hash, if they match everything was parsed, and re-encoded correctly
        XCTAssertEqual(rlpTxn.hash!.toHexString().addHexPrefix(), vector.hash, "Transaction Hash Mismatch")
        // check that we recovered the address correctly
        XCTAssertEqual(rlpTxn.sender!.address, expectedAddress.address, "Recovered Address Mismatch")
    }

    // test signing a normal legacy transaction conforming to EIP155
    func testLegacyEIP155SignAndEncodeRLP() throws {
        let vector = testVector[TestCase.legacyEip155.rawValue]

        let expectedAddress = EthereumAddress(testSenderAddress)!
        let privateKeyData = Data.fromHex(testSigningKey)!
        let jsonData = vector.JSON.data(using: .utf8)!

        do {
            var jsonTxn: EthereumTransaction = try JSONDecoder().decode(EthereumTransaction.self, from: jsonData)

            // unsign the input transaction
            jsonTxn.unsign()

            // now sign the transaction with the private key
            try jsonTxn.sign(privateKey: privateKeyData, useExtraEntropy: false)
            let rawTxn = jsonTxn.encode()!.toHexString().addHexPrefix()

            // check the hash, if they match everything was parsed, and re-encoded correctly
            XCTAssertEqual(rawTxn, vector.RLP, "Transaction Encoding Mismatch")
            // check the hash, if they match everything was parsed, and re-encoded correctly
            XCTAssertEqual(jsonTxn.hash!.toHexString().addHexPrefix(), vector.hash, "Transaction Hash Mismatch")
            // check that we recovered the address correctly
            XCTAssertEqual(jsonTxn.sender!.address, expectedAddress.address, "Recovered Address Mismatch")
        } catch {
            print(error)
            return XCTFail(String(describing: error))
        }
    }

    // test a JSON EIP-2930 transaction without accessList
    func testEIP2930DecodeAndRecoverJSON() throws {
        let vector = testVector[TestCase.eip2930.rawValue]

        let expectedAddress = EthereumAddress(testSenderAddress)!
        let jsonData = vector.JSON.data(using: .utf8)!

        do {
            let jsonTxn: EthereumTransaction = try JSONDecoder().decode(EthereumTransaction.self, from: jsonData)
            // check that the transaction type is eip2930
            XCTAssertEqual(jsonTxn.type, .eip2930, "Transaction Type Mismatch")
            // check the hash, if they match everything was parsed, and re-encoded correctly
            XCTAssertEqual(jsonTxn.hash!.toHexString().addHexPrefix(), vector.hash, "Transaction Hash Mismatch")
            // check that we recovered the address correctly
            XCTAssertEqual(jsonTxn.sender!.address, expectedAddress.address, "Recovered Address Mismatch")
        } catch {
            print(error)
            return XCTFail(String(describing: error))
        }
    }

    // test a RLP EIP-2930 transaction without accessList
    func testEIP2930DecodeAndRecoverRLP() throws {
        let vector = testVector[TestCase.eip2930.rawValue]

        let expectedAddress = EthereumAddress(testSenderAddress)!
        let rlpData = Data.fromHex(vector.RLP)!

        guard let rlpTxn = EthereumTransaction(rawValue: rlpData) else {
            return XCTFail("Decoding RLP encoded transaction failed")
        }
        // check that the transaction type is eip2930
        XCTAssertEqual(rlpTxn.type, .eip2930, "Transaction Type Mismatch")
        // check the hash, if they match everything was parsed, and re-encoded correctly
        XCTAssertEqual(rlpTxn.hash!.toHexString().addHexPrefix(), vector.hash, "Transaction Hash Mismatch")
        // check that we recovered the address correctly
        XCTAssertEqual(rlpTxn.sender!.address, expectedAddress.address, "Recovered Address Mismatch")
    }

    // test signing a EIP-2930 transaction (without accessList)
    func testEIP2930SignAndEncodeRLP() throws {
        let vector = testVector[TestCase.eip2930.rawValue]

        let expectedAddress = EthereumAddress(testSenderAddress)!
        let privateKeyData = Data.fromHex(testSigningKey)!
        let jsonData = vector.JSON.data(using: .utf8)!

        do {
            var jsonTxn: EthereumTransaction = try JSONDecoder().decode(EthereumTransaction.self, from: jsonData)

            // unsign the input transaction
            jsonTxn.unsign()

            // now sign the transaction with the private key
            try jsonTxn.sign(privateKey: privateKeyData, useExtraEntropy: false)
            let rawTxn = jsonTxn.encode()!.toHexString().addHexPrefix()

            // check the hash, if they match everything was parsed, and re-encoded correctly
            XCTAssertEqual(rawTxn, vector.RLP, "Transaction Encoding Mismatch")
            // check the hash, if they match everything was parsed, and re-encoded correctly
            XCTAssertEqual(jsonTxn.hash!.toHexString().addHexPrefix(), vector.hash, "Transaction Hash Mismatch")
            // check that we recovered the address correctly
            XCTAssertEqual(jsonTxn.sender!.address, expectedAddress.address, "Recovered Address Mismatch")
        } catch {
            print(error)
            return XCTFail(String(describing: error))
        }
    }

    // test a JSON EIP-2930 transaction with accessList
    func testEIP2930WithAccessDecodeAndRecoverJSON() throws {
        let vector = testVector[TestCase.eip2930withAccessList.rawValue]

        let expectedAddress = EthereumAddress(testSenderAddress)!
        let jsonData = vector.JSON.data(using: .utf8)!

        do {
            let jsonTxn: EthereumTransaction = try JSONDecoder().decode(EthereumTransaction.self, from: jsonData)
            // check that the transaction type is eip2930
            XCTAssertEqual(jsonTxn.type, .eip2930, "Transaction Type Mismatch")
            // check the hash, if they match everything was parsed, and re-encoded correctly
            XCTAssertEqual(jsonTxn.hash!.toHexString().addHexPrefix(), vector.hash, "Transaction Hash Mismatch")
            // check that we recovered the address correctly
            XCTAssertEqual(jsonTxn.sender!.address, expectedAddress.address, "Recovered Address Mismatch")
        } catch {
            print(error)
            return XCTFail(String(describing: error))
        }
    }

    // test a RLP EIP-2930 transaction with accessList
    func testEIP2930WithAccessDecodeAndRecoverRLP() throws {
        let vector = testVector[TestCase.eip2930withAccessList.rawValue]

        let expectedAddress = EthereumAddress(testSenderAddress)!
        let rlpData = Data.fromHex(vector.RLP)!

        guard let rlpTxn = EthereumTransaction(rawValue: rlpData) else {
            return XCTFail("Decoding RLP encoded transaction failed")
        }
        // check that the transaction type is eip2930
        XCTAssertEqual(rlpTxn.type, .eip2930, "Transaction Type Mismatch")
        // check the hash, if they match everything was parsed, and re-encoded correctly
        XCTAssertEqual(rlpTxn.hash!.toHexString().addHexPrefix(), vector.hash, "Transaction Hash Mismatch")
        // check that we recovered the address correctly
        XCTAssertEqual(rlpTxn.sender!.address, expectedAddress.address, "Recovered Address Mismatch")
    }

    // test signing a EIP-2930 transaction (with accessList)
    func testEIP2930WithAccessSignAndEncodeRLP() throws {
        let vector = testVector[TestCase.eip2930withAccessList.rawValue]

        let expectedAddress = EthereumAddress(testSenderAddress)!
        let privateKeyData = Data.fromHex(testSigningKey)!
        let jsonData = vector.JSON.data(using: .utf8)!

        do {
            var jsonTxn: EthereumTransaction = try JSONDecoder().decode(EthereumTransaction.self, from: jsonData)

            // unsign the input transaction
            jsonTxn.unsign()

            // now sign the transaction with the private key
            try jsonTxn.sign(privateKey: privateKeyData, useExtraEntropy: false)
            let rawTxn = jsonTxn.encode()!.toHexString().addHexPrefix()

            // check the hash, if they match everything was parsed, and re-encoded correctly
            XCTAssertEqual(rawTxn, vector.RLP, "Transaction Encoding Mismatch")
            // check the hash, if they match everything was parsed, and re-encoded correctly
            XCTAssertEqual(jsonTxn.hash!.toHexString().addHexPrefix(), vector.hash, "Transaction Hash Mismatch")
            // check that we recovered the address correctly
            XCTAssertEqual(jsonTxn.sender!.address, expectedAddress.address, "Recovered Address Mismatch")
        } catch {
            print(error)
            return XCTFail(String(describing: error))
        }
    }

    // test EIP-1559 encoding with empty access list
    func testEIP1559DecodeAndRecoverJSON() throws {
        let vector = testVector[TestCase.eip1559.rawValue]

        let expectedAddress = EthereumAddress(testSenderAddress)!
        let jsonData = vector.JSON.data(using: .utf8)!

        do {
            let jsonTxn: EthereumTransaction = try JSONDecoder().decode(EthereumTransaction.self, from: jsonData)
            // check that the transaction type is eip1559
            XCTAssertEqual(jsonTxn.type, .eip1559, "Transaction Type Mismatch")
            // check the hash, if they match everything was parsed, and re-encoded correctly
            XCTAssertEqual(jsonTxn.hash!.toHexString().addHexPrefix(), vector.hash, "Transaction Hash Mismatch")
            // check that we recovered the address correctly
            XCTAssertEqual(jsonTxn.sender!.address, expectedAddress.address, "Recovered Address Mismatch")
        } catch {
            print(error)
            return XCTFail(String(describing: error))
        }
    }

    // test EIP-1559 encoding with empty access list
    func testEIP1559DecodeAndRecoverRLP() throws {
        let vector = testVector[TestCase.eip1559.rawValue]

        let expectedAddress = EthereumAddress(testSenderAddress)!
        let rlpData = Data.fromHex(vector.RLP)!

        guard let rlpTxn = EthereumTransaction(rawValue: rlpData) else {
            return XCTFail("Decoding RLP encoded transaction failed")
        }
        // check that the transaction type is eip1559
        XCTAssertEqual(rlpTxn.type, .eip1559, "Transaction Type Mismatch")
        // check the hash, if they match everything was parsed, and re-encoded correctly
        XCTAssertEqual(rlpTxn.hash!.toHexString().addHexPrefix(), vector.hash, "Transaction Hash Mismatch")
        // check that we recovered the address correctly
        XCTAssertEqual(rlpTxn.sender!.address, expectedAddress.address, "Recovered Address Mismatch")
    }

    // test signing a EIP-1559 transaction (without accessList)
    func testEIP1559SignAndEncodeRLP() throws {
        let vector = testVector[TestCase.eip1559.rawValue]

        let expectedAddress = EthereumAddress(testSenderAddress)!
        let privateKeyData = Data.fromHex(testSigningKey)!
        let jsonData = vector.JSON.data(using: .utf8)!

        do {
            var jsonTxn: EthereumTransaction = try JSONDecoder().decode(EthereumTransaction.self, from: jsonData)

            // unsign the input transaction
            jsonTxn.unsign()

            // now sign the transaction with the private key
            try jsonTxn.sign(privateKey: privateKeyData, useExtraEntropy: false)
            let rawTxn = jsonTxn.encode()!.toHexString().addHexPrefix()

            // check the hash, if they match everything was parsed, and re-encoded correctly
            XCTAssertEqual(rawTxn, vector.RLP, "Transaction Encoding Mismatch")
            // check the hash, if they match everything was parsed, and re-encoded correctly
            XCTAssertEqual(jsonTxn.hash!.toHexString().addHexPrefix(), vector.hash, "Transaction Hash Mismatch")
            // check that we recovered the address correctly
            XCTAssertEqual(jsonTxn.sender!.address, expectedAddress.address, "Recovered Address Mismatch")
        } catch {
            print(error)
            return XCTFail(String(describing: error))
        }
    }

    // test EIP-1559 encoding with an access list
    func testEIP1559WithAccessDecodeAndRecoverJSON() throws {
        let vector = testVector[TestCase.eip1559withAccessList.rawValue]

        let expectedAddress = EthereumAddress(testSenderAddress)!
        let jsonData = vector.JSON.data(using: .utf8)!

        do {
            let jsonTxn: EthereumTransaction = try JSONDecoder().decode(EthereumTransaction.self, from: jsonData)
            // check that the transaction type is eip1559
            XCTAssertEqual(jsonTxn.type, .eip1559, "Transaction Type Mismatch")
            // check the hash, if they match everything was parsed, and re-encoded correctly
            XCTAssertEqual(jsonTxn.hash!.toHexString().addHexPrefix(), vector.hash, "Transaction Hash Mismatch")
            // check that we recovered the address correctly
            XCTAssertEqual(jsonTxn.sender!.address, expectedAddress.address, "Recovered Address Mismatch")
        } catch {
            print(error)
            return XCTFail(String(describing: error))
        }
    }

    // test EIP-1559 encoding with an access list
    func testEIP1559WithAccessDecodeAndRecoverRLP() throws {
        let vector = testVector[TestCase.eip1559withAccessList.rawValue]

        let expectedAddress = EthereumAddress(testSenderAddress)!
        let rlpData = Data.fromHex(vector.RLP)!

        guard let rlpTxn = EthereumTransaction(rawValue: rlpData) else {
            return XCTFail("Decoding RLP encoded transaction failed")
        }
        // check that the transaction type is eip1559
        XCTAssertEqual(rlpTxn.type, .eip1559, "Transaction Type Mismatch")
        // check the hash, if they match everything was parsed, and re-encoded correctly
        XCTAssertEqual(rlpTxn.hash!.toHexString().addHexPrefix(), vector.hash, "Transaction Hash Mismatch")
        // check that we recovered the address correctly
        XCTAssertEqual(rlpTxn.sender!.address, expectedAddress.address, "Recovered Address Mismatch")
    }

    // test signing a EIP-1559 transaction (with accessList)
    func testEIP1559WithAccessSignAndEncodeRLP() throws {
        let vector = testVector[TestCase.eip1559withAccessList.rawValue]

        let expectedAddress = EthereumAddress(testSenderAddress)!
        let privateKeyData = Data.fromHex(testSigningKey)!
        let jsonData = vector.JSON.data(using: .utf8)!

        do {
            var jsonTxn: EthereumTransaction = try JSONDecoder().decode(EthereumTransaction.self, from: jsonData)

            // unsign the input transaction
            jsonTxn.unsign()

            // now sign the transaction with the private key
            try jsonTxn.sign(privateKey: privateKeyData, useExtraEntropy: false)
            let rawTxn = jsonTxn.encode()!.toHexString().addHexPrefix()

            // check the hash, if they match everything was parsed, and re-encoded correctly
            XCTAssertEqual(rawTxn, vector.RLP, "Transaction Encoding Mismatch")
            // check the hash, if they match everything was parsed, and re-encoded correctly
            XCTAssertEqual(jsonTxn.hash!.toHexString().addHexPrefix(), vector.hash, "Transaction Hash Mismatch")
            // check that we recovered the address correctly
            XCTAssertEqual(jsonTxn.sender!.address, expectedAddress.address, "Recovered Address Mismatch")
        } catch {
            print(error)
            return XCTFail(String(describing: error))
        }
    }

    // ***** Legacy Tests *****
    // TODO: Replace `XCTAssert` with more explicite `XCTAssertEqual`, where Applicable

    func testDirectTransaction() throws {
        do {
            var options = TransactionOptions()
            options.gasPrice = .manual(20000000000)
            options.gasLimit = .manual(21000)
            var transaction = EthereumTransaction(
                to: EthereumAddress("0x3535353535353535353535353535353535353535")!,
                nonce: 9, value: 1000000000000000000, data: Data(),
                v: 0, r: 0, s: 0, options: options)
            let privateKeyData = Data.fromHex("0x4646464646464646464646464646464646464646464646464646464646464646")!
            let publicKey = Web3.Utils.privateToPublic(privateKeyData, compressed: false)
            let sender = Web3.Utils.publicToAddress(publicKey!)
            transaction.chainID = 1
            print(transaction)
            let hash = transaction.hashForSignature()
            let expectedHash = "0xdaf5a779ae972f972197303d7b574746c7ef83eadac0f2791ad23db92e4c8e53".stripHexPrefix()
            XCTAssert(hash!.toHexString() == expectedHash, "Transaction signature failed")
            try transaction.sign(privateKey: privateKeyData, useExtraEntropy: false)
            print(transaction)
            XCTAssert(transaction.v == 37, "Transaction signature failed")
            XCTAssert(sender == transaction.sender)
        } catch {
            print(error)
            XCTFail()
        }
    }

    func testEthSendExampleAndGetTransactionReceiptAndDetails() {
        do {
            let web3 = try Web3.new(URL.init(string: "http://127.0.0.1:8545")!)
            let sendToAddress = EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901")!
            let allAddresses = try web3.eth.getAccounts()
            let contract = web3.contract(Web3.Utils.coldWalletABI, at: sendToAddress, abiVersion: 2)
            let value = Web3.Utils.parseToBigUInt("1.0", units: .eth)
            let from = allAddresses[0]
            let writeTX = contract!.write("fallback")!
            writeTX.transactionOptions.from = from
            writeTX.transactionOptions.value = value
            writeTX.transactionOptions.gasLimit = .manual(78423)
            let result = try writeTX.sendPromise(password: "").wait()
            let txHash = result.hash
            print("Transaction with hash " + txHash)

            Thread.sleep(forTimeInterval: 1.0)

            let receipt = try web3.eth.getTransactionReceipt(txHash)
            print(receipt)
            XCTAssert(receipt.status == .ok)

            switch receipt.status {
            case .notYetProcessed:
                return
            default:
                break
            }

            let details = try web3.eth.getTransactionDetails(txHash)
            print(details)
            let txnGasLimit = details.transaction.gasLimit
            XCTAssert(txnGasLimit == BigUInt(78423))
        } catch Web3Error.nodeError(let descr) {
            guard descr == "insufficient funds for gas * price + value" else {return XCTFail()}
        } catch {
            print(error)
            XCTFail()
        }
    }

    func testGenerateDummyKeystore() throws {
        let keystore = try! EthereumKeystoreV3.init(password: "web3swift")
        let dump = try! keystore!.serialize()
        let jsonString = String.init(data: dump!, encoding: .ascii)
        print(jsonString!)
    }
}
