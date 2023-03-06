//
//  ContractProtocol.swift
//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt

/// Standard representation of a smart contract.
///
/// ## How to
/// To create a smart contract deployment transaction there is only one requirement - `bytecode`.
/// That is the compiled smart contract that is ready to be executed by EVM, or eWASM if that is a Serenity.
/// Creating a transaction is as simple as:
///
/// ```swift
/// contractInstance.deploy(bytecode: smartContractBytecode)
/// ```
///
/// One of the default implementations of `ContractProtocol` is ``EthereumContract``.
/// ```swift
/// let contract = EthereumContract(abi: [])
/// contract.deploy(bytecode: smartContractBytecode)
/// ```
///
/// ### Setting constructor arguments
/// Some smart contracts expect input arguments for a constructor that is called on contract deployment.
/// To set these input arguments you must provide `constructor` and `parameters`.
/// Constructor can be statically created if you know upfront what are the input arguments and their exact order:
///
/// ```swift
/// let inputArgsTypes: [ABI.Element.InOut] = [.init(name: "firstArgument", type: ABI.Element.ParameterType.string),
///                                            .init(name: "secondArgument", type: ABI.Element.ParameterType.uint(bits: 256))]
/// let constructor = ABI.Element.Constructor(inputs: inputArgsTypes, constant: false, payable: payable)
/// let constructorArguments: [Any] = ["This is the array of constructor arguments", 10_000]
///
/// contract.deploy(bytecode: smartContractBytecode,
///                 constructor: constructor,
///                 parameters: constructorArguments)
/// ```
///
/// Alternatively, if you have ABI string that holds meta data about the constructor you can use it instead of creating constructor manually.
/// But you must make sure the arguments for constructor call are of expected type in and correct order.
/// Example of ABI string can be found in ``Web3/Utils/erc20ABI``.
///
/// ```swift
/// let contract = EthereumContract(abiString)
/// let constructorArguments: [Any] = ["This is the array of constructor arguments", 10_000]
///
/// contract.deploy(bytecode: smartContractBytecode,
///                 constructor: contract.constructor,
///                 parameters: constructorArguments)
/// ```
///
/// ⚠️ If you pass in only constructor or only parameters - it will have no effect on the final transaction object.
/// Also, you have an option to set any extra bytes at the end of ``CodableTransaction/data``  attribute.
/// Alternatively you can encode constructor parameters outside of the deploy function and only set `extraData` to pass in these
/// parameters:
///
/// ```swift
/// // `encodeParameters` call returns `Data?`. Check it for nullability before calling `deploy`
/// // function to create `CodableTransaction`.
/// let encodedConstructorArguments = someConstructor.encodeParameters(arrayOfInputArguments)
/// constructor.deploy(bytecode: smartContractBytecode, extraData: encodedConstructorArguments)
/// ```
public protocol ContractProtocol {
    /// Address of the referenced smart contract. Can be set later, e.g. if the contract is deploying and address is not yet known.
    var address: EthereumAddress? {get set}

    /// All ABI elements like: events, functions, constructors and errors.
    var abi: [ABI.Element] {get}

    /// Functions filtered from ``abi``.
    /// Functions are mapped to:
    /// - name, like `getData` that is defined in ``ABI/Element/Function/name``;
    /// - name with input parameters that is a combination of ``ABI/Element/Function/name`` and
    /// ``ABI/Element/Function/inputs``, e.g. `getData(bytes32)`;
    /// - and 4 bytes signature `0xffffffff` (expected to be lowercased).
    /// The mapping by name (e.g. `getData`) is the one most likely expected to return arrays with
    /// more than one entry due to the fact that solidity allows method overloading.
    var methods: [String: [ABI.Element.Function]] {get}

    /// All values from ``methods``.
    var allMethods: [ABI.Element.Function] {get}

    /// Events filtered from ``abi`` and mapped to their unchanged ``ABI/Element/Event/name``.
    var events: [String: ABI.Element.Event] {get}

    /// All values from ``events``.
    var allEvents: [ABI.Element.Event] {get}

    /// Errors filtered from ``abi`` and mapped to their unchanged ``ABI/Element/EthError/name``.
    var errors: [String: ABI.Element.EthError] {get}

    /// All values from ``errors``.
    var allErrors: [ABI.Element.EthError] {get}

    /// Parsed from ABI or a default constructor with no input arguments.
    var constructor: ABI.Element.Constructor {get}

    /// Required initializer that is capable of reading ABI in JSON format.
    /// - Parameters:
    ///   - abiString: ABI string in JSON format.
    ///   - at: contract added. Can be set later.
    ///
    /// If ABI failed to be decoded `nil` will be returned. Reasons could be invalid keys and values in ABI, invalid JSON structure,
    /// new Solidity keywords, types etc. that are not yet supported, etc.
    init(_ abiString: String, at: EthereumAddress?) throws

