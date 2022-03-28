//
//  SoliditySha3.swift
//  web3swift
//
//  Created by JeneaVranceanu on 28/03/2022.
//  Copyright © 2022 web3swift. All rights reserved.
//

import Foundation
import BigInt

/**
 A convenience implementation of web3js [soliditySha3](https://web3js.readthedocs.io/en/v1.2.11/web3-utils.html?highlight=soliditySha3#soliditysha3)
 that is based on web3swift [`ABIEncoder`](https://github.com/skywinder/web3swift/blob/develop/Sources/web3swift/EthereumABI/ABIEncoding.swift ).
 */
func soliditySha3(_ values: [Any]) -> Data {
    abiEncode(values).sha3(.keccak256)
}

func soliditySha3(_ value: Any) -> Data {
    if let values = value as? [Any] {
        return abiEncode(values).sha3(.keccak256)
    } else {
        return try! abiEncode(value).sha3(.keccak256)
    }
}

/// Using AnyObject any number can be represented as Bool and Bool can be represented as number.
/// That will lead to invalid hash output. DO NOT USE THIS FUNCTION.
/// This function will exist to intentionally throw an error that will raise awareness that the hash output can be potentially,
/// and most likely will be, wrong.
/// - Parameter values: to hash
/// - Returns: solidity sha3 hash
func soliditySha3(_ values: [AnyObject]) throws -> Data {
    throw Web3Error.inputError(desc: "AnyObject creates ambiguity and does not guarantee that the output will be correct. Please, use `soliditySha3(Any) or soliditySha3([Any]) instead.`")
}

/// See docs for ``soliditySha3(_ values: [AnyObject])``
func soliditySha3(_ value: AnyObject) throws -> Data {
    throw Web3Error.inputError(desc: "AnyObject creates ambiguity and does not guarantee that the output will be correct. Please, use `soliditySha3(Any) or soliditySha3([Any]) instead.`")
}

func abiEncode(_ values: [Any]) -> Data {
    return values.map {
        try! abiEncode($0)
    }.reduce(into: Data()) { partialResult, nextElement in
        partialResult.append(nextElement)
    }
}

func abiEncode(_ value: Any) throws -> Data {
    if let v = value as? Bool {
        return Data(v ? [0b1] : [0b0])
    } else if let v = value as? Int {
        return ABIEncoder.convertToData(BigInt(exactly: v)?.abiEncode(bits: 256)! as AnyObject)!
    } else if let v = value as? Int8 {
        return ABIEncoder.convertToData(BigInt(exactly: v)?.abiEncode(bits: 8) as AnyObject)!
    } else if let v = value as? Int16 {
        return ABIEncoder.convertToData(BigInt(exactly: v)?.abiEncode(bits: 16)! as AnyObject)!
    } else if let v = value as? Int32 {
        return ABIEncoder.convertToData(BigInt(exactly: v)?.abiEncode(bits: 32)! as AnyObject)!
    } else if let v = value as? Int64 {
        return ABIEncoder.convertToData(BigInt(exactly: v)?.abiEncode(bits: 64)! as AnyObject)!
    } else if let v = value as? UInt {
        return ABIEncoder.convertToData(BigUInt(exactly: v)?.abiEncode(bits: 256)! as AnyObject)!
    } else if let v = value as? UInt8 {
        return ABIEncoder.convertToData(BigUInt(exactly: v)?.abiEncode(bits: 8)! as AnyObject)!
    } else if let v = value as? UInt16 {
        return ABIEncoder.convertToData(BigUInt(exactly: v)?.abiEncode(bits: 16)! as AnyObject)!
    } else if let v = value as? UInt32 {
        return ABIEncoder.convertToData(BigUInt(exactly: v)?.abiEncode(bits: 32)! as AnyObject)!
    } else if let v = value as? UInt64 {
        return ABIEncoder.convertToData(BigUInt(exactly: v)?.abiEncode(bits: 64)! as AnyObject)!
    } else if let data = ABIEncoder.convertToData(value as AnyObject) {
        return data
    }
    throw Web3Error.inputError(desc: "SoliditySha3: `abiEncode` accepts an Int/UInt (any of 8, 16, 32, 64 bits long), HEX string, Bool, Data, BigInt or BigUInt instance. Given value is of type \(type(of: value)).")
}
