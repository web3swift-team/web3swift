import Foundation
import XCTest
import BigInt

@testable import web3swift

// Dummy Test-suite
// used to generate 25 blocks on the Ganache blockchain so that our localTests can run properly
// this only needs to be run once on a clean Ganache environment
// if you save the Ganache state after running this once, you never need to run it agan
// just reset Ganache to that state instead of a new clean start
class GanacheGenerator: XCTestCase {
    static let url = URL.init(string: "http://127.0.0.1:8545")!

    func testGenerateData() throws {

        let web3 = try! Web3.new(GanacheGenerator.url)

        let block = try! web3.eth.getBlockNumber()
        if block >= 25 { return }

        print("\n ****** Preloading Ganache (\(25 - block) blocks) *****\n")

        let allAddresses = try! web3.eth.getAccounts()
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
            let result = try! writeTX.sendPromise(password: "").wait()

            let txHash = result.hash
            print("Transaction with hash " + txHash)

            Thread.sleep(forTimeInterval: 1.0)

            let receipt = try web3.eth.getTransactionReceipt(txHash)
            print(receipt)
            XCTAssert(receipt.status == .ok)

        }

        print("\n***** Ganache has been initialized, you can now run the local tests *****\n")

    }


}
