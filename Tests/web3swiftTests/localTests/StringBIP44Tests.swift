//
//  StringBIP44Tests.swift
//  Created by Alberto Penas Amor on 18/12/22.
//

import XCTest
@testable import Web3Core

final class StringBIP44Tests: XCTestCase {
    private var invalidPaths: [String] {
        [
            "",
            "m",
            "m/",
            "m/44",
            "m/44'",
            "m/44'/",
            "m/44'/60",
            "m/44'/60'",
            "m/44'/60'/",
            "m/44'/60'/0",
            "m/44'/60'/0'",
            "m/44'/60'/0'/",
            "m/44'/60'/0'/0",
            "m/44'/60'/0'/0/",
            "/44'/60'/0'/0/0",
            "m44'/60'/0'/0/0",
            "m0'/60'/0'/0/0",
            "m/'/60'/0'/0/0",
            "m/60'/0'/0/0",
            "m/44'/60/0'/0/0",
            "m/44'/'/0'/0/0",
            "m/44'/60'/0/0/0",
            "m/44'/60'/'/0/0",
            "m/44'/60'/0'/0",
            "m/44'/60'/0'/0/",
            "m/44'/60'/0'/-1/0",
            "m/44'/60'/0'/2/0",
            "m/44'/60.0'/0'/0/0",
            "m/44'/60'/0.0'/0/0",
            "m/44'/60'/0'/0/0.0"]
    }

    // MARK: - accountFromPath

    func testInvalidPathReturnNilAccount() throws {
        invalidPaths.forEach { invalidPath in
            XCTAssertNil(invalidPath.accountFromPath)
        }
    }

    func testValidPathReturnAccount() {
        let scenarios: [TestScenario<String, Int>] = [
            .init(input: "m/44'/60'/0'/1/4", expected: 0),
            .init(input: "m/44'/60'/1'/0/3", expected: 1),
            .init(input: "m/44'/60'/2'/0/2", expected: 2),
            .init(input: "m/44'/60'/3'/0/1", expected: 3),
            .init(input: "m/44'/60'/4'/0/0", expected: 4)]
        scenarios.forEach { scenario in
            XCTAssertEqual(scenario.input.accountFromPath, scenario.expected)
        }
    }

    // MARK: - isBip44Path

    func testVerifyBip44Paths() {
        let validPaths = [
            "m/44'/0'/0'/0/0",
            "m/44'/1'/0'/0/0",
            "m/44'/0'/1'/0/0",
            "m/44'/0'/0'/1/0",
            "m/44'/0'/0'/0/1"]
        validPaths.forEach { validPath in
            XCTAssertTrue(validPath.isBip44Path)
        }
    }

    func testVerifyNotBip44Paths() {
        invalidPaths.forEach { invalidPath in
            XCTAssertFalse(invalidPath.isBip44Path)
        }
    }

    // MARK: - newPath

    func testNotBip44PathNewPathReturnsNil() {
        invalidPaths.forEach { invalidPath in
            XCTAssertNil(invalidPath.newPath(account: Int.random(in: 0...Int.max), addressIndex: Int.random(in: 0...Int.max)))
        }
    }

    func testNewPathGeneratesExternalChainAsZero() {
        let path = "m/44'/60'/0'/1/0"

        let result = path.newPath(account: 0, addressIndex: 0)

        XCTAssertEqual(result, "m/44'/60'/0'/0/0")
    }

    func testNewPathGeneratesNewAccountAndAddressIndex() {
        let path = "m/44'/60'/1'/0/2"

        let result = path.newPath(account: 4, addressIndex: 3)

        XCTAssertEqual(result, "m/44'/60'/4'/0/3")
    }
}

struct TestScenario<I, E> {
    let input: I
    let expected: E
}
