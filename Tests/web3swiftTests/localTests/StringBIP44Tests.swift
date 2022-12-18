//
//  StringBIP44Tests.swift
//  Created by Alberto Penas Amor on 18/12/22.
//

import XCTest
@testable import Web3Core

final class StringBIP44Tests: XCTestCase {
    
    //MARK: - externalChangePath
    
    func testInvalidChangesReturnNil() throws {
        let invalidPaths = ["m/44'/60'/0'/-1/0",
                            "m/44'/60'/0'/2/0"]
        invalidPaths.forEach { invalidPath in
            XCTAssertNil(invalidPath.externalChangePath)
        }
    }
    
    func testInternalChangeReturnsExternalChangePath() throws {
        let path = "m/44'/60'/0'/1/0"
        let result = path.externalChangePath
        XCTAssertEqual(result, "m/44'/60'/0'/0/0")
    }
    
    func testExternalChangeReturnsExternalChangePath() throws {
        let path = "m/44'/60'/0'/0/0"
        let result = path.externalChangePath
        XCTAssertEqual(result, path)
    }
    
    //MARK: - isBip44Path
    
    func testVerifyBip44Paths() {
        let validPaths = ["m/44'/0'/0'/0/0",
                          "m/44'/1'/0'/0/0",
                          "m/44'/0'/1'/0/0",
                          "m/44'/0'/0'/1/0",
                          "m/44'/0'/0'/0/1"]
        validPaths.forEach { validPath in
            let result = validPath.isBip44Path
            XCTAssertTrue(result)
        }
    }
    
    func testVerifyNotBip44Paths() {
        let invalidPaths = ["",
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
        invalidPaths.forEach { invalidPath in
            let result = invalidPath.isBip44Path
            XCTAssertFalse(result)
        }
    }
}
