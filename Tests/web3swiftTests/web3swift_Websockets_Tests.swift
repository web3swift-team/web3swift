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
class web3swift_websocket_Tests: XCTestCase, Web3SocketDelegate {
    
    var socketProvider: InfuraWebsocketProvider? = nil
    
    func testConnectingToSocketAndGettingPendingTXs() {
        socketProvider = InfuraWebsocketProvider.connectToInfuraSocket(.Mainnet, delegate: self)
        sleep(1)
        try! socketProvider!.subscribeOnNewPendingTransactions()
        sleep(2)
        XCTAssert(true)
    }
    
    func received(message: Any) {
        print(message as! String)
    }
    
    func gotError(error: Error) {
        XCTFail(error.localizedDescription)
    }
}
