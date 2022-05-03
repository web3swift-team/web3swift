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

    func gotError(error: Error) {
        XCTFail(error.localizedDescription)
    }
}

// MARK: Works only with network connection
class WebsocketTests: XCTestCase {

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

    // FIXME: Occasionally fails on ci/cd
//    func testSubscribeOnNewHeads() throws {
//        spyDelegate.asyncExpectation = expectation(description: "Delegate called")
//        let eventExpectation = expectation(description: "eventExpectation")
//        guard let socketProvider = InfuraWebsocketProvider.connectToInfuraSocket(.Mainnet, delegate: spyDelegate) else {
//            return XCTFail()
//        }
//        let eth = web3(provider: socketProvider).eth
//        var eventExpectationFulfilled = false
//        let subscription = try eth.subscribeOnNewHeads { result in
//            _ = try! result.get()
//            if !eventExpectationFulfilled {
//                eventExpectation.fulfill()
//                eventExpectationFulfilled = true
//            }
//        }
//        waitForExpectations(timeout: 1000) { error in
//            if let error = error {
//                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
//            }
//
//            guard self.spyDelegate.somethingWithDelegateResult != nil else {
//                XCTFail("Expected delegate to be called")
//                return
//            }
//
//            XCTAssert(true)
//        }
//        subscription.unsubscribe()
//    }

    // FIXME: Occasionally fails on ci/cd
//    func testSubscribeOnLogs() throws {
//        spyDelegate.asyncExpectation = expectation(description: "Delegate called")
//        let eventExpectation = expectation(description: "eventExpectation")
//        guard let socketProvider = InfuraWebsocketProvider.connectToInfuraSocket(.Mainnet, delegate: spyDelegate) else {
//            return XCTFail()
//        }
//        let eth = web3(provider: socketProvider).eth
//        var eventExpectationFulfilled = false
//        let subscription = try eth.subscribeOnLogs { result in
//            _ = try! result.get()
//            if !eventExpectationFulfilled {
//                eventExpectation.fulfill()
//                eventExpectationFulfilled = true
//            }
//        }
//        waitForExpectations(timeout: 1000) { error in
//            if let error = error {
//                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
//            }
//
//            guard self.spyDelegate.somethingWithDelegateResult != nil else {
//                XCTFail("Expected delegate to be called")
//                return
//            }
//
//            XCTAssert(true)
//        }
//        subscription.unsubscribe()
//    }

    // FIXME: Occasionally fails on ci/cd
//    func testSubscribeOnNewPendingTransactions() throws {
//        spyDelegate.asyncExpectation = expectation(description: "Delegate called")
//        let eventExpectation = expectation(description: "eventExpectation")
//        guard let socketProvider = InfuraWebsocketProvider.connectToInfuraSocket(.Mainnet, delegate: spyDelegate) else {
//            return XCTFail()
//        }
//        let eth = web3(provider: socketProvider).eth
//        var eventExpectationFulfilled = false
//        let subscription = try eth.subscribeOnNewPendingTransactions { result in
//            _ = try! result.get()
//            if !eventExpectationFulfilled {
//                eventExpectation.fulfill()
//                eventExpectationFulfilled = true
//            }
//        }
//        waitForExpectations(timeout: 1000) { error in
//            if let error = error {
//                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
//            }
//
//            guard self.spyDelegate.somethingWithDelegateResult != nil else {
//                XCTFail("Expected delegate to be called")
//                return
//            }
//
//            XCTAssert(true)
//        }
//        subscription.unsubscribe()
//    }

    // FIXME: Occasionally fails on ci/cd
//    func testSubscribeOnSyncing() throws {
//        spyDelegate.asyncExpectation = expectation(description: "Delegate called")
//        guard let socketProvider = InfuraWebsocketProvider.connectToInfuraSocket(.Mainnet, delegate: spyDelegate) else {
//            return XCTFail()
//        }
//        let eth = web3(provider: socketProvider).eth
//        let subscription = try eth.subscribeOnSyncing { result in
//            _ = try! result.get()
//        }
//        waitForExpectations(timeout: 1000) { error in
//            if let error = error {
//                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
//            }
//
//            guard self.spyDelegate.somethingWithDelegateResult != nil else {
//                XCTFail("Expected delegate to be called")
//                return
//            }
//
//            XCTAssert(true)
//        }
//        subscription.unsubscribe()
//    }
}
