//
//  ContractProtocol.swift
//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt

public protocol ContractProtocol {
    var address: EthereumAddress? {get set}

    /// Default options added to all ``EthereumTransaction`` objects created by this protocol.
    var transactionOptions: TransactionOptions? {get set}

    /// All ABI elements like: events, functions, constructors and errors.
    var abi: [ABI.Element] {get}

    /// Functions filtered from `abi`.
    /// Contains methods mapped to function name, like `getData`,
    /// name with input parameters `getData(bytes32)` and 4 bytes signature `0xffFFffFF`.
    /// The mapping by name (e.g. `getData`) is the one most likely expected to return arrays with
    /// more than one entry due to the fact that solidity allows method overloading.
    var methods: [String:[ABI.Element.Function]] {get}

    /// All entries from `methods`.
    var allMethods: [ABI.Element.Function] {get}

    /// Events filtered from `abi`.
    var events: [String:ABI.Element.Event] {get}

    /// All events from `events`.
    var allEvents: [ABI.Element.Event] {get}

    /// Parsed from ABI or a default constructor with no input arguments.
    var constructor: ABI.Element.Constructor {get}

    /// Required initializer that is capable of reading ABI in JSON format.
    /// - Parameters:
    ///   - abiString: ABI string in JSON format.
    ///   - at: contract added. Can be set later.
    ///
    /// If ABI failed to be decoded `nil` will be returned. Reasons could be invalid keys and values in ABI, invalid JSON structure,
    /// new Solidity keywords, types etc. that are not yet supported, etc.
    init?(_ abiString: String, at: EthereumAddress?)

    /// Creates transaction to deploy a smart contract.
    /// - Parameters:
    ///   - bytecode: bytecode to deploy.
    ///   - constructor: constructor to encode `parameters` with.
    ///   - parameters: parameters for `constructor`.
    ///   - extraData: any extra data. It can be encoded input arguments for a constuctor but then you should set `constructor` and
    ///   `parameters` to be `nil`.
    /// - Returns: transaction if given `parameters` were successfully encoded in a `constructor`. If any or both are `nil`
    /// then no encoding will take place and a transaction with `bytecode + extraData`  will be returned.
    func deploy(bytecode: Data,
                constructor: ABI.Element.Constructor?,
                parameters: [AnyObject]?,
                extraData: Data?) -> EthereumTransaction?

    /// Creates function call transaction with data set as `method` encoded with given `parameters`.
    /// The `method` must be part of the ABI used to init this contract.
    /// - Parameters:
    ///   - method: method name in one of the following variants:
    ///     - name without arguments: `myFunction`. Use with caution! If smart contract has overloaded methods encoding might fail!
    ///     - name with arguments:`myFunction(uint256)`.
    ///     - method signature (with or without `0x` prefix, case insensitive): `0xFFffFFff`;
    ///   - parameters: method input arguments;
    ///   - extraData: additional data to append at the end of `transaction.data` field;
    /// - Returns: transaction object if `method` was found and `parameters` were successfully encoded.
    func method(_ method: String, parameters: [AnyObject], extraData: Data?) -> EthereumTransaction?

    /// Decode output data of a function.
    /// - Parameters:
    ///   - method: method name in one of the following variants:
    ///     - name without arguments: `myFunction`. Use with caution! If smart contract has overloaded methods encoding might fail!
    ///     - name with arguments:`myFunction(uint256)`.
    ///     - method signature (with or without `0x` prefix, case insensitive): `0xFFffFFff`;
    ///   - data: non empty bytes to decode;
    /// - Returns: dictionary with decoded values. `nil` if decoding failed.
    func decodeReturnData(_ method: String, data: Data) -> [String: Any]?

    /// Decode input arguments of a function.
    /// - Parameters:
    ///   - method: method name in one of the following variants:
    ///     - name without arguments: `myFunction`. Use with caution! If smart contract has overloaded methods encoding might fail!
    ///     - name with arguments:`myFunction(uint256)`.
    ///     - method signature (with or without `0x` prefix, case insensitive): `0xFFffFFff`;
    ///   - data: non empty bytes to decode;
    /// - Returns: dictionary with decoded values. `nil` if decoding failed.
    func decodeInputData(_ method: String, data: Data) -> [String: Any]?

