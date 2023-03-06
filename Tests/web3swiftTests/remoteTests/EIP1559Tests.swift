//
//  EIP1559Tests.swift
//
//
//  Created by Jann Driessen on 01.11.22.
//

import XCTest
import Web3Core

@testable import web3swift

// swiftlint:disable force_unwrapping
final class EIP1559Tests: XCTestCase {

    func testEIP1159MainnetTransaction() async throws {
        let web3 = try await Web3.InfuraMainnetWeb3(accessToken: Constants.infuraToken)
        var tx = CodableTransaction(
            type: .eip1559,
            to: EthereumAddress("0xb47292B7bBedA4447564B8336E4eD1f93735e7C7")!,
            chainID: web3.provider.network!.chainID,
            value: try XCTUnwrap(Utilities.parseToBigUInt("0.1", units: .ether)),
            gasLimit: 21_000
        )
        // Vitalik's address
        tx.from = EthereumAddress("0xAb5801a7D398351b8bE11C439e05C5B3259aeC9B")!
        // Should fail if there would be something wrong with the tx
        let res = try await web3.eth.estimateGas(for: tx)
        XCTAssertGreaterThan(res, 0)
    }

    func testEIP1159GoerliTransaction() async throws {
        let web3 = try await Web3.InfuraGoerliWeb3(accessToken: Constants.infuraToken)
        var tx = CodableTransaction(
            type: .eip1559,
            to: EthereumAddress("0xeBec795c9c8bBD61FFc14A6662944748F299cAcf")!,
            chainID: web3.provider.network!.chainID,
            value: try XCTUnwrap(Utilities.parseToBigUInt("0.1", units: .ether)),
            gasLimit: 21_000
        )
        // Vitalik's address
        tx.from = EthereumAddress("0xAb5801a7D398351b8bE11C439e05C5B3259aeC9B")!
        // Should fail if there would be something wrong with the tx
        let res = try await web3.eth.estimateGas(for: tx)
        XCTAssertGreaterThan(res, 0)
    }

}
