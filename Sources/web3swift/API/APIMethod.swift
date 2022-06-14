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

// FIXME: Add documentation to each method.
/// Ethereum JSON RPC API Calls
///
/// ## How to
/// Using new API is as easy as write three line of a code:
/// ```swift
/// func feeHistory(blockCount: UInt, block: BlockNumber, percentiles:[Double]) async throws -> Web3.Oracle.FeeHistory {
///     let requestCall: APIRequest = .feeHistory(blockCount, block, percentiles)
///     let response: APIResponse<Web3.Oracle.FeeHistory> = try await APIRequest.sendRequest(with: web3.provider, for: requestCall) /// explicitly declaring `Result` type is **required**.
///     return response.result
/// }
/// ```
///
/// 1. On the first line you’re creating a request where passing all required and strictly typed parameters.
/// 2. On a second you’re both declaring expected `Result` type and making a network request.
/// 3. On the third one you’re reaching result itself.
///
/// And that’s it, you’re done here.
///
/// ## Types overview
/// There’s follow types have been implemented
///
/// ### Main types
/// #### `public enum APIRequest`
/// This is the main type of whole network layer API. It responsible to both compose API request to a node and to send it to a node with a given provider (which stores Node URL and session), as cases it have all available JSON RPC requests and most of them have associated values to pass request parameters there.
///
/// Additionally it have follow computed properties:
/// - `public responseType: APIResultType.Type` - this variable returns appropriate `Result` generic parameter type for each API call. Which can be split generally in two parts:
///     - Literals (e.g. `Int`, `BigInt`) which **could not be** extended on client side.
///     - Decodable structures (e.g. `Block`) which **could be** extended on client side. That said that user able to add additional `Result` type on their side if it’s not literal (e.g. if it’s a `struct` or `class`).
/// - `method: REST` - this internal variable returns REST method for each API call. Currently its returning only `POST` one.
/// - `parameters: [RequestParameter]` - this internal variable is purposed to return parameters of request as an heterogeneous Array which is Node expected in most cases.
/// - `encodedBody: Data` - this internal variable returns encoded data of `RequestBody` type, which is required to compose correct request to a Node.
/// - `call: String` - this internal variable returns method call string, which is one of property of `RequestBody` type.
///
/// There’s two methods are provided for API calls.
/// - `public static func sendRequest<Result>(with provider: Web3Provider, for call: APIRequest) async throws -> APIResponse<Result>` - this method is the main one. It composes and sends request to a Node. This method could be called only with explicitly return type declaration like `let response: APIResponse<BigUInt> = try await APIRequest.sendRequest(with: self.provider, for: .gasPrice)`, where `response` is the whole APIResponse struct with a service properties and the `response.result` is a point of interests in example above — gas price.
/// * `static func setupRequest(for call: APIRequest, with provider: Web3Provider) -> URLRequest` - this internal method is just composing network request from all properties of related `APIRequest` case.
///
/// #### `public struct APIResponse<Result>: Decodable where Result: APIResultType`
/// This generic struct is any Ethereum node response container, where all stored properties are utility fields and one generic `result: Result` is the property that stores strictly typed result of any given request.
///
/// ### Protocols
/// To make things work there’s are some protocols be presented which both adds restriction to types that could be passed within new API and add some common methods to Literal types to be able initialize it from a hex string.
///
/// #### ``APIResultType``
/// This protocol responsible for any **nonliteral** type that could be stored within `APIResponse<Result>` generic struct. This protocol have no requirements except it conforms `Decodable` protocol. So any decodable type **could be** extended to conforms it.
///
/// #### ``LiteralInitiableFromString``
/// This protocol responsible for any literal types that could be stored within `APIResponse<Result>`. This protocol conforms `APIResultType` and it adds some requirements to it, like initializer from hex string. Despite that a given type could be extended to implement such initializer ==this should be done on a user side== because to make it work it requires some work within `sendRequest` method to be done.
///
/// #### ``IntegerInitableWithRadix``
/// This protocol is just utility one, which declares some convenient initializer which have both `Int` and `BigInt` types, but don’t have any common protocol which declares such requirement.
///
/// ### Utility types
/// - `struct RequestBody: Encodable` — just a request body that passes into request body.
/// - `public enum REST: String` — enum of REST methods. Only `POST` and `GET` presented yet.
/// - `enum RequestParameter` — this enum is a request composing helper. It make happened to encode request attribute as heterogeneous array.
/// - `protocol APIRequestParameterType: Encodable` — this type is part of the ``RequestParameter`` enum mechanism which purpose is to restrict types that can be passed as associated types within `RequestParameter` cases.
/// - `protocol APIRequestParameterElementType: Encodable` — this type purpose is the same as ``APIRequestParameterType` one except this one is made for `Element`s of an `Array` s when the latter is an associated type of a given `RequestParameter` case.
public enum APIRequest {
    // MARK: - Official API
    // 0 parameter in call
    /// Gas price request
    case gasPrice
    case blockNumber
    case getNetwork
    case getAccounts
    // ??
    case estimateGas(TransactionParameters, BlockNumber)
    case sendRawTransaction(Hash)
    case sendTransaction(TransactionParameters)
    case getTransactionByHash(Hash)
    case getTransactionReceipt(Hash)
    case getLogs(EventFilterParameters)
    case personalSign(Address, String)
    case call(TransactionParameters, BlockNumber)
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
    case feeHistory(BigUInt, BlockNumber, [Double])

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

// FIXME: This conformance should be changed to `LiteralInitiableFromString`
extension Data: APIResultType { }

extension APIRequest {
    var method: REST {
        switch self {
        default: return .POST
        }
    }

