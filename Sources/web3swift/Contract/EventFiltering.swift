//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation

internal func filterLogs(decodedLogs: [EventParserResultProtocol], eventFilter: EventFilter) -> [EventParserResultProtocol] {

    let filteredLogs = decodedLogs
        .filter { eventFilter.addresses?.contains($0.contractAddress) ?? true }
        .filter { result -> Bool in
            guard let eventParamFilters = eventFilter.parameterFilters else {
                return true
            }

            let keys = result.decodedResult.keys.compactMap {$0}

            if keys.count < eventParamFilters.count {
                return false
            }
            for i in 0 ..< eventParamFilters.count {
                guard let actualValue = result.decodedResult["\(i)"] else {
                    return false
                }
                guard let allowedValues = eventParamFilters[i] else {
                    continue
                }
                var inAllowed = false
                for value in allowedValues {
                    if value.isEqualTo(actualValue as AnyObject) {
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
    return filteredLogs
}

internal func encodeTopicToGetLogs(contract: EthereumContract, eventName: String?, filter: EventFilter) -> EventFilterParameters? {

    var event: ABI.Element.Event?
    var topics: [[String?]?]

    if let evName = eventName {
        guard let ev = contract.events[evName] else {return nil}
        let evTopic = ev.topic.toHexString().addHexPrefix()
        event = ev
        topics = [[evTopic]]
    } else {
        topics = [nil]
    }

    if let filterParamFilters = filter.parameterFilters {
        guard let event = event else {
            return nil
        }
        var lastNonemptyFilter = -1
        for i in 0 ..< filterParamFilters.count {
            let filterValue = filterParamFilters[i]
            if filterValue != nil {
                lastNonemptyFilter = i
            }
        }
        if lastNonemptyFilter >= 0 {
            guard lastNonemptyFilter <= event.inputs.count else {return nil}
            for i in 0 ... lastNonemptyFilter {
                guard let filterValues = filterParamFilters[i] else {
                    topics.append(nil as [String?]?)
                    continue
                }

                var isFound = false
                var targetIndexedPosition = i
                for j in 0 ..< event.inputs.count {
                    if event.inputs[j].indexed {
                        if targetIndexedPosition == 0 {
                            isFound = true
                            break
                        }
                        targetIndexedPosition -= 1
                    }
                }

                if !isFound {return nil}

                var encodings = [String]()
                for val in filterValues {
                    guard let enc = val.eventFilterEncoded() else {return nil}
                    encodings.append(enc)
                }
                topics.append(encodings)
            }
        }
    }
    var preEncoding = filter.rpcPreEncode()
    preEncoding.topics = topics
    return preEncoding
}

internal func parseReceiptForLogs(receipt: TransactionReceipt, contract: ContractProtocol, eventName: String, filter: EventFilter?) -> [EventParserResultProtocol]? {
    guard let bloom = receipt.logsBloom else {return nil}
    if let contAddr = contract.address, bloom.test(topic: contAddr.addressData) != true {
        return [EventParserResultProtocol]()
    }

    if filter != nil, let filterAddresses = filter?.addresses {
        var oneIsPresent = false
        for addr in filterAddresses {
            let addressPresent = bloom.test(topic: addr.addressData)
            if addressPresent == true {
                oneIsPresent = true
                break
            }
        }
        if oneIsPresent != true {
            return [EventParserResultProtocol]()
        }
    }
    guard let eventOfSuchTypeIsPresent = contract.testBloomForEventPrecence(eventName: eventName, bloom: bloom) else {return nil}
    if !eventOfSuchTypeIsPresent {
        return [EventParserResultProtocol]()
    }
    var allLogs = receipt.logs
    if contract.address != nil {
        allLogs = receipt.logs.filter { $0.address == contract.address }
    }
    let decodedLogs = allLogs.compactMap { log -> EventParserResultProtocol? in
        let (n, d) = contract.parseEvent(log)
        guard let evName = n, let evData = d else {return nil}
        var result = EventParserResult(eventName: evName, transactionReceipt: receipt, contractAddress: log.address, decodedResult: evData)
        result.eventLog = log
        return result
    }
    .filter { $0.eventName == eventName }

    let allResults: [EventParserResultProtocol]
    if let eventFilter = filter {
        allResults = filterLogs(decodedLogs: decodedLogs, eventFilter: eventFilter)
    } else {
        allResults = decodedLogs
    }
    return allResults
}
