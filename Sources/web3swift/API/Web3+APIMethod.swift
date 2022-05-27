//
//  Web3+APIMethod.swift
//  Web3swift
//
//  Created by Yaroslav on 24.05.2022.
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
    case getBlockByNumber(BlockNumber, Bool)

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
    public var method: REST {
        switch self {
        default: return .POST
        }
    }

    public var responseType: APIResultType.Type {
        switch self {
        case .blockNumber: return UInt.self
        case .getAccounts: return [EthereumAddress].self
        case .getBalance: return BigUInt.self
        case .getBlockByHash: return Block.self
        case .getBlockByNumber: return Block.self
        case .feeHistory: return Web3.Oracle.FeeHistory.self
        default: return String.self
        }
    }

    var encodedBody: Data {
        let request = RequestBody(method: self.call, params: self.parameters)
        // this is safe to force try this here
        // Because request must failed to compile if it not conformable with `Encodable` protocol
        return try! JSONEncoder().encode(request)
    }

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

        case .getBlockByNumber(let block, let bool):
            return [RequestParameter.string(block.stringValue), RequestParameter.bool(bool)]

        case .feeHistory(let uInt, let blockNumber, let array):
            return [RequestParameter.string(uInt.hexString), RequestParameter.string(blockNumber.stringValue), RequestParameter.doubleArray(array)]

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
    public static func sendRequest<Result>(with provider: Web3Provider, for call: APIRequest) async throws -> APIResponse<Result> {
        /// Don't even try to make network request if the `Result` type dosen't equal to supposed by API
        // FIXME: Add appropriate error thrown
        guard Result.self == call.responseType else { throw Web3Error.unknownError }

        let request = setupRequest(for: call, with: provider)
        let (data, response) = try await provider.session.data(for: request)

        // FIXME: Add appropriate error thrown
        guard let httpResponse = response as? HTTPURLResponse,
               200 ..< 400 ~= httpResponse.statusCode else { throw Web3Error.connectionError }

        if Result.self == UInt.self || Result.self == Int.self || Result.self == BigInt.self || Result.self == BigUInt.self {
            /// This types for sure conformed with `LiteralInitiableFromString`
            // FIXME: Make appropriate error
            guard let U = Result.self as? LiteralInitiableFromString.Type else { throw Web3Error.unknownError}
            let responseAsString = try! JSONDecoder().decode(APIResponse<String>.self, from: data)
            // FIXME: Add appropriate error thrown.
            guard let literalValue = U.init(from: responseAsString.result) else { throw Web3Error.unknownError }
            /// `U` is a APIResponseType type, which `LiteralInitiableFromString` conforms to, so it is safe to cast that.
            // FIXME: Make appropriate error
            guard let asT = literalValue as? Result else { throw Web3Error.unknownError }
            return APIResponse(id: responseAsString.id, jsonrpc: responseAsString.jsonrpc, result: asT)
        }
        return try JSONDecoder().decode(APIResponse<Result>.self, from: data)
    }

    static func setupRequest(for call: APIRequest, with provider: Web3Provider) -> URLRequest {
        var urlRequest = URLRequest(url: provider.url, cachePolicy: .reloadIgnoringCacheData)
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

struct RequestBody: Encodable {
    var jsonrpc = "2.0"
    var id = Counter.increment()

    var method: String
    var params: [RequestParameter]
}

/// JSON RPC response structure for serialization and deserialization purposes.
public struct APIResponse<Result>: Decodable where Result: APIResultType {
    public var id: Int
    public var jsonrpc = "2.0"
    public var result: Result
}
