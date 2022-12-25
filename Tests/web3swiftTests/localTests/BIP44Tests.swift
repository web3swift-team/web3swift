//
//  BIP44Tests.swift
//  Created by Alberto Penas Amor on 15/12/22.
//

import XCTest
import Web3Core
@testable import web3swift

final class BIP44Tests: LocalTestCase {
    private var mockTransactionChecker: MockTransactionChecker!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockTransactionChecker = MockTransactionChecker()
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        mockTransactionChecker = nil
    }

    //MARK: - warns false
    
    func testDeriveNoWarn() async throws {
        let rootNode = try rootNode()
        
        let childNode = try await rootNode.derive(path: "m/44'/60'/8096'/0/1", warns: false, transactionChecker: mockTransactionChecker)
                
        XCTAssertEqual(try XCTUnwrap(childNode).publicKey.toHexString(), "035785d4918449c87892371c0f9ccf6e4eda40a7fb0f773f1254c064d3bba64026")
    }

    //MARK: - warns true
    
    func testDeriveInvalidPath() async throws {
        let rootNode = try rootNode()
        
        let childNode = try? await rootNode.derive(path: "", warns: true, transactionChecker: mockTransactionChecker)
        
        XCTAssertNil(childNode)
    }
    
    func testAccountZeroCanBeDerivedAlways() async throws {
        let rootNode = try rootNode()
        
        let childNode = try await rootNode.derive(path: "m/44'/60'/0'/0/255", warns: true, transactionChecker: mockTransactionChecker)
        
        XCTAssertEqual(try XCTUnwrap(childNode).publicKey.toHexString(), "0262fba1af8f149258123265318114066decf50d16c1222a9d657b7de2296c2734")
    }
    
    func testAccountOneWithoutTransactionsInAccountZeroWarns() async throws {
        do {
            let rootNode = try rootNode()
            let path = "m/44'/60'/1'/0/0"
            mockTransactionChecker.results = false.times(n: 20)
            
            let _ = try await rootNode.derive(path: path, warns: true, transactionChecker: mockTransactionChecker)
            
            XCTFail("Child must not be created usign warns true for the path: \(path)")
        } catch BIP44Error.warning {
            XCTAssertTrue(true)
        }
    }
    
    func testAccountOneWithTransactionsInAccountZeroNotWarns() async throws {
        do {
            let rootNode = try rootNode()
            let path = "m/44'/60'/1'/0/0"
            var results = false.times(n: 19)
            results.append(true)
            mockTransactionChecker.results = results
            
            let childNode = try await rootNode.derive(path: path, warns: true, transactionChecker: mockTransactionChecker)
            
            XCTAssertEqual(try XCTUnwrap(childNode).publicKey.toHexString(), "036cd8f1bad46fa7caf7a80d48528b90db2a3b7a5c9a18d74d61b286e03850abf4")
        } catch BIP44Error.warning {
            XCTFail("BIP44Error.warning must not be thrown")
        }
    }
    
    func testAccountTwoWithTransactionsInAccountZeroButNotInOneWarns() async throws {
        do {
            let rootNode = try rootNode()
            let path = "m/44'/60'/2'/0/0"
            var results: Array<Bool> = .init()
            results.append(true)
            results.append(contentsOf: false.times(n: 20))
            mockTransactionChecker.results = results
            
            let _ = try await rootNode.derive(path: path, warns: true, transactionChecker: mockTransactionChecker)
            
            XCTFail("Child must not be created usign warns true for the path: \(path)")
        } catch BIP44Error.warning {
            XCTAssertTrue(true)
        }
    }
    
    // MARK: - private
    
    private func rootNode() throws -> HDNode {
        let mnemonic = "fruit wave dwarf banana earth journey tattoo true farm silk olive fence"
        let seed = try XCTUnwrap(BIP39.seedFromMmemonics(mnemonic, password: ""))
        return try XCTUnwrap(HDNode(seed: seed))
    }
}

extension Bool {
    func times(n: Int) -> Array<Bool> {
        var array: Array<Bool> = .init()
        (0..<n).forEach { _ in
            array.append(self)
        }
        return array
    }
}

private final class MockTransactionChecker: TransactionChecker {
    var addresses: [String] = .init()
    var results: [Bool] = .init()
    
    func hasTransactions(address: String) async throws -> Bool {
        addresses.append(address)
        return results.removeFirst()
    }
}
