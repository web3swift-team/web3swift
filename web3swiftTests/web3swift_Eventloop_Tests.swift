//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import XCTest
import EthereumAddress

@testable import web3swift_iOS

class web3swift_Eventloop_Tests: XCTestCase {

    func testBasicEventLoop() {
        var ticksToWait = 10
        let expectation = self.expectation(description: "Waiting")
        func getBlockNumber(_ web3: web3) {
            do {
                let blockNumber = try web3.eth.getBlockNumber()
                print("Block number = " + String(blockNumber))
                ticksToWait = ticksToWait - 1
                if ticksToWait == 0 {
                    expectation.fulfill()
                }
            } catch {
                print(error)
            }
        }
        let web3main = Web3.InfuraMainnetWeb3()
        let functionToCall: web3.Eventloop.EventLoopCall = getBlockNumber
        let monitoredProperty = web3.Eventloop.MonitoredProperty.init(name: "onNewBlock", queue: web3main.requestDispatcher.queue, calledFunction: functionToCall)
        web3main.eventLoop.monitoredProperties.append(monitoredProperty)
        web3main.eventLoop.start(1)
        
        waitForExpectations(timeout: 30, handler: nil)
    }

}
