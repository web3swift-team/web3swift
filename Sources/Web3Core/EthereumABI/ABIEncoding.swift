//
//  Created by Alex Vlasov on 25/10/2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt

public struct ABIEncoder {
    /// Attempts to convert given value to `BigUInt`.
    /// Supported types are `BigUInt`, `BigInt`, `String` as hex and decimal, `UInt[8-64]`, `Int[8-64]` and `Data`.
    /// All negative values will return `nil`.
    /// - Parameter value: an arbitrary object.
    /// - Returns: converted value or `nil` if types is not support or initialization failed.
    public static func convertToBigUInt(_ value: Any) -> BigUInt? {
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
            let v = v.trimmingCharacters(in: .whitespacesAndNewlines)
            if v.starts(with: "-") {
                return nil
            }
            return BigUInt(v, radix: 10) ?? BigUInt(v.stripHexPrefix(), radix: 16)
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
            return v < 0 ? nil : BigUInt(v)
        case let v as Int8:
            return v < 0 ? nil : BigUInt(v)
        case let v as Int16:
            return v < 0 ? nil : BigUInt(v)
        case let v as Int32:
            return v < 0 ? nil : BigUInt(v)
        case let v as Int64:
            return v < 0 ? nil : BigUInt(v)
        case let v as Data:
            return BigUInt(v)
        default:
            return nil
        }
    }

    /// Attempts to convert given value to `BigInt`.
    /// Supported types are `BigUInt`, `BigInt`, `String` as hex and decimal, `UInt[8-64]`, `Int[8-64]` and `Data`.
    /// - Parameter value: an arbitrary object.
    /// - Returns: converted value or `nil` if types is not support or initialization failed.
    public static func convertToBigInt(_ value: Any) -> BigInt? {
        switch value {
        case let v as BigUInt:
            return BigInt(v)
        case let v as BigInt:
            return v
        case let v as String:
            let v = v.trimmingCharacters(in: .whitespacesAndNewlines)
            return BigInt(v, radix: 10) ?? BigInt(v.stripHexPrefix(), radix: 16)
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
        case let v as Data:
            return BigInt(v)
        default:
            return nil
        }
    }

    /// Attempts to convert given object into `Data`.
    /// Used as a part of ABI encoding process.
    /// Supported types are `Data`, `String`, `[UInt8]`, ``EthereumAddress``, `[IntegerLiteralType]` and `Bool`.
    /// Note: if `String` has `0x` prefix an attempt to interpret it as a hexadecimal number will take place. Otherwise, UTF-8 bytes are returned.
    /// - Parameter value: any object.
    /// - Returns: `Data` representation of an object ready for ABI encoding.
    public static func convertToData(_ value: Any) -> Data? {
        switch value {
        case let d as Data:
            return d
        case let d as String:
            if d.hasHexPrefix(),
               let hex = Data.fromHex(d) {
                return hex
            }
            return d.data(using: .utf8)
        case let d as [UInt8]:
            return Data(d)
        case let d as EthereumAddress:
            return d.addressData
        case let d as [IntegerLiteralType]:
            var bytesArray = [UInt8]()
            for el in d {
                guard el >= 0, el <= 255 else { return nil }
                bytesArray.append(UInt8(el))
            }
            return Data(bytesArray)
        case let b as Bool:
            return b ? Data([UInt8(1)]) : Data(count: 1)
        default:
            return nil
        }
    }

    /// Performs ABI encoding conforming to [the documentation of encoding](https://docs.soliditylang.org/en/develop/abi-spec.html#basic-design) in Solidity.
    /// Overloading to support `ABI.Element.InOut` as the type of the `types` array.
    /// Identical to use of `web3.eth.abi.encodeParameters` in web3.js.
    /// - Parameters:
    ///   - types: an array of values' Solidity types. Must be declared in the same order as entries in `values` or encoding will fail;
    ///   - values: an array of values to encode. Must be declared in the same order as entries in `types` or encoding will fail;
    /// - Returns: ABI encoded data, e.g. function call parameters. Returns `nil` if:
    ///     - `types.count != values.count`;
    ///     - encoding of at least one value has failed (e.g. type mismatch).
    public static func encode(types: [ABI.Element.InOut], values: [Any]) -> Data? {
        guard types.count == values.count else { return nil }
        let params = types.compactMap { el -> ABI.Element.ParameterType in
            return el.type
        }
        return encode(types: params, values: values)
    }

    /// Performs ABI encoding conforming to [the documentation of encoding](https://docs.soliditylang.org/en/develop/abi-spec.html#basic-design) in Solidity.
    /// Identical to use of `web3.eth.abi.encodeParameters` in web3.js.
    /// - Parameters:
    ///   - types: an array of values' Solidity types. Must be declared in the same order as entries in `values` or encoding will fail;
    ///   - values: an array of values to encode. Must be declared in the same order as entries in `types` or encoding will fail;
    /// - Returns: ABI encoded data, e.g. function call parameters. Returns `nil` if:
    ///     - `types.count != values.count`;
    ///     - encoding of at least one value has failed (e.g. type mismatch).
    public static func encode(types: [ABI.Element.ParameterType], values: [Any]) -> Data? {
        guard types.count == values.count else { return nil }
        var tails = [Data]()
        var heads = [Data]()
        for i in 0 ..< types.count {
            let enc = encodeSingleType(type: types[i], value: values[i])
            guard let encoding = enc else { return nil }
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
                guard let newHead = tailsPointer.abiEncode(bits: 256) else { return nil }
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

    /// Performs ABI encoding conforming to [the documentation of encoding](https://docs.soliditylang.org/en/develop/abi-spec.html#basic-design) in Solidity.
    ///
    /// **It does not add the data offset for dynamic types!!** To return single value **with data offset** use the following instead:
    /// ```swift
    /// ABIEncoder.encode(types: [type], values: [value])
    /// ```
    /// Almost identical to use of `web3.eth.abi.encodeParameter` in web3.js.
    /// Calling `web3.eth.abi.encodeParameter('string','test')` in web3.js will return the following:
    /// ```
    /// 0x0000000000000000000000000000000000000000000000000000000000000020
    /// 0000000000000000000000000000000000000000000000000000000000000004
    /// 7465737400000000000000000000000000000000000000000000000000000000
    /// ```
    /// but calling `ABIEncoder.encodeSingleType(type: .string, value: "test")` will return:
    /// ```
    /// 0x0000000000000000000000000000000000000000000000000000000000000004
    /// 7465737400000000000000000000000000000000000000000000000000000000
    /// ```
    /// - Parameters:
    ///   - type: Solidity type of the `value`;
    ///   - value: value to encode.
    /// - Returns: ABI encoded data, e.g. function call parameters. Returns `nil` if:
    ///     - `types.count != values.count`;
    ///     - encoding has failed (e.g. type mismatch).
    public static func encodeSingleType(type: ABI.Element.ParameterType, value: Any) -> Data? {
        switch type {
        case .uint:
            let biguint = convertToBigUInt(value)
            return biguint == nil ? nil : biguint!.abiEncode(bits: 256)
        case .int:
            let bigint = convertToBigInt(value)
            return bigint == nil ? nil : bigint!.abiEncode(bits: 256)
        case .address:
            if let string = value as? String {
                guard let address = EthereumAddress(string) else { return nil }
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
                if bool {
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
                } else {
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
                guard let val = value as? [Any] else {break}
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
                    return total
                } else {
                    // create new context
                    var tails = [Data]()
                    var heads = [Data]()
                    for i in 0 ..< val.count {
                        let enc = encodeSingleType(type: subType, value: val[i])
                        guard let encoding = enc else { return nil }
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
                            guard let newHead = tailsPointer.abiEncode(bits: 256) else { return nil }
                            headsConcatenated.append(newHead)
                            tailsConcatenated.append(tail)
                            tailsPointer = tailsPointer + BigUInt(tail.count)
                        } else {
                            headsConcatenated.append(head)
                            tailsConcatenated.append(tail)
                        }
                    }
                    let total =  lengthEncoding + headsConcatenated + tailsConcatenated
                    return total
                }
            case .staticSize(let staticLength):
                guard staticLength != 0 else {break}
                guard let val = value as? [Any] else {break}
                guard staticLength == val.count else {break}
                if subType.isStatic {
                    // work in a previous context
                    var toReturn = Data()
                    for i in 0 ..< val.count {
                        let enc = encodeSingleType(type: subType, value: val[i])
                        guard let encoding = enc else {break}
                        toReturn.append(encoding)
                    }
                    let total = toReturn
                    return total
                } else {
                    // create new context
                    var tails = [Data]()
                    var heads = [Data]()
                    for i in 0 ..< val.count {
                        let enc = encodeSingleType(type: subType, value: val[i])
                        guard let encoding = enc else { return nil }
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
                        guard let newHead = tailsPointer.abiEncode(bits: 256) else { return nil }
                        headsConcatenated.append(newHead)
                        tailsConcatenated.append(tail)
                        tailsPointer = tailsPointer + BigUInt(tail.count)
                    }
                    let total = headsConcatenated + tailsConcatenated
                    return total
                }
            case .notArray:
                break
            }
        case .tuple(types: let subTypes):
            var tails = [Data]()
            var heads = [Data]()
            guard let val = value as? [Any] else {break}
            for i in 0 ..< subTypes.count {
                let enc = encodeSingleType(type: subTypes[i], value: val[i])
                guard let encoding = enc else { return nil }
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
                    guard let newHead = tailsPointer.abiEncode(bits: 256) else { return nil }
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

// MARK: - SoliditySHA3 implementation based on web3js

public extension ABIEncoder {

    /// A convenience implementation of web3js [soliditySha3](https://web3js.readthedocs.io/en/v1.2.11/web3-utils.html?highlight=soliditySha3#soliditysha3)
    /// that is based on web3swift [`ABIEncoder`](https://github.com/skywinder/web3swift/blob/develop/Sources/web3swift/EthereumABI/ABIEncoding.swift ).
    /// - Parameter values: an array of values to hash. Supported types are: `Int/UInt` (any of 8, 16, 32, 64 bits long),
    /// decimal or hexadecimal `String`, `Bool`, `Data`, `[UInt8]`, `EthereumAddress`, `[IntegerLiteralType]`, `BigInt` or `BigUInt`.
    /// - Returns: solidity SHA3, `nil` if hashing failed or throws if type is not supported.
    static func soliditySha3(_ values: [Any]) throws -> Data {
        try abiEncode(values).sha3(.keccak256)
    }

    /// A convenience implementation of web3js [soliditySha3](https://web3js.readthedocs.io/en/v1.2.11/web3-utils.html?highlight=soliditySha3#soliditysha3)
    /// that is based on web3swift [`ABIEncoder`](https://github.com/skywinder/web3swift/blob/develop/Sources/web3swift/EthereumABI/ABIEncoding.swift ).
    /// - Parameter value: a value to hash. Supported types are: `Int/UInt` (any of 8, 16, 32, 64 bits long),
    /// decimal or hexadecimal `String`, `Bool`, `Data`, `[UInt8]`, `EthereumAddress`, `[IntegerLiteralType]`, `BigInt` or `BigUInt`.
    /// - Returns: solidity SHA3, `nil` if hashing failed or throws if type is not supported.
    static func soliditySha3(_ value: Any) throws -> Data {
        if let values = value as? [Any] {
            return try abiEncode(values).sha3(.keccak256)
        } else {
            return try abiEncode(value).sha3(.keccak256)
        }
    }

    /// Using Any any number can be represented as Bool and Bool can be represented as number.
    /// That will lead to invalid hash output. DO NOT USE THIS FUNCTION.
    /// This function will exist to intentionally throw an error that will raise awareness that the hash output can be potentially,
    /// and most likely will be, wrong.
    /// - Parameter values: to hash
    /// - Returns: solidity sha3 hash
    static func soliditySha3(_ values: [AnyObject]) throws -> Data {
        throw Web3Error.inputError(desc: "AnyObject creates ambiguity and does not guarantee that the output will be correct. Please, use `soliditySha3(Any) or soliditySha3([Any]) instead.`")
    }

    /// See docs for ``soliditySha3(_ values: [AnyObject])``
    static func soliditySha3(_ value: AnyObject) throws -> Data {
        throw Web3Error.inputError(desc: "AnyObject creates ambiguity and does not guarantee that the output will be correct. Please, use `soliditySha3(Any) or soliditySha3([Any]) instead.`")
    }

    static func abiEncode(_ values: [Any]) throws -> Data {
        return try values.map {
            try abiEncode($0)
        }.reduce(into: Data()) { partialResult, nextElement in
            partialResult.append(nextElement)
        }
    }

    static func abiEncode(_ value: Any) throws -> Data {
        if let v = value as? Bool {
            return Data(v ? [0b1] : [0b0])
        } else if let v = value as? Int {
            return ABIEncoder.convertToData(BigInt(exactly: v)?.abiEncode(bits: 256)!)!
        } else if let v = value as? Int8 {
            return ABIEncoder.convertToData(BigInt(exactly: v)?.abiEncode(bits: 8))!
        } else if let v = value as? Int16 {
            return ABIEncoder.convertToData(BigInt(exactly: v)?.abiEncode(bits: 16)!)!
        } else if let v = value as? Int32 {
            return ABIEncoder.convertToData(BigInt(exactly: v)?.abiEncode(bits: 32)!)!
        } else if let v = value as? Int64 {
            return ABIEncoder.convertToData(BigInt(exactly: v)?.abiEncode(bits: 64)!)!
        } else if let v = value as? UInt {
            return ABIEncoder.convertToData(BigUInt(exactly: v)?.abiEncode(bits: 256)!)!
        } else if let v = value as? UInt8 {
            return ABIEncoder.convertToData(BigUInt(exactly: v)?.abiEncode(bits: 8)!)!
        } else if let v = value as? UInt16 {
            return ABIEncoder.convertToData(BigUInt(exactly: v)?.abiEncode(bits: 16)!)!
        } else if let v = value as? UInt32 {
            return ABIEncoder.convertToData(BigUInt(exactly: v)?.abiEncode(bits: 32)!)!
        } else if let v = value as? UInt64 {
            return ABIEncoder.convertToData(BigUInt(exactly: v)?.abiEncode(bits: 64)!)!
        } else if let data = ABIEncoder.convertToData(value) {
            return data
        }
        throw Web3Error.inputError(desc: "SoliditySha3: `abiEncode` accepts an Int/UInt (any of 8, 16, 32, 64 bits long), decimal or hexadecimal string, Bool, Data, [UInt8], EthereumAddress, [IntegerLiteralType], BigInt or BigUInt instance. Given value is of type \(type(of: value)).")
    }
}
