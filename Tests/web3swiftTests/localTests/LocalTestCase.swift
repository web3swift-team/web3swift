import Foundation
import XCTest
import BigInt
import Core

import web3swift

// SuperClass that all local tests should be derived from
// while this class does show up in the navigator, it has no associated tests
class LocalTestCase: XCTestCase {
    
    enum TestError: Error {
        case testError
    }

    static let url = URL(string: "http://127.0.0.1:8545")!

    override func setUp() async throws {
        let web3 = try await Web3.new(LocalTestCase.url)

        let block = try await web3.eth.blockNumber()
        if block >= 25 { return }

        print("\n ****** Preloading Ganache (\(25 - block) blocks) *****\n")

        let allAddresses = try await web3.eth.ownedAccounts()
        let sendToAddress = allAddresses[0]
        guard let contract = web3.contract(Web3.Utils.coldWalletABI, at: sendToAddress, abiVersion: 2),
            let value = Utilities.parseToBigUInt("1.0", units: .eth) else {
            throw TestError.testError
        }

        let from = allAddresses[0]
        guard let writeTX = contract.createWriteOperation("fallback") else {
            throw TestError.testError
        }
        writeTX.transaction.from = from
        writeTX.transaction.value = value
        writeTX.transaction.gasLimitPolicy = .manual(78423)
        writeTX.transaction.gasPricePolicy = .manual(20000000000)

        for _ in block..<25 {
            let _ = try await writeTX.writeToChain(password: "")
        }
    }
}
