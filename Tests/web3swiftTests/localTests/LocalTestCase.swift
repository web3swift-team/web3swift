import Foundation
import XCTest
import BigInt

import web3swift

// SuperClass that all local tests should be derived from
// while this class does show up in the navigator, it has no associated tests
class LocalTestCase: XCTestCase {
    static let url = URL.init(string: "http://127.0.0.1:8545")!
    static var isSetUp = false

    override class func setUp() {
        super.setUp()

        Task {
            // check to see if we need to run the one-time setup
            if isSetUp { return }
            isSetUp = true

            let web3 = try! await Web3.new(LocalTestCase.url)

            let block = try! await web3.eth.getBlockNumber()
            if block >= 25 { return }

            print("\n ****** Preloading Ganache (\(25 - block) blocks) *****\n")

            let allAddresses = try! await web3.eth.getAccounts()
            let sendToAddress = allAddresses[0]
            let contract = web3.contract(Web3.Utils.coldWalletABI, at: sendToAddress, abiVersion: 2)
            let value = Web3.Utils.parseToBigUInt("1.0", units: .eth)

            let from = allAddresses[0]
            let writeTX = contract!.write("fallback")!
            writeTX.transactionOptions.from = from
            writeTX.transactionOptions.value = value
            writeTX.transactionOptions.gasLimit = .manual(78423)
            writeTX.transactionOptions.gasPrice = .manual(20000000000)

            for _ in block..<25 {
                let _ = try! await writeTX.send(password: "")
            }
        }
    }
}
