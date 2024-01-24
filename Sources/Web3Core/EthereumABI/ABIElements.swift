//
//  Created by Alex Vlasov on 25/10/2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt

public extension ABI {
    struct Input: Decodable {
        public var name: String?
        public var type: String
        public var indexed: Bool?
        public var components: [Input]?
    }

    struct Output: Decodable {
        public var name: String?
        public var type: String
        public var components: [Output]?
    }

    struct Record: Decodable {
        public var name: String?
        public var type: String?
        public var payable: Bool?
        public var constant: Bool?
        public var stateMutability: String?
        public var inputs: [ABI.Input]?
        public var outputs: [ABI.Output]?
        public var anonymous: Bool?
    }

    enum Element {
        public enum ArraySize { // bytes for convenience
            case staticSize(UInt64)
            case dynamicSize
            case notArray
        }

        case function(Function)
        case constructor(Constructor)
        case fallback(Fallback)
        case event(Event)
        case receive(Receive)
        case error(EthError)

        public enum StateMutability {
            case payable
            case mutating
            case view
            case pure

            var isConstant: Bool {
                switch self {
                case .payable:
                    return false
                case .mutating:
                    return false
                default:
                    return true
                }
            }

            var isPayable: Bool {
                switch self {
                case .payable:
                    return true
                default:
                    return false
                }
            }
        }

        public struct InOut {
            public let name: String
            public let type: ParameterType

            public init(name: String, type: ParameterType) {
                self.name = name.trim()
                self.type = type
            }
        }

        public struct Function {
            public let name: String?
            public let inputs: [InOut]
            public let outputs: [InOut]
            public let stateMutability: StateMutability? = nil
            public let constant: Bool
            public let payable: Bool

            public init(name: String?, inputs: [InOut], outputs: [InOut], constant: Bool, payable: Bool) {
                self.name = name?.trim()
                self.inputs = inputs
                self.outputs = outputs
                self.constant = constant
                self.payable = payable
            }
        }

        public struct Constructor {
            public let inputs: [InOut]
            public let constant: Bool
            public let payable: Bool

            public init(inputs: [InOut], constant: Bool, payable: Bool) {
                self.inputs = inputs
                self.constant = constant
                self.payable = payable
            }
        }

        public struct Fallback {
            public let constant: Bool
            public let payable: Bool

            public init(constant: Bool, payable: Bool) {
                self.constant = constant
                self.payable = payable
            }
        }

        public struct Event {
            public let name: String
            public let inputs: [Input]
            public let anonymous: Bool

            public init(name: String, inputs: [Input], anonymous: Bool) {
                self.name = name.trim()
                self.inputs = inputs
                self.anonymous = anonymous
            }

            public struct Input {
                public let name: String
                public let type: ParameterType
                public let indexed: Bool

                public init(name: String, type: ParameterType, indexed: Bool) {
                    self.name = name.trim()
                    self.type = type
                    self.indexed = indexed
                }
            }
        }
        public struct Receive {
            public let payable: Bool
            public let inputs: [InOut]

            public init(inputs: [InOut], payable: Bool) {
                self.inputs = inputs
                self.payable = payable
            }
        }
        /// Custom structured error type available since solidity 0.8.4
        public struct EthError {
            public let name: String
            public let inputs: [InOut]

            /// e.g. `CustomError(uint32, address sender)`
            public var errorDeclaration: String {
                "\(name)(\(inputs.map { "\($0.type.abiRepresentation) \($0.name)".trim() }.joined(separator: ",")))"
            }

            public init(name: String, inputs: [InOut] = []) {
                self.name = name.trim()
                self.inputs = inputs
            }
        }
    }
}

// MARK: - Function parameters encoding

extension ABI.Element {
    public func encodeParameters(_ parameters: [Any]) -> Data? {
        switch self {
        case .constructor(let constructor):
            return constructor.encodeParameters(parameters)
        case .event:
            return nil
        case .fallback:
            return nil
        case .function(let function):
            return function.encodeParameters(parameters)
        case .receive:
            return nil
        case .error:
            return nil
        }
    }
}

extension ABI.Element.Constructor {
    public func encodeParameters(_ parameters: [Any]) -> Data? {
        guard parameters.count == inputs.count else { return nil }
        return ABIEncoder.encode(types: inputs, values: parameters)
    }
}

extension ABI.Element.Function {

    /// Encode parameters of a given contract method
    /// - Parameters: Parameters to pass to Ethereum contract
    /// - Returns: Encoded data
    public func encodeParameters(_ parameters: [Any]) -> Data? {
        guard parameters.count == inputs.count,
              let data = ABIEncoder.encode(types: inputs, values: parameters) else { return nil }
        return methodEncoding + data
    }
}

