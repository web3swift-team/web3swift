//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import XCTest

@testable import web3swift

class web3swiftEventloopTests: LocalTestCase {

    func testBasicEventLoop() throws {
        var ticksToWait = 5
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

        let functionToCall: web3.Eventloop.EventLoopCall = getBlockNumber
        let monitoredProperty = web3.Eventloop.MonitoredProperty.init(name: "onNewBlock", queue: ganache.requestDispatcher.queue, calledFunction: functionToCall)
        ganache.eventLoop.monitoredProperties.append(monitoredProperty)
        ganache.eventLoop.start(5)

        waitForExpectations(timeout: 60, handler: nil)
    }
}
