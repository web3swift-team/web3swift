//
//  ABIEncoder.swift
//  web3swift
//
//  Created by Alexander Vlasov on 05.12.2017.
//  Copyright © 2017 Alexander Vlasov. All rights reserved.
//

import Foundation
import Sodium
import BigInt

extension Data {
    func padLeft(_ toBytes: Int, isNegative:Bool = false ) -> Data? {
        let existingLength = self.count;
        if (existingLength == toBytes) {
            return Data(self)
        } else if (existingLength > toBytes) {
            return nil
        }
        var data:Data
        if (isNegative) {
            data = Data(repeating: UInt8(255), count: toBytes - existingLength)
        } else {
            data = Data(repeating: UInt8(0), count: toBytes - existingLength)
        }
        data.append(self)
        return data
    }
}

extension BigInt {
    func toTwosComplement() -> Data {
        if (self.sign == BigInt.Sign.plus) {
            return self.magnitude.serialize()
        } else {
            let serializedLength = self.magnitude.serialize().count
            let MAX = BigUInt(1) << serializedLength*8
            let twoComplement = MAX - self.magnitude
            return twoComplement.serialize()
        }
    }
}

extension ABIElement.ParameterType {
    func encode(_ value: AnyObject) -> Data? {
        switch self {
        case .staticType(let type):
            return type.encode(value)
        case .dynamicType(let type):
            return type.encode(value)
        }
    }
    func encode(_ values: [AnyObject]) -> Data? {
        switch self {
        case .staticType(let type):
            return type.encode(values)
        case .dynamicType(let type):
            return type.encode(values)
        }
    }
    
    static func abiEncode(_ value: BigUInt, bits: Int) -> Data? {
        let data = value.serialize()
        let paddedLength = Int(ceil((Double(bits)/8.0)))
        let padded = data.padLeft(paddedLength)
        return padded
    }
    
    static func abiEncode(_ value: BigInt, bits: Int) -> Data? {
        let isNegative = value >= (BigInt(0))
        let data = value.toTwosComplement()
        let paddedLength = Int(ceil((Double(bits)/8.0)))
        let padded = data.padLeft(paddedLength, isNegative: isNegative)
        return padded
    }
}

extension ABIElement.ParameterType.StaticType {
    
    func encode(_ value: AnyObject) -> Data? {
        let sodium = Sodium()
        switch self {
        case .uint(let bits):
            if let biguint = value as? BigUInt {
                return ABIElement.ParameterType.abiEncode(biguint, bits: bits);
            }
            if let bigint = value as? BigInt {
                return ABIElement.ParameterType.abiEncode(bigint, bits: bits);
            }
            return nil;
        case .int(let bits):
            if let biguint = value as? BigUInt {
                return ABIElement.ParameterType.abiEncode(biguint, bits: bits);
            }
            if let bigint = value as? BigInt {
                return ABIElement.ParameterType.abiEncode(bigint, bits: bits);
            }
        case .address:
            if let string = value as? String {
                guard let data = sodium.utils.hex2bin(string.lowercased().stripHexPrefix()) else {return nil}
                return data.padLeft(20)
            } else if let address = value as? EthereumAddress {
                guard address.isValid else {return nil}
                let data = address.addressData
                return data.padLeft(20)
            } else if let data = value as? Data {
                return data.padLeft(20)
            }
            return nil
        case .bool:
            if let bool = value as? Bool {
                if (bool) {
                    return ABIElement.ParameterType.abiEncode(BigUInt(1), bits: 256);
                } else {
                    return ABIElement.ParameterType.abiEncode(BigUInt(0), bits: 256);
                }
            }
            return nil
        case .bytes(let length):
            if let string = value as? String {
                guard let data = sodium.utils.hex2bin(string.lowercased().stripHexPrefix()) else {return nil}
                return data.padLeft(length)
            } else if let address = value as? EthereumAddress {
                guard address.isValid else {return nil}
                let data = address.addressData
                return data.padLeft(length)
            } else if let data = value as? Data {
                return data.padLeft(length)
            }
            return nil
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
                guard let encoded = type.encode(value) else {return nil}
                data.append(encoded)
            }
            return data
        default:
            return nil
        }
    }
    

}

extension ABIElement.ParameterType.DynamicType {
    func encode(_ value: AnyObject) -> Data? {
        let sodium = Sodium()
        switch self {
        case .string:
            if let string = value as? String {
                guard let data = string.data(using: .utf8) else {return nil}
                let length = data.count
                guard var prefix = ABIElement.ParameterType.abiEncode(BigUInt(length), bits: 256) else {return nil}
                prefix.append(data)
                return prefix
            } else if let data = value as? Data {
                let length = data.count
                guard var prefix = ABIElement.ParameterType.abiEncode(BigUInt(length), bits: 256) else {return nil}
                prefix.append(data)
                return prefix
            }
            return nil
        case .bytes:
            if let string = value as? String {
                guard let data = sodium.utils.hex2bin(string.lowercased().stripHexPrefix()) else {return nil}
                let length = data.count
                guard var prefix = ABIElement.ParameterType.abiEncode(BigUInt(length), bits: 256) else {return nil}
                prefix.append(data)
                return prefix
            } else if let data = value as? Data {
                let length = data.count
                guard var prefix = ABIElement.ParameterType.abiEncode(BigUInt(length), bits: 256) else {return nil}
                prefix.append(data)
                return prefix
            }
        default:
            return nil
        }
        return nil
    }
    
    func encode(_ values: [AnyObject]) -> Data? {
        switch self {
        case let .array(type):
            var data = Data()
            for value in values {
                guard let encoded = type.encode(value) else {return nil}
                data.append(encoded)
            }
            let length = data.count
            guard var prefix = ABIElement.ParameterType.abiEncode(BigUInt(length), bits: 256) else {return nil}
            prefix.append(data)
            return prefix
        default:
            return nil
        }
    }
}



extension ABIElement {
    func encodeParameters(_ parameters: [AnyObject]) -> Data? {
        switch self {
        case .constructor(_):
            return nil
        case .event(_):
            return nil
        case .fallback(_):
            return nil
        case .function(let function):
            var data = Data()
            guard parameters.count == function.inputs.count else {return nil}
            for index in 0..<function.inputs.count {
                let input  = function.inputs[index]
                let parameter = parameters[index]
                guard let parameterBinaryRepresentation = input.type.encode(parameter) else {return nil}
                data.append(parameterBinaryRepresentation)
            }
            return data
        }
    }
}
