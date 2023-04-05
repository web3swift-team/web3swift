//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import XCTest
import Web3Core

@testable import web3swift

// MARK: Works only with network connection
class ENSTests: XCTestCase {

    func testDomainNormalization() throws {
        let normalizedString = NameHash.normalizeDomainName("Example.ENS")
        XCTAssertEqual(normalizedString, "example.ens")
    }

    func testNameHash() throws {
        XCTAssertEqual(NameHash.nameHash(""), Data.fromHex("0x0000000000000000000000000000000000000000000000000000000000000000"))
        XCTAssertEqual(NameHash.nameHash("eth"), Data.fromHex("0x93cdeb708b7545dc668eb9280176169d1c33cfd8ed6f04690a0bcc88a93fc4ae"))
        XCTAssertEqual(NameHash.nameHash("foo.eth"), Data.fromHex("0xde9b09fd7c5f901e23a3f19fecc54828e9c848539801e86591bd9801b019f84f"))
    }

    func testResolverAddress() async throws {
        let web3 = try await Web3.InfuraMainnetWeb3(accessToken: Constants.infuraToken)
        let ens = ENS(web3: web3)
        let domain = "somename.eth"
        let address = try await ens?.registry.getResolver(forDomain: domain).resolverContractAddress

        XCTAssertEqual(address?.address.lowercased(), "0x4976fb03c32e5b8cfe2b6ccb31c09ba78ebaba41")
    }

    func testResolver() async throws {
        let web3 = try await Web3.InfuraMainnetWeb3(accessToken: Constants.infuraToken)
        let ens = ENS(web3: web3)
        let domain = "somename.eth"
        let address = try await ens?.getAddress(forNode: domain)
        XCTAssertEqual(address?.address.lowercased(), "0xc1ccfb5fc589b83b9e849c6f9b26efc71419898d")
    }

    func testSupportsInterface() async throws {
        let web3 = try await Web3.InfuraMainnetWeb3(accessToken: Constants.infuraToken)
        let ens = ENS(web3: web3)
        let domain = "somename.eth"
        let resolver = try await ens?.registry.getResolver(forDomain: domain)
        let isAddrSupports = try await resolver?.supportsInterface(interfaceID: .addr)
        let isNameSupports = try await resolver?.supportsInterface(interfaceID: .name)
        let isABIsupports = try await resolver?.supportsInterface(interfaceID: .ABI)
        let isPubkeySupports = try await resolver?.supportsInterface(interfaceID: .pubkey)
        XCTAssertEqual(isAddrSupports, true)
        XCTAssertEqual(isNameSupports, true)
        XCTAssertEqual(isABIsupports, true)
        XCTAssertEqual(isPubkeySupports, true)
    }

    func testABI() async throws {
        let web3 = try await Web3.InfuraMainnetWeb3(accessToken: Constants.infuraToken)
        let ens = ENS(web3: web3)
        let domain = "somename.eth"
        let resolver = try await ens?.registry.getResolver(forDomain: domain)
        if let isABIsupported = try await resolver?.supportsInterface(interfaceID: .ABI),
            isABIsupported {
            let res = try await resolver?.getContractABI(forNode: domain, contentType: .zlibCompressedJSON)
            XCTAssert(res?.0 == 0)
            XCTAssert(res?.1.count == 0)
        } else {
            XCTFail()
        }
    }

    func testOwner() async throws {
        let web3 = try await Web3.InfuraMainnetWeb3(accessToken: Constants.infuraToken)
        let ens = ENS(web3: web3)
        let domain = "somename.eth"
        let owner = try await ens?.registry.getOwner(node: domain)
        XCTAssertEqual("0xc1ccfb5fc589b83b9e849c6f9b26efc71419898d", owner?.address.lowercased())
    }

    func testTTL() async throws {
        let web3 = try await Web3.InfuraMainnetWeb3(accessToken: Constants.infuraToken)
        let ens = try XCTUnwrap(ENS(web3: web3))
        let domain = "somename.eth"
        let ttl = try await ens.registry.getTTL(node: domain)
        XCTAssertGreaterThanOrEqual(ttl, 0)
    }

    func testGetAddress() async throws {
        let web3 = try await Web3.InfuraMainnetWeb3(accessToken: Constants.infuraToken)
        let ens = ENS(web3: web3)
        let domain = "somename.eth"
        let resolver = try await ens?.registry.getResolver(forDomain: domain)
        let address = try await resolver?.getAddress(forNode: domain)
        XCTAssertEqual(address?.address.lowercased(), "0xc1ccfb5fc589b83b9e849c6f9b26efc71419898d")
    }

    func testGetPubkey() async throws {
        let web3 = try await Web3.InfuraMainnetWeb3(accessToken: Constants.infuraToken)
        let ens = ENS(web3: web3)
        let domain = "somename.eth"
        let resolver = try await ens?.registry.getResolver(forDomain: domain)
        let pubkey = try await resolver?.getPublicKey(forNode: domain)
        XCTAssert(pubkey?.x == "0x0000000000000000000000000000000000000000000000000000000000000000")
        XCTAssert(pubkey?.y == "0x0000000000000000000000000000000000000000000000000000000000000000")
    }
}
