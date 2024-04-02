//
//  Web3ErrorTests.swift
//
//  Created by JeneaVranceanu on 11.11.2022.
//

import XCTest
import Foundation
@testable import Web3Core

class Web3ErrorTests: XCTestCase {

    func testWeb3ErrorReturnsExpectedDescription() {
        let emojis = ["🚀", "👋", "🥇", "☑️"]
        let message = "This is a custom description for test case! web3swift \(emojis.randomElement()!)"

        /// It's important that we represent `Web3Error` as a generic `Error`!
        /// This is intentional as in `do-catch` block we do not receive `Web3Error`
        /// but `Error` type instead that can be casted.
        let error: Error = Web3Error.inputError(desc: message)
        XCTAssertEqual(error.localizedDescription, message)
    }

}
