//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import XCTest
import CryptoSwift
import BigInt

@testable import Web3Core
@testable import web3swift

class UncategorizedTests: LocalTestCase {
    func testBitFunctions () throws {
        let data = Data([0xf0, 0x02, 0x03])
        let firstBit = data.bitsInRange(0, 1)
        XCTAssert(firstBit == 1)
        let first4bits = data.bitsInRange(0, 4)
        XCTAssert(first4bits == 0x0f)
    }

    func testCombiningPublicKeys() throws {
        let priv1 = Data(repeating: 0x01, count: 32)
        let pub1 = Utilities.privateToPublic(priv1, compressed: true)!
        let priv2 = Data(repeating: 0x02, count: 32)
        let pub2 = Utilities.privateToPublic(priv2, compressed: true)!
        let combined = SECP256K1.combineSerializedPublicKeys(keys: [pub1, pub2], outputCompressed: true)
        let compinedPriv = Data(repeating: 0x03, count: 32)
        let compinedPub = Utilities.privateToPublic(compinedPriv, compressed: true)
        XCTAssert(compinedPub == combined)
    }

    func testChecksumAddress() throws {
        let input = "0xfb6916095ca1df60bb79ce92ce3ea74c37c5d359"
        let output = EthereumAddress.toChecksumAddress(input)
        XCTAssert(output == "0xfB6916095ca1df60bB79Ce92cE3Ea74c37c5d359", "Failed to checksum address")
    }

    func testChecksumAddressParsing() throws {
        let input = "0xfB6916095ca1df60bB79Ce92cE3Ea74c37c5d359"
        let addr = EthereumAddress(input)
        XCTAssert(addr != nil)
        let invalidInput = "0xfb6916095ca1df60bB79Ce92cE3Ea74c37c5d359"
        let invalidAddr = EthereumAddress(invalidInput)
        XCTAssert(invalidAddr == nil)
    }

    func testBigUIntFromHex() throws {
        let hexRepresentation = "0x1c31de57e49fc00".stripHexPrefix()
        let biguint = BigUInt(hexRepresentation, radix: 16)!
        XCTAssert(biguint == BigUInt("126978086000000000"))
    }

    func testStringSplit() {
        XCTAssertEqual("abcdefgh".split(every: 3), ["abc", "def", "gh"])
        XCTAssertEqual("abcdefgh".split(every: 3, backwards: true), ["ab", "cde", "fgh"])

        XCTAssertEqual("abcdefgh".split(every: 10), ["abcdefgh"])
        XCTAssertEqual("".split(every: 3), [])

        XCTAssertEqual("abcdefgh".split(every: 1), ["a", "b", "c", "d", "e", "f", "g", "h"])
        XCTAssertEqual("abcdefgh".split(every: 1, backwards: true), ["a", "b", "c", "d", "e", "f", "g", "h"])  // should be the same as from the front
    }

    func testBloom() throws {
        let positive = [
                "testtest",
                "test",
                "hallo",
                "other"
            ]
        let negative = [
                "tes",
                "lo"
            ]
        var bloom = EthereumBloomFilter()
        for str in positive {
            let data = str.data(using: .utf8)!
            let oldBytes = bloom.bytes
            bloom.add(BigUInt(data))
            let newBytes = bloom.bytes
            if newBytes != oldBytes {

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

    func testMakePrivateKey() throws {
        let privKey = SECP256K1.generatePrivateKey()
        XCTAssert(privKey != nil, "Failed to create new private key")
    }

    func testIBANcreation() throws {
        let iban = "XE7338O073KYGTWWZN0F2WZ0R8PX5ZPPZS"
        let native = Web3.Utils.Iban(iban)
        XCTAssert(native != nil)
        let expectedAddress = "0x00c5496aEe77C1bA1f0854206A26DdA82a81D6D8"
        let createdAddress = native?.toEthereumAddress()?.address
        XCTAssert(createdAddress == expectedAddress)

        let address = EthereumAddress("0x03c5496aee77c1ba1f0854206a26dda82a81d6d8")!
        let fromAddress = Web3.Utils.Iban(address)
        let ibn = fromAddress?.iban
        XCTAssert(ibn == "XE83FUTTUNPK7WZJSGGCWVEBARQWQ8YML4")
    }

//    func testGenericRPCresponse() throws {
//        let hex = "0x1"
//        let rpcResponse = JSONRPCresponse(id: 1, jsonrpc: "2.0", result: hex, error: nil)
//        let value: BigUInt? = rpcResponse.getValue()
//        XCTAssert(value == 1)
//    }

    func testPublicMappingsAccess() async throws {
        let bytecode = Data(hex: "0x608060405234801561001057600080fd5b5061023d806100206000396000f3fe608060405234801561001057600080fd5b50600436106100415760003560e01c8063365b98b2146100465780635e79ab6014610076578063bff1f9e1146100a6575b600080fd5b610060600480360381019061005b919061014a565b6100c4565b60405161006d9190610182565b60405180910390f35b610090600480360381019061008b9190610121565b6100ce565b60405161009d9190610182565b60405180910390f35b6100ae6100ee565b6040516100bb9190610182565b60405180910390f35b6000819050919050565b60008173ffffffffffffffffffffffffffffffffffffffff169050919050565b60006064905090565b600081359050610106816101d9565b92915050565b60008135905061011b816101f0565b92915050565b60006020828403121561013357600080fd5b6000610141848285016100f7565b91505092915050565b60006020828403121561015c57600080fd5b600061016a8482850161010c565b91505092915050565b61017c816101cf565b82525050565b60006020820190506101976000830184610173565b92915050565b60006101a8826101af565b9050919050565b600073ffffffffffffffffffffffffffffffffffffffff82169050919050565b6000819050919050565b6101e28161019d565b81146101ed57600080fd5b50565b6101f9816101cf565b811461020457600080fd5b5056fea26469706673582212207373b0db986284793522a82bff7bf03e30323defa94e6d25f7141e7d63e1ee0564736f6c63430008040033")
        let jsonString = "[{\"constant\":true,\"inputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"name\":\"users\",\"outputs\":[{\"name\":\"name\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"\",\"type\":\"address\"}],\"name\":\"userDeviceCount\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"totalUsers\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"}]"
        let receipt = try await deployContract(bytecode: bytecode, abiString: jsonString)
        let web3 = try await Web3.new(LocalTestCase.url)
        guard let addr = receipt.contractAddress else {return XCTFail()}
        let contract = web3.contract(jsonString, at: receipt.contractAddress!, abiVersion: 2)

        let userDeviceCount = try await contract!
            .createReadOperation("userDeviceCount", parameters: [addr])!
            .callContractMethod()

        let totalUsers = try await contract!
            .createReadOperation("totalUsers")!
            .callContractMethod()

        let user = try await contract!
            .createReadOperation("users", parameters: [0])!
            .callContractMethod()

        XCTAssertEqual((userDeviceCount["0"] as? BigUInt)?.hexString.lowercased(), addr.address.lowercased())
        XCTAssertEqual(totalUsers["0"] as? BigUInt, 100)
        XCTAssertEqual(user["0"] as? BigUInt, 0)
    }

    func testBloomFilterPerformance() throws {
        var uuids = [Data]()
        for _ in 0..<4000 {
            uuids.append(UUID().uuidString.data(using: .utf8)!)
        }
        measure {
            for bytes in uuids {
                _ = EthereumBloomFilter.bloom9(bytes)
            }
        }
    }
}
