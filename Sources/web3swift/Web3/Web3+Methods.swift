//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt

public typealias Hash = String // 32 bytes hash of block (64 chars length without 0x)
public typealias Receipt = Hash
public typealias Address = Hash // 20 bytes (40 chars length without 0x)
public typealias TransactionHash = Hash // 64 chars length without 0x

/// Ethereum JSON RPC API Calls
public enum APIRequest {
    // MARK: - Official API
    // 0 parameter in call
    case gasPrice
    case blockNumber
    case getNetwork
    case getAccounts
    // ??
    case estimateGas

    case sendRawTransaction(Hash)
    case sendTransaction(TransactionParameters)
    case getTransactionByHash(Hash)
    case getTransactionReceipt(Receipt)
    case getLogs(EventFilterParameters)
    case personalSign(Address, Data)
    case call(TransactionParameters)
    case getTransactionCount(Address, BlockNumber)
    case getBalance(Address, BlockNumber)

    /// Returns the value from a storage position at a given address.
    ///
    /// - Parameters:
    ///   - Address: Address
    ///   - Storage: slot
    ///   - BlockNumber: sd
    case getStorageAt(Address, Hash, BlockNumber)

    case getCode(Address, BlockNumber)
    case getBlockByHash(Hash, Bool)
    case getBlockByNumber(Hash, Bool)

    /// Returns fee history with a respect to given setup
    ///
    /// Generates and returns an estimate of how much gas is necessary to allow the transaction to complete.
    /// The transaction will not be added to the blockchain. Note that the estimate may be significantly more
    /// than the amount of gas actually used by the transaction, for a variety of reasons including EVM mechanics and node performance.
    ///
    /// - Parameters:
    ///   - UInt: Requested range of blocks. Clients will return less than the requested range if not all blocks are available.
    ///   - BlockNumber: Highest block of the requested range.
    ///   - [Double]: A monotonically increasing list of percentile values.
    ///     For each block in the requested range, the transactions will be sorted in ascending order
    ///     by effective tip per gas and the coresponding effective tip for the percentile will be determined, accounting for gas consumed."
    case feeHistory(UInt, BlockNumber, [Double])

    // MARK: - Additional API
    /// Creates new account.
    ///
    /// Note: it becomes the new current unlocked account. There can only be one unlocked account at a time.
    ///
    /// - Parameters:
    ///   - String: Password for the new account.
    case createAccount(String) // No in Eth API

    /// Unlocks specified account for use.
    ///
    /// If permanent unlocking is disabled (the default) then the duration argument will be ignored,
    /// and the account will be unlocked for a single signing.
    /// With permanent locking enabled, the duration sets the number of seconds to hold the account open for.
    /// It will default to 300 seconds. Passing 0 unlocks the account indefinitely.
    ///
    /// There can only be one unlocked account at a time.
    ///
    /// - Parameters:
    ///   - Address: The address of the account to unlock.
    ///   - String: Passphrase to unlock the account.
    ///   - UInt?: Duration in seconds how long the account should remain unlocked for.
    case unlockAccount(Address, String, UInt?)
    case getTxPoolStatus // No in Eth API
    case getTxPoolContent // No in Eth API
    case getTxPoolInspect // No in Eth API
}

extension APIRequest {
    var call: String {
        switch self {
        case .gasPrice: return "eth_gasPrice"
        case .blockNumber: return "eth_blockNumber"
        case .getNetwork: return "net_version"
        case .getAccounts: return "eth_accounts"
        case .sendRawTransaction: return "eth_sendRawTransaction"
        case .sendTransaction: return "eth_sendTransaction"
        case .getTransactionByHash: return "eth_getTransactionByHash"
        case .getTransactionReceipt: return "eth_getTransactionReceipt"
        case .personalSign: return "eth_sign"
        case .getLogs: return "eth_getLogs"
        case .call: return "eth_call"
        case .estimateGas: return "eth_estimateGas"
        case .getTransactionCount: return "eth_getTransactionCount"
        case .getBalance: return "eth_getBalance"
        case .getStorageAt: return "eth_getStorageAt"
        case .getCode: return "eth_getCode"
        case .getBlockByHash: return "eth_getBlockByHash"
        case .getBlockByNumber: return "eth_getBlockByNumber"
        case .feeHistory: return "eth_feeHistory"

        case .unlockAccount: return "personal_unlockAccount"
        case .createAccount: return "personal_createAccount"
        case .getTxPoolStatus: return "txpool_status"
        case .getTxPoolContent: return "txpool_content"
        case .getTxPoolInspect: return "txpool_inspect"
        }
    }
}

extension APIRequest {
    public var responseType: APIResponseType.Type {
        switch self {
        default: return String.self
        }
    }
}

extension APIRequest {
    public var method: REST {
        switch self {
        default: return .POST
        }
    }
}

