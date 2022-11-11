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
                self.name = name
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
                self.name = name
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
                self.name = name
                self.inputs = inputs
                self.anonymous = anonymous
            }

            public struct Input {
                public let name: String
                public let type: ParameterType
                public let indexed: Bool

                public init(name: String, type: ParameterType, indexed: Bool) {
                    self.name = name
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
            public let inputs: [Input]
            
            public struct Input {
                public let name: String
                public let type: ParameterType
                
                public init(name: String, type: ParameterType) {
                    self.name = name
                    self.type = type
                }
            }
        }
    }
}

// MARK: - Function parameters encoding

extension ABI.Element {
    public func encodeParameters(_ parameters: [AnyObject]) -> Data? {
        switch self {
        case .constructor(let constructor):
            return constructor.encodeParameters(parameters)
        case .event(_):
            return nil
        case .fallback(_):
            return nil
        case .function(let function):
            return function.encodeParameters(parameters)
        case .receive(_):
            return nil
        case .error(_):
            return nil
        }
    }
}

extension ABI.Element.Constructor {
    public func encodeParameters(_ parameters: [AnyObject]) -> Data? {
        guard parameters.count == inputs.count else { return nil }
        return ABIEncoder.encode(types: inputs, values: parameters)
    }
}

extension ABI.Element.Function {

    /// Encode parameters of a given contract method
    /// - Parameter parameters: Parameters to pass to Ethereum contract
    /// - Returns: Encoded data 
    public func encodeParameters(_ parameters: [AnyObject]) -> Data? {
        guard parameters.count == inputs.count,
              let data = ABIEncoder.encode(types: inputs, values: parameters) else { return nil }
        return methodEncoding + data
    }
}

// MARK: - Event logs decoding

extension ABI.Element.Event {
    public func decodeReturnedLogs(eventLogTopics: [Data], eventLogData: Data) -> [String: Any]? {
        guard let eventContent = ABIDecoder.decodeLog(event: self, eventLogTopics: eventLogTopics, eventLogData: eventLogData) else {return nil}
        return eventContent
    }
}

// MARK: - Function input/output decoding

extension ABI.Element {
    public func decodeReturnData(_ data: Data) -> [String: Any]? {
        switch self {
        case .constructor(_):
            return nil
        case .event(_):
            return nil
        case .fallback(_):
            return nil
        case .function(let function):
            return function.decodeReturnData(data)
        case .receive(_):
            return nil
        case .error(_):
            return nil
        }
    }

    public func decodeInputData(_ data: Data) -> [String: Any]? {
        guard data.count == 0 || data.count % 32 == 4 else { return nil }

        switch self {
        case .constructor(let constructor):
            return constructor.decodeInputData(data)
        case .event(_):
            return nil
        case .fallback(_):
            return nil
        case .function(let function):
            return function.decodeInputData(data)
        case .receive(_):
            return nil
        case .error(_):
            return nil
        }
    }
}

extension ABI.Element.Function {
    public func decodeInputData(_ rawData: Data) -> [String: Any]? {
        return Core.decodeInputData(rawData, methodEncoding: methodEncoding, inputs: inputs)
    }

    public func decodeReturnData(_ data: Data) -> [String: Any]? {
        // the response size greater than equal 100 bytes, when read function aborted by "require" statement.
        // if "require" statement has no message argument, the response is empty (0 byte).
        if data.bytes.count >= 100 {
            let check00_31 = BigUInt("08C379A000000000000000000000000000000000000000000000000000000000", radix: 16)!
            let check32_63 = BigUInt("0000002000000000000000000000000000000000000000000000000000000000", radix: 16)!

            // check data[00-31] and data[32-63]
            if check00_31 == BigUInt(data[0...31]) && check32_63 == BigUInt(data[32...63]) {
                // data.bytes[64-67] contains the length of require message
                let len = (Int(data.bytes[64])<<24) | (Int(data.bytes[65])<<16) | (Int(data.bytes[66])<<8) | Int(data.bytes[67])

                let message = String(bytes: data.bytes[68..<(68+len)], encoding: .utf8)!

                print("read function aborted by require statement: \(message)")

                var returnArray = [String: Any]()

                // set infomation
                returnArray["_abortedByRequire"] = true
                returnArray["_errorMessageFromRequire"] = message

                // set empty values
                for i in 0 ..< outputs.count {
                    let name = "\(i)"
                    returnArray[name] = outputs[i].type.emptyValue
                    if outputs[i].name != "" {
                        returnArray[outputs[i].name] = outputs[i].type.emptyValue
                    }
                }

                return returnArray
            }
        }

        var returnArray = [String: Any]()

        // the "require" statement with no message argument will be caught here
        if data.count == 0 && outputs.count == 1 {
            let name = "0"
            let value = outputs[0].type.emptyValue
            returnArray[name] = value
            if outputs[0].name != "" {
                returnArray[outputs[0].name] = value
            }
        } else {
            guard outputs.count * 32 <= data.count else { return nil }

            var i = 0
            guard let values = ABIDecoder.decode(types: outputs, data: data) else { return nil }
            for output in outputs {
                let name = "\(i)"
                returnArray[name] = values[i]
                if output.name != "" {
                    returnArray[output.name] = values[i]
                }
                i = i + 1
            }
            // set a flag to detect the request succeeded
        }

        if returnArray.isEmpty && !outputs.isEmpty && data.isEmpty{
            return nil
        }

        returnArray["_success"] = true
        return returnArray
    }
}

extension ABI.Element.Constructor {
    public func decodeInputData(_ rawData: Data) -> [String: Any]? {
        return Core.decodeInputData(rawData, inputs: inputs)
    }
}

/// Generic input decoding function.
/// - Parameters:
///   - rawData: data to decode. Must match the followin criteria: `data.count == 0 || data.count % 32 == 4`.
///   - methodEncoding: 4 bytes represeting method signature like `0xFFffFFff`. Can be ommited to avoid checking method encoding.
///   - inputs: expected input types. Order must be the same as in function declaration.
/// - Returns: decoded dictionary of input arguments mapped to their indices and arguments' names if these are not empty.
/// If decoding of at least one argument fails, `rawData` size is invalid or `methodEncoding` doesn't match - `nil` is returned.
fileprivate func decodeInputData(_ rawData: Data,
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
        guard let values = ABIDecoder.decode(types: inputs, data: data) else {return nil}
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
