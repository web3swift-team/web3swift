//
//  web3swift_ENS_Tests.swift
//  web3swift-iOS_Tests
//
//  Created by Alex Vlasov on 08.09.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import XCTest
@testable import web3swift_iOS
class web3swift_ENS_Tests: XCTestCase {
    
    func testDomainNormalization() {
        let normalizedString = NameHash.normalizeDomainName("example.ens")
        print(normalizedString)
    }
    
    func testNameHash() {
        XCTAssertEqual(NameHash.nameHash(""), Data.fromHex("0x0000000000000000000000000000000000000000000000000000000000000000"))
        XCTAssertEqual(NameHash.nameHash("eth"), Data.fromHex("0x93cdeb708b7545dc668eb9280176169d1c33cfd8ed6f04690a0bcc88a93fc4ae"))
        XCTAssertEqual(NameHash.nameHash("foo.eth"), Data.fromHex("0xde9b09fd7c5f901e23a3f19fecc54828e9c848539801e86591bd9801b019f84f"))
    }
    
    func testResolverAddress() {
        let web = web3(provider: InfuraProvider(Networks.Mainnet)!)
        var ens = ENS(web3: web)
        guard case .success(let resolver) = ens.resolver(forDomain: "somename.eth") else { XCTAssert(false); return }
        XCTAssertEqual(resolver.resolverAddress.address.lowercased(), "0x5ffc014343cd971b7eb70732021e26c35b744cc4")
    }
    
    func testResolver() {
        let web = web3(provider: InfuraProvider(Networks.Mainnet)!)
        var ens = ENS(web3: web)
        let domain = "somename.eth"
        guard case .success(var resolver) = ens.resolver(forDomain: domain) else { XCTAssert(false); return  }
        guard case .success(let address) = resolver.addr(forDomain: domain) else { XCTAssert(false); return  }
        XCTAssertEqual(address.address.lowercased(), "0x3487acfb1479ad1df6c0eb56ae743d34897798ac")
        
    }
    
    func testSupportsInterface() {
        let web = web3(provider: InfuraProvider(Networks.Mainnet)!)
        var ens = ENS(web3: web)
        let domain = "somename.eth"
        guard case .success(var resolver) = ens.resolver(forDomain: domain) else { XCTAssert(false); return  }
        guard case .success(let isAddrSupports) = resolver.supportsInterface(interfaceID: ResolverENS.InterfaceName.addr.hash()) else { XCTAssert(false); return  }
        XCTAssertEqual(isAddrSupports, true)
        guard case .success(let isNameSupports) = resolver.supportsInterface(interfaceID: ResolverENS.InterfaceName.name.hash()) else { XCTAssert(false); return  }
        XCTAssertEqual(isNameSupports, true)
        guard case .success(let isABIsupports) = resolver.supportsInterface(interfaceID: ResolverENS.InterfaceName.ABI.hash()) else { XCTAssert(false); return  }
        XCTAssertEqual(isABIsupports, true)
        guard case .success(let isPubkeySupports) = resolver.supportsInterface(interfaceID: ResolverENS.InterfaceName.pubkey.hash()) else { XCTAssert(false); return  }
        XCTAssertEqual(isPubkeySupports, true)
    }
    
    func testABI() {
        let web = web3(provider: InfuraProvider(Networks.Mainnet)!)
        var ens = ENS(web3: web)
        let domain = "somename.eth"
        guard case .success(var resolver) = ens.resolver(forDomain: domain) else { XCTAssert(false); return }
        guard case .success(let isABIsupported) = resolver.supportsInterface(interfaceID: ResolverENS.InterfaceName.ABI.hash()) else { XCTAssert(false); return }
        if isABIsupported {
            guard case .success(let res) = resolver.ABI(node: domain, contentType: 2) else { XCTAssert(false); return }
            XCTAssert(res.0 == 0)
            XCTAssert(res.1.count == 0)
        }
    }
    
    func testOwner() {
        let web = web3(provider: InfuraProvider(Networks.Mainnet)!)
        var ens = ENS(web3: web)
        let domain = "somename.eth"
        guard case .success(let result) = ens.owner(node: domain) else { XCTAssert(false); return }
        XCTAssertEqual("0xc67247454e720328714c4e17bec7640572657bee", result.address.lowercased())
    }
    
    func testTTL() {
        let web = web3(provider: InfuraProvider(Networks.Mainnet)!)
        var ens = ENS(web3: web)
        let domain = "somename.eth"
        guard case .success(let result) = ens.ttl(node: domain) else { XCTAssert(false); return }
        print(result)
    }
    
    func testGetAddress() {
        let web = web3(provider: InfuraProvider(Networks.Mainnet)!)
        var ens = ENS(web3: web)
        let domain = "somename.eth"
        guard case .success(let address) = ens.getAddress(domain) else { XCTAssert(false); return }
        XCTAssertEqual(address.address.lowercased(), "0x3487acfb1479ad1df6c0eb56ae743d34897798ac")
    }
    
    func testGetPubkey() {
        let web = web3(provider: InfuraProvider(Networks.Mainnet)!)
        var ens = ENS(web3: web)
        let domain = "somename.eth"
        guard case .success(let point) = ens.getPubkey(domain: domain) else { XCTAssert(false); return }
        XCTAssert(point.x == "0x0000000000000000000000000000000000000000000000000000000000000000")
        XCTAssert(point.y == "0x0000000000000000000000000000000000000000000000000000000000000000")
    }
    
    func testSetOwner() {
        let web = web3(provider: InfuraProvider(Networks.Rinkeby)!)
        let pk = Data.fromHex("0xc606bf70d7cbf90e8eb75050c810a4a749f8dce645f5afbe70635d1f0ebdb13b")!
        let keystore = (try! EthereumKeystoreV3(privateKey: pk))!
        let manager = KeystoreManager([keystore])
        web.addKeystoreManager(manager)
        var ens = ENS(web3: web)
        let node = "somename.test"
        var options = Web3Options.defaultOptions()
        options.from = EthereumAddress("0x7792e5D9FcC8cc23D312B9062F492a7f3E9f2f98")!
        options.value = 0
        ens.setOwner(node: node, owner: EthereumAddress("0x7792e5D9FcC8cc23D312B9062F492a7f3E9f2f98")!, options: options)
    }
    
    
    
    
    
    
    
}
