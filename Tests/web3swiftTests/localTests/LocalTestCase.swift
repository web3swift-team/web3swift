import Foundation
import XCTest
import BigInt
import Web3Core

import web3swift

// SuperClass that all local tests should be derived from
// while this class does show up in the navigator, it has no associated tests
class LocalTestCase: XCTestCase {

    static let url = URL(string: "http://127.0.0.1:8545")!
    static let keyStoreManager: KeystoreManager = KeystoreManager([try! EthereumKeystoreV3(password: "web3swift")!])

    override func setUp() async throws {
        let web3 = try! await Web3.new(LocalTestCase.url)

        let block = try await web3.eth.blockNumber()
        guard block < 25 else { return }

        let allAddresses = try! await web3.eth.ownedAccounts()
        let sendToAddress = allAddresses[0]
        let contract = web3.contract(Web3.Utils.coldWalletABI, at: sendToAddress, abiVersion: 2)
        let value = try XCTUnwrap(Utilities.parseToBigUInt("1.0", units: .ether))
        let from = allAddresses[0]
        let writeTX = contract!.createWriteOperation("fallback")!
        writeTX.transaction.from = from
        writeTX.transaction.value = value
        let policies = Policies(gasLimitPolicy: .manual(78423), gasPricePolicy: .manual(20000000000))
        for _ in block..<25 {
            _ = try! await writeTX.writeToChain(password: "", policies: policies, sendRaw: false)
        }
    }

    func deployContract(bytecode: Data, abiString: String) async throws -> TransactionReceipt {
        let web3 = try await Web3.new(LocalTestCase.url)
        let allAddresses = try await web3.eth.ownedAccounts()
        var contract = web3.contract(abiString, at: nil, abiVersion: 2)!

        let parameters: [Any] = []
        // MARK: Writing Data flow
        let deployTx = contract.prepareDeploy(bytecode: bytecode, parameters: parameters)!
        deployTx.transaction.from = allAddresses[0]
        let policies = Policies(gasLimitPolicy: .manual(3000000))
        let result = try await deployTx.writeToChain(password: "web3swift", policies: policies, sendRaw: false)
        let txHash = result.hash.stripHexPrefix()
        Thread.sleep(forTimeInterval: 1.0)
        let receipt = try await web3.eth.transactionReceipt(Data.fromHex(txHash)!)
        return receipt
    }
}
