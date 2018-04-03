//
//  ABIElementsConvenience.swift
//  web3swift
//
//  Created by Alexander Vlasov on 02.04.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//
import Foundation

fileprivate typealias ParameterType = ABIv2.Element.ParameterType;

extension ABIv2.Element.ParameterType: Equatable {
    public static func ==(lhs: ABIv2.Element.ParameterType, rhs: ABIv2.Element.ParameterType) -> Bool {
        switch (lhs, rhs) {
        case let (.uint(length1), .uint(length2)):
            return length1 == length2
        case let (.int(length1), .int(length2)):
            return length1 == length2
        case (.address, .address):
            return true
        case (.bool, .bool):
            return true
        case let (.bytes(length1), .bytes(length2)):
            return length1 == length2
        case (.function, .function):
            return true
        case let (.array(type1, length1), .array(type2, length2)):
            return type1 == type2 && length1 == length2
        case (.dynamicBytes, .dynamicBytes):
            return true
        case (.string, .string):
            return true
        default:
            return false
        }
    }
}

extension ABIv2.Element.Function {
    public var signature: String {
        return "\(name ?? "")(\(inputs.map { $0.type.abiRepresentation }.joined(separator: ",")))"
    }
    
    public var methodString: String {
        return String(signature.sha3(.keccak256).prefix(8))
    }
    
    public var methodEncoding: Data {
        return signature.data(using: .ascii)!.sha3(.keccak256)[0...3]
    }
}

// MARK: - Event topic
extension ABIv2.Element.Event {
    public var signature: String {
        return "\(name)(\(inputs.map { $0.type.abiRepresentation }.joined(separator: ",")))"
    }
    
    public var topic: Data {
        return signature.data(using: .ascii)!.sha3(.keccak256)
    }
}


extension ABIv2.Element.ParameterType: ABIv2Encoding {
    public var abiRepresentation: String {
        switch self {
        case .uint(let bits):
            return "uint\(bits)"
        case .int(let bits):
            return "int\(bits)"
        case .address:
            return "address"
        case .bool:
            return "bool"
        case .bytes(let length):
            return "bytes\(length)"
        case .dynamicBytes:
            return "bytes"
        case .function:
            return "function"
        case let .array(type, length):
            return "\(type.abiRepresentation)[\(length)]"
        }
    }
}

extension ABIv2.Element.ParameterType: ABIv2Validation {
    public var isValid: Bool {
        switch self {
        case .uint(let bits), .int(let bits):
            return bits > 0 && bits <= 256 && bits % 8 == 0
        case .bytes(let length):
            return length > 0 && length <= 32
        case .array(type: let type, _):
            return type.isValid
        case .tuple(types: let types):
            for t in types {
                if (!t.isValid) {
                    return false
                }
            }
            return true
        default:
            return true
        }
    }
}
