//
//  web3swift_numberFormattingUtil_Tests.swift
//  web3swift-iOS_Tests
//
//  Created by Антон Григорьев on 02.07.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import XCTest
import CryptoSwift
import BigInt
import Result

@testable import web3swift_iOS

class web3swift_numberFormattingUtil_Tests: XCTestCase {
    
    func testNumberFormattingUtil() {
        let balance = BigInt("-1000000000000000000")!
        let formatted = Web3.Utils.formatToPrecision(balance, numberDecimals: 18, formattingDecimals: 4, decimalSeparator: ",")
        XCTAssert(formatted == "-1")
    }
    
    func testNumberFormattingUtil2() {
        let balance = BigInt("-1000000000000000")!
        let formatted = Web3.Utils.formatToPrecision(balance, numberDecimals: 18, formattingDecimals: 4, decimalSeparator: ",")
        XCTAssert(formatted == "-0,0010")
    }
    
    func testNumberFormattingUtil3() {
        let balance = BigInt("-1000000000000")!
        let formatted = Web3.Utils.formatToPrecision(balance, numberDecimals: 18, formattingDecimals: 4, decimalSeparator: ",")
        XCTAssert(formatted == "-0,0000")
    }
    
    func testNumberFormattingUtil4() {
        let balance = BigInt("-1000000000000")!
        let formatted = Web3.Utils.formatToPrecision(balance, numberDecimals: 18, formattingDecimals: 9, decimalSeparator: ",")
        XCTAssert(formatted == "-0,000001000")
    }
    
    func testNumberFormattingUtil5() {
        let balance = BigInt("-1")!
        let formatted = Web3.Utils.formatToPrecision(balance, numberDecimals: 18, formattingDecimals: 9, decimalSeparator: ",", fallbackToScientific: true)
        XCTAssert(formatted == "-1e-18")
    }
    
    func testNumberFormattingUtil6() {
        let balance = BigInt("0")!
        let formatted = Web3.Utils.formatToPrecision(balance, numberDecimals: 18, formattingDecimals: 9, decimalSeparator: ",")
        XCTAssert(formatted == "0")
    }
    
    func testNumberFormattingUtil7() {
        let balance = BigInt("-1100000000000000000")!
        let formatted = Web3.Utils.formatToPrecision(balance, numberDecimals: 18, formattingDecimals: 4, decimalSeparator: ",")
        XCTAssert(formatted == "-1,1000")
    }
    
    func testNumberFormattingUtil8() {
        let balance = BigInt("100")!
        let formatted = Web3.Utils.formatToPrecision(balance, numberDecimals: 18, formattingDecimals: 4, decimalSeparator: ",", fallbackToScientific: true)
        XCTAssert(formatted == "1,00e-16")
    }
    
    func testNumberFormattingUtil9() {
        let balance = BigInt("1000000")!
        let formatted = Web3.Utils.formatToPrecision(balance, numberDecimals: 18, formattingDecimals: 4, decimalSeparator: ",", fallbackToScientific: true)
        XCTAssert(formatted == "1,0000e-12")
    }
    
}
