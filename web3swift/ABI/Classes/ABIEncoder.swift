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
        case .dynamicType(_):
            return nil
        }
    }
//    func encode(_ values: [AnyObject]) -> Data? {
//        switch self {
//        case .staticType(let type):
//            return type.encode(values)
//        case .dynamicType(let type):
//            return type.encode(values)
//        }
//    }
}

extension ABIElement.ParameterType.StaticType {
    func encode(_ value: AnyObject) -> Data? {
        let sodium = Sodium()
        switch self {
        case .uint(let bits):
            if let biguint = value as? BigUInt {
                return ABIElement.ParameterType.StaticType.abiEncode(biguint, bits: bits);
            }
            if let bigint = value as? BigInt {
                return ABIElement.ParameterType.StaticType.abiEncode(bigint, bits: bits);
            }
            return nil;
        case .int(let bits):
            return nil
        case .address:
            if let string = value as? String {
                guard let data = sodium.utils.hex2bin(string.lowercased().stripHexPrefix()) else {return nil}
                return data.padLeft(20)
            }
            return nil
//            return "address"
        case .bool:
            return nil
//            return "bool"
        case .bytes(let length):
            return nil
//            return "bytes\(length)"
        case .function:
            return nil
        case let .array(type, length):
            return nil
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

extension ABIElement.ParameterType.DynamicType {
    func encode(_ value: AnyObject) -> Data? {
        return nil
//        let sodium = Sodium()
//        switch self {
//        case .uint(let bits):
//            if let biguint = value as? BigUInt {
//                return ABIElement.ParameterType.StaticType.abiEncode(biguint, bits: bits);
//            }
//            if let bigint = value as? BigInt {
//                return ABIElement.ParameterType.StaticType.abiEncode(bigint, bits: bits);
//            }
//            return nil;
//        case .int(let bits):
//            return nil
//        case .address:
//
//            return "address"
//        case .bool:
//            return "bool"
//        case .bytes(let length):
//            return "bytes\(length)"
//        case .function:
//            return nil
//        case let .array(type, length):
//            return nil
//        }
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
//            var data = Data()
//            for element in parameters {
//                let keys = Array(element.keys)
//                guard keys.count == 1 else {
//                    return nil
//                }
//                guard let encoded = RLP.encode(element[keys[0]]!) else {
//                    continue
//                }
//                data.append(encoded)
//            }
//            return data
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
