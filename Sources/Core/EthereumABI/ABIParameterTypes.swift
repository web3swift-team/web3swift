//
//  Created by Alex Vlasov on 25/10/2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt

extension ABI.Element {

    /// Specifies the type that parameters in a contract have.
    public enum ParameterType: ABIElementPropertiesProtocol {
        case uint(bits: UInt64)
        case int(bits: UInt64)
        case address
        case function
        case bool
        case bytes(length: UInt64)
        indirect case array(type: ParameterType, length: UInt64)
        case dynamicBytes
        case string
        indirect case tuple(types: [ParameterType])

        var isStatic: Bool {
            switch self {
            case .string:
                return false
            case .dynamicBytes:
                return false
            case .array(type: let type, length: let length):
                if length == 0 {
                    return false
                }
                if !type.isStatic {
                    return false
                }
                return true
            case .tuple(types: let types):
                for t in types {
                    if !t.isStatic {
                        return false
                    }
                }
                return true
            case .bytes(length: _):
                return true
            default:
                return true
            }
        }

        var isArray: Bool {
            switch self {
            case .array(type: _, length: _):
                return true
            default:
                return false
            }
        }

        var isTuple: Bool {
            switch self {
            case .tuple:
                return true
            default:
                return false
            }
        }

        var subtype: ABI.Element.ParameterType? {
            switch self {
            case .array(type: let type, length: _):
                return type
            default:
                return nil
            }
        }

        var memoryUsage: UInt64 {
            switch self {
            case .array(_, length: let length):
                if length == 0 {
                    return 32
                }
                if self.isStatic {
                    return 32*length
                }
                return 32
            case .tuple(types: let types):
                if !self.isStatic {
                    return 32
                }
                var sum: UInt64 = 0
                for t in types {
                    sum = sum + t.memoryUsage
                }
                return sum
            default:
                return 32
            }
        }

        var emptyValue: Any {
            switch self {
            case .uint(bits: _):
                return BigUInt(0)
            case .int(bits: _):
                return BigUInt(0)
            case .address:
                return EthereumAddress("0x0000000000000000000000000000000000000000")!
            case .function:
                return Data(repeating: 0x00, count: 24)
            case .bool:
                return false
            case .bytes(length: let length):
                return Data(repeating: 0x00, count: Int(length))
            case .array(type: let type, length: let length):
                let emptyValueOfType = type.emptyValue
                return Array.init(repeating: emptyValueOfType, count: Int(length))
            case .dynamicBytes:
                return Data()
            case .string:
                return ""
            case .tuple(types: _):
                return [Any]()
            }
        }

        var arraySize: ABI.Element.ArraySize {
            switch self {
            case .array(type: _, length: let length):
                if length == 0 {
                    return ArraySize.dynamicSize
                }
                return ArraySize.staticSize(length)
            default:
                return ArraySize.notArray
            }
        }
    }
}

extension ABI.Element.ParameterType: Equatable {
    public static func ==(lhs: ABI.Element.ParameterType, rhs: ABI.Element.ParameterType) -> Bool {
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

extension ABI.Element.Function {
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
extension ABI.Element.Event {
    public var signature: String {
        return "\(name)(\(inputs.map { $0.type.abiRepresentation }.joined(separator: ",")))"
    }

    public var topic: Data {
        return signature.data(using: .ascii)!.sha3(.keccak256)
    }
}

extension ABI.Element.ParameterType: ABIEncoding {
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
        case .array(type: let type, length: let length):
            if length == 0 {
                return  "\(type.abiRepresentation)[]"
            }
            return "\(type.abiRepresentation)[\(length)]"
        case .tuple(types: let types):
            let typesRepresentation = types.map({return $0.abiRepresentation})
            let typesJoined = typesRepresentation.joined(separator: ",")
            return "(\(typesJoined))"
        case .string:
            return "string"
        }
    }
}

extension ABI.Element.ParameterType: ABIValidation {
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
                if !t.isValid {
                    return false
                }
            }
            return true
        default:
            return true
        }
    }
}
