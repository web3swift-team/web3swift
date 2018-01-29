//
//  ABIEncoder.swift
//  web3swift
//
//  Created by Alexander Vlasov on 05.12.2017.
//  Copyright © 2017 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt

extension Data {
    func setLengthLeft(_ toBytes: Int, isNegative:Bool = false ) -> Data? {
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
    
    func setLengthRight(_ toBytes: Int, isNegative:Bool = false ) -> Data? {
        let existingLength = self.count;
        if (existingLength == toBytes) {
            return Data(self)
        } else if (existingLength > toBytes) {
            return nil
        }
        var data:Data = Data()
        data.append(self)
        if (isNegative) {
            data.append(Data(repeating: UInt8(255), count: toBytes - existingLength))
        } else {
            data.append(Data(repeating: UInt8(0), count: toBytes - existingLength))
        }
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
    func encode(_ value: AnyObject) -> (head:Data?, tail: Data?) {
        switch self {
        case .staticType(let type):
            return type.encode(value)
        case .dynamicType(let type):
            return type.encode(value)
        }
    }
    func encode(_ values: [AnyObject]) -> (head:Data?, tail: Data?) {
        switch self {
        case .staticType(let type):
            return type.encode(values)
        case .dynamicType(let type):
            return type.encode(values)
        }
    }
}

extension BigUInt {
    func abiEncode(bits: Int) -> (head:Data?, tail: Data?) {
        let data = self.serialize()
        let paddedLength = Int(ceil((Double(bits)/8.0)))
        let padded = data.setLengthLeft(paddedLength)
        return (padded, Data())
    }
}

extension BigInt {
    func abiEncode(bits: Int) -> (head:Data?, tail: Data?) {
        let isNegative = self >= (BigInt(0))
        let data = self.toTwosComplement()
        let paddedLength = Int(ceil((Double(bits)/8.0)))
        let padded = data.setLengthLeft(paddedLength, isNegative: isNegative)
        return (padded, Data())
    }
}

extension ABIElement.ParameterType.StaticType {
    
    func encode(_ value: AnyObject) -> (head:Data?, tail: Data?) {
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
                guard let data = Data.fromHex(string.lowercased().stripHexPrefix()) else {return (nil, nil)}
                return (data.setLengthLeft(32), Data())
            } else if let address = value as? EthereumAddress {
                guard address.isValid else {return (nil, nil)}
                let data = address.addressData
                return (data.setLengthLeft(32), Data())
            } else if let data = value as? Data {
                return (data.setLengthLeft(32), Data())
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
                if string.hasHexPrefix() {
                    guard let data = Data.fromHex(string.lowercased().stripHexPrefix()) else {return (nil, nil)}
                    return (data.setLengthRight(length), Data())
                } else {
                    guard let data = string.data(using: .utf8) else {return (nil, nil)}
                    if data.count > length {return (nil, nil)}
                    return (data.setLengthRight(length), Data())
                }
            } else if let addr = value as? EthereumAddress {
                guard addr.isValid else {return (nil, nil)}
                let data = addr.addressData
                return (data.setLengthRight(length), Data())
            } else if let data = value as? Data {
                return (data.setLengthRight(length), Data())
            }
        default:
            return (nil, nil)
        }
        return (nil, nil)
    }
    
    func encode(_ values: [AnyObject]) -> (head:Data?, tail: Data?) {
        switch self {
        case let .array(type, length):
            if (values.count != length) {
                return (nil, nil)
            }
            var heads = Data()
            var tails = Data()
            for value in values {
                let encoded = type.encode(value)
                guard let head = encoded.head, let tail = encoded.tail else {return (nil, nil) }
                heads.append(head)
                tails.append(tail)
            }
            return (heads, tails)
        default:
            return (nil, nil)
        }
    }
    

}

