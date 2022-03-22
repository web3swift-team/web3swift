//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import PromiseKit
fileprivate typealias PromiseResult = PromiseKit.Result

extension web3.web3contract {
    /// An event parser to fetch events produced by smart-contract related transactions. Should not be constructed manually, but rather by calling the corresponding function on the web3contract object.
    public struct EventParser: EventParserProtocol {

        public var contract: ContractProtocol
        public var eventName: String
        public var filter: EventFilter?
        var web3: web3
        public init? (web3 web3Instance: web3, eventName: String, contract: ContractProtocol, filter: EventFilter? = nil) {
            //  guard let _ = contract.allEvents.index(of: eventName) else {return nil}
            guard let _ = contract.allEvents.firstIndex(of: eventName) else {return nil}
            self.eventName = eventName
            self.web3 = web3Instance
            self.contract = contract
            self.filter = filter
        }

        /**
         *Parses the block for events matching the EventParser settings.*

         - parameters:
            - blockNumber: Ethereum network block number

         - returns:
            - Result object

         - important: This call is synchronous

         */
        public func parseBlockByNumber(_ blockNumber: UInt64) throws -> [EventParserResultProtocol] {
            let result = try self.parseBlockByNumberPromise(blockNumber).wait()
            return result
        }

        /**
         *Parses the block for events matching the EventParser settings.*

         - parameters:
            - block: Native web3swift block object

         - returns:
            - Result object

         - important: This call is synchronous

         */
        public func parseBlock(_ block: Block) throws -> [EventParserResultProtocol] {
            let result = try self.parseBlockPromise(block).wait()
            return result
        }

        /**
         *Parses the transaction for events matching the EventParser settings.*

         - parameters:
            - hash: Transaction hash

         - returns:
            - Result object

         - important: This call is synchronous

         */
        public func parseTransactionByHash(_ hash: Data) throws -> [EventParserResultProtocol] {
            let result = try self.parseTransactionByHashPromise(hash).wait()
            return result
        }

        /**
         *Parses the transaction for events matching the EventParser settings.*

         - parameters:
            - transaction: web3swift native EthereumTransaction object

         - returns:
            - Result object

         - important: This call is synchronous

         */
        public func parseTransaction(_ transaction: EthereumTransaction) throws -> [EventParserResultProtocol] {
            let result = try self.parseTransactionPromise(transaction).wait()
            return result
        }
    }
}

extension web3.web3contract.EventParser {
    public func parseTransactionPromise(_ transaction: EthereumTransaction) -> Promise<[EventParserResultProtocol]> {
        let queue = self.web3.requestDispatcher.queue
        do {
            guard let hash = transaction.hash else {
                throw Web3Error.processingError(desc: "Failed to get transaction hash")}
            return self.parseTransactionByHashPromise(hash)
        } catch {
            let returnPromise = Promise<[EventParserResultProtocol]>.pending()
            queue.async {
                returnPromise.resolver.reject(error)
            }
            return returnPromise.promise
        }
    }

    public func parseTransactionByHashPromise(_ hash: Data) -> Promise<[EventParserResultProtocol]> {
        let queue = self.web3.requestDispatcher.queue
        return self.web3.eth.getTransactionReceiptPromise(hash).map(on: queue) {receipt throws -> [EventParserResultProtocol] in
            guard let results = parseReceiptForLogs(receipt: receipt, contract: self.contract, eventName: self.eventName, filter: self.filter) else {
                throw Web3Error.processingError(desc: "Failed to parse receipt for events")
            }
            return results
        }
    }

    public func parseBlockByNumberPromise(_ blockNumber: UInt64) -> Promise<[EventParserResultProtocol]> {
        let queue = self.web3.requestDispatcher.queue
        do {
            if self.filter != nil && (self.filter?.fromBlock != nil || self.filter?.toBlock != nil) {
                throw Web3Error.inputError(desc: "Can not mix parsing specific block and using block range filter")
            }
            return self.web3.eth.getBlockByNumberPromise(blockNumber).then(on: queue) {res in
                return self.parseBlockPromise(res)
            }
        } catch {
            let returnPromise = Promise<[EventParserResultProtocol]>.pending()
            queue.async {
                returnPromise.resolver.reject(error)
            }
            return returnPromise.promise
        }
    }