    /// Decode input data of a function.
    /// - Parameters:
    ///   - data: encoded function call with first 4 bytes being function signature and the rest is input arguments, if any.
    ///   Empty dictionary will be return if function call doesn't accept any input arguments.
    /// - Returns: dictionary with decoded input arguments. `nil` if decoding failed.
    func decodeInputData(_ data: Data) -> [String: Any]?

    /// Attempts to parse given event based on the data from `allEvents`, or in other words based on the given smart contract ABI.
    func parseEvent(_ eventLog: EventLog) -> (eventName:String?, eventData:[String: Any]?)

    func testBloomForEventPrecence(eventName: String, bloom: EthereumBloomFilter) -> Bool?
}

extension ContractProtocol {

    /// Overloading of ``ContractProtocol/deploy(bytecode:constructor:parameters:extraData:)`` to allow
    /// omitting evertyhing but `bytecode`.
    ///
    /// See ``ContractProtocol/deploy(bytecode:constructor:parameters:extraData:)`` for details.
    func deploy(_ bytecode: Data,
                constructor: ABI.Element.Constructor? = nil,
                parameters: [AnyObject]? = nil,
                extraData: Data? = nil) -> EthereumTransaction? {
        return deploy(bytecode: bytecode,
                      constructor: constructor,
                      parameters: parameters,
                      extraData: extraData)
    }

    /// Overloading of ``ContractProtocol/method(_:parameters:extraData:)`` to allow
    /// omitting `extraData` and `parameters` if `method` does not expect any.
    ///
    /// See ``ContractProtocol/method(_:parameters:extraData:)`` for details.
    func method(_ method: String = "fallback",
                parameters: [AnyObject]? = nil,
                extraData: Data? = nil) -> EthereumTransaction? {
        return self.method(method, parameters: parameters ?? [], extraData: extraData)
    }

    func decodeInputData(_ data: Data) -> [String: Any]? {
        guard data.count >= 4 else { return nil }
        let methodId = data[0..<4].toHexString()
        let data = data[4...]
        return decodeInputData(methodId, data: data)
    }
}

public protocol EventFilterComparable {
    func isEqualTo(_ other: AnyObject) -> Bool
}

public protocol EventFilterEncodable {
    func eventFilterEncoded() -> String?
}

public protocol EventFilterable: EventFilterComparable, EventFilterEncodable { }

extension BigUInt: EventFilterable { }
extension BigInt: EventFilterable { }
extension Data: EventFilterable { }
extension String: EventFilterable { }
extension EthereumAddress: EventFilterable { }

public struct EventFilter {
    public enum Block {
        case latest
        case pending
        case blockNumber(UInt64)

        var encoded: String {
            switch self {
            case .latest:
                return "latest"
            case .pending:
                return "pending"
            case .blockNumber(let number):
                return String(number, radix: 16).addHexPrefix()
            }
        }
    }

    public init() { }

    public init(fromBlock: Block?, toBlock: Block?,
                addresses: [EthereumAddress]? = nil,
                parameterFilters: [[EventFilterable]?]? = nil) {
        self.fromBlock = fromBlock
        self.toBlock = toBlock
        self.addresses = addresses
        self.parameterFilters = parameterFilters
    }

    public var fromBlock: Block?
    public var toBlock: Block?
    public var addresses: [EthereumAddress]?
    public var parameterFilters: [[EventFilterable]?]?

    public func rpcPreEncode() -> EventFilterParameters {
        var encoding = EventFilterParameters()
        if self.fromBlock != nil {
            encoding.fromBlock = self.fromBlock!.encoded
        }
        if self.toBlock != nil {
            encoding.toBlock = self.toBlock!.encoded
        }
        if self.addresses != nil {
            if self.addresses!.count == 1 {
                encoding.address = [self.addresses![0].address]
            } else {
                var encodedAddresses = [String?]()
                for addr in self.addresses! {
                    encodedAddresses.append(addr.address)
                }
                encoding.address = encodedAddresses
            }
        }
        return encoding
    }
}