extension ABIElement.ParameterType.DynamicType {
    func encode(_ value: AnyObject) -> (head:Data?, tail: Data?) {
        switch self {
        case .string:
            if let string = value as? String {
                guard let data = string.data(using: .utf8) else {return (nil, nil)}
                let length = data.count
                let lengthToPad = Int(ceil(Double(data.count) / 32.0)) * 32
                var tail = Data()
                let encodedLen = BigUInt(length).abiEncode(bits: 256)
                guard let lenHead = encodedLen.head, let _ = encodedLen.tail else {return (nil, nil)}
                guard let paddedData = data.setLengthRight(lengthToPad) else {return (nil, nil)}
                tail.append(lenHead)
                tail.append(paddedData)
                return (Data(), tail)
            } else if let data = value as? Data {
                let length = data.count
                let lengthToPad = Int(ceil(Double(data.count) / 32.0)) * 32
                var tail = Data()
                let encodedLen = BigUInt(length).abiEncode(bits: 256)
                guard let lenHead = encodedLen.head, let _ = encodedLen.tail else {return (nil, nil)}
                guard let paddedData = data.setLengthRight(lengthToPad) else {return (nil, nil)}
                tail.append(lenHead)
                tail.append(paddedData)
                return (Data(), tail)
            }
            return (nil, nil)
        case .bytes:
            if let string = value as? String {
                guard let data = Data.fromHex(string.lowercased().stripHexPrefix()) else {return (nil, nil) }
                let length = data.count
                let lengthToPad = Int(ceil(Double(data.count) / 32.0)) * 32
                var tail = Data()
                let encodedLen = BigUInt(length).abiEncode(bits: 256)
                guard let lenHead = encodedLen.head, let _ = encodedLen.tail else {return (nil, nil)}
                guard let paddedData = data.setLengthRight(lengthToPad) else {return (nil, nil)}
                tail.append(lenHead)
                tail.append(paddedData)
                return (Data(), tail)
            } else if let data = value as? Data {
                let length = data.count
                let lengthToPad = Int(ceil(Double(data.count) / 32.0)) * 32
                var tail = Data()
                let encodedLen = BigUInt(length).abiEncode(bits: 256)
                guard let lenHead = encodedLen.head, let _ = encodedLen.tail else {return (nil, nil)}
                guard let paddedData = data.setLengthRight(lengthToPad) else {return (nil, nil)}
                tail.append(lenHead)
                tail.append(paddedData)
                return (Data(), tail)
            }
        default:
            return (nil, nil)
        }
        return (nil, nil)
    }
    
    func encode(_ values: [AnyObject]) -> (head:Data?, tail: Data?) {
        switch self {
        case let .dynamicArray(type):
            var data = Data()
            for value in values {
                let encoded = type.encode(value)
                guard let encodedHead = encoded.head, let encodedTail = encoded.tail else {return (nil, nil)}
                data.append(encodedHead)
            }
            var tail = Data()
            let length = data.count
            let encodedLen = BigUInt(length).abiEncode(bits: 256)
            guard let lenHead = encodedLen.head, let _ = encodedLen.tail else {return (nil, nil)}
            tail.append(lenHead)
            tail.append(data)
            return (Data(), tail)
        default:
            return (nil, nil)
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
            var signature = function.methodEncoding
            var heads = Data()
            var tails = Data()
//            var tailsPointer = BigUInt(32)*BigUInt(function.inputs.count)
            var tailsPointer = BigUInt(0)
            guard parameters.count == function.inputs.count else {return nil}
            for index in 0..<function.inputs.count {
                let input  = function.inputs[index]
                let parameter = parameters[index]
                let encoded = input.type.encode(parameter)
                guard let head = encoded.head, let tail = encoded.tail else {return nil}
                if (head != Data() && tail == Data()) {
                    heads.append(head)
                    tailsPointer = tailsPointer + BigUInt(head.count)
                } else if (head == Data() && tail != Data()) {
                    let pointer = tailsPointer.abiEncode(bits: 256)
                    guard let h = pointer.head, let _ = pointer.tail else {return nil}
                    guard h != Data() else {return nil}
                    heads.append(h)
                    tailsPointer = tailsPointer + BigUInt(h.count)
                    tails.append(tail)
                    tailsPointer = tailsPointer + BigUInt(tail.count)
                } else {
                    return nil
                }
            }
            heads.append(tails)
            signature.append(heads)
            return signature
        }
    }
}
