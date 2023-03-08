//
//  EIP4361Test.swift
//
//  Created by JeneaVranceanu at 21.09.2022.
//

import Foundation
import XCTest
import Web3Core

@testable import web3swift

class EIP4361Test: XCTestCase {

    /// Parsing Sign in with Ethereum message
    func testEIP4361Parsing() {
        let rawSiweMessage = "service.invalid wants you to sign in with your Ethereum account:\n0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2\n\nI accept the ServiceOrg Terms of Service: https://service.invalid/tos\n\nURI: https://service.invalid/login\nVersion: 1\nChain ID: 1\nNonce: 32891756\nIssued At: 2021-09-30T16:25:24.345Z\nExpiration Time: 2021-09-29T15:25:24.234Z\nNot Before: 2021-10-28T14:25:24.123Z\nRequest ID: random-0123456789abcdefrequest-id_STRING-._~:@!$&\'()*+,;=\nResources:\n- ipfs://bafybeiemxf5abjwjbikoz4mc3a3dla6ual3jsgpdr4cjr3oz3evfyavhwq/\n- https://example.com/my-web2-claim.json"
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
        XCTAssertEqual(siweMessage.requestId, "random-0123456789abcdefrequest-id_STRING-._~:@!$&\'()*+,;=")
        XCTAssertEqual(siweMessage.resources, [URL(string: "ipfs://bafybeiemxf5abjwjbikoz4mc3a3dla6ual3jsgpdr4cjr3oz3evfyavhwq/")!,
                                               URL(string: "https://example.com/my-web2-claim.json")!])
        XCTAssertEqual(siweMessage.description, rawSiweMessage)
    }

    func testEIP4361StaticValidationFunc() {
        let rawSiweMessage = "service.invalid wants you to sign in with your Ethereum account:\n0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2\n\nI accept the ServiceOrg Terms of Service: https://service.invalid/tos\n\nURI: https://service.invalid/login\nVersion: 1\nChain ID: 1\nNonce: 32891756\nIssued At: 2021-09-30T16:25:24.345Z\nExpiration Time: 2021-09-29T15:25:24.234Z\nNot Before: 2021-10-28T14:25:24.123Z\nRequest ID: random-0123456789abcdefrequest-id_STRING-._~:@!$&\'()*+,;=\nResources:\n- ipfs://bafybeiemxf5abjwjbikoz4mc3a3dla6ual3jsgpdr4cjr3oz3evfyavhwq/\n- https://example.com/my-web2-claim.json"

        let validationResponse = EIP4361.validate(rawSiweMessage)

        guard validationResponse.isValid else {
            XCTFail("Failed to parse SIWE message.")
            return
        }

        let siweMessage = validationResponse.eip4361!

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
        XCTAssertEqual(siweMessage.requestId, "random-0123456789abcdefrequest-id_STRING-._~:@!$&\'()*+,;=")
        XCTAssertEqual(siweMessage.resources, [URL(string: "ipfs://bafybeiemxf5abjwjbikoz4mc3a3dla6ual3jsgpdr4cjr3oz3evfyavhwq/")!,
                                               URL(string: "https://example.com/my-web2-claim.json")!])
        XCTAssertEqual(siweMessage.description, rawSiweMessage)
    }

    func testValidEIP4361NoOptionalFields() {
        let rawSiweMessage = "service.invalid wants you to sign in with your Ethereum account:\n0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2\n\nI accept the ServiceOrg Terms of Service: https://service.invalid/tos\n\nURI: https://service.invalid/login\nVersion: 1\nChain ID: 1\nNonce: 32891756\nIssued At: 2021-09-30T16:25:24.345Z"

        let validationResponse = EIP4361.validate(rawSiweMessage)
        guard validationResponse.isValid else {
            XCTFail("Failed to parse valid SIWE message.")
            return
        }

        XCTAssertNotNil(validationResponse.eip4361)
        XCTAssertNil(validationResponse.capturedFields[.expirationTime])
        XCTAssertNil(validationResponse.capturedFields[.notBefore])
        XCTAssertNil(validationResponse.capturedFields[.requestId])
        XCTAssertNil(validationResponse.capturedFields[.resources])
    }