    public func parseBlockPromise(_ block: Block) -> Promise<[EventParserResultProtocol]> {
        let queue = self.web3.requestDispatcher.queue
        do {
            guard let bloom = block.logsBloom else {
                throw Web3Error.processingError(desc: "Block doesn't have a bloom filter log")
            }
            if self.contract.address != nil {
                let addressPresent = block.logsBloom?.test(topic: self.contract.address!.addressData)
                if (addressPresent != true) {
                    let returnPromise = Promise<[EventParserResultProtocol]>.pending()
                    queue.async {
                        returnPromise.resolver.fulfill([EventParserResultProtocol]())
                    }
                    return returnPromise.promise
                }
            }
            guard let eventOfSuchTypeIsPresent = self.contract.testBloomForEventPrecence(eventName: self.eventName, bloom: bloom) else {
                throw Web3Error.processingError(desc: "Error processing bloom for events")
            }
            if (!eventOfSuchTypeIsPresent) {
                let returnPromise = Promise<[EventParserResultProtocol]>.pending()
                queue.async {
                    returnPromise.resolver.fulfill([EventParserResultProtocol]())
                }
                return returnPromise.promise
            }
            return Promise {seal in

                var pendingEvents: [Promise<[EventParserResultProtocol]>] = [Promise<[EventParserResultProtocol]>]()
                for transaction in block.transactions {
                    switch transaction {
                    case .null:
                        seal.reject(Web3Error.processingError(desc: "No information about transactions in block"))
                        return
                    case .transaction(let tx):
                        guard let hash = tx.hash else {
                            seal.reject(Web3Error.processingError(desc: "Failed to get transaction hash"))
                            return
                        }
                        let subresultPromise = self.parseTransactionByHashPromise(hash)
                        pendingEvents.append(subresultPromise)
                    case .hash(let hash):
                        let subresultPromise = self.parseTransactionByHashPromise(hash)
                        pendingEvents.append(subresultPromise)
                    }
                }
                when(resolved: pendingEvents).done(on: queue){ (results: [PromiseResult<[EventParserResultProtocol]>]) throws in
                    var allResults = [EventParserResultProtocol]()
                    for res in results {
                        guard case .fulfilled(let subresult) = res else {
                            throw Web3Error.processingError(desc: "Failed to parse event for one transaction in block")
                        }
                        allResults.append(contentsOf: subresult)
                    }
                    seal.fulfill(allResults)
                }.catch(on: queue) {err in
                    seal.reject(err)
                }
            }
        } catch {
            //  let returnPromise = Promise<[EventParserResultProtocol]>.pending()
            //  queue.async {
            //      returnPromise.resolver.fulfill([EventParserResultProtocol]())
            //  }
            //  return returnPromise.promise
            let returnPromise = Promise<[EventParserResultProtocol]>.pending()
            queue.async {
                returnPromise.resolver.reject(error)
            }
            return returnPromise.promise
        }
    }

}

extension web3.web3contract {

    /**
     *Fetches events by doing a lookup on "indexed" parameters of the event. Smart-contract developer can make some of event values "indexed" for such fast queries.*

     - parameters:
         - eventName: Event name, should be present in ABI interface of the contract
         - filter: EventFilter object setting the block limits for query
         - joinWithReceipts: Bool indicating whether TransactionReceipt should be fetched separately for every matched transaction

     - returns:
        - Result object

     - important: This call is synchronous

     */
    public func getIndexedEvents(eventName: String?, filter: EventFilter, joinWithReceipts: Bool = false) throws -> [EventParserResultProtocol] {
        let result = try self.getIndexedEventsPromise(eventName: eventName, filter: filter, joinWithReceipts: joinWithReceipts).wait()
        return result
    }
}

extension web3.web3contract {
    public func getIndexedEventsPromise(eventName: String?, filter: EventFilter, joinWithReceipts: Bool = false) -> Promise<[EventParserResultProtocol]> {
        let queue = self.web3.requestDispatcher.queue
        do {
            let rawContract = self.contract
            guard let preEncoding = encodeTopicToGetLogs(contract: rawContract, eventName: eventName, filter: filter) else {
                throw Web3Error.processingError(desc: "Failed to encode topic for request")
            }

            if eventName != nil {
                guard let _ = rawContract.events[eventName!] else {
                    throw Web3Error.processingError(desc: "No such event in a contract")
                }
            }
            let request = JSONRPCRequestFabric.prepareRequest(.getLogs, parameters: [preEncoding])
            let fetchLogsPromise = self.web3.dispatch(request).map(on: queue) {response throws -> [EventParserResult] in
                guard let value: [EventLog] = response.getValue() else {
                    if response.error != nil {
                        throw Web3Error.nodeError(desc: response.error!.message)
                    }
                    throw Web3Error.nodeError(desc: "Empty or malformed response")
                }
                let allLogs = value
                let decodedLogs = allLogs.compactMap({ (log) -> EventParserResult? in
                    let (n, d) = self.contract.parseEvent(log)
                    guard let evName = n, let evData = d else {return nil}
                    var res = EventParserResult(eventName: evName, transactionReceipt: nil, contractAddress: log.address, decodedResult: evData)
                    res.eventLog = log
                    return res
                }).filter{ (res: EventParserResult?) -> Bool in
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
            return fetchLogsPromise.thenMap(on: queue) {singleEvent in
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
