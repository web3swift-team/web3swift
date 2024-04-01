//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import Web3Core

// extension web3.web3contract {
//    /// An event parser to fetch events produced by smart-contract related transactions. Should not be constructed manually, but rather by calling the corresponding function on the web3contract object.
//    public struct EventParser: EventParserProtocol {
//
//        public var contract: ContractProtocol
//        public var eventName: String
//        public var filter: EventFilter?
//        var web3: web3
//
//        public init? (web3 web3Instance: web3, eventName: String, contract: ContractProtocol, filter: EventFilter? = nil) {
//            guard contract.events[eventName] != nil else { return nil }
//            self.eventName = eventName
//            self.web3 = web3Instance
//            self.contract = contract
//            self.filter = filter
//        }
//
//        /**
//         *Parses the block for events matching the EventParser settings.*
//
//         - parameters:
//         - blockNumber: Ethereum network block number
//
//         - returns:
//         - Result object
//
//         - important: This call is synchronous
//
//         */
//        public func parseBlockByNumber(_ blockNumber: BigUInt) async throws -> [EventParserResultProtocol] {
//            let result = try await self.parseBlockByNumberPromise(blockNumber)
//            return result
//        }
//
//        /**
//         *Parses the block for events matching the EventParser settings.*
//
//         - parameters:
//         - block: Native web3swift block object
//
//         - returns:
//         - Result object
//
//         - important: This call is synchronous
//
//         */
//        public func parseBlock(_ block: Block) async throws -> [EventParserResultProtocol] {
//            let result = try await self.parseBlockPromise(block)
//            return result
//        }
//
//        /**
//         *Parses the transaction for events matching the EventParser settings.*
//
//         - parameters:
//         - hash: Transaction hash
//
//         - returns:
//         - Result object
//
//         - important: This call is synchronous
//
//         */
//        public func parseTransactionByHash(_ hash: Data) async throws -> [EventParserResultProtocol] {
//            let result = try await self.parseTransactionByHashPromise(hash)
//            return result
//        }
//
//        /**
//         *Parses the transaction for events matching the EventParser settings.*
//
//         - parameters:
//         - transaction: web3swift native EthereumTransaction object
//
//         - returns:
//         - Result object
//
//         - important: This call is synchronous
//
//         */
//        public func parseTransaction(_ transaction: EthereumTransaction) async throws -> [EventParserResultProtocol] {
//            let result = try await self.parseTransactionPromise(transaction)
//            return result
//        }
//    }
// }
//
//// extension web3.web3contract.EventParser {
////    public func parseTransactionPromise(_ transaction: EthereumTransaction) async throws -> [EventParserResultProtocol] {
////        guard let hash = transaction.hash else {
////            throw Web3Error.processingError(desc: "Failed to get transaction hash")
////        }
////        return try await self.parseTransactionByHashPromise(hash)
////    }
//
////    public func parseTransactionByHashPromise(_ hash: Data) async throws -> [EventParserResultProtocol] {
////        let receipt = try await self.web3.eth.transactionReceipt(hash)
////
////        guard let results = parseReceiptForLogs(receipt: receipt, contract: contract, eventName: eventName, filter: filter) else {
////            throw Web3Error.processingError(desc: "Failed to parse receipt for events")
////        }
////        return results
////
////    }
//
//    public func parseBlockByNumberPromise(_ blockNumber: BigUInt) async throws -> [EventParserResultProtocol] {
//
//        guard filter == nil || filter?.fromBlock == nil && filter?.toBlock == nil else {
//            throw Web3Error.inputError(desc: "Can not mix parsing specific block and using block range filter")
//        }
//
//        let res = try await self.web3.eth.block(by: blockNumber)
//
//        return try await self.parseBlockPromise(res)
//    }
//
//    public func parseBlockPromise(_ block: Block) async throws -> [EventParserResultProtocol] {
//
//        guard let bloom = block.logsBloom else {
//            throw Web3Error.processingError(desc: "Block doesn't have a bloom filter log")
//        }
//
//        if let contractAddress =  contract.address {
//            if !(block.logsBloom?.test(topic: contractAddress.addressData) ?? true) {
//                return [EventParserResultProtocol]()
//            }
//        }
//
//        guard let eventOfSuchTypeIsPresent = self.contract.testBloomForEventPresence(eventName: self.eventName, bloom: bloom) else {
//            throw Web3Error.processingError(desc: "Error processing bloom for events")
//        }
//        if (!eventOfSuchTypeIsPresent) {
//            return [EventParserResultProtocol]()
//        }
//
//
//        return try await withThrowingTaskGroup(of: [EventParserResultProtocol].self, returning: [EventParserResultProtocol].self) { group in
//
//            block.transactions.forEach { transaction in
//                var txHash: Data? = nil
//
//                switch transaction {
//                case .null:
//                    txHash = nil
//                case .transaction(let tx):
//                    txHash = tx.hash
//                case .hash(let hash):
//                    txHash = hash
//                }
//
//                guard let hash = txHash else {
//                    return
//                }
//
//                group.addTask {
//                    try await self.parseTransactionByHashPromise(hash)
//                }
//            }
//
//            let allTransactions = try await group.reduce(into: [EventParserResultProtocol]()) { $0 += $1 }
//            return allTransactions
//        }
//    }
//
// }
//
// extension web3.web3contract {
//    /**
//     *Fetches events by doing a lookup on "indexed" parameters of the event. Smart-contract developer can make some of event values "indexed" for such fast queries.*
//
//     - parameters:
//     - eventName: Event name, should be present in ABI interface of the contract
//     - filter: EventFilter object setting the block limits for query
//     - joinWithReceipts: Bool indicating whether TransactionReceipt should be fetched separately for every matched transaction
//
//     - returns:
//     - Result object
//
//     - important: This call is synchronous
//
//     */
//    public func getIndexedEvents(eventName: String?, filter: EventFilter, joinWithReceipts: Bool = false) async throws -> [EventParserResultProtocol] {
//        let rawContract = self.contract
//        guard let preEncoding = encodeTopicToGetLogs(contract: rawContract, eventName: eventName, filter: filter) else {
//            throw Web3Error.processingError(desc: "Failed to encode topic for request")
//        }
//
//        if eventName != nil {
//            guard let _ = rawContract.events[eventName!] else {
//                throw Web3Error.processingError(desc: "No such event in a contract")
//            }
//        }
//
//        let request: APIRequest = .getLogs(preEncoding)
//        let response: APIResponse<[EventLog]> = try await APIRequest.sendRequest(with: self.web3.provider, for: request)
//
//        let decodedLogs = response.result.compactMap { (log) -> EventParserResult? in
//            let (n, d) = self.contract.parseEvent(log)
//            guard let evName = n, let evData = d else { return nil }
//            var res = EventParserResult(eventName: evName, transactionReceipt: nil, contractAddress: log.address, decodedResult: evData)
//            res.eventLog = log
//            return res
//        }
//            .filter{ res in res.eventLog != nil || (res.eventName == eventName && eventName != nil)}
//
//
//        if (!joinWithReceipts) {
//            return decodedLogs as [EventParserResultProtocol]
//        }
//
//        return await withTaskGroup(of: EventParserResultProtocol.self, returning: [EventParserResultProtocol].self) { group -> [EventParserResultProtocol] in
//
//            decodedLogs.forEach { singleEvent in
//                group.addTask {
//                    var joinedEvent = singleEvent
//                    let receipt = try? await self.web3.eth.transactionReceipt(singleEvent.eventLog!.transactionHash)
//                    joinedEvent.transactionReceipt = receipt
//                    return joinedEvent as EventParserResultProtocol
//                }
//            }
//
//            var collected = [EventParserResultProtocol]()
//
//            for await value in group {
//                collected.append(value)
//            }
//
//            return collected
//        }
//    }
// }