// MARK: - Event logs decoding & encoding

extension ABI.Element.Event {
    public func decodeReturnedLogs(eventLogTopics: [Data], eventLogData: Data) -> [String: Any]? {
        guard let eventContent = ABIDecoder.decodeLog(event: self, eventLogTopics: eventLogTopics, eventLogData: eventLogData) else { return nil }
        return eventContent
    }

    public static func encodeTopic(input: ABI.Element.Event.Input, value: Any) -> EventFilterParameters.Topic? {
        switch input.type {
        case .string:
            guard let string = value as? String else {
                return nil
            }
            return .string(string.sha3(.keccak256).addHexPrefix())
        case .dynamicBytes:
            guard let data = ABIEncoder.convertToData(value) else {
                return nil
            }
            return .string(data.sha3(.keccak256).toHexString().addHexPrefix())
        case .bytes(length: _):
            guard let data = ABIEncoder.convertToData(value), let data = data.setLengthLeft(32) else {
                return nil
            }
            return .string(data.toHexString().addHexPrefix())
        case .address, .uint(bits: _), .int(bits: _), .bool:
            guard let encoded = ABIEncoder.encodeSingleType(type: input.type, value: value) else {
                return nil
            }
            return .string(encoded.toHexString().addHexPrefix())
        default:
            guard let data = try? ABIEncoder.abiEncode(value).setLengthLeft(32) else {
                return nil
            }
            return .string(data.toHexString().addHexPrefix())
        }
    }

    public func encodeParameters(_ parameters: [Any?]) -> [EventFilterParameters.Topic?] {
        guard parameters.count <= inputs.count else {
            // too many arguments for fragment
            return []
        }
        var topics: [EventFilterParameters.Topic?] = []

        if !anonymous {
            topics.append(.string(topic.toHexString().addHexPrefix()))
        }

        for (i, p) in parameters.enumerated() {
            let input = inputs[i]
            if !input.indexed {
                // cannot filter non-indexed parameters; must be null
                return []
            }
            if p == nil {
                topics.append(nil)
            } else if input.type.isArray || input.type.isTuple {
                // filtering with tuples or arrays not supported
                return []
            } else if let p = p as? Array<Any> {
                topics.append(.strings(p.map { Self.encodeTopic(input: input, value: $0) }))
            } else {
                topics.append(Self.encodeTopic(input: input, value: p!))
            }
        }

        // Trim off trailing nulls
        while let last = topics.last {
            if last == nil {
                topics.removeLast()
            } else if case .string(let string) = last, string == nil {
                topics.removeLast()
            } else {
                break
            }
        }
        return topics
    }
}

// MARK: - Decode custom error

extension ABI.Element.EthError {
    /// Decodes `revert CustomError(_)` calls.
    /// - Parameters:
    ///  - data: bytes returned by a function call that stripped error signature hash.
    /// - Returns: a dictionary containing decoded data mappend to indices and names of returned values or nil if decoding failed.
    public func decodeEthError(_ data: Data) -> [String: Any]? {
        guard inputs.count * 32 <= data.count,
              let decoded = ABIDecoder.decode(types: inputs, data: data) else {
            return nil
        }

        var result = [String: Any]()
        for (index, out) in inputs.enumerated() {
            result["\(index)"] = decoded[index]
            if !out.name.isEmpty {
                result[out.name] = decoded[index]
            }
        }
        return result
    }

    /// Decodes `revert(string)` or `require(expression, string)` calls.
    /// These calls are decomposed as `Error(string)` error.
    public static func decodeStringError(_ data: Data) -> String? {
        let decoded = ABIDecoder.decode(types: [.init(name: "", type: .string)], data: data)
        return decoded?.first as? String
    }

    /// Decodes `Panic(uint256)` errors.
    /// See more about panic code explain at:  https://docs.soliditylang.org/en/v0.8.21/control-structures.html#panic-via-assert-and-error-via-require
    public static func decodePanicError(_ data: Data) -> BigUInt? {
        let decoded = ABIDecoder.decode(types: [.init(name: "", type: .uint(bits: 256))], data: data)
        return decoded?.first as? BigUInt
    }
}

// MARK: - Function input/output decoding

extension ABI.Element {
    public func decodeReturnData(_ data: Data) -> [String: Any]? {
        switch self {
        case .constructor:
            return nil
        case .event:
            return nil
        case .fallback:
            return nil
        case .function(let function):
            return try? function.decodeReturnData(data)
        case .receive:
            return nil
        case .error:
            return nil
        }
    }

