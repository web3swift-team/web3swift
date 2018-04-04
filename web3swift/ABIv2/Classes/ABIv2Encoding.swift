//
//  ABIv2Encoding.swift
//  web3swift
//
//  Created by Alexander Vlasov on 03.04.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt

public struct ABIv2Encoder {
    
}

extension ABIv2Encoder {
    public static func encode(types: [ABIv2.Element.InOut], values: [AnyObject]) -> Data? {
        guard types.count == values.count else {return nil}
        let params = types.flatMap { (el) -> ABIv2.Element.ParameterType in
            return el.type
        }
        let tuple = ABIv2.Element.ParameterType.tuple(types: params, dynamic: false)
        let (h, t, _) = encodeTypesTuple(tuple: tuple, values: values)
        guard let head = h, let tail = t else {return nil}
        return head + tail
    }
    
    public static func encodeSingleType(type: ABIv2.Element.ParameterType, value: AnyObject, pointer: BigUInt = BigUInt(0)) -> (head: Data?, tail: Data?, pointer: BigUInt?) {
        switch type {
        case .uint(_):
            if let biguint = value as? BigUInt {
                return (biguint.abiEncode(bits: 256), Data(), pointer)
            }
            if let bigint = value as? BigInt {
                return (bigint.abiEncode(bits: 256), Data(), pointer)
            }
        case .int(_):
            if let biguint = value as? BigUInt {
                return (biguint.abiEncode(bits: 256), Data(), pointer)
            }
            if let bigint = value as? BigInt {
                return (bigint.abiEncode(bits: 256), Data(), pointer)
            }
        case .address:
            if let string = value as? String {
                let address = EthereumAddress(string)
                guard address.isValid else {break}
                let data = address.addressData
                return (data.setLengthLeft(32), Data(), pointer)
            } else if let address = value as? EthereumAddress {
                guard address.isValid else {break}
                let data = address.addressData
                return (data.setLengthLeft(32), Data(), pointer)
            } else if let data = value as? Data {
                return (data.setLengthLeft(32), Data(), pointer)
            }
        case .bool:
            if let bool = value as? Bool {
                if (bool) {
                    return (BigUInt(1).abiEncode(bits: 256), Data(), pointer)
                } else {
                    return (BigUInt(0).abiEncode(bits: 256), Data(), pointer)
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
                guard let data = dataGuess else {break}
                if data.count > length {break}
                return (data.setLengthRight(32), Data(), pointer)
            } else if let addr = value as? EthereumAddress {
                guard addr.isValid else {break}
                let data = addr.addressData
                return (data.setLengthRight(32), Data(), pointer)
            } else if let data = value as? Data {
                return (data.setLengthRight(32), Data(), pointer)
            }
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
                let tail = head+paddedData
                return (Data(), tail, pointer + BigUInt(tail.count))
            }
        case .dynamicBytes:
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
                let tail = head+paddedData
                return (Data(), tail, pointer + BigUInt(tail.count))
            } else if let data = value as? Data {
                let minLength = ((data.count + 31) / 32)*32
                guard let paddedData = data.setLengthRight(UInt64(minLength)) else {break}
                let length = BigUInt(data.count)
                guard let head = length.abiEncode(bits: 256) else {break}
                let tail = head+paddedData
                return (Data(), tail, pointer + BigUInt(tail.count))
            }
        case .array(type: let subType, length: let length):
            switch type.arraySize {
            case .dynamicSize:
                guard length == 0 else {break}
                guard let val = value as? [AnyObject] else {break}
                var tails = Data()
                for i in 0 ..< val.count {
                    let (h, t, p) = encodeSingleType(type: subType, value: val[i], pointer: pointer)
                    guard let headUnwrapped = h, let tailUnwrapped = t, let _ = p else {break}
                    guard headUnwrapped != Data() else {break}
                    guard tailUnwrapped == Data() else {break}
                    tails.append(headUnwrapped)
                }
                guard let prefix = BigUInt(val.count).abiEncode(bits: 256) else {break}
                tails = prefix + tails
                return (pointer.abiEncode(bits: 256)!, tails, pointer + BigUInt(tails.count))
            case .staticSize(let staticLength):
                guard length == staticLength else {break}
                guard let val = value as? [AnyObject] else {break}
                guard staticLength == val.count else {break}
                let types = [ABIv2.Element.ParameterType](repeating: subType, count: val.count)
                let tuple = ABIv2.Element.ParameterType.tuple(types: types, dynamic: false)
                return encodeTypesTuple(tuple: tuple, values: val, pointer: pointer)
            case .notArray:
                break
            }
        case .tuple(types: let subTypes, dynamic: let dynamic):
            guard let val = value as? [AnyObject] else {break}
            guard subTypes.count == val.count else {break}
            let tuple = ABIv2.Element.ParameterType.tuple(types: subTypes, dynamic: dynamic)
            return encodeTypesTuple(tuple: tuple, values: val, pointer: pointer)
        case .function:
            if let data = value as? Data {
                return (data.setLengthLeft(32), Data(), pointer)
            }
        }
        return (nil, nil, nil)
    }
    
    public static func encodeTypesTuple(tuple: ABIv2.Element.ParameterType, values: [AnyObject], pointer: BigUInt = BigUInt(0)) -> (head: Data?, tail: Data?, pointer: BigUInt?) {
        guard case .tuple(types: let types, dynamic: _) = tuple else {return (nil, nil, nil)}
        let memoryUsage = tuple.memoryUsage
        var offset: BigUInt = BigUInt(memoryUsage);
        if pointer != BigUInt(0) {
            offset = pointer
        }
        guard types.count == values.count else {return (nil, nil, nil)}
        var head = Data()
        var tail = Data()
        var h, t : Data?
        var p: BigUInt?
        if tuple.isStatic {
            for i in 0 ..< types.count {
                if let val = values[i] as? AnyObject {
                    (h, t, p) = encodeSingleType(type: types[i], value: val, pointer: offset)
                } else {
                    return (nil, nil, nil)
                }
                guard let headUnwrapped = h, let tailUnwrapped = t, let pointerUnwrapped = p else {return (nil, nil, nil)}
                guard headUnwrapped != Data() else {return (nil, nil, nil)}
                head.append(headUnwrapped)
                offset = pointerUnwrapped
            }
        } else {
            for i in 0 ..< types.count {
                if let val = values[i] as? AnyObject {
                    (h, t, p) = encodeSingleType(type: types[i], value: val, pointer: offset)
                } else {
                    return (nil, nil, nil)
                }
                guard let headUnwrapped = h, let tailUnwrapped = t, let pointerUnwrapped = p else {return (nil, nil, nil)}
                if headUnwrapped != Data() {
                    head.append(headUnwrapped)
                    tail.append(tailUnwrapped)
                    offset = pointerUnwrapped
                } else {
                    guard let pointerEncoded = offset.abiEncode(bits: 256) else {return (nil, nil, nil)}
                    head.append(pointerEncoded)
                    offset = pointerUnwrapped
                    tail.append(tailUnwrapped)
                }
                print(offset)
            }
        }
        return (head, tail, offset)
    }
    
}
