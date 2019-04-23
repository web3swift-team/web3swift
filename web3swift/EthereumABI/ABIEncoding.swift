//
//  Created by Alex Vlasov on 25/10/2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt

public struct ABIEncoder {
    
}

extension ABIEncoder {
    public static func convertToBigUInt(_ value: AnyObject) -> BigUInt? {
        switch value {
        case let v as BigUInt:
            return v
        case let v as BigInt:
            switch v.sign {
            case .minus:
                return nil
            case .plus:
                return v.magnitude
            }
        case let v as String:
            let base10 = BigUInt(v, radix: 10)
            if base10 != nil {
                return base10!
            }
            let base16 = BigUInt(v.stripHexPrefix(), radix: 16)
            if base16 != nil {
                return base16!
            }
            break
        case let v as UInt:
            return BigUInt(v)
        case let v as UInt8:
            return BigUInt(v)
        case let v as UInt16:
            return BigUInt(v)
        case let v as UInt32:
            return BigUInt(v)
        case let v as UInt64:
            return BigUInt(v)
        case let v as Int:
            return BigUInt(v)
        case let v as Int8:
            return BigUInt(v)
        case let v as Int16:
            return BigUInt(v)
        case let v as Int32:
            return BigUInt(v)
        case let v as Int64:
            return BigUInt(v)
        default:
            return nil
        }
        return nil
    }
    
    public static func convertToBigInt(_ value: AnyObject) -> BigInt? {
        switch value {
        case let v as BigUInt:
            return BigInt(v)
        case let v as BigInt:
            return v
        case let v as String:
            let base10 = BigInt(v, radix: 10)
            if base10 != nil {
                return base10
            }
            let base16 = BigInt(v.stripHexPrefix(), radix: 16)
            if base16 != nil {
                return base16
            }
            break
        case let v as UInt:
            return BigInt(v)
        case let v as UInt8:
            return BigInt(v)
        case let v as UInt16:
            return BigInt(v)
        case let v as UInt32:
            return BigInt(v)
        case let v as UInt64:
            return BigInt(v)
        case let v as Int:
            return BigInt(v)
        case let v as Int8:
            return BigInt(v)
        case let v as Int16:
            return BigInt(v)
        case let v as Int32:
            return BigInt(v)
        case let v as Int64:
            return BigInt(v)
        default:
            return nil
        }
        return nil
    }
    
    public static func convertToData(_ value: AnyObject) -> Data? {
        switch value {
        case let d as Data:
            return d
        case let d as String:
            if d.hasHexPrefix() {
                let hex = Data.fromHex(d)
                if hex != nil {
                    return hex
                }
            }
            let str = d.data(using: .utf8)
            if str != nil {
                return str
            }
        case let d as [UInt8]:
            return Data(d)
        case let d as EthereumAddress:
            return d.addressData
        case let d as [IntegerLiteralType]:
            var bytesArray = [UInt8]()
            for el in d {
                guard el >= 0, el <= 255 else {return nil}
                bytesArray.append(UInt8(el))
            }
            return Data(bytesArray)
        default:
            return nil
        }
        return nil
    }
    
    
    public static func encode(types: [ABI.Element.InOut], values: [AnyObject]) -> Data? {
        guard types.count == values.count else {return nil}
        let params = types.compactMap { (el) -> ABI.Element.ParameterType in
            return el.type
        }
        return encode(types: params, values: values)
    }
    
