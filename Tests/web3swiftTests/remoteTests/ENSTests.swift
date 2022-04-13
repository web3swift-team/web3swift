//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import XCTest

@testable import web3swift

// MARK: Works only with network connection
class ENSTests: XCTestCase {
    
    func testDomainNormalization() throws {
        let normalizedString = NameHash.normalizeDomainName("example.ens")
        print(normalizedString!)
    }
    
    func testNameHash() throws {
        XCTAssertEqual(NameHash.nameHash(""), Data.fromHex("0x0000000000000000000000000000000000000000000000000000000000000000"))
        XCTAssertEqual(NameHash.nameHash("eth"), Data.fromHex("0x93cdeb708b7545dc668eb9280176169d1c33cfd8ed6f04690a0bcc88a93fc4ae"))
        XCTAssertEqual(NameHash.nameHash("foo.eth"), Data.fromHex("0xde9b09fd7c5f901e23a3f19fecc54828e9c848539801e86591bd9801b019f84f"))
    }
    
    func testResolverAddress() throws {
        let web3 = Web3.InfuraMainnetWeb3(accessToken: Constants.infuraToken)
        let ens = ENS(web3: web3)
        let domain = "somename.eth"
        let address = try await ens?.registry.getResolver(forDomain: domain).resolverContractAddress
        print(address as Any)
        XCTAssertEqual(address?.address.lowercased(), "0x5ffc014343cd971b7eb70732021e26c35b744cc4")
    }

    func testResolver() throws {
        let web3 = Web3.InfuraMainnetWeb3(accessToken: Constants.infuraToken)
        let ens = ENS(web3: web3)
        let domain = "somename.eth"
        let address = try await ens?.getAddress(forNode: domain)
        XCTAssertEqual(address?.address.lowercased(), "0x3487acfb1479ad1df6c0eb56ae743d34897798ac")
    }

    func testSupportsInterface() throws {
        let web3 = Web3.InfuraMainnetWeb3(accessToken: Constants.infuraToken)
        let ens = ENS(web3: web3)
        let domain = "somename.eth"
        let resolver = try await ens?.registry.getResolver(forDomain: domain)
        let isAddrSupports = try await resolver?.supportsInterface(interfaceID: ENS.Resolver.InterfaceName.addr.hash())
        let isNameSupports = try await resolver?.supportsInterface(interfaceID: ENS.Resolver.InterfaceName.name.hash())
        let isABIsupports = try await resolver?.supportsInterface(interfaceID: ENS.Resolver.InterfaceName.ABI.hash())
        let isPubkeySupports = try await resolver?.supportsInterface(interfaceID: ENS.Resolver.InterfaceName.pubkey.hash())
        XCTAssertEqual(isAddrSupports, true)
        XCTAssertEqual(isNameSupports, true)
        XCTAssertEqual(isABIsupports, true)
        XCTAssertEqual(isPubkeySupports, true)
    }

    func testABI() throws {
        let web3 = Web3.InfuraMainnetWeb3(accessToken: Constants.infuraToken)
        let ens = ENS(web3: web3)
        let domain = "somename.eth"
        let resolver = try await ens?.registry.getResolver(forDomain: domain)
        if let isABIsupported = try await resolver?.supportsInterface(interfaceID: ENS.Resolver.InterfaceName.ABI.hash()),
            isABIsupported {
            let res = try await resolver?.getContractABI(forNode: domain, contentType: .zlibCompressedJSON)
            XCTAssert(res?.0 == 0)
            XCTAssert(res?.1.count == 0)
        } else {
            XCTFail()
        }
    }

    func testOwner() throws {
        let web3 = Web3.InfuraMainnetWeb3(accessToken: Constants.infuraToken)
        let ens = ENS(web3: web3)
        let domain = "somename.eth"
        let owner = try await ens?.registry.getOwner(node: domain)
        XCTAssertEqual("0xc67247454e720328714c4e17bec7640572657bee", owner?.address.lowercased())
    }

    func testTTL() throws {
        let web3 = Web3.InfuraMainnetWeb3(accessToken: Constants.infuraToken)
        let ens = ENS(web3: web3)
        let domain = "somename.eth"
        let ttl = try await ens?.registry.getTTL(node: domain)
        print(ttl!.description)
    }

    func testGetAddress() throws {
        let web3 = Web3.InfuraMainnetWeb3(accessToken: Constants.infuraToken)
        let ens = ENS(web3: web3)
        let domain = "somename.eth"
        let resolver = try await ens?.registry.getResolver(forDomain: domain)
        let address = try await resolver?.getAddress(forNode: domain)
        XCTAssertEqual(address?.address.lowercased(), "0x3487acfb1479ad1df6c0eb56ae743d34897798ac")
    }

    func testGetPubkey() throws {
        let web3 = Web3.InfuraMainnetWeb3(accessToken: Constants.infuraToken)
        let ens = ENS(web3: web3)
        let domain = "somename.eth"
        let resolver = try await ens?.registry.getResolver(forDomain: domain)
        let pubkey = try await resolver?.getPublicKey(forNode: domain)
        XCTAssert(pubkey?.x == "0x0000000000000000000000000000000000000000000000000000000000000000")
        XCTAssert(pubkey?.y == "0x0000000000000000000000000000000000000000000000000000000000000000")
    }
}
