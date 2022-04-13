////  web3swift
////
////  Created by Alex Vlasov.
////  Copyright © 2018 Alex Vlasov. All rights reserved.
////
//
//import XCTest
//
//@testable import web3swift
//
//class web3swiftEventloopTests: XCTestCase {
//
//    func testBasicEventLoop() async throws {
//        let expectation = self.expectation(description: "Waiting")
//        @Sendable func getBlockNumber(_ web3: web3) async {
//            do {
//                let blockNumber = try await web3.eth.getBlockNumber()
//                print("Block number = " + String(blockNumber))
//                expectation.fulfill()
//            } catch {
//                print(error)
//            }
//        }
//
//        let web3main = try await Web3.new(URL.init(string: "http://127.0.0.1:8545")!)
//        async let functionToCall: web3.Eventloop.EventLoopCall = getBlockNumber
//        let monitoredProperty = await web3.Eventloop.MonitoredProperty.init(name: "onNewBlock", calledFunction: functionToCall)
//        web3main.eventLoop.monitoredProperties.append(monitoredProperty)
//        web3main.eventLoop.start(5)
//
//        await waitForExpectations(timeout: 60, handler: nil)
//    }
//
//   func getKeystoreData() -> Data? {
//       let bundle = Bundle(for: type(of: self))
//       guard let path = bundle.path(forResource: "key", ofType: "json") else {return nil}
//       guard let data = NSData(contentsOfFile: path) else {return nil}
//       return data as Data
//   }
//
//}
