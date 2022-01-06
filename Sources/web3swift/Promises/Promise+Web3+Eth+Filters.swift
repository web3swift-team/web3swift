//
//  Promise+Web3+Eth+Filters.swift
//  
//
//  Created by Ostap Danylovych on 06.01.2022.
//

import Foundation
import PromiseKit
import BigInt

public enum BlockNumber {
    case pending
    case latest
    case earliest
    case exact(BigUInt)
    
    public var stringValue: String {
        switch self {
        case .pending:
            return "pending"
        case .latest:
            return "latest"
        case .earliest:
            return "earliest"
        case .exact(let number):
            return String(number, radix: 16).addHexPrefix()
        }
    }
}

extension web3.Eth {
    private func dispatchRequest<T>(_ request: JSONRPCrequest) -> Promise<T> {
        web3.dispatch(request).map(on: web3.requestDispatcher.queue) { response in
            guard let value: T = response.getValue() else {
                if response.error != nil {
                    throw Web3Error.nodeError(desc: response.error!.message)
                }
                throw Web3Error.nodeError(desc: "Invalid value from Ethereum node")
            }
            return value
        }
    }
    
    public func newFilterPromise(addresses: [EthereumAddress],
                                 fromBlock: BlockNumber? = .latest,
                                 toBlock: BlockNumber? = .latest,
                                 topics: [String]) -> Promise<String> {
        let addresses = addresses.map { $0.address.lowercased() }
        return dispatchRequest(JSONRPCRequestFabric.prepareRequest(.newFilter, parameters: [addresses, fromBlock?.stringValue, toBlock?.stringValue, topics]))
    }
    
    public func newBlockFilterPromise() -> Promise<String> {
        return dispatchRequest(JSONRPCRequestFabric.prepareRequest(.newBlockFilter, parameters: []))
    }
    
    public func newPendingTransactionFilterPromise() -> Promise<String> {
        return dispatchRequest(JSONRPCRequestFabric.prepareRequest(.newPendingTransactionFilter, parameters: []))
    }
    
    public func uninstallFilterPromise(filterID: String) -> Promise<Bool> {
        return dispatchRequest(JSONRPCRequestFabric.prepareRequest(.uninstallFilter, parameters: [filterID]))
    }
    
    public func getFilterChangesPromise(filterID: String) -> Promise<FilterChanges> {
        return dispatchRequest(JSONRPCRequestFabric.prepareRequest(.getFilterChanges, parameters: [filterID]))
    }
    
    public func getFilterLogsPromise(filterID: String) -> Promise<FilterChanges> {
        return dispatchRequest(JSONRPCRequestFabric.prepareRequest(.getFilterLogs, parameters: [filterID]))
    }
}
