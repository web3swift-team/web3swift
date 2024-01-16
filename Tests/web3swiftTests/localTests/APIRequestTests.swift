//
//  APIRequestTests.swift
//
//  Created by JeneaVranceanu on 09.01.2024.
//

import Foundation
import XCTest
@testable import web3swift
@testable import Web3Core

class APIRequestTests: XCTestCase {

    func testLiteralTypeParsingErrors() throws {
        do {
            let _: APIResponse<String>? = try APIRequest.initalizeLiteralTypeApiResponse(Data())
        } catch (let error) {
            XCTAssertTrue((error as! Web3Error).errorDescription!.starts(with: "Failed to decode received data as `APIResponse<String>`"))
        }
    }

}