    public static func encode(types: [ABI.Element.ParameterType], values: [AnyObject]) -> Data? {
        guard types.count == values.count else {return nil}
        var tails = [Data]()
        var heads = [Data]()
        for i in 0 ..< types.count {
            let enc = encodeSingleType(type: types[i], value: values[i])
            guard let encoding = enc else {return nil}
            if types[i].isStatic {
                heads.append(encoding)
                tails.append(Data())
            } else {
                heads.append(Data(repeating: 0x0, count: 32))
                tails.append(encoding)
            }
        }
        var headsConcatenated = Data()
        for h in heads {
            headsConcatenated.append(h)
        }
        var tailsPointer = BigUInt(headsConcatenated.count)
        headsConcatenated = Data()
        var tailsConcatenated = Data()
        for i in 0 ..< types.count {
            let head = heads[i]
            let tail = tails[i]
            if !types[i].isStatic {
                guard let newHead = tailsPointer.abiEncode(bits: 256) else {return nil}
                headsConcatenated.append(newHead)
                tailsConcatenated.append(tail)
                tailsPointer = tailsPointer + BigUInt(tail.count)
            } else {
                headsConcatenated.append(head)
                tailsConcatenated.append(tail)
            }
        }
        return headsConcatenated + tailsConcatenated
    }
    