    public var responseType: APIResultType.Type {
        switch self {
        case .blockNumber: return BigUInt.self
        case .getAccounts: return [EthereumAddress].self
        case .getBalance: return BigUInt.self
        case .getBlockByHash: return Block.self
        case .getBlockByNumber: return Block.self
        case .gasPrice: return BigUInt.self
        case .feeHistory: return Web3.Oracle.FeeHistory.self
        case .getTransactionCount: return BigUInt.self
        case .getCode: return Hash.self
        case .getTransactionReceipt: return TransactionReceipt.self
        case .createAccount: return EthereumAddress.self
        case .unlockAccount: return Bool.self
        case .getTransactionByHash: return TransactionDetails.self
        case .sendTransaction: return Hash.self
        case .sendRawTransaction: return Hash.self
        case .estimateGas: return BigUInt.self
        case .call: return Data.self
        // FIXME: Not checked
        case .getNetwork: return Int.self
        case .personalSign: return Data.self
        case .getTxPoolStatus: return TxPoolStatus.self
        case .getTxPoolContent: return TxPoolContent.self
        case .getLogs: return [EventLog].self

        // FIXME: Not implemented
        case .getStorageAt: return String.self
        case .getTxPoolInspect: return String.self
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
        case .gasPrice, .blockNumber, .getNetwork, .getAccounts, .getTxPoolStatus, .getTxPoolContent, .getTxPoolInspect:
            return [RequestParameter]()

        case .estimateGas(let transactionParameters, let blockNumber):
            return [RequestParameter.transaction(transactionParameters), RequestParameter.string(blockNumber.stringValue)]

        case let .sendRawTransaction(hash):
            return [RequestParameter.string(hash)]

        case let .sendTransaction(transactionParameters):
            return [RequestParameter.transaction(transactionParameters)]

        case .getTransactionByHash(let hash):
            return [RequestParameter.string(hash)]

        case .getTransactionReceipt(let receipt):
            return [RequestParameter.string(receipt)]

        case .getLogs(let eventFilterParameters):
            return [RequestParameter.eventFilter(eventFilterParameters)]

        case .personalSign(let address, let string):
            // FIXME: Add second parameter
            return [RequestParameter.string(address), RequestParameter.string(string)]

        case .call(let transactionParameters, let blockNumber):
            return [RequestParameter.transaction(transactionParameters), RequestParameter.string(blockNumber.stringValue)]

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
            return [RequestParameter.string(string)]

        case .unlockAccount(let address, let string, let uInt):
            return [RequestParameter.string(address), RequestParameter.string(string), RequestParameter.uint(uInt ?? 0)]
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
        return try await APIRequest.send(uRLRequest: request, with: provider.session)
    }

    static func setupRequest(for call: APIRequest, with provider: Web3Provider) -> URLRequest {
        var urlRequest = URLRequest(url: provider.url, cachePolicy: .reloadIgnoringCacheData)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.httpMethod = call.method.rawValue
        urlRequest.httpBody = call.encodedBody
        return urlRequest
    }
    
    static func send<Result>(uRLRequest: URLRequest, with session: URLSession) async throws -> APIResponse<Result> {
        let (data, response) = try await session.data(for: uRLRequest)

        // FIXME: Add appropriate error thrown
        guard let httpResponse = response as? HTTPURLResponse,
               200 ..< 400 ~= httpResponse.statusCode else { throw Web3Error.connectionError }

        // FIXME: Add throwing an error from is server fails.
        /// This bit of code is purposed to work with literal types that comes in Response in hexString type.
        /// Currently it's just `Data` and any kind of Integers `(U)Int`, `Big(U)Int`.
        if Result.self == Data.self || Result.self == UInt.self || Result.self == Int.self || Result.self == BigInt.self || Result.self == BigUInt.self {
            // FIXME: Make appropriate error
            guard let Literal = Result.self as? LiteralInitiableFromString.Type else { throw Web3Error.unknownError }
            // FIXME: Add appropriate error thrown.
            guard let responseAsString = try? JSONDecoder().decode(APIResponse<String>.self, from: data) else { throw Web3Error.unknownError }
            // FIXME: Add appropriate error thrown.
            guard let literalValue = Literal.init(from: responseAsString.result) else { throw Web3Error.unknownError }
            /// `Literal` conforming `LiteralInitiableFromString`, that conforming to an `APIResponseType` type, so it's never fails.
            // FIXME: Make appropriate error
            guard let result = literalValue as? Result else { throw Web3Error.unknownError }
            return APIResponse(id: responseAsString.id, jsonrpc: responseAsString.jsonrpc, result: result)
        }
        return try JSONDecoder().decode(APIResponse<Result>.self, from: data)
    }
}

enum REST: String {
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