extension APIRequest {
    var parameters: [RequestParameter] {
        switch self {
        case .gasPrice, .blockNumber, .getNetwork, .getAccounts, .estimateGas:
            return [RequestParameter]()
        case let .sendRawTransaction(hash):
            return [RequestParameter.string(hash)]
        case .sendTransaction(let transactionParameters):
            return [RequestParameter.transaction(transactionParameters)]
        case .getTransactionByHash(let hash):
            return [RequestParameter.string(hash)]
        case .getTransactionReceipt(let receipt):
            return [RequestParameter.string(receipt)]
        case .getLogs(let eventFilterParameters):
            return [RequestParameter.eventFilter(eventFilterParameters)]
        case .personalSign(let address, let data):
            // FIXME: Add second parameter
            return [RequestParameter.string(address)]
        case .call(let transactionParameters):
            return [RequestParameter.transaction(transactionParameters)]
        case .getTransactionCount(let address, let blockNumber):
            return [RequestParameter.string(address), RequestParameter.string(blockNumber.stringValue)]
        case .getBalance(let address, let blockNumber):
            return [RequestParameter.string(address), RequestParameter.string(blockNumber.stringValue)]
        case .getStorageAt(let address, let hash, let blockNumber):
            return [RequestParameter.string(address), RequestParameter.string(hash), RequestParameter.string(blockNumber.stringValue)]
        case .getCode(let address, let blockNumber):
            return [RequestParameter.string(address), RequestParameter.string(blockNumber.stringValue)]
        case .getBlockByHash(let hash, let bool):
            return [RequestParameter.string(hash), RequestParameter.bool(bool)]
        case .getBlockByNumber(let hash, let bool):
            return [RequestParameter.string(hash), RequestParameter.bool(bool)]
        case .feeHistory(let uInt, let blockNumber, let array):
            return [RequestParameter.uint(uInt), RequestParameter.string(blockNumber.stringValue), RequestParameter.doubleArray(array)]
        case .createAccount(let string):
            return [RequestParameter]()
        case .unlockAccount(let address, let string, let optional):
            return [RequestParameter]()
        case .getTxPoolStatus:
            return [RequestParameter]()
        case .getTxPoolContent:
            return [RequestParameter]()
        case .getTxPoolInspect:
            return [RequestParameter]()
        }
    }
}

extension APIRequest {
    var encodedBody: Data {
        let request = RequestBody(method: self.call, parameters: self.parameters)
        // this is safe to force try this here
        // Because request must failed to compile would not conformable with `Encodable` protocol
        return try! JSONEncoder().encode(request)
    }
}

extension APIRequest {
    public static func sendRequest<U>(with call: APIRequest) async throws -> APIResponse<U> {
        let request = setupRequest(for: call)
        let (data, response) = try await URLSession.shared.data(for: request)

        // FIXME: Add appropriate error thrown
        guard let httpResponse = response as? HTTPURLResponse,
               200 ..< 400 ~= httpResponse.statusCode else { throw Web3Error.connectionError }

        // FIXME: Add appropriate error thrown
        guard U.self == call.responseType else { throw Web3Error.unknownError }

        // FIXME: What to do when `result` is just an hexString?
        // All works here must be end at leving it string.
        // Another way is to made type HexString with its own init and decode method
        return try JSONDecoder().decode(APIResponse<U>.self, from: data)
    }
}

private extension APIRequest {
    static func setupRequest(for call: APIRequest) -> URLRequest {
        // FIXME: Make custom url
        let url = URL(string: "https://mainnet.infura.io/v3/4406c3acf862426c83991f1752c46dd8")!
        var urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.httpMethod = call.method.rawValue
        urlRequest.httpBody = call.encodedBody
        return urlRequest
    }
}

public enum REST: String {
    case POST
    case GET
}

public struct RequestBody: Encodable {
    var jsonrpc = "2.0"
    var id = Counter.increment()

    var method: String
    var parameters: [RequestParameter]
}

/// JSON RPC response structure for serialization and deserialization purposes.
public struct APIResponse<T>: Decodable where T: APIResponseType {
    public var id: Int
    public var jsonrpc = "2.0"
    public var result: T
}

public protocol APIResponseType: Decodable { }

extension BigUInt: APIResponseType { }

extension String: APIResponseType { }

public enum JSONRPCmethod: String, Encodable {
    // 0 parameter in call
    case gasPrice = "eth_gasPrice"
    case blockNumber = "eth_blockNumber"
    case getNetwork = "net_version"
    case getAccounts = "eth_accounts"
    case getTxPoolStatus = "txpool_status"
    case getTxPoolContent = "txpool_content"
    case getTxPoolInspect = "txpool_inspect"

    // 1 parameter in call
    case sendRawTransaction = "eth_sendRawTransaction"
    case sendTransaction = "eth_sendTransaction"
    case getTransactionByHash = "eth_getTransactionByHash"
    case getTransactionReceipt = "eth_getTransactionReceipt"
    case personalSign = "eth_sign"
    case unlockAccount = "personal_unlockAccount"
    case createAccount = "personal_createAccount"
    case getLogs = "eth_getLogs"

    // 2 parameters in call
    case call = "eth_call"
    case estimateGas = "eth_estimateGas"
    case getTransactionCount = "eth_getTransactionCount"
    case getBalance = "eth_getBalance"
    case getStorageAt = "eth_getStorageAt"
    case getCode = "eth_getCode"
    case getBlockByHash = "eth_getBlockByHash"
    case getBlockByNumber = "eth_getBlockByNumber"

    // 3 parameters in call
    case feeHistory = "eth_feeHistory"

    public var requiredNumOfParameters: Int {
        switch self {
        case .gasPrice,
                .blockNumber,
                .getNetwork,
                .getAccounts,
                .getTxPoolStatus,
                .getTxPoolContent,
                .getTxPoolInspect:
            return 0
        case .sendRawTransaction,
                .sendTransaction,
                .getTransactionByHash,
                .getTransactionReceipt,
                .personalSign,
                .unlockAccount,
                .createAccount,
                .getLogs,
                .estimateGas:
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
    public static func prepareRequest(_ method: JSONRPCmethod, parameters: [APIRequestParameterType]) -> JSONRPCrequest {
        var request = JSONRPCrequest()
        request.method = method
        request.params = parameters.compactMap { RequestParameter.init(rawValue: $0) }
        return request
    }

    public static func prepareRequest(_ method: InfuraWebsocketMethod, parameters: [APIRequestParameterType]) -> InfuraWebsocketRequest {
        var request = InfuraWebsocketRequest()
        request.method = method
        request.params = parameters.compactMap { RequestParameter.init(rawValue: $0) }
        return request
    }
}