    func testInvalidEIP4361MissingDomain() {
        let rawSiweMessage = "wants you to sign in with your Ethereum account:\n0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2\n\nI accept the ServiceOrg Terms of Service: https://service.invalid/tos\n\nURI: https://service.invalid/login\nVersion: 1\nChain ID: 1\nNonce: 32891756\nIssued At: 2021-09-30T16:25:24.345Z"

        let validationResponse = EIP4361.validate(rawSiweMessage)
        guard !validationResponse.isValid else {
            XCTFail("Failed to parse valid SIWE message.")
            return
        }

        XCTAssertNil(validationResponse.eip4361)
        XCTAssertNil(validationResponse.capturedFields[.domain])
    }

    func testInvalidEIP4361MissingAddress() {
        let rawSiweMessage = "service.invalid wants you to sign in with your Ethereum account:\nI accept the ServiceOrg Terms of Service: https://service.invalid/tos\n\nURI: https://service.invalid/login\nVersion: 1\nChain ID: 1\nNonce: 32891756\nIssued At: 2021-09-30T16:25:24.345Z\nExpiration Time: 2021-09-29T15:25:24.234Z\nNot Before: 2021-10-28T14:25:24.123Z\nRequest ID: random-0123456789abcdefrequest-id_STRING-._~:@!$&\'()*+,;=\nResources:\n- ipfs://bafybeiemxf5abjwjbikoz4mc3a3dla6ual3jsgpdr4cjr3oz3evfyavhwq/\n- https://example.com/my-web2-claim.json"

        let validationResponse = EIP4361.validate(rawSiweMessage)
        guard validationResponse.isEIP4361 && !validationResponse.isValid else {
            XCTFail("Failed to parse SIWE message. isEIP4361 must be `true` but the SIWE must be invalid.")
            return
        }

        XCTAssertNil(validationResponse.capturedFields[.address])
    }

    func testInvalidEIP4361MissingUri() {
        let rawSiweMessage = "service.invalid wants you to sign in with your Ethereum account:\n0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2\n\nI accept the ServiceOrg Terms of Service: https://service.invalid/tos\n\nVersion: 1\nChain ID: 1\nNonce: 32891756\nIssued At: 2021-09-30T16:25:24.345Z\nExpiration Time: 2021-09-29T15:25:24.234Z\nNot Before: 2021-10-28T14:25:24.123Z\nRequest ID: random-0123456789abcdefrequest-id_STRING-._~:@!$&\'()*+,;=\nResources:\n- ipfs://bafybeiemxf5abjwjbikoz4mc3a3dla6ual3jsgpdr4cjr3oz3evfyavhwq/\n- https://example.com/my-web2-claim.json"

        let validationResponse = EIP4361.validate(rawSiweMessage)
        guard validationResponse.isEIP4361 && !validationResponse.isValid else {
            XCTFail("Failed to parse SIWE message. isEIP4361 must be `true` but the SIWE must be invalid.")
            return
        }

        XCTAssertNil(validationResponse.capturedFields[.uri])
    }

    func testInvalidEIP4361MissingVersion() {
        let rawSiweMessage = "service.invalid wants you to sign in with your Ethereum account:\n0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2\n\nI accept the ServiceOrg Terms of Service: https://service.invalid/tos\n\nURI: https://service.invalid/login\nChain ID: 1\nNonce: 32891756\nIssued At: 2021-09-30T16:25:24.345Z\nExpiration Time: 2021-09-29T15:25:24.234Z\nNot Before: 2021-10-28T14:25:24.123Z\nRequest ID: random-0123456789abcdefrequest-id_STRING-._~:@!$&\'()*+,;=\nResources:\n- ipfs://bafybeiemxf5abjwjbikoz4mc3a3dla6ual3jsgpdr4cjr3oz3evfyavhwq/\n- https://example.com/my-web2-claim.json"

        let validationResponse = EIP4361.validate(rawSiweMessage)
        guard validationResponse.isEIP4361 && !validationResponse.isValid else {
            XCTFail("Failed to parse SIWE message. isEIP4361 must be `true` but the SIWE must be invalid.")
            return
        }

        XCTAssertNil(validationResponse.capturedFields[.version])
    }

