////  web3swift
////
////  Created by Alex Vlasov.
////  Copyright © 2018 Alex Vlasov. All rights reserved.
////
//
//import XCTest
//
//@testable import web3swift_iOS
//
//class web3swift_ObjC_Tests: XCTestCase {
//    func testBalance() {
//        let web3 = _ObjCWeb3.InfuraMainnetWeb3()
//        let address = _ObjCEthereumAddress(address: "0xe22b8979739D724343bd002F9f432F5990879901")
//        let err: NSErrorPointer = NSErrorPointer(nilLiteral: ())
//        let balance = web3.web3Eth.getBalance(address: address, error: err)
//        XCTAssert(err?.pointee == nil)
//        XCTAssert(balance != nil)
//    }
//    
//    func testGettingBlockNumber() {
//        let web3 = _ObjCWeb3.InfuraMainnetWeb3()
//        let err: NSErrorPointer = NSErrorPointer(nilLiteral: ())
//        let blockNumber = web3.web3Eth.getBlockNumber(error: err)
//        XCTAssert(err?.pointee == nil)
//        XCTAssert(blockNumber != nil)
//        
//    }
//    
//    func testGasPrice(){
//        let web3 = _ObjCWeb3.InfuraMainnetWeb3()
//        let err: NSErrorPointer = NSErrorPointer(nilLiteral: ())
//        let gasPrice = web3.web3Eth.getGasPrice(error: err)
//        XCTAssert(err?.pointee == nil)
//        XCTAssert(gasPrice != nil)
//    }
//}
