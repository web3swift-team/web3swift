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
    /// name with input parameters `getData(bytes32)` and 4 bytes signature `0xffffffff` (expected to be lowercased).
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
    ///   - constructor: constructor of the smart contract bytecode is related to. Used to encode `parameters`.
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

/// Contains default implementations of all functions of ``ContractProtocol``.
public protocol DefaultContractProtocol: ContractProtocol {}
extension DefaultContractProtocol {
    public func deploy(bytecode: Data,
                       constructor: ABI.Element.Constructor?,
                       parameters: [AnyObject]?,
                       extraData: Data?) -> EthereumTransaction? {
        var fullData = bytecode

        if let constructor = constructor,
           let parameters = parameters,
           !parameters.isEmpty {
            guard constructor.inputs.count == parameters.count,
                  let encodedData = constructor.encodeParameters(parameters)
            else {
                NSLog("Constructor encoding will fail as the number of input arguments doesn't match the number of given arguments.")
                return nil
            }
            fullData.append(encodedData)
        }

        if let extraData = extraData {
            fullData.append(extraData)
        }

        return EthereumTransaction(to: .contractDeploymentAddress(),
                                   value: BigUInt(0),
                                   data: fullData,
                                   parameters: .init(gasLimit: BigUInt(0), gasPrice: BigUInt(0)))
    }

    public func method(_ method: String,
                       parameters: [AnyObject],
                       extraData: Data?) -> EthereumTransaction? {
        guard let to = self.address else { return nil }

        let params = EthereumParameters(gasLimit: BigUInt(0), gasPrice: BigUInt(0))

        if method == "fallback" {
            return EthereumTransaction(to: to, value: BigUInt(0), data: extraData ?? Data(), parameters: params)
        }

        let method = Data.fromHex(method) == nil ? method : method.addHexPrefix().lowercased()

        guard let abiMethod = methods[method]?.first,
              var encodedData = abiMethod.encodeParameters(parameters) else { return nil }

        if let extraData = extraData {
            encodedData.append(extraData)
        }

        return EthereumTransaction(to: to, value: BigUInt(0), data: encodedData, parameters: params)
    }

    public func parseEvent(_ eventLog: EventLog) -> (eventName: String?, eventData: [String: Any]?) {
        for (eName, ev) in self.events {
            if (!ev.anonymous) {
                if eventLog.topics[0] != ev.topic {
                    continue
                }
                else {
                    let logTopics = eventLog.topics
                    let logData = eventLog.data
                    let parsed = ev.decodeReturnedLogs(eventLogTopics: logTopics, eventLogData: logData)
                    if parsed != nil {
                        return (eName, parsed!)
                    }
                }
            } else {
                let logTopics = eventLog.topics
                let logData = eventLog.data
                let parsed = ev.decodeReturnedLogs(eventLogTopics: logTopics, eventLogData: logData)
                if parsed != nil {
                    return (eName, parsed!)
                }
            }
        }
        return (nil, nil)
    }

    public func testBloomForEventPrecence(eventName: String, bloom: EthereumBloomFilter) -> Bool? {
        guard let event = events[eventName] else { return nil }
        if event.anonymous {
            return true
        }
        return bloom.test(topic: event.topic)
    }

    public func decodeReturnData(_ method: String, data: Data) -> [String: Any]? {
        if method == "fallback" {
            return [String: Any]()
        }
        return methods[method]?.compactMap({ function in
            return function.decodeReturnData(data)
        }).first
    }

    public func decodeInputData(_ method: String, data: Data) -> [String: Any]? {
        if method == "fallback" {
            return nil
        }
        return methods[method]?.compactMap({ function in
            return function.decodeInputData(data)
        }).first
    }

    public func decodeInputData(_ data: Data) -> [String: Any]? {
        guard data.count % 32 == 4 else { return nil }
        let methodSignature = data[0..<4].toHexString().addHexPrefix().lowercased()

        guard let function = methods[methodSignature]?.first else { return nil }
        return function.decodeInputData(Data(data[4 ..< data.count]))
    }
}
