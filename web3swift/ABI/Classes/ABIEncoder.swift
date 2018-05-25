//
//  ABIEncoder.swift
//  web3swift
//
//  Created by Alexander Vlasov on 05.12.2017.
//  Copyright © 2017 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt

extension ABIElement.ParameterType {
    func encode(_ value: AnyObject) -> Data? {
        switch self {
        case .staticABIType(let type):
            return type.encode(value)
        case .dynamicABIType(let type):
            return type.encode(value)
        }
    }
    func encode(_ values: [AnyObject]) -> Data? {
        switch self {
        case .staticABIType(let type):
            return type.encode(values)
        case .dynamicABIType(let type):
            return type.encode(values)
        }
    }
}

extension ABIElement.ParameterType.StaticType {
    
    func encode(_ value: AnyObject) -> Data? {
        switch self {
        case .uint(_):
            if let biguint = value as? BigUInt {
                return biguint.abiEncode(bits: 256);
            }
            if let bigint = value as? BigInt {
                return bigint.abiEncode(bits: 256);
            }
        case .int(_):
            if let biguint = value as? BigUInt {
                return biguint.abiEncode(bits: 256);
            }
            if let bigint = value as? BigInt {
                return bigint.abiEncode(bits: 256);
            }
        case .address:
            if let string = value as? String {
                let address = EthereumAddress(string)
                guard address.isValid  else {return nil}
                let data = address.addressData
                return data.setLengthLeft(32)
            } else if let address = value as? EthereumAddress {
                guard address.isValid else {return nil}
                let data = address.addressData
                return data.setLengthLeft(32)
            } else if let data = value as? Data {
                return data.setLengthLeft(32)
            }
        case .bool:
            if let bool = value as? Bool {
                if (bool) {
                    return BigUInt(1).abiEncode(bits: 256)
                } else {
                    return BigUInt(0).abiEncode(bits: 256)
                }
            }
        case .bytes(let length):
            if let string = value as? String {
                var dataGuess: Data?
                if string.hasHexPrefix() {
                    dataGuess = Data.fromHex(string.lowercased().stripHexPrefix())
                }
                else {
                    dataGuess = string.data(using: .utf8)
                }
                guard let data = dataGuess else {return nil}
                if data.count > length {return nil}
                return data.setLengthRight(32)
            } else if let addr = value as? EthereumAddress {
                guard addr.isValid else {return nil}
                let data = addr.addressData
                return data.setLengthRight(32)
            } else if let data = value as? Data {
                return data.setLengthRight(32)
            }
        default:
            return nil
        }
        return nil
    }
    
    func encode(_ values: [AnyObject]) -> Data? {
        switch self {
        case let .array(type, length):
            if (values.count != length) {
                return nil
            }
            var data = Data()
            for value in values {
                if let arrayOfValues = value as? [AnyObject] {
                    guard case .array(let subtype, length: let sublength) = type else {return nil}
                    guard sublength == arrayOfValues.count else {return nil}
                    guard let encoded = TypesEncoder.encode(types: Array(repeating: ABIElement.ParameterType.staticABIType(subtype), count: Int(sublength)), parameters: arrayOfValues) else {
                        return nil
                    }
//                    guard let encoded = type.encode(arrayOfValues) else {
//                        return nil
//                    }
                    data.append(encoded)
                } else {
                    guard let encoded = type.encode(value) else {
                        return nil
                    }
                    data.append(encoded)
                }
            }
            return data
        default:
            return nil
        }
    }
    
    
}

extension ABIElement.ParameterType.DynamicType {
    func encode(_ value: AnyObject) -> Data? {
        switch self {
        case .string:
            if let string = value as? String {
                guard let data = string.data(using: .utf8) else {return nil}
                let lengthToPad = UInt64(ceil(Double(data.count) / 32.0)) * 32
                guard let lengthEncoded = BigUInt(data.count).abiEncode(bits: 256) else {return nil}
                guard let paddedData = data.setLengthRight(lengthToPad) else {return nil}
                return lengthEncoded + paddedData
            } else if let data = value as? Data {
                let lengthToPad = UInt64(ceil(Double(data.count) / 32.0)) * 32
                guard let lengthEncoded = BigUInt(data.count).abiEncode(bits: 256) else {return nil}
                guard let paddedData = data.setLengthRight(lengthToPad) else {return (nil)}
                return lengthEncoded + paddedData
            }
            return nil
        case .bytes:
            if let string = value as? String {
                var dataGuess: Data?
                if string.hasHexPrefix() {
                    dataGuess = Data.fromHex(string.lowercased().stripHexPrefix())
                }
                else {
                    dataGuess = string.data(using: .utf8)
                }
                guard let data = dataGuess else {return nil}
                let lengthToPad = UInt64(ceil(Double(data.count) / 32.0)) * 32
                guard let lengthEncoded = BigUInt(data.count).abiEncode(bits: 256) else {return nil}
                guard let paddedData = data.setLengthRight(lengthToPad) else {return nil}
                return lengthEncoded + paddedData
            } else if let data = value as? Data {
                let lengthToPad = UInt64(ceil(Double(data.count) / 32.0)) * 32
                guard let lengthEncoded = BigUInt(data.count).abiEncode(bits: 256) else {return nil}
                guard let paddedData = data.setLengthRight(lengthToPad) else {return (nil)}
                return lengthEncoded + paddedData
            }
        default:
            return nil
        }
        return nil
    }
    
    func encode(_ values: [AnyObject]) -> Data? {
        switch self {
        case let .dynamicArray(type):
            var data = Data()
            for value in values {
                guard let encoded = type.encode(value) else {return nil}
                data.append(encoded)
            }
            let length = values.count
            guard let encodedLen = BigUInt(length).abiEncode(bits: 256) else {return nil}
            return encodedLen + data
        case let .arrayOfDynamicTypes(type, length: length):
            let typesArray = Array(repeating: ABIElement.ParameterType.dynamicABIType(type), count: Int(length))
            guard let data = TypesEncoder.encode(types: typesArray, parameters: values) else {return nil}
            return data
//            var data = Data()
//            for value in values {
//                guard let encoded = type.encode(value) else {return nil}
//                data.append(encoded)
//            }
//            guard let encodedLen = BigUInt(length).abiEncode(bits: 256) else {return nil}
//            return encodedLen + data
        default:
            return nil
        }
    }
}

extension ABIElement {
    func encodeParameters(_ parameters: [AnyObject]) -> Data? {
        switch self {
        case .constructor(let constructor):
            guard parameters.count == constructor.inputs.count else {return nil}
            let allTypes = constructor.inputs.compactMap({ (input) -> ABIElement.ParameterType in
                return input.type
            })
            guard let data = TypesEncoder.encode(types: allTypes, parameters: parameters) else {return nil}
            return data
        case .event(_):
            return nil
        case .fallback(_):
            return nil
        case .function(let function):
            guard parameters.count == function.inputs.count else {return nil}
            let allTypes = function.inputs.compactMap({ (input) -> ABIElement.ParameterType in
                return input.type
            })
            let signature = function.methodEncoding
            guard let data = TypesEncoder.encode(types: allTypes, parameters: parameters) else {return nil}
            return signature + data
        }
    }
}

