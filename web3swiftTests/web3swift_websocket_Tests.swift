//
//  web3swift_websocket_Tests.swift
//  web3swift-iOS_Tests
//
//  Created by Anton on 01/04/2019.
//  Copyright © 2019 The Matter Inc. All rights reserved.
//

import XCTest
import Starscream

@testable import web3swift_iOS

class SpyDelegate: Web3SocketDelegate {
    
    // Setting .None is unnecessary, but helps with clarity imho
    var somethingWithDelegateResult: String? = nil
    
    // Async test code needs to fulfill the XCTestExpecation used for the test
    // when all the async operations have been completed. For this reason we need
    // to store a reference to the expectation
    var asyncExpectation: XCTestExpectation?
    
    func received(message: Any) {
        guard let expectation = asyncExpectation else {
            XCTFail("SpyDelegate was not setup correctly. Missing XCTExpectation reference")
            return
        }
        
        print(message as? String)
        expectation.fulfill()
    }
    
    func gotError(error: Error) {
        XCTFail(error.localizedDescription)
    }
}

class web3swift_websocket_Tests: XCTestCase {
    
    let spyDelegate = SpyDelegate()
    var socketProvider: InfuraWebsocketProvider?

    func testSubscribeOnPendingTXs() {
        guard let socketProvider = InfuraWebsocketProvider.connectToSocket(.Mainnet, delegate: spyDelegate) else {
            return XCTFail()
        }
        spyDelegate.asyncExpectation = expectation(description: "Delegate called")
        try! socketProvider.filter(method: .newPendingTransactionFilter)
        
        waitForExpectations(timeout: 100000) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
            
            guard let result = self.spyDelegate.somethingWithDelegateResult else {
                XCTFail("Expected delegate to be called")
                return
            }
            print(result)
            
            XCTAssert(true)
        }
    }
}
