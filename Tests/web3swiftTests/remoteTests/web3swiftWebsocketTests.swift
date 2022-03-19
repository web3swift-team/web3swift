//
//  web3swift_websocket_Tests.swift
//  web3swift-iOS_Tests
//
//  Created by Anton on 01/04/2019.
//  Copyright © 2019 The Matter Inc. All rights reserved.
//
import XCTest
import Starscream

@testable import web3swift

class SpyDelegate: Web3SocketDelegate {

    // Setting .None is unnecessary, but helps with clarity imho
    var somethingWithDelegateResult: Any? = nil

    // Async test code needs to fulfill the XCTestExpecation used for the test
    // when all the async operations have been completed. For this reason we need
    // to store a reference to the expectation
    var asyncExpectation: XCTestExpectation?
    var fulfilled = false

    func socketConnected(_ headers: [String:String]) {
        somethingWithDelegateResult = headers
        guard let expectation = asyncExpectation else {
            XCTFail("SpyDelegate was not setup correctly. Missing XCTExpectation reference")
            return
        }
        print("socket connected, headers: \(headers)")

        if !fulfilled {
            print("fullfilled")
            fulfilled = true
            expectation.fulfill()
        }
    }

    func received(message: Any) {
        somethingWithDelegateResult = message
        guard let expectation = asyncExpectation else {
            XCTFail("SpyDelegate was not setup correctly. Missing XCTExpectation reference")
            return
        }
        print(message)
        if !fulfilled {
            print("fullfilled")
            fulfilled = true
            expectation.fulfill()
        }
    }

    func gotError(error: Error) {
        XCTFail(error.localizedDescription)
    }
}

// MARK: Works only with network connection
class web3swiftWebsocketTests: XCTestCase {
    
    let spyDelegate = SpyDelegate()
    var socketProvider: InfuraWebsocketProvider?

    func testSocketConnection(){
        guard let socketProvider = InfuraWebsocketProvider.connectToInfuraSocket(.Mainnet, delegate: spyDelegate) else {
            return XCTFail()
        }
        self.socketProvider = socketProvider

        spyDelegate.asyncExpectation = expectation(description: "Delegate called")

        waitForExpectations(timeout: 1000) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }

            guard self.spyDelegate.somethingWithDelegateResult != nil else {
                XCTFail("Expected delegate to be called")
                return
            }

            XCTAssert(true)
        }
    }

    func testSubscribeOnPendingTXs() {
        guard let socketProvider = InfuraWebsocketProvider.connectToInfuraSocket(.Mainnet, delegate: spyDelegate) else {
            return XCTFail()
        }
        self.socketProvider = socketProvider
        spyDelegate.asyncExpectation = expectation(description: "Delegate called")
        try! self.socketProvider!.subscribeOnNewPendingTransactions()
//        DispatchQueue.main.asyncAfter(deadline: .now()+5) { [unowned self] in
//            try! self.socketProvider!.subscribeOnNewPendingTransactions()
//        }
        waitForExpectations(timeout: 1000) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }

            guard self.spyDelegate.somethingWithDelegateResult != nil else {
                XCTFail("Expected delegate to be called")
                return
            }

            XCTAssert(true)
        }
    }

    func testSubscribeOnLogs() {
        guard let socketProvider = InfuraWebsocketProvider.connectToInfuraSocket(.Mainnet, delegate: spyDelegate) else {
            return XCTFail()
        }
        self.socketProvider = socketProvider
        spyDelegate.asyncExpectation = expectation(description: "Delegate called")
        try! self.socketProvider!.subscribeOnLogs(addresses: [EthereumAddress("0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48")!], topics: nil)
        //        DispatchQueue.main.asyncAfter(deadline: .now()+5) { [unowned self] in
        //            try! self.socketProvider!.subscribeOnNewPendingTransactions()
        //        }
        waitForExpectations(timeout: 1000) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }

            guard self.spyDelegate.somethingWithDelegateResult != nil else {
                XCTFail("Expected delegate to be called")
                return
            }

            XCTAssert(true)
        }
    }

    func testSubscribeOnNewHeads() {
        guard let socketProvider = InfuraWebsocketProvider.connectToInfuraSocket(.Mainnet, delegate: spyDelegate) else {
            return XCTFail()
        }
        self.socketProvider = socketProvider
        spyDelegate.asyncExpectation = expectation(description: "Delegate called")
        try! self.socketProvider!.subscribeOnNewHeads()
        //        DispatchQueue.main.asyncAfter(deadline: .now()+5) { [unowned self] in
        //            try! self.socketProvider!.subscribeOnNewPendingTransactions()
        //        }
        waitForExpectations(timeout: 1000) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }

            guard self.spyDelegate.somethingWithDelegateResult != nil else {
                XCTFail("Expected delegate to be called")
                return
            }

            XCTAssert(true)
        }
    }

    func testFilter() {
        guard let socketProvider = InfuraWebsocketProvider.connectToInfuraSocket(.Mainnet, delegate: spyDelegate) else {
            return XCTFail()
        }
        self.socketProvider = socketProvider
        spyDelegate.asyncExpectation = expectation(description: "Delegate called")
        try! self.socketProvider?.setFilterAndGetLogs(method: .newFilter, address: EthereumAddress("0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48")!, fromBlock: .earliest, toBlock: .latest, topics: nil)
        //        DispatchQueue.main.asyncAfter(deadline: .now()+5) { [unowned self] in
        //            try! self.socketProvider!.subscribeOnNewPendingTransactions()
        //        }
        waitForExpectations(timeout: 1000) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }

            guard self.spyDelegate.somethingWithDelegateResult != nil else {
                XCTFail("Expected delegate to be called")
                return
            }

            XCTAssert(true)
        }
    }
}
