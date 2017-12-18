//
//  ABIDecoder.swift
//  web3swift
//
//  Created by Alexander Vlasov on 05.12.2017.
//  Copyright © 2017 Alexander Vlasov. All rights reserved.
//

import Foundation
import Sodium
import BigInt


extension BigInt {
    static func fromTwosComplement(data: Data) -> BigInt {
        let isPositive = ((data[0] & 128) >> 7) == 0
        if (isPositive) {
            let magnitude = BigUInt(data)
            return BigInt(magnitude)
        } else {
            let MAX = (BigUInt(1) << 256)
            let magnitude = MAX - BigUInt(data)
            let bigint = BigInt(0) - BigInt(magnitude)
            return bigint
        }
    }
}

extension ABIElement.ParameterType.StaticType {
    func decode(expectedType: ABIElement.ParameterType.StaticType, data: Data, tailPointer: BigUInt) -> Any? {
        let sodium = Sodium()
        switch self {
        case .uint(let bits):
            let dataSlice = Data(data[0..<32])
            let biguint = BigUInt(dataSlice)
            guard biguint.bitWidth <= bits else {return nil}
            return biguint
        case .int(let bits):
            let dataSlice = Data(data[0..<32])
            let bigint = BigInt.fromTwosComplement(data: dataSlice)
            guard bigint.bitWidth <= bits else {return nil}
            return bigint
        case .address:
            let dataSlice = Data(data[0..<32])
            guard Data(dataSlice[0..<12]) == Data(count: 12) else {return nil}
            guard let hexAddress = sodium.utils.bin2hex(Data(dataSlice[12..<32])) else {return nil}
            return EthereumAddress(hexAddress)
        case .bool:
            let dataSlice = Data(data[0..<32])
            let biguint = BigUInt(dataSlice)
            guard biguint.bitWidth == 1 else {return nil}
            return biguint == BigUInt(1)
        case .bytes(let length):
            guard data.count <= length / 8 else {return nil}
            return data
        case .array(let type, let length):
            guard data.count <= length*32 else {return nil}
            var returnArray = [Any]()
            for i in 0..<length {
                let dataSlice = data[i*32 ..< (i+1)*32]
                guard let value = type.decode(expectedType: type, data: dataSlice, tailPointer: BigUInt(0)) else {return nil}
                returnArray.append(value)
            }
            return returnArray
        default:
            return nil
        }
        return nil
    }
}

extension ABIElement {
    func decodeReturnData(_ data: Data) -> [String:Any]? {
        switch self {
        case .constructor(_):
            return nil
        case .event(_):
            return nil
        case .fallback(_):
            return nil
        case .function(let function):
            guard function.outputs.count*32 <= data.count else {return nil}
            let tailPointer = BigUInt(function.outputs.count*32)
            var returnArray = [String:Any]()
            var i = 0;
            for output in function.outputs{
                let expectedType = output.type
                switch expectedType {
                case .staticType(let type):
                    guard let value = type.decode(expectedType: type, data: data, tailPointer: tailPointer) else {return nil}
                    let name = "\(i)"
                    returnArray[name] = value
                    if output.name != "" {
                        returnArray[output.name] = value
                    }
                    i = i + 1
                case .dynamicType(let type):
                    let name = "\(i)"
                    returnArray[name] = nil
                    if output.name != "" {
                        returnArray[output.name] = nil
                    }
                    i = i + 1
                    break
                }
            }
            return returnArray
        }
    }
}