    public static func encodeSingleType(type: ABI.Element.ParameterType, value: AnyObject) -> Data? {
        switch type {
        case .uint(_):
            if let biguint = convertToBigUInt(value) {
                return biguint.abiEncode(bits: 256)
            }
            if let bigint = convertToBigInt(value) {
                return bigint.abiEncode(bits: 256)
            }
        case .int(_):
            if let biguint = convertToBigUInt(value) {
                return biguint.abiEncode(bits: 256)
            }
            if let bigint = convertToBigInt(value) {
                return bigint.abiEncode(bits: 256)
            }
        case .address:
            if let string = value as? String {
                guard let address = EthereumAddress(string) else {return nil}
                let data = address.addressData
                return data.setLengthLeft(32)
            } else if let address = value as? EthereumAddress {
                guard address.isValid else {break}
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
            guard let data = convertToData(value) else {break}
            if data.count > length {break}
            return data.setLengthRight(32)
        case .string:
            if let string = value as? String {
                var dataGuess: Data?
                if string.hasHexPrefix() {
                    dataGuess = Data.fromHex(string.lowercased().stripHexPrefix())
                }
                else {
                    dataGuess = string.data(using: .utf8)
                }
                guard let data = dataGuess else {break}
                let minLength = ((data.count + 31) / 32)*32
                guard let paddedData = data.setLengthRight(UInt64(minLength)) else {break}
                let length = BigUInt(data.count)
                guard let head = length.abiEncode(bits: 256) else {break}
                let total = head+paddedData
                return total
            }
        case .dynamicBytes:
            guard let data = convertToData(value) else {break}
            let minLength = ((data.count + 31) / 32)*32
            guard let paddedData = data.setLengthRight(UInt64(minLength)) else {break}
            let length = BigUInt(data.count)
            guard let head = length.abiEncode(bits: 256) else {break}
            let total = head+paddedData
            return total
        case .array(type: let subType, length: let length):
            switch type.arraySize {
            case .dynamicSize:
                guard length == 0 else {break}
                guard let val = value as? [AnyObject] else {break}
                guard let lengthEncoding = BigUInt(val.count).abiEncode(bits: 256) else {break}
                if subType.isStatic {
                    // work in a previous context
                    var toReturn = Data()
                    for i in 0 ..< val.count {
                        let enc = encodeSingleType(type: subType, value: val[i])
                        guard let encoding = enc else {break}
                        toReturn.append(encoding)
                    }
                    let total = lengthEncoding + toReturn
                    //                    print("Dynamic array of static types encoding :\n" + String(total.toHexString()))
                    return total
                } else {
                    // create new context
                    var tails = [Data]()
                    var heads = [Data]()
                    for i in 0 ..< val.count {
                        let enc = encodeSingleType(type: subType, value: val[i])
                        guard let encoding = enc else {return nil}
                        heads.append(Data(repeating: 0x0, count: 32))
                        tails.append(encoding)
                    }
                    var headsConcatenated = Data()
                    for h in heads {
                        headsConcatenated.append(h)
                    }
                    var tailsPointer = BigUInt(headsConcatenated.count)
                    headsConcatenated = Data()
                    var tailsConcatenated = Data()
                    for i in 0 ..< val.count {
                        let head = heads[i]
                        let tail = tails[i]
                        if tail != Data() {
                            guard let newHead = tailsPointer.abiEncode(bits: 256) else {return nil}
                            headsConcatenated.append(newHead)
                            tailsConcatenated.append(tail)
                            tailsPointer = tailsPointer + BigUInt(tail.count)
                        } else {
                            headsConcatenated.append(head)
                            tailsConcatenated.append(tail)
                        }
                    }
                    let total =  lengthEncoding + headsConcatenated + tailsConcatenated
                    //                    print("Dynamic array of dynamic types encoding :\n" + String(total.toHexString()))
                    return total
                }
            case .staticSize(let staticLength):
                guard staticLength != 0 else {break}
                guard let val = value as? [AnyObject] else {break}
                guard staticLength == val.count else {break}
                if subType.isStatic {
                    // work in a previous context
                    var toReturn = Data()
                    for i in 0 ..< val.count {
                        let enc = encodeSingleType(type: subType, value: val[i])
                        guard let encoding = enc else {break}
                        toReturn.append(encoding)
                    }
                    //                    print("Static array of static types encoding :\n" + String(toReturn.toHexString()))
                    let total = toReturn
                    return total
                } else {
                    // create new context
                    var tails = [Data]()
                    var heads = [Data]()
                    for i in 0 ..< val.count {
                        let enc = encodeSingleType(type: subType, value: val[i])
                        guard let encoding = enc else {return nil}
                        heads.append(Data(repeating: 0x0, count: 32))
                        tails.append(encoding)
                    }
                    var headsConcatenated = Data()
                    for h in heads {
                        headsConcatenated.append(h)
                    }
                    var tailsPointer = BigUInt(headsConcatenated.count)
                    headsConcatenated = Data()
                    var tailsConcatenated = Data()
                    for i in 0 ..< val.count {
                        let tail = tails[i]
                        guard let newHead = tailsPointer.abiEncode(bits: 256) else {return nil}
                        headsConcatenated.append(newHead)
                        tailsConcatenated.append(tail)
                        tailsPointer = tailsPointer + BigUInt(tail.count)
                    }
                    let total = headsConcatenated + tailsConcatenated
                    //                    print("Static array of dynamic types encoding :\n" + String(total.toHexString()))
                    return total
                }
            case .notArray:
                break
            }
        case .tuple(types: let subTypes):
            var tails = [Data]()
            var heads = [Data]()
            guard let val = value as? [AnyObject] else {break}
            for i in 0 ..< subTypes.count {
                let enc = encodeSingleType(type: subTypes[i], value: val[i])
                guard let encoding = enc else {return nil}
                if subTypes[i].isStatic {
                    heads.append(encoding)
                    tails.append(Data())
                } else {
                    heads.append(Data(repeating: 0x0, count: 32))
                    tails.append(encoding)
                }
            }
            var headsConcatenated = Data()
            for h in heads {
                headsConcatenated.append(h)
            }
            var tailsPointer = BigUInt(headsConcatenated.count)
            headsConcatenated = Data()
            var tailsConcatenated = Data()
            for i in 0 ..< subTypes.count {
                let head = heads[i]
                let tail = tails[i]
                if !subTypes[i].isStatic {
                    guard let newHead = tailsPointer.abiEncode(bits: 256) else {return nil}
                    headsConcatenated.append(newHead)
                    tailsConcatenated.append(tail)
                    tailsPointer = tailsPointer + BigUInt(tail.count)
                } else {
                    headsConcatenated.append(head)
                    tailsConcatenated.append(tail)
                }
            }
            let total = headsConcatenated + tailsConcatenated
            return total
        case .function:
            if let data = value as? Data {
                return data.setLengthLeft(32)
            }
        }
        return nil
    }
}
