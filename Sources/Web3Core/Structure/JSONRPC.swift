//  Package: web3swift
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//
//  Additions to support new transaction types by Mark Loit March 2022

import Foundation
import BigInt

public enum JSONRPCMethod: String, Encodable {

    // variable number of parameters in call
    case newFilter = "eth_newFilter"
    case getFilterLogs = "eth_getFilterLogs"
    case subscribe = "eth_subscribe"

    // 0 parameter in call
    case gasPrice = "eth_gasPrice"
    case blockNumber = "eth_blockNumber"
    case getNetwork = "net_version"
    case getAccounts = "eth_accounts"
    case getTxPoolStatus = "txpool_status"
    case getTxPoolContent = "txpool_content"
    case getTxPoolInspect = "txpool_inspect"
    case estimateGas = "eth_estimateGas"
    case newPendingTransactionFilter = "eth_newPendingTransactionFilter"
    case newBlockFilter = "eth_newBlockFilter"

    // 1 parameter in call
    case sendRawTransaction = "eth_sendRawTransaction"
    case sendTransaction = "eth_sendTransaction"
    case getTransactionByHash = "eth_getTransactionByHash"
    case getTransactionReceipt = "eth_getTransactionReceipt"
    case personalSign = "eth_sign"
    case unlockAccount = "personal_unlockAccount"
    case createAccount = "personal_createAccount"
    case getLogs = "eth_getLogs"
    case getFilterChanges = "eth_getFilterChanges"
    case uninstallFilter = "eth_uninstallFilter"
    case unsubscribe = "eth_unsubscribe"

    // 2 parameters in call
    case call = "eth_call"
    case getTransactionCount = "eth_getTransactionCount"
    case getBalance = "eth_getBalance"
    case getStorageAt = "eth_getStorageAt"
    case getCode = "eth_getCode"
    case getBlockByHash = "eth_getBlockByHash"
    case getBlockByNumber = "eth_getBlockByNumber"

    // 3 parameters in call
    case feeHistory = "eth_feeHistory"

    public var requiredNumOfParameters: Int? {
        switch self {
        case .newFilter,
                .getFilterLogs,
                .subscribe:
            return nil
        case .gasPrice,
                .blockNumber,
                .getNetwork,
                .getAccounts,
                .getTxPoolStatus,
                .getTxPoolContent,
                .getTxPoolInspect,
                .newPendingTransactionFilter,
                .newBlockFilter:
            return 0
        case .sendRawTransaction,
                .sendTransaction,
                .getTransactionByHash,
                .getTransactionReceipt,
                .personalSign,
                .unlockAccount,
                .createAccount,
                .getLogs,
                .estimateGas,
                .getFilterChanges,
                .uninstallFilter,
                .unsubscribe:
            return 1
        case .call,
                .getTransactionCount,
                .getBalance,
                .getStorageAt,
                .getCode,
                .getBlockByHash,
                .getBlockByNumber:
            return 2
        case .feeHistory:
            return 3
        }
    }
}

public struct JSONRPCRequestFabric {
    public static func prepareRequest(_ method: JSONRPCMethod, parameters: [Encodable]) -> JSONRPCRequest {
        var request = JSONRPCRequest()
        request.method = method
        let pars = JSONRPCParams(params: parameters)
        request.params = pars
        return request
    }
}

/// JSON RPC request structure for serialization and deserialization purposes.
public struct JSONRPCRequest: Encodable {
    public var jsonrpc: String = "2.0"
    public var method: JSONRPCMethod?
    public var params: JSONRPCParams?
    public var id: UInt = Counter.increment()

    enum CodingKeys: String, CodingKey {
        case jsonrpc
        case method
        case params
        case id
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(jsonrpc, forKey: .jsonrpc)
        try container.encode(method?.rawValue, forKey: .method)
        try container.encode(params, forKey: .params)
        try container.encode(id, forKey: .id)
    }

    public var isValid: Bool {
        get {
            if self.method == nil {
                return false
            }
            guard let method = self.method else {return false}
            return method.requiredNumOfParameters == self.params?.params.count
        }
    }
}