    /// Prepare transaction data for smart contract deployment transaction.
    ///
    /// - Parameters:
    ///   - bytecode: bytecode to deploy.
    ///   - constructor: constructor of the smart contract bytecode is related to. Used to encode `parameters`.
    ///   - parameters: parameters for `constructor`.
    ///   - extraData: any extra data. It can be encoded input arguments for a constructor but then you should set `constructor` and
    ///   `parameters` to be `nil`.
    /// - Returns: Encoded data for a given parameters, which is should be assigned to ``CodableTransaction.data`` property
    func deploy(bytecode: Data,
                constructor: ABI.Element.Constructor?,
                parameters: [Any]?,
                extraData: Data?) -> Data?

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
    func method(_ method: String, parameters: [Any], extraData: Data?) -> Data?

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
    func parseEvent(_ eventLog: EventLog) -> (eventName: String?, eventData: [String: Any]?)

    /// Tests for probable presence of an event with `eventName` in a given bloom filter.
    /// - Parameters:
    ///   - eventName: event name like `ValueReceived`.
    ///   - bloom: bloom filter.
    /// - Returns: `true` if event is possibly present, `false` if definitely not present and `nil` if event with given name
    /// is not part of the ``EthereumContract/abi``.
    func testBloomForEventPresence(eventName: String, bloom: EthereumBloomFilter) -> Bool?

    /// Given the transaction data searches for a match in ``ContractProtocol/methods``.
    /// - Parameter data: encoded function call used in transaction data field. Must be at least 4 bytes long.
    /// - Returns: function decoded from the ABI of this contract or `nil` if nothing was found.
    func getFunctionCalled(_ data: Data) -> ABI.Element.Function?
}

// MARK: - Overloaded ContractProtocol's functions

extension ContractProtocol {

    /// Overloading of ``ContractProtocol/deploy(bytecode:constructor:parameters:extraData:)`` to allow
    /// omitting everything but `bytecode`.
    ///
    /// See ``ContractProtocol/deploy(bytecode:constructor:parameters:extraData:)`` for details.
    func deploy(_ bytecode: Data,
                constructor: ABI.Element.Constructor? = nil,
                parameters: [Any]? = nil,
                extraData: Data? = nil) -> Data? {
        deploy(bytecode: bytecode,
               constructor: constructor,
               parameters: parameters,
               extraData: extraData)
    }

    /// Overloading of ``ContractProtocol/method(_:parameters:extraData:)`` to allow
    /// omitting `extraData` and `parameters` if `method` does not expect any.
    ///
    /// See ``ContractProtocol/method(_:parameters:extraData:)`` for details.
    func method(_ method: String = "fallback",
                parameters: [Any]? = nil,
                extraData: Data? = nil) -> Data? {
        self.method(method, parameters: parameters ?? [], extraData: extraData)
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
    // MARK: Writing Data flow
    public func deploy(bytecode: Data,
                       constructor: ABI.Element.Constructor?,
                       parameters: [Any]?,
                       extraData: Data?) -> Data? {
        var fullData = bytecode

        if let constructor = constructor,
           let parameters = parameters,
           !parameters.isEmpty {
            guard constructor.inputs.count == parameters.count,
                  let encodedData = constructor.encodeParameters(parameters) else {
                NSLog("Constructor encoding will fail as the number of input arguments doesn't match the number of given arguments.")
                return nil
            }
            fullData.append(encodedData)
        }

        if let extraData = extraData {
            fullData.append(extraData)
        }

        // MARK: Writing Data flow
        return fullData
    }

    /// Call given contract method with given parameters
    /// - Parameters:
    ///   - method: Method to call
    ///   - parameters: Parameters to pass to method call
    ///   - extraData: Any additional data that needs to be encoded
    /// - Returns: preset CodableTransaction with filled date
    ///
    /// Returned transaction have filled following priperties:
    ///   - to: contractAddress
    ///   - value: 0
    ///   - data: parameters + extraData
    ///   - params: EthereumParameters with no contract method call encoded data.
    public func method(_ method: String,
                       parameters: [Any],
                       extraData: Data?) -> Data? {
        // MARK: - Encoding ABI Data flow
        if method == "fallback" {
            return extraData ?? Data()
        }

        let method = Data.fromHex(method) == nil ? method : method.addHexPrefix().lowercased()

        // MARK: - Encoding ABI Data flow
        guard let abiMethod = methods[method]?.first(where: { $0.inputs.count == parameters.count }),
              var encodedData = abiMethod.encodeParameters(parameters) else { return nil }

        // Extra data just appends in the end of parameters data
        if let extraData = extraData {
            encodedData.append(extraData)
        }

        // MARK: - Encoding ABI Data flow
        return encodedData
    }

    public func parseEvent(_ eventLog: EventLog) -> (eventName: String?, eventData: [String: Any]?) {
        for (eName, ev) in self.events {
            if !ev.anonymous {
                if eventLog.topics[0] != ev.topic {
                    continue
                } else {
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

    public func testBloomForEventPresence(eventName: String, bloom: EthereumBloomFilter) -> Bool? {
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

    public func getFunctionCalled(_ data: Data) -> ABI.Element.Function? {
        guard data.count >= 4 else { return nil }
        return methods[data[0..<4].toHexString().addHexPrefix()]?.first
    }
}
