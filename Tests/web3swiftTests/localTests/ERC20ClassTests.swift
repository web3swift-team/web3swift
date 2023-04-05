//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import XCTest
import Web3Core

@testable import web3swift

class ERC20ClassTests: LocalTestCase {

    func testERC20TokenCreation() async throws {
        let (web3, _, receipt, _) = try await TestHelpers.localDeployERC20()
        func testRun() async throws {
            let erc20token = ERC20(web3: web3, provider: web3.provider, address: receipt.contractAddress!)
            // All async reads happen in readProperties
            try await erc20token.readProperties()
            XCTAssertEqual(erc20token.symbol, "w3s")
            XCTAssertEqual(erc20token.name, "web3swift")
            XCTAssertEqual(erc20token.decimals, 18)
        }
        /// We had an issue with multiple async reads performed at the same point in time
        /// sometimes returning wrong values (actually values of each other).
        /// The issue is most likely related to async/await feature of Swift.
        /// Due to that was decided to add a loop to execute the same async calls that checks the same ERC20 properties
        /// multiple times. All calls must succeed.
        /// Each run executes 3 async read operations.
        /// DO NOT REMOVE THE LOOP!
        for _ in 0...100 {
            do {
                try await testRun()
            } catch {
                XCTFail("Failed to validate ERC20 fields due to an error: \(error.localizedDescription)")
                break
            }
        }
    }

    func testERC20tokenBalanceAndAllowance() async throws {
        let (web3, _, receipt, _) = try await TestHelpers.localDeployERC20()
        let erc20token = ERC20(web3: web3, provider: web3.provider, address: receipt.contractAddress!)

        let userAddress = EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901")!

        let balance = try await erc20token.getBalance(account: userAddress)
        let allowance = try await erc20token.getAllowance(originalOwner: userAddress, delegate: userAddress)
        XCTAssert(String(balance) == "1024")
        XCTAssert(allowance == 0)
    }
}