/// JSON RPC response structure for serialization and deserialization purposes.
public struct JSONRPCResponse: Decodable {
    public var id: Int
    public var jsonrpc = "2.0"
    public var result: Result
    public var error: ErrorMessage?
    public var message: String?

    enum JSONRPCResponseKeys: String, CodingKey {
        case id = "id"
        case jsonrpc = "jsonrpc"
        case result = "result"
        case error = "error"
    }

    public init(id: Int, jsonrpc: String, result: Result, error: ErrorMessage?) {
        self.id = id
        self.jsonrpc = jsonrpc
        self.result = result
        self.error = error
    }

    public struct Result: Decodable {
        private let value: Any?

        public init(value: Any?) {
            self.value = value
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            // TODO: refactor me
            var value: Any? = nil
            if let rawValue = try? container.decode(String.self) {
                value = rawValue
            } else if let rawValue = try? container.decode(Int.self) {
                value = rawValue
            } else if let rawValue = try? container.decode(Bool.self) {
                value = rawValue
            } else if let rawValue = try? container.decode(EventLog.self) {
                value = rawValue
            } else if let rawValue = try? container.decode(Block.self) {
                value = rawValue
            } else if let rawValue = try? container.decode(TransactionReceipt.self) {
                value = rawValue
            } else if let rawValue = try? container.decode(TransactionDetails.self) {
                value = rawValue
            } else if let rawValue = try? container.decode([EventLog].self) {
                value = rawValue
            } else if let rawValue = try? container.decode([Block].self) {
                value = rawValue
            } else if let rawValue = try? container.decode([TransactionReceipt].self) {
                value = rawValue
            } else if let rawValue = try? container.decode([TransactionDetails].self) {
                value = rawValue
            } else if let rawValue = try? container.decode(TxPoolStatus.self) {
                value = rawValue
            } else if let rawValue = try? container.decode(TxPoolContent.self) {
                value = rawValue
            } else if let rawValue = try? container.decode([Bool].self) {
                value = rawValue
            } else if let rawValue = try? container.decode([Int].self) {
                value = rawValue
            } else if let rawValue = try? container.decode([String].self) {
                value = rawValue
            } else if let rawValue = try? container.decode([String: String].self) {
                value = rawValue
            } else if let rawValue = try? container.decode([String: Int].self) {
                value = rawValue
            } else if let rawValue = try? container.decode([String: [String: [String: String]]].self) {
                value = rawValue
            } else if let rawValue = try? container.decode([String: [String: [String: [String: String?]]]].self) {
                value = rawValue
            } else if let rawValue = try? container.decode(Oracle.FeeHistory.self) {
                value = rawValue
            } else if let rawValue = try? container.decode(FilterChanges.self) {
                value = rawValue
            }
            self.value = value
        }

        public func getValue<T>() -> T? {
            let type = T.self
            
            if type == BigUInt.self {
                guard let string = self.value as? String else { return nil }
                guard let value = BigUInt(string.stripHexPrefix(), radix: 16) else { return nil }
                return value as? T
            } else if type == BigInt.self {
                guard let string = self.value as? String else { return nil }
                guard let value = BigInt(string.stripHexPrefix(), radix: 16) else { return nil }
                return value as? T
            } else if type == Data.self {
                guard let string = self.value as? String else { return nil }
                guard let value = Data.fromHex(string) else { return nil }
                return value as? T
            } else if type == EthereumAddress.self {
                guard let string = self.value as? String else { return nil }
                guard let value = EthereumAddress(string, ignoreChecksum: true) else { return nil }
                return value as? T
            } else if type == [BigUInt].self {
                guard let string = self.value as? [String] else { return nil }
                let values = string.compactMap { (str) -> BigUInt? in
                    return BigUInt(str.stripHexPrefix(), radix: 16)
                }
                return values as? T
            } else if type == [BigInt].self {
                guard let string = self.value as? [String] else { return nil }
                let values = string.compactMap { (str) -> BigInt? in
                    return BigInt(str.stripHexPrefix(), radix: 16)
                }
                return values as? T
            } else if type == [Data].self {
                guard let string = self.value as? [String] else { return nil }
                let values = string.compactMap { (str) -> Data? in
                    return Data.fromHex(str)
                }
                return values as? T
            } else if type == [EthereumAddress].self {
                guard let string = self.value as? [String] else { return nil }
                let values = string.compactMap { (str) -> EthereumAddress? in
                    return EthereumAddress(str, ignoreChecksum: true)
                }
                return values as? T
            }
            return self.value as? T
        }
    }