    public func decodeInputData(_ data: Data) -> [String: Any]? {
        guard data.count == 0 || data.count % 32 == 4 else { return nil }

        switch self {
        case .constructor(let constructor):
            return constructor.decodeInputData(data)
        case .event:
            return nil
        case .fallback:
            return nil
        case .function(let function):
            return function.decodeInputData(data)
        case .receive:
            return nil
        case .error:
            return nil
        }
    }
}

extension ABI.Element.Function {
    public func decodeInputData(_ rawData: Data) -> [String: Any]? {
        return ABIDecoder.decodeInputData(rawData, methodEncoding: methodEncoding, inputs: inputs)
    }

    /// Decodes data returned by a function call.
    /// - Parameters:
    ///  - data: bytes returned by a function call;
    /// - Returns: a dictionary containing decoded data mappend to indices and names of returned values if these are not `nil`.
    /// - Throws:
    ///  - `Web3Error.processingError(desc: String)` when decode process failed.
    ///
    /// Return cases:
    /// - when no `outputs` declared:
    /// ```swift
    /// [:]
    /// ```
    /// - when `outputs` declared and decoding completed successfully:
    /// ```swift
    /// ["0": value_1, "1": value_2, ...]
    /// ```
    /// Additionally this dictionary will have mappings to output names if these names are specified in the ABI;
    public func decodeReturnData(_ data: Data) throws -> [String: Any] {
        guard !outputs.isEmpty else {
            NSLog("Function doesn't have any output types to decode given data.")
            return [:]
        }

        guard outputs.count * 32 <= data.count else {
            throw Web3Error.processingError(desc: "Bytes count must be at least \(outputs.count * 32). Given \(data.count). Decoding will fail.")
        }

        // TODO: need improvement - we should be able to tell which value failed to be decoded
        guard let values = ABIDecoder.decode(types: outputs, data: data) else {
            throw Web3Error.processingError(desc: "Failed to decode at least one value.")
        }
        var returnArray: [String: Any] = [:]
        for i in outputs.indices {
            returnArray["\(i)"] = values[i]
            if !outputs[i].name.isEmpty {
                returnArray[outputs[i].name] = values[i]
            }
        }
        return returnArray
    }

    /// Decodes `revert(string)`, `revert CustomError(...)` and `require(expression, string)` calls.
    /// If `data` is empty and `outputs` are not empty it's considered that data is a result of `revert()` or `require(false)`.
    /// - Parameters:
    ///   - data: returned function call data to decode;
    ///   - errors: optional known errors that could be thrown by the function you called.
    /// - Returns: dictionary containing information about the error thrown by the function call.
    ///
    /// What could be returned:
    /// - `nil` if data doesn't represent an error or it failed to be mapped to any of the `errors` or `Error(string)` types;
    /// - `nil` is `data.isEmpty` and `outputs.isEmpty`;
    /// - `data.isEmpty` and `!outputs.isEmpty`:
    /// ```swift
    /// ["_success": false,
    /// "_failureReason": "Cannot decode empty data. X outputs are expected: [outputs_types]. Was this a result of en empty `require(false)` or `revert()` call?"]
    /// ```
    /// - function call was aborted using `revert(message)` or `require(expression, message)`:
    /// ```swift
    /// ["_success": false, "_abortedByRevertOrRequire": true, "_errorMessage": message]`
    /// ```
    /// - function call was aborted using `revert CustomMessage()` and `errors` argument contains the ABI of that custom error type:
    /// ```swift
    /// ["_success": false,
    /// "_abortedByRevertOrRequire": true,
    /// "_error": error_name_and_types, // e.g. `MyCustomError(uint256, address senderAddress)`
    /// "0": error_arg1,
    /// "1": error_arg2,
    /// ...,
    /// "error_arg1_name": error_arg1, // Only named arguments will be mapped to their names, e.g. `"senderAddress": EthereumAddress`
    /// "error_arg2_name": error_arg2, // Otherwise, you can query them by position index.
    /// ...]
    ///
    /// /// or if custo error found but decoding failed
    /// ["_success": false,
    /// "_abortedByRevertOrRequire": true,
    /// // "_error" can contain value like `MyCustomError(uint256, address senderAddress)`
    /// "_error": error_name_and_types,
    /// // "_parsingError" is optional and is present only if decoding of custom error arguments failed
    /// "_parsingError": "Data matches MyCustomError(uint256, address senderAddress) but failed to be decoded."]
    /// ```
    @available(*, deprecated, message: "Use decode function from `ABI.Element.EthError` instead")
    public func decodeErrorResponse(_ data: Data, errors: [String: ABI.Element.EthError]? = nil) -> [String: Any]? {
        /// If data is empty and outputs are expected it is treated as a `require(expression)` or `revert()` call with no message.
        /// In solidity `require(false)` and `revert()` calls return empty error response.
        if data.isEmpty && !outputs.isEmpty {
            return ["_success": false, "_failureReason": "Cannot decode empty data. \(outputs.count) outputs are expected: \(outputs.map { $0.type.abiRepresentation }). Was this a result of en empty `require(false)` or `revert()` call?"]
        }

        /// Explanation of this condition:
        /// When `revert(string)` or `require(false, string)` are called in soliditiy they produce
        /// an error, specifically an instance of default `Error(string)` type.
        /// 1) The total number of bytes returned are at least 100.
        /// 2) The function selector for `Error(string)` is `08C379A0`;
        /// 3) Data offset must be present. Hexadecimal value of `0000...0020` is 32 in decimal. Reasoning for `BigInt(...) == 32`.
        /// 4) `messageLength` is used to determine where message bytes end to decode string correctly.
        /// 5) The rest of the `data` must be 0 bytes or empty.
        if data.bytes.count >= 100,
           Data(data[data.startIndex ..< data.startIndex + 4]) == Data.fromHex("08C379A0"),
           BigInt(data[data.startIndex + 4 ..< data.startIndex + 36]) == 32,
           let messageLength = Int(Data(data[data.startIndex + 36 ..< data.startIndex + 68]).toHexString(), radix: 16),
           let message = String(bytes: data.bytes[68..<(68+messageLength)], encoding: .utf8),
           (68+messageLength == data.count || data.bytes[68+messageLength..<data.count].reduce(0) { $0 + $1 } == 0) {
            return ["_success": false,
                    "_failureReason": "`revert(string)` or `require(expression, string)` was executed.",
                    "_abortedByRevertOrRequire": true,
                    "_errorMessage": message]
        }

        if data.count >= 4,
           let errors = errors,
           let customError = errors[data[data.startIndex ..< data.startIndex + 4].toHexString().stripHexPrefix()] {
            var errorResponse: [String: Any] = ["_success": false, "_abortedByRevertOrRequire": true, "_error": customError.errorDeclaration]

            if (data.count > 32 && !customError.inputs.isEmpty),
               let decodedInputs = ABIDecoder.decode(types: customError.inputs, data: Data(data[data.startIndex + 4 ..< data.startIndex + data.count])) {
                for idx in decodedInputs.indices {
                    errorResponse["\(idx)"] = decodedInputs[idx]
                    if !customError.inputs[idx].name.isEmpty {
                        errorResponse[customError.inputs[idx].name] = decodedInputs[idx]
                    }
                }
            } else if !customError.inputs.isEmpty {
                errorResponse["_parsingError"] = "Data matches \(customError.errorDeclaration) but failed to be decoded."
            }
            return errorResponse
        }
        return nil
    }
}

