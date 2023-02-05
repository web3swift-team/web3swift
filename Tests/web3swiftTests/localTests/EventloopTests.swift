//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import XCTest
import Web3Core

@testable import web3swift

class EventloopTests: XCTestCase {

    func testBasicEventLoop() async throws {
        var ticksToWait = 5
        let expectation = self.expectation(description: "Waiting")
        func getBlockNumber(_ web3: Web3) async {
            do {
                let blockNumber = try await web3.eth.blockNumber()
                ticksToWait = ticksToWait - 1
                if ticksToWait == 0 {
                    expectation.fulfill()
                }
            } catch {

            }
        }

        let web3main = try await Web3.new(LocalTestCase.url)
        let functionToCall: Web3.Eventloop.EventLoopCall = getBlockNumber
        let monitoredProperty = Web3.Eventloop.MonitoredProperty.init(name: "onNewBlock", calledFunction: functionToCall)
        web3main.eventLoop.monitoredProperties.append(monitoredProperty)
        web3main.eventLoop.start(5)

        await waitForExpectations(timeout: 60, handler: nil)
    }
}
