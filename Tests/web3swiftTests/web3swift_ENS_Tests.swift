//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import XCTest

@testable import web3swift

class web3swift_ENS_Tests: XCTestCase {
    
    func testDomainNormalization() {
        let normalizedString = NameHash.normalizeDomainName("example.ens")
        print(normalizedString!)
    }
    
    func testNameHash() {
        XCTAssertEqual(NameHash.nameHash(""), Data.fromHex("0x0000000000000000000000000000000000000000000000000000000000000000"))
        XCTAssertEqual(NameHash.nameHash("eth"), Data.fromHex("0x93cdeb708b7545dc668eb9280176169d1c33cfd8ed6f04690a0bcc88a93fc4ae"))
        XCTAssertEqual(NameHash.nameHash("foo.eth"), Data.fromHex("0xde9b09fd7c5f901e23a3f19fecc54828e9c848539801e86591bd9801b019f84f"))
    }
    
    func testResolverAddress() {
        do {
            let web = web3(provider: InfuraProvider(Networks.Mainnet)!)
            let ens = ENS(web3: web)
            let domain = "somename.eth"
            let address = try ens?.registry.getResolver(forDomain: domain).resolverContractAddress
            XCTAssertEqual(address?.address.lowercased(), "0x5ffc014343cd971b7eb70732021e26c35b744cc4")
        } catch {
            XCTFail()
        }
    }
    
    func testResolver() {
        do {
            let web = web3(provider: InfuraProvider(Networks.Mainnet)!)
            let ens = ENS(web3: web)
            let domain = "somename.eth"
            let address = try ens?.getAddress(forNode: domain)
            XCTAssertEqual(address?.address.lowercased(), "0x3487acfb1479ad1df6c0eb56ae743d34897798ac")
        } catch {
            XCTFail()
        }
    }
    
    func testSupportsInterface() {
        do {
            let web = web3(provider: InfuraProvider(Networks.Mainnet)!)
            let ens = ENS(web3: web)
            let domain = "somename.eth"
            let resolver = try ens?.registry.getResolver(forDomain: domain)
            let isAddrSupports = try resolver?.supportsInterface(interfaceID: ENS.Resolver.InterfaceName.addr.hash())
            let isNameSupports = try resolver?.supportsInterface(interfaceID: ENS.Resolver.InterfaceName.name.hash())
            let isABIsupports = try resolver?.supportsInterface(interfaceID: ENS.Resolver.InterfaceName.ABI.hash())
            let isPubkeySupports = try resolver?.supportsInterface(interfaceID: ENS.Resolver.InterfaceName.pubkey.hash())
            XCTAssertEqual(isAddrSupports, true)
            XCTAssertEqual(isNameSupports, true)
            XCTAssertEqual(isABIsupports, true)
            XCTAssertEqual(isPubkeySupports, true)
        } catch {
            XCTFail()
        }
    }
    
    func testABI() {
        do {
            let web = web3(provider: InfuraProvider(Networks.Mainnet)!)
            let ens = ENS(web3: web)
            let domain = "somename.eth"
            let resolver = try ens?.registry.getResolver(forDomain: domain)
            if let isABIsupported = try resolver?.supportsInterface(interfaceID: ENS.Resolver.InterfaceName.ABI.hash()),
                isABIsupported {
                let res = try resolver?.getContractABI(forNode: domain, contentType: .zlibCompressedJSON)
                XCTAssert(res?.0 == 0)
                XCTAssert(res?.1.count == 0)
            } else {
                XCTFail()
            }
        } catch {
            XCTFail()
        }
    }
    
    func testOwner() {
        do {
            let web = web3(provider: InfuraProvider(Networks.Mainnet)!)
            let ens = ENS(web3: web)
            let domain = "somename.eth"
            let owner = try ens?.registry.getOwner(node: domain)
            XCTAssertEqual("0xc67247454e720328714c4e17bec7640572657bee", owner?.address.lowercased())
        } catch {
            XCTFail()
        }
    }
    
    func testTTL() {
        do {
            let web = web3(provider: InfuraProvider(Networks.Mainnet)!)
            let ens = ENS(web3: web)
            let domain = "somename.eth"
            let ttl = try ens?.registry.getTTL(node: domain)
            print(ttl!.description)
        } catch {
            XCTFail()
        }
    }
    
    func testGetAddress() {
        do {
            let web = web3(provider: InfuraProvider(Networks.Mainnet)!)
            let ens = ENS(web3: web)
            let domain = "somename.eth"
            let resolver = try ens?.registry.getResolver(forDomain: domain)
            let address = try resolver?.getAddress(forNode: domain)
            XCTAssertEqual(address?.address.lowercased(), "0x3487acfb1479ad1df6c0eb56ae743d34897798ac")
        } catch {
            XCTFail()
        }
    }
    
    func testGetPubkey() {
        do {
            let web = web3(provider: InfuraProvider(Networks.Mainnet)!)
            let ens = ENS(web3: web)
            let domain = "somename.eth"
            let resolver = try ens?.registry.getResolver(forDomain: domain)
            let pubkey = try resolver?.getPublicKey(forNode: domain)
            XCTAssert(pubkey?.x == "0x0000000000000000000000000000000000000000000000000000000000000000")
            XCTAssert(pubkey?.y == "0x0000000000000000000000000000000000000000000000000000000000000000")
        } catch {
            XCTFail()
        }
    }
}