    func testInvalidEIP4361MissingChainId() {
        let rawSiweMessage = "service.invalid wants you to sign in with your Ethereum account:\n0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2\n\nI accept the ServiceOrg Terms of Service: https://service.invalid/tos\n\nURI: https://service.invalid/login\nVersion: 1\nNonce: 32891756\nIssued At: 2021-09-30T16:25:24.345Z\nExpiration Time: 2021-09-29T15:25:24.234Z\nNot Before: 2021-10-28T14:25:24.123Z\nRequest ID: random-0123456789abcdefrequest-id_STRING-._~:@!$&\'()*+,;=\nResources:\n- ipfs://bafybeiemxf5abjwjbikoz4mc3a3dla6ual3jsgpdr4cjr3oz3evfyavhwq/\n- https://example.com/my-web2-claim.json"

        let validationResponse = EIP4361.validate(rawSiweMessage)
        guard validationResponse.isEIP4361 && !validationResponse.isValid else {
            XCTFail("Failed to parse SIWE message. isEIP4361 must be `true` but the SIWE must be invalid.")
            return
        }

        XCTAssertNil(validationResponse.capturedFields[.chainId])
    }

    func testInvalidEIP4361MissingNonce() {
        let rawSiweMessage = "service.invalid wants you to sign in with your Ethereum account:\n0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2\n\nI accept the ServiceOrg Terms of Service: https://service.invalid/tos\n\nURI: https://service.invalid/login\nVersion: 1\nChain ID: 1\nIssued At: 2021-09-30T16:25:24.345Z\nExpiration Time: 2021-09-29T15:25:24.234Z\nNot Before: 2021-10-28T14:25:24.123Z\nRequest ID: random-0123456789abcdefrequest-id_STRING-._~:@!$&\'()*+,;=\nResources:\n- ipfs://bafybeiemxf5abjwjbikoz4mc3a3dla6ual3jsgpdr4cjr3oz3evfyavhwq/\n- https://example.com/my-web2-claim.json"

        let validationResponse = EIP4361.validate(rawSiweMessage)
        guard validationResponse.isEIP4361 && !validationResponse.isValid else {
            XCTFail("Failed to parse SIWE message. isEIP4361 must be `true` but the SIWE must be invalid.")
            return
        }

        XCTAssertNil(validationResponse.capturedFields[.nonce])
    }

    func testInvalidEIP4361MissingIssuedAt() {
        let rawSiweMessage = "service.invalid wants you to sign in with your Ethereum account:\n0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2\n\nI accept the ServiceOrg Terms of Service: https://service.invalid/tos\n\nURI: https://service.invalid/login\nVersion: 1\nChain ID: 1\nNonce: 32891756\nExpiration Time: 2021-09-29T15:25:24.234Z\nNot Before: 2021-10-28T14:25:24.123Z\nRequest ID: random-0123456789abcdefrequest-id_STRING-._~:@!$&\'()*+,;=\nResources:\n- ipfs://bafybeiemxf5abjwjbikoz4mc3a3dla6ual3jsgpdr4cjr3oz3evfyavhwq/\n- https://example.com/my-web2-claim.json"

        let validationResponse = EIP4361.validate(rawSiweMessage)
        guard validationResponse.isEIP4361 && !validationResponse.isValid else {
            XCTFail("Failed to parse SIWE message. isEIP4361 must be `true` but the SIWE must be invalid.")
            return
        }

        XCTAssertNil(validationResponse.capturedFields[.issuedAt])
    }

