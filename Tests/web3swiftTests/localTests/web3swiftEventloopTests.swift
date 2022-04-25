//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import XCTest

@testable import web3swift

class web3swiftEventloopTests: XCTestCase {
    // this is needed for any test suites that depend on the block-chain state from Ganache
    override class func setUp() {
        super.setUp()
        preloadGanache()
    }

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
        
        let web3main = try Web3.new(URL.init(string: "http://127.0.0.1:8545")!)
        let functionToCall: web3.Eventloop.EventLoopCall = getBlockNumber
        let monitoredProperty = web3.Eventloop.MonitoredProperty.init(name: "onNewBlock", queue: web3main.requestDispatcher.queue, calledFunction: functionToCall)
        web3main.eventLoop.monitoredProperties.append(monitoredProperty)
        web3main.eventLoop.start(5)
        
        waitForExpectations(timeout: 60, handler: nil)
    }
    
   // func testNonceMiddleware() throws {
   //     let web3 = try Web3.new(URL.init(string: "http://127.0.0.1:8545")!)
   //     let middleware = Web3.Utils.NonceMiddleware()
   //     middleware.attach(web3)

   //     let sendToAddress = EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901")!
   //     let ksData = getKeystoreData()
        // FIXME: Ganache crash here
   //     let tempKeystore = EthereumKeystoreV3(ksData!)
   //     let keystoreManager = KeystoreManager([tempKeystore!])
   //     web3.addKeystoreManager(keystoreManager)

   //     var tx = web3.eth.sendETH(to: sendToAddress, amount: 1000)
   //     tx!.transactionOptions.from = tempKeystore!.addresses!.first!
   //     var result = try! tx!.send(password: "web3swift")
   //     let newNonce = result.transaction.nonce
   //     sleep(1)
   //     let hookNewNonce = middleware.nonceLookups[tempKeystore!.addresses!.first!]!
   //     XCTAssertEqual(newNonce, hookNewNonce)

   //     tx = web3.eth.sendETH(to: sendToAddress, amount: 1000)
   //     tx!.transactionOptions.from = tempKeystore!.addresses!.first!
   //     result = try! tx!.send(password: "web3swift")
   //     sleep(1)
   //     let newNonce2 = result.transaction.nonce
   //     let hookNewNonce2 = middleware.nonceLookups[tempKeystore!.addresses!.first!]!
   //     XCTAssert(newNonce2 == hookNewNonce2)
   // }
   
   func getKeystoreData() -> Data? {
       let bundle = Bundle(for: type(of: self))
       guard let path = bundle.path(forResource: "key", ofType: "json") else {return nil}
       guard let data = NSData(contentsOfFile: path) else {return nil}
       return data as Data
   }
    
}
