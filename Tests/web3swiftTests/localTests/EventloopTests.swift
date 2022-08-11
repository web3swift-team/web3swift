//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import XCTest
import Core

@testable import web3swift

class EventloopTests: XCTestCase {

    func testBasicEventLoop() async throws {
        var ticksToWait = 5
        let expectation = self.expectation(description: "Waiting")
        func getBlockNumber(_ web3: web3) async {
            do {
                let blockNumber = try await web3.eth.blockNumber()
                print("Block number = " + String(blockNumber))
                ticksToWait = ticksToWait - 1
                if ticksToWait == 0 {
                    expectation.fulfill()
                }
            } catch {
                print(error)
            }
        }

        let web3main = try await Web3.new(URL.init(string: "http://127.0.0.1:8545")!)
        let functionToCall: web3.Eventloop.EventLoopCall = getBlockNumber
        let monitoredProperty = web3.Eventloop.MonitoredProperty.init(name: "onNewBlock", calledFunction: functionToCall)
        web3main.eventLoop.monitoredProperties.append(monitoredProperty)
        web3main.eventLoop.start(5)

        await waitForExpectations(timeout: 60, handler: nil)
    }
}
