//
//  scrypt_Tests.swift
//  web3swift-iOS_Tests
//
//  Created by Alexander Vlasov on 10.08.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import XCTest
import CryptoSwift

@testable import web3swift_iOS

class scrypt_Tests: XCTestCase {
    
    func testScrypt() {
        let password = Array("password".data(using: .ascii)!)
        let salt = Array("NaCl".data(using: .ascii)!)
        let deriver = try! Scrypt.init(password: password, salt: salt, dkLen: 64, N: 1024, r: 8, p: 16)
        let derived = try! deriver.calculate()
        let expected: [UInt8] = Array<UInt8>.init(hex: """
        fd ba be 1c 9d 34 72 00 78 56 e7 19 0d 01 e9 fe
           7c 6a d7 cb c8 23 78 30 e7 73 76 63 4b 37 31 62
           2e af 30 d9 2e 22 a3 88 6f f1 09 27 9d 98 30 da
           c7 27 af b9 4a 83 ee 6d 83 60 cb df a2 cc 06 40
""".replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\t", with: ""))
        XCTAssertEqual(derived, expected)
    }
    
    func testProfilerRun() {
        //            N: Int = 4096, R: Int = 6, P: Int = 1
        let password = Array("web3swift".data(using: .ascii)!)
        let salt = Array(Data.randomBytes(length: 32)!)
        let deriver = try! Scrypt(password: password, salt: salt, dkLen: 32, N: 4096, r: 6, p: 1)
        let _ = try! deriver.calculate()
    }
    
    func testReplacement() {
        for _ in 0 ..< 5 {
            //            N: Int = 4096, R: Int = 6, P: Int = 1
            let password = "web3swift"
            let salt = Data.randomBytes(length: 32)!
            let derivedFromLibsodium = scrypt(password: password, salt: salt, length: 32, N: 4096, R: 6, P: 1)!.bytes
            let deriver = try! Scrypt(password: Array(password.data(using: .ascii)!), salt: Array(salt), dkLen: 32, N: 4096, r: 6, p: 1)
            let derived = try! deriver.calculate()
            XCTAssertEqual(Array(derivedFromLibsodium), derived)
        }
    }
    
    func testLibsodiumPerformance() {
        let password = "web3swift"
        let salt = Data.randomBytes(length: 32)!
        self.measure {
            let _ = scrypt(password: password, salt: salt, length: 32, N: 4096, R: 6, P: 1)!.bytes
        }
    }
    
    func testNativePerformance() {
        let password = "web3swift"
        let salt = Data.randomBytes(length: 32)!
        let deriver = try! Scrypt(password: password.data(using: .ascii)!.bytes, salt: salt.bytes, dkLen: 32, N: 4096, r: 6, p: 1)
        self.measure {
            let _ = try! deriver.calculate()
        }
    }
    
}
