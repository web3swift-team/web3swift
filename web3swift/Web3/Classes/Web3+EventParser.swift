//
//  Web3+TransactionIntermediate.swift
//  web3swift-iOS
//
//  Created by Alexander Vlasov on 26.02.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import Result
import BigInt

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
                guard let bloom = receipt.logsBloom else {return Result.failure(Web3Error.dataError)}
                if self.contract.address != nil {
                    let addressPresent = bloom.test(topic: self.contract.address!.addressData)
                    if (addressPresent != true) {
                        return Result([EventParserResultProtocol]())
                    }
                }
                guard let eventOfSuchTypeIsPresent = self.contract.testBloomForEventPrecence(eventName: self.eventName, bloom: bloom) else {return Result.failure(Web3Error.dataError)}
                if (!eventOfSuchTypeIsPresent) {
                    return Result([EventParserResultProtocol]())
                }
                var allLogs = receipt.logs
                if (self.contract.address != nil) {
                    allLogs = receipt.logs.filter({ (log) -> Bool in
                        log.address == self.contract.address
                    })
                }
                let decodedLogs = allLogs.compactMap({ (log) -> EventParserResultProtocol? in
                    let (n, d) = contract.parseEvent(log)
                    guard let evName = n, let evData = d else {return nil}
                    return EventParserResult(eventName: evName, transactionReceipt: receipt, contractAddress: log.address, decodedResult: evData)
                }).filter { (res:EventParserResultProtocol?) -> Bool in
                    return res != nil && res?.eventName == self.eventName
                }
                var allResults = [EventParserResultProtocol]()
                if (self.filter != nil) {
                    let eventFilter = self.filter!
                    let filteredLogs = filterLogs(decodedLogs: decodedLogs, eventFilter: eventFilter)
                    allResults = filteredLogs
                } else {
                    allResults = decodedLogs
                }
                return Result(allResults)
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
        var eventTopic: Data? = nil
        var event: ABIv2.Element.Event? = nil
        if eventName != nil {
            guard let ev = rawContract.events[eventName!] else {return Result.failure(Web3Error.dataError)}
            event = ev
            eventTopic = ev.topic
        }
        var topics = [[String?]?]()
        if eventTopic != nil {
            topics.append([eventTopic!.toHexString().addHexPrefix()])
        } else {
            topics.append(nil as [String?]?)
        }
        if filter.parameterFilters != nil {
            if event == nil {return Result.failure(Web3Error.dataError)}
//            let indexedInputs = event!.inputs.filter { (inp) -> Bool in
//                return inp.indexed
//            }
            var lastNonemptyFilter = 0
            for i in 0 ..< filter.parameterFilters!.count {
                let filterValue = filter.parameterFilters![i]
                if filterValue != nil {
                    lastNonemptyFilter = i
                }
            }
            if lastNonemptyFilter != 0 {
                guard lastNonemptyFilter <= event!.inputs.count else {return Result.failure(Web3Error.dataError)}
                for i in 0 ... lastNonemptyFilter {
                    let filterValues = filter.parameterFilters![i]
                    let input = event!.inputs[i]
                    if filterValues != nil && !input.indexed {
                        return Result.failure(Web3Error.dataError)
                    }
                    if filterValues == nil {
                        topics.append(nil as [String?]?)
                        continue
                    }
                    var encodings = [String]()
                    for val in filterValues! {
                        guard let enc = val.eventFilterEncoded() else {return Result.failure(Web3Error.dataError)}
                        encodings.append(enc)
                    }
//                    if encodings.count == 1 {
//                        topics.append(encodings[0] as AnyObject)
//                    } else {
                    topics.append(encodings)
//                    }
                }
            }
        }
        var preEncoding = filter.rpcPreEncode()
        preEncoding.topics = topics
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

fileprivate func filterLogs(decodedLogs: [EventParserResultProtocol], eventFilter: EventFilter) -> [EventParserResultProtocol] {
    let filteredLogs = decodedLogs.filter { (result) -> Bool in
        if eventFilter.addresses == nil {
            return true
        } else {
            if eventFilter.addresses!.contains(result.contractAddress) {
                return true
            } else {
                return false
            }
        }
        }.filter { (result) -> Bool in
            if eventFilter.parameterFilters == nil {
                return true
            } else {
                let keys = result.decodedResult.keys.filter({ (key) -> Bool in
                    if let _ = UInt64(key) {
                        return true
                    }
                    return false
                })
                if keys.count < eventFilter.parameterFilters!.count {
                    return false
                }
                for i in 0 ..< eventFilter.parameterFilters!.count {
                    let allowedValues = eventFilter.parameterFilters![i]
                    let actualValue = result.decodedResult["\(i)"]
                    if actualValue == nil {
                        return false
                    }
                    if allowedValues == nil {
                        continue
                    }
                    var inAllowed = false
                    for value in allowedValues! {
                        if value.isEqualTo(actualValue! as AnyObject) {
                            inAllowed = true
                            break
                        }
                    }
                    if !inAllowed {
                        return false
                    }
                }
                return true
            }
    }
    return filteredLogs
}