    public struct ErrorMessage: Decodable {
        public var code: Int
        public var message: String

        public init(code: Int, message: String) {
            self.code = code
            self.message = message
        }
    }

    internal var decodableTypes: [Decodable.Type] = [
        [EventLog].self,
        [TransactionDetails].self,
        [TransactionReceipt].self,
        [Block].self,
        [String].self,
        [Int].self,
        [Bool].self,
        EventLog.self,
        TransactionDetails.self,
        TransactionReceipt.self,
        Block.self,
        String.self,
        Int.self,
        Bool.self,
        [String: String].self,
        [String: Int].self,
        [String: [String: [String: [String]]]].self,
        Oracle.FeeHistory.self
    ]

    // FIXME: Make me a real generic
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: JSONRPCResponseKeys.self)
        let id: Int = try container.decode(Int.self, forKey: .id)
        let jsonrpc: String = try container.decode(String.self, forKey: .jsonrpc)
        let errorMessage = try container.decodeIfPresent(ErrorMessage.self, forKey: .error)
        if errorMessage != nil {
            self.init(id: id, jsonrpc: jsonrpc, result: Result(value: nil), error: errorMessage)
            return
        }
        let result = try container.decode(Result.self, forKey: .result)
        self.init(id: id, jsonrpc: jsonrpc, result: result, error: nil)
    }

    // FIXME: Make me a real generic
    /// Get the JSON RCP reponse value by deserializing it into some native <T> class.
    ///
    /// Returns nil if serialization fails
    public func getValue<T>() -> T? {
        result.getValue()
    }
}

/// Transaction parameters JSON structure for interaction with Ethereum node.
public struct TransactionParameters: Codable {
    /// accessList parameter JSON structure
    public struct AccessListEntry: Codable {
        public var address: String
        public var storageKeys: [String]
    }

    public var type: String?  // must be set for new EIP-2718 transaction types
    public var chainID: String?
    public var data: String?
    public var from: String?
    public var gas: String?
    public var gasPrice: String? // Legacy & EIP-2930
    public var maxFeePerGas: String? // EIP-1559
    public var maxPriorityFeePerGas: String? // EIP-1559
    public var accessList: [AccessListEntry]? // EIP-1559 & EIP-2930
    public var to: String?
    public var value: String? = "0x0"

    public init(from _from: String?, to _to: String?) {
        from = _from
        to = _to
    }
}


/// Raw JSON RCP 2.0 internal flattening wrapper.
public struct JSONRPCParams: Encodable{
    // TODO: Rewrite me to generic
    public var params = [Any]()

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        for par in params {
            if let p = par as? TransactionParameters {
                try container.encode(p)
            } else if let p = par as? String {
                try container.encode(p)
            } else if let p = par as? Bool {
                try container.encode(p)
            } else if let p = par as? EventFilterParameters {
                try container.encode(p)
            } else if let p = par as? [Double] {
                try container.encode(p)
            } else if let p = par as? SubscribeOnLogsParams {
                try container.encode(p)
            }
        }
    }
}

public struct SubscribeOnLogsParams: Encodable {
    public let address: [String]?
    public let topics: [String]?

    public init(address: [String]?, topics: [String]?) {
        self.address = address
        self.topics = topics
    }
}

public enum FilterChanges: Decodable {
    case hashes([String])
    case logs([EventLog])

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let hashes = try? container.decode([String].self) {
            self = .hashes(hashes)
        } else {
            self = .logs(try container.decode([EventLog].self))
        }
    }
}
