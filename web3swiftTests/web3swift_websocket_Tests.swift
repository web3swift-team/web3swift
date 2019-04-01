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

class web3swift_websocket_Tests: XCTestCase {
    
    var socketProvider: Web3SocketProvider?

    func test() {
        let provider = Web3.InfuraMainnetWeb3().provider
        guard let socketProvider = Web3SocketProvider.connectToSocket(provider, delegate: self) else {
            return XCTFail()
        }
        self.socketProvider = socketProvider
        do {
            try self.socketProvider!.subscribeOn(method: .pendingTransactions)
            sleep(1000000000)
        } catch {
            XCTFail()
        }
    }
}

extension web3swift_websocket_Tests: Web3SocketDelegate {
    func received(message: Any) {
        print("received: \(message)")
    }
}