    func testInvalidEIP4361WrongVersionNumber() {
        let rawSiweMessage = "service.invalid wants you to sign in with your Ethereum account:\n0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2\n\nI accept the ServiceOrg Terms of Service: https://service.invalid/tos\n\nURI: https://service.invalid/login\nVersion: 123\nChain ID: 1\nNonce: 32891756\nIssued At: 2021-09-30T16:25:24.345Z\nExpiration Time: 2021-09-29T15:25:24.234Z\nNot Before: 2021-10-28T14:25:24.123Z\nRequest ID: random-0123456789abcdefrequest-id_STRING-._~:@!$&\'()*+,;=\nResources:\n- ipfs://bafybeiemxf5abjwjbikoz4mc3a3dla6ual3jsgpdr4cjr3oz3evfyavhwq/\n- https://example.com/my-web2-claim.json"

        let validationResponse = EIP4361.validate(rawSiweMessage)
        guard validationResponse.isEIP4361 && !validationResponse.isValid else {
            XCTFail("Failed to parse SIWE message. isEIP4361 must be `true` but the SIWE must be invalid.")
            return
        }

        XCTAssertEqual(validationResponse.capturedFields[.version], "123")
    }

    func testInvalidEIP4361WrongCharInDomain() {
        let rawSiweMessage = "service.invalid/ wants you to sign in with your Ethereum account:\n0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2\n\nI accept the ServiceOrg Terms of Service: https://service.invalid/tos\n\nURI: https://service.invalid/login\nVersion: 1\nChain ID: 1\nNonce: 32891756\nIssued At: 2021-09-30T16:25:24.345Z"

        let validationResponse = EIP4361.validate(rawSiweMessage)
        guard !validationResponse.isValid else {
            XCTFail("Failed to parse valid SIWE message.")
            return
        }

        XCTAssertNil(validationResponse.eip4361)
        XCTAssertEqual(validationResponse.capturedFields[.domain], "service.invalid/")
    }

    func testInvalidEIP4361AllRequiredFieldsContainWrongData() {
        let rawSiweMessage = "service.invalid/path wants you to sign in with your Ethereum account:\nnot-a-hex-1234567890qwertyuiop1234567890qwertyuiop\n\nTHESTATEMENT123102938102938: aURIisSupposedToBeHEre\n\nURI: ANOTHER_URIisSupposedToBeHEre\nVersion: dsfjlsdafhjalsdfjh\nChain ID: not-a-chain-id\nNonce: not a nonce\nIssued At: this-is-not-a-date\nExpiration Time: expiration-time-not-a-date\nNot Before: not-before-not-a-date\nRequest ID: %%%%random-0123456789abcdefrequest-id_STRING-._~:@!$&\'()*+,;=\nResources:noURLSreallyHERE"

        let validationResponse = EIP4361.validate(rawSiweMessage)
        guard validationResponse.isEIP4361 && !validationResponse.isValid else {
            XCTFail("Must not be able to parse this SIWE message.")
            return
        }

        XCTAssertEqual(validationResponse.capturedFields[.domain], "service.invalid/path")
        XCTAssertEqual(validationResponse.capturedFields[.address], "not-a-hex-1234567890qwertyuiop1234567890qwertyuiop")
        XCTAssertEqual(validationResponse.capturedFields[.statement], "THESTATEMENT123102938102938: aURIisSupposedToBeHEre")
        XCTAssertEqual(validationResponse.capturedFields[.uri], "ANOTHER_URIisSupposedToBeHEre")
        XCTAssertEqual(validationResponse.capturedFields[.version], "dsfjlsdafhjalsdfjh")
        XCTAssertEqual(validationResponse.capturedFields[.chainId], "not-a-chain-id")
        XCTAssertEqual(validationResponse.capturedFields[.nonce], "not a nonce")
        XCTAssertEqual(validationResponse.capturedFields[.issuedAt], "this-is-not-a-date")
        XCTAssertEqual(validationResponse.capturedFields[.expirationTime], "expiration-time-not-a-date")
        XCTAssertEqual(validationResponse.capturedFields[.notBefore], "not-before-not-a-date")
        XCTAssertEqual(validationResponse.capturedFields[.requestId], "%%%%random-0123456789abcdefrequest-id_STRING-._~:@!$&\'()*+,;=")
        XCTAssertEqual(validationResponse.capturedFields[.resources], "noURLSreallyHERE")
    }
}
