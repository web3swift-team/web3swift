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

public struct EventParser {
    public struct EventParsingResult {
        public var event: ABIElement
        public var receipt: TransactionReceipt
        public var decodedResult: [String:Any]
    }
    
    
    public var contract: Contract
    public var contractAddress: EthereumAddress?
    public var event: ABIElement
    public var filter: Contract.EventFilter?
    var web3: web3
    public init? (web3 web3Instance: web3, event: ABIElement, contract: Contract, filter: Contract.EventFilter? = nil, forAddress: EthereumAddress? = nil) {
        guard case .event(_) = event else {return nil}
        self.event = event
        self.web3 = web3Instance
        self.contract = contract
        self.filter = filter
        self.contractAddress = forAddress
    }
    
    
    public func parseBlock(_ block: Block) -> Result<[EventParsingResult], Web3Error> {
        guard case .event(let ev) = event else {return Result.failure(Web3Error.dataError)}
        guard let eventOfSuchTypeIsPresent = block.logsBloom?.test(topic: ev.topic) else {return Result.failure(Web3Error.dataError)}
        if (!eventOfSuchTypeIsPresent) {
            return Result([])
        }
        var allResults = [EventParsingResult]()
        if (self.contractAddress == nil) {
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
        } else {
            for transaction in block.transactions {
                switch transaction {
                case .null:
                    return Result.failure(Web3Error.dataError)
                case .transaction(let tx):
                    guard let hash = tx.hash else {return Result.failure(Web3Error.dataError)}
                    if (tx.to != self.contractAddress) {
                        continue
                    }
                    let subresult = parseTransactionByHash(hash)
                    switch subresult {
                    case .failure(let error):
                        return Result.failure(error)
                    case .success(let subsetOfEvents):
                        allResults += subsetOfEvents
                    }
                case .hash(let hash):
                    let response = self.web3.eth.getTransactionDetails(hash)
                    switch response {
                    case .failure(let error):
                        return Result.failure(error)
                    case .success(let details):
                        guard let hash = details.transaction.hash else {return Result.failure(Web3Error.dataError)}
                        let to = details.transaction.to
                        if (to != self.contractAddress) {
                            continue
                        }
                        let subresult = parseTransactionByHash(hash)
                        switch subresult {
                        case .failure(let error):
                            return Result.failure(error)
                        case .success(let subsetOfEvents):
                            allResults += subsetOfEvents
                        }
                    }
                }
            }
        }
        return Result(allResults)
    }
    
    public func parseTransactionByHash(_ hash: Data) -> Result<[EventParsingResult], Web3Error> {
        let response = web3.eth.getTransactionReceipt(hash)
        switch response {
        case .failure(let error):
            return Result.failure(error)
        case .success(let receipt):
            guard case .event(let ev) = event else {return Result.failure(Web3Error.dataError)}
            guard let eventOfSuchTypeIsPresent = receipt.logsBloom?.test(topic: ev.topic) else {return Result.failure(Web3Error.dataError)}
            if (!eventOfSuchTypeIsPresent) {
                return Result([])
            }
            let decodedLogs = receipt.logs.flatMap({ (log) -> [String:Any]? in
                self.event.decodeReturnedLogs(log)
            })
            var allResults = [EventParsingResult]()
            if (self.filter != nil) {
                for log in decodedLogs {
                    let parsingResult = EventParsingResult(event: self.event, receipt: receipt, decodedResult: log)
                    allResults.append(parsingResult)
                }
            } else {
                for log in decodedLogs {
                    let parsingResult = EventParsingResult(event: self.event, receipt: receipt, decodedResult: log)
                    allResults.append(parsingResult)
                }
            }
            return Result(allResults)
        }
    }
    
    public func parseTransaction(_ transaction: EthereumTransaction) -> Result<[EventParsingResult], Web3Error> {
        guard let hash = transaction.hash else {return Result.failure(Web3Error.dataError)}
        return self.parseTransactionByHash(hash)
    }
}