extension ABI.Element.Constructor {
    public func decodeInputData(_ rawData: Data) -> [String: Any]? {
        return ABIDecoder.decodeInputData(rawData, inputs: inputs)
    }
}

extension ABIDecoder {
    /// Generic input decoding function.
    /// - Parameters:
    ///   - rawData: data to decode. Must match the following criteria: `data.count == 0 || data.count % 32 == 4`.
    ///   - methodEncoding: 4 bytes representing method signature like `0xFFffFFff`. Can be omitted to avoid checking method encoding.
    ///   - inputs: expected input types. Order must be the same as in function declaration.
    /// - Returns: decoded dictionary of input arguments mapped to their indices and arguments' names if these are not empty.
    /// If decoding of at least one argument fails, `rawData` size is invalid or `methodEncoding` doesn't match - `nil` is returned.
    static func decodeInputData(_ rawData: Data,
                                     methodEncoding: Data? = nil,
                                     inputs: [ABI.Element.InOut]) -> [String: Any]? {
        let data: Data
        let sig: Data?

        switch rawData.count % 32 {
        case 0:
            sig = nil
            data = Data()
            break
        case 4:
            sig = rawData[0 ..< 4]
            data = Data(rawData[4 ..< rawData.count])
        default:
            return nil
        }

        if methodEncoding != nil && sig != nil && sig != methodEncoding {
            return nil
        }

        var returnArray = [String: Any]()
        if data.count == 0 && inputs.count == 1 {
            let name = "0"
            let value = inputs[0].type.emptyValue
            returnArray[name] = value
            if inputs[0].name != "" {
                returnArray[inputs[0].name] = value
            }
        } else {
            guard inputs.count * 32 <= data.count else { return nil }

            var i = 0
            guard let values = ABIDecoder.decode(types: inputs, data: data) else { return nil }
            for input in inputs {
                let name = "\(i)"
                returnArray[name] = values[i]
                if input.name != "" {
                    returnArray[input.name] = values[i]
                }
                i = i + 1
            }
        }
        return returnArray
    }
}
