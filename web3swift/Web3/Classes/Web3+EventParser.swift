//
//  Web3+TransactionIntermediate.swift
//  web3swift-iOS
//
//  Created by Alexander Vlasov on 26.02.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import enum Result.Result
import BigInt
import PromiseKit
fileprivate typealias PromiseResult = PromiseKit.Result

extension web3.web3contract {
    public struct EventParser: EventParserProtocol {

        public var contract: ContractProtocol
        public var eventName: String
        public var filter: EventFilter?
        var web3: web3
        public init? (web3 web3Instance: web3, eventName: String, contract: ContractProtocol, filter: EventFilter? = nil) {
            guard let _ = contract.allEvents.index(of: eventName) else {return nil}
            self.eventName = eventName
            self.web3 = web3Instance
            self.contract = contract
            self.filter = filter
        }
        
        public func parseBlockByNumber(_ blockNumber: UInt64) -> Result<[EventParserResultProtocol], Web3Error> {
            if self.filter != nil && (self.filter?.fromBlock != nil || self.filter?.toBlock != nil) {
                return Result([EventParserResultProtocol]())
            }
            let response = web3.eth.getBlockByNumber(blockNumber)
            switch response {
            case .success(let block):
                return parseBlock(block)
            case .failure(let error):
                return Result.failure(error)
            }
        }
        
        public func parseBlock(_ block: Block) -> Result<[EventParserResultProtocol], Web3Error> {
            guard let bloom = block.logsBloom else {return Result.failure(Web3Error.dataError)}
            if self.contract.address != nil {
                let addressPresent = block.logsBloom?.test(topic: self.contract.address!.addressData)
                if (addressPresent != true) {
                    return Result([EventParserResultProtocol]())
                }
            }
            guard let eventOfSuchTypeIsPresent = self.contract.testBloomForEventPrecence(eventName: self.eventName, bloom: bloom) else {return Result.failure(Web3Error.dataError)}
            if (!eventOfSuchTypeIsPresent) {
                return Result([EventParserResultProtocol]())
            }
            var allResults = [EventParserResultProtocol]()
            for transaction in block.transactions {
                switch transaction {
                case .null:
                    return Result.failure(Web3Error.dataError)
                case .transaction(let tx):
                    guard let hash = tx.hash else {return Result.failure(Web3Error.dataError)}
                    let subresult = parseTransactionByHash(hash)
                    switch subresult {
                    case .failure(let error):
                        return Result.failure(error)
                    case .success(let subsetOfEvents):
                        allResults += subsetOfEvents
                    }
                case .hash(let hash):
                    let subresult = parseTransactionByHash(hash)
                    switch subresult {
                    case .failure(let error):
                        return Result.failure(error)
                    case .success(let subsetOfEvents):
                        allResults += subsetOfEvents
                    }
                }
            }
            return Result(allResults)
        }
        
        public func parseTransactionByHash(_ hash: Data) -> Result<[EventParserResultProtocol], Web3Error> {
            if self.filter != nil && (self.filter?.fromBlock != nil || self.filter?.toBlock != nil) {
                return Result([EventParserResultProtocol]())
            }
            let response = web3.eth.getTransactionReceipt(hash)
            switch response {
            case .failure(let error):
                return Result.failure(error)
            case .success(let receipt):
                guard let results = parseReceiptForLogs(receipt: receipt, contract: self.contract, eventName: self.eventName, filter: self.filter) else {return Result.failure(Web3Error.dataError)}
                return Result(results)
            }
        }
        
        public func parseTransaction(_ transaction: EthereumTransaction) -> Result<[EventParserResultProtocol], Web3Error> {
            guard let hash = transaction.hash else {return Result.failure(Web3Error.dataError)}
            return self.parseTransactionByHash(hash)
        }
    }
}

extension web3.web3contract {
    public func getIndexedEvents(eventName: String?, filter: EventFilter) -> Result<[EventParserResultProtocol], Web3Error> {
        guard let rawContract = self.contract as? ContractV2 else {return Result.failure(Web3Error.nodeError("ABIv1 is not supported for this method"))}
        guard let preEncoding = encodeTopicToGetLogs(contract: rawContract, eventName: eventName, filter: filter) else {
            return Result.failure(Web3Error.dataError)
        }
        var event: ABIv2.Element.Event? = nil
        if eventName != nil {
            guard let ev = rawContract.events[eventName!] else {return Result.failure(Web3Error.dataError)}
            event = ev
        }
        let request = JSONRPCRequestFabric.prepareRequest(.getLogs, parameters: [preEncoding])
        let response = self.web3.provider.send(request: request)
        let result = ResultUnwrapper.getResponse(response)
        switch result {
        case .failure(let error):
            return Result.failure(error)
        case .success(let payload):
            if payload is NSNull {
                return Result.failure(Web3Error.nodeError("Empty response"))
            }
            guard let resultArray = payload as? [[String: AnyObject]] else {
                return Result.failure(Web3Error.dataError)
            }
            var allLogs = [EventLog]()
            for log in resultArray {
                guard let parsedLog = EventLog.init(log) else {return Result.failure(Web3Error.dataError)}
                allLogs.append(parsedLog)
            }
            if event != nil {
                let decodedLogs = allLogs.compactMap({ (log) -> EventParserResultProtocol? in
                    let (n, d) = contract.parseEvent(log)
                    guard let evName = n, let evData = d else {return nil}
                    return EventParserResult(eventName: evName, transactionReceipt: nil, contractAddress: log.address, decodedResult: evData)
                }).filter { (res:EventParserResultProtocol?) -> Bool in
                    if eventName != nil {
                        return res != nil && res?.eventName == eventName
                    } else {
                        return res != nil
                    }
                }
                var allResults = [EventParserResultProtocol]()
                allResults = decodedLogs
                return Result(allResults)
            }
            return Result([EventParserResultProtocol]())
        }
    }
}

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
                    res.transactionHash = log.transactionHash
                    return res
                }).filter{ (res:EventParserResult?) -> Bool in
                    if eventName != nil {
                        if res != nil && res?.eventName == eventName && res?.transactionHash != nil {
                            return true
                        }
                    } else {
                        if res != nil && res?.transactionHash != nil {
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
                return self.web3.eth.getTransactionReceiptPromise(singleEvent.transactionHash!).map(on: queue) { receipt in
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


