//
//  EIP4361Test.swift
//
//  Created by JeneaVranceanu at 21.09.2022.
//

import Foundation
import XCTest
import Core

@testable import web3swift

class EIP4361Test: XCTestCase {

    /// Parsing Sign in with Ethereum message
    func test_EIP4361Parsing() {
        let rawSiweMessage = "service.invalid wants you to sign in with your Ethereum account:\n0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2\n\nI accept the ServiceOrg Terms of Service: https://service.invalid/tos\n\nURI: https://service.invalid/login\nVersion: 1\nChain ID: 1\nNonce: 32891756\nIssued At: 2021-09-30T16:25:24.345Z\nExpiration Time: 2021-09-29T15:25:24.234Z\nNot Before: 2021-10-28T14:25:24.123Z\nRequest ID: random-request-id_STRING!@$%%&\nResources:\n- ipfs://bafybeiemxf5abjwjbikoz4mc3a3dla6ual3jsgpdr4cjr3oz3evfyavhwq/\n- https://example.com/my-web2-claim.json"
        guard let siweMessage = EIP4361(rawSiweMessage) else {
            XCTFail("Failed to parse SIWE message.")
            return
        }

        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        XCTAssertEqual(siweMessage.domain, "service.invalid")
        XCTAssertEqual(siweMessage.address, EthereumAddress("0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2")!)
        XCTAssertEqual(siweMessage.statement, "I accept the ServiceOrg Terms of Service: https://service.invalid/tos")
        XCTAssertEqual(siweMessage.uri, URL(string: "https://service.invalid/login")!)
        XCTAssertEqual(siweMessage.version, 1)
        XCTAssertEqual(siweMessage.chainId, 1)
        XCTAssertEqual(siweMessage.nonce, "32891756")
        XCTAssertEqual(siweMessage.issuedAt, dateFormatter.date(from: "2021-09-30T16:25:24.345Z")!)
        XCTAssertEqual(siweMessage.expirationTime, dateFormatter.date(from: "2021-09-29T15:25:24.234Z")!)
        XCTAssertEqual(siweMessage.notBefore, dateFormatter.date(from: "2021-10-28T14:25:24.123Z")!)
        XCTAssertEqual(siweMessage.requestId, "random-request-id_STRING!@$%%&")
        XCTAssertEqual(siweMessage.resources, [URL(string: "ipfs://bafybeiemxf5abjwjbikoz4mc3a3dla6ual3jsgpdr4cjr3oz3evfyavhwq/")!,
                                               URL(string: "https://example.com/my-web2-claim.json")!])
        XCTAssertEqual(siweMessage.description, rawSiweMessage)
    }
}
