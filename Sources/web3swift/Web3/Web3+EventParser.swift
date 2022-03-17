//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt

extension web3.web3contract {
    /// An event parser to fetch events produced by smart-contract related transactions. Should not be constructed manually, but rather by calling the corresponding function on the web3contract object.
    public struct EventParser: EventParserProtocol {

        public var contract: ContractProtocol
        public var eventName: String
        public var filter: EventFilter?
        var web3: web3
        public init(web3 web3Instance: web3, eventName: String, contract: ContractProtocol, filter: EventFilter? = nil) throws {
            guard contract.allEvents.firstIndex(of: eventName) != nil else {
                throw Web3Error.dataError
            }
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
        public func parseBlockByNumber(_ blockNumber: UInt64) async throws -> [EventParserResultProtocol] {
            try await self.parseBlockByNumberPromise(blockNumber)
        }

        /**
         *Parses the block for events matching the EventParser settings.*

         - parameters:
         - block: Native web3swift block object

         - returns:
         - Result object

         - important: This call is synchronous

         */
        public func parseBlock(_ block: Block) async throws -> [EventParserResultProtocol] {
            try await self.parseBlockPromise(block)
        }

        /**
         *Parses the transaction for events matching the EventParser settings.*

         - parameters:
         - hash: Transaction hash

         - returns:
         - Result object

         - important: This call is synchronous

         */
        public func parseTransactionByHash(_ hash: Data) async throws -> [EventParserResultProtocol] {
            try await self.parseTransactionByHashPromise(hash)
        }

        /**
         *Parses the transaction for events matching the EventParser settings.*

         - parameters:
         - transaction: web3swift native EthereumTransaction object

         - returns:
         - Result object

         - important: This call is synchronous

         */
        public func parseTransaction(_ transaction: EthereumTransaction) async throws -> [EventParserResultProtocol] {
            try await self.parseTransactionPromise(transaction)
        }
    }
}

extension web3.web3contract.EventParser {
    public func parseTransactionPromise(_ transaction: EthereumTransaction) async throws-> [EventParserResultProtocol] {
        guard let hash = transaction.hash else {
            throw Web3Error.processingError(desc: "Failed to get transaction hash")}
        return try await self.parseTransactionByHashPromise(hash)
    }

    public func parseTransactionByHashPromise(_ hash: Data) async throws -> [EventParserResultProtocol] {
        let receipt = try await self.web3.eth.getTransactionReceiptPromise(hash)
        guard let results = parseReceiptForLogs(receipt: receipt, contract: self.contract, eventName: self.eventName, filter: self.filter) else {
            throw Web3Error.processingError(desc: "Failed to parse receipt for events")
        }
        return results
    }

    public func parseBlockByNumberPromise(_ blockNumber: UInt64) async throws -> [EventParserResultProtocol] {
        if self.filter != nil && (self.filter?.fromBlock != nil || self.filter?.toBlock != nil) {
            throw Web3Error.inputError(desc: "Can not mix parsing specific block and using block range filter")
        }
        let res = try await self.web3.eth.getBlockByNumberPromise(blockNumber)
        return try await self.parseBlockPromise(res)
    }

    public func parseBlockPromise(_ block: Block) async throws -> [EventParserResultProtocol] {

        guard let bloom = block.logsBloom else {
            throw Web3Error.processingError(desc: "Block doesn't have a bloom filter log")
        }

        if let address = self.contract.address {
            let addressPresent = block.logsBloom?.test(topic: address.addressData)
            if (addressPresent != true) {
                return [EventParserResultProtocol]()
            }
        }

        guard let eventOfSuchTypeIsPresent = self.contract.testBloomForEventPrecence(eventName: self.eventName, bloom: bloom) else {
            throw Web3Error.processingError(desc: "Error processing bloom for events")
        }

        if (!eventOfSuchTypeIsPresent) {
            return [EventParserResultProtocol]()
        }

        let results = await parseTransactionBy(hashes: block.transactions)

        var allResults = [EventParserResultProtocol]()
        for res in results {
            guard let subresult = res else {
                throw Web3Error.processingError(desc: "Failed to parse event for one transaction in block")
            }
            allResults.append(contentsOf: subresult)
        }
        return allResults


    }

    func parseTransactionBy(hashes: [TransactionInBlock]) async -> [[EventParserResultProtocol]?] {
        return await withTaskGroup(of: [EventParserResultProtocol]?.self, returning: [[EventParserResultProtocol]?].self) { group in
            for name in hashes {
                group.addTask {
                    guard let hash = name.hash else {
                        return nil
                    }
                    return try? await self.parseTransactionByHashPromise(hash)
                }
            }

            var promises = [[EventParserResultProtocol]?]()

            for await result in group {
                promises.append(result)
            }

            return promises
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
    public func getIndexedEvents(eventName: String?, filter: EventFilter, joinWithReceipts: Bool = false) async throws -> [EventParserResultProtocol] {
        try await self.getIndexedEventsPromise(eventName: eventName, filter: filter, joinWithReceipts: joinWithReceipts)
    }
}

extension web3.web3contract {
    public func getIndexedEventsPromise(eventName: String?, filter: EventFilter, joinWithReceipts: Bool = false) async throws -> [EventParserResultProtocol] {
        let rawContract = self.contract
        guard let preEncoding = encodeTopicToGetLogs(contract: rawContract, eventName: eventName, filter: filter) else {
            throw Web3Error.processingError(desc: "Failed to encode topic for request")
        }

        if let eventName = eventName, rawContract.events[eventName] == nil {
                throw Web3Error.processingError(desc: "No such event in a contract")
        }
        let request = JSONRPCRequestFabric.prepareRequest(.getLogs, parameters: [preEncoding])
        let response = await self.web3.dispatch(request)

        guard let value: [EventLog] = response?.getValue() else {
            throw Web3Error.nodeError(desc: response?.error?.message ?? "Empty or malformed response")
        }
        let allLogs = value
        let decodedLogs: [EventParserResult] = allLogs.compactMap{ log in
            let (n, d) = self.contract.parseEvent(log)
            guard let evName = n, let evData = d else {return nil}
            var res = EventParserResult(eventName: evName, transactionReceipt: nil, contractAddress: log.address, decodedResult: evData)
            res.eventLog = log
            return res
        }
            .filter{ res in
                if eventName != nil {
                    if res.eventName == eventName {
                        return true
                    }
                } else {
                    if res.eventLog != nil {
                        return true
                    }
                }
                return false
            }


        if (!joinWithReceipts) {
            return decodedLogs.map {res -> EventParserResultProtocol in
                return res as EventParserResultProtocol
            }
        }

        return await getTransactionReceiptPromises(events: decodedLogs)
    }

    func getTransactionReceiptPromises(events: [EventParserResult]) async -> [EventParserResultProtocol] {
        return await withTaskGroup(of: EventParserResultProtocol?.self, returning: [EventParserResultProtocol].self) { group in
            for name in events {
                group.addTask {
                    guard let eventLog = name.eventLog else {
                        return nil
                    }
                    let receipt = try? await self.web3.eth.getTransactionReceiptPromise(eventLog.transactionHash)
                    var joinedEvent = name
                    joinedEvent.transactionReceipt = receipt
                    return joinedEvent as EventParserResultProtocol
                }
            }

            var promises = [EventParserResultProtocol]()

            for await result in group {
                guard let result = result else { continue }
                promises.append(result)
            }

            return promises
        }
    }
}




