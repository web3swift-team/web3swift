//
//  Promise+Web3+Contract+GetIndexedEvents.swift
//  web3swift-iOS
//
//  Created by Alexander Vlasov on 18.06.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import PromiseKit

extension web3.web3contract {
    public func getIndexedEventsPromise(eventName: String?, filter: EventFilter, joinWithReceipts: Bool = false) -> Promise<[EventParserResultProtocol]> {
        let queue = self.web3.requestDispatcher.queue
        do {
            guard let rawContract = self.contract as? ContractV2 else {
                throw Web3Error.nodeError("ABIv1 is not supported for this method")
            }
            guard let preEncoding = encodeTopicToGetLogs(contract: rawContract, eventName: eventName, filter: filter) else {
                throw Web3Error.processingError("Failed to encode topic for request")
            }
            //            var event: ABIv2.Element.Event? = nil
            if eventName != nil {
                guard let _ = rawContract.events[eventName!] else {
                    throw Web3Error.processingError("No such event in a contract")
                }
                //                event = ev
            }
            let request = JSONRPCRequestFabric.prepareRequest(.getLogs, parameters: [preEncoding])
            let fetchLogsPromise = self.web3.dispatch(request).map(on: queue) {response throws -> [EventParserResult] in
                guard let value: [EventLog] = response.getValue() else {
                    throw Web3Error.nodeError("Empty or malformed response")
                }
                let allLogs = value
                let decodedLogs = allLogs.compactMap({ (log) -> EventParserResult? in
                    let (n, d) = self.contract.parseEvent(log)
                    guard let evName = n, let evData = d else {return nil}
                    var res = EventParserResult(eventName: evName, transactionReceipt: nil, contractAddress: log.address, decodedResult: evData)
                    res.eventLog = log
                    return res
                }).filter{ (res:EventParserResult?) -> Bool in
                    if eventName != nil {
                        if res != nil && res?.eventName == eventName && res!.eventLog != nil {
                            return true
                        }
                    } else {
                        if res != nil && res!.eventLog != nil {
                            return true
                        }
                    }
                    return false
                }
                return decodedLogs
            }
            if (!joinWithReceipts) {
                return fetchLogsPromise.mapValues(on: queue) {res -> EventParserResultProtocol in
                    return res as EventParserResultProtocol
                }
            }
            return fetchLogsPromise.thenMap(on:queue) {singleEvent in
                return self.web3.eth.getTransactionReceiptPromise(singleEvent.eventLog!.transactionHash).map(on: queue) { receipt in
                    var joinedEvent = singleEvent
                    joinedEvent.transactionReceipt = receipt
                    return joinedEvent as EventParserResultProtocol
                }
            }
        } catch {
            let returnPromise = Promise<[EventParserResultProtocol]>.pending()
            queue.async {
                returnPromise.resolver.reject(error)
            }
            return returnPromise.promise
        }
    }
}
