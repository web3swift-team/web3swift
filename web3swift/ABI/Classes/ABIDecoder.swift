//
//  ABIDecoder.swift
//  web3swift
//
//  Created by Alexander Vlasov on 05.12.2017.
//  Copyright © 2017 Alexander Vlasov. All rights reserved.
//

import Foundation
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
    func decode(expectedType: ABIElement.ParameterType.StaticType, data: Data, tailPointer: BigUInt) -> (bytesConsumed: Int?, value: Any?) {
        switch self {
        case .uint(let bits):
            let dataSlice = Data(data[0..<32])
            let biguint = BigUInt(dataSlice)
            guard biguint.bitWidth <= bits else {break}
            return (32, biguint)
        case .int(let bits):
            let dataSlice = Data(data[0..<32])
            let bigint = BigInt.fromTwosComplement(data: dataSlice)
            guard bigint.bitWidth <= bits else {break}
            return (32, bigint)
        case .address:
            let dataSlice = Data(data[0..<32])
            guard Data(dataSlice[0..<12]) == Data(count: 12) else {break}
            let addressData = Data(dataSlice[12..<32])
            let hexAddress = addressData.toHexString().addHexPrefix().lowercased()
            return (32, EthereumAddress(hexAddress))
        case .bool:
            let dataSlice = Data(data[0..<32])
            let biguint = BigUInt(dataSlice)
            guard biguint.bitWidth == 1 else {break}
            return (32, biguint == BigUInt(1))
        case .bytes(let length):
            guard data.count <= length / 8 else {break}
            return (32, data)
        case .array(let type, let length):
            guard data.count <= length*32 else {break}
            var returnArray = [Any]()
            var len = 0
            for i in 0..<length {
                let dataSlice = data[i*32 ..< (i+1)*32]
                let decoded = type.decode(expectedType: type, data: dataSlice, tailPointer: BigUInt(0))
                guard let value = decoded.value, let consumed = decoded.bytesConsumed else {break}
                len = len + consumed
                returnArray.append(value)
            }
            return (len, returnArray)
        default:
            return (nil, nil)
        }
        return (nil, nil)
    }
}

extension ABIElement.ParameterType.DynamicType {
    func decode(expectedType: ABIElement.ParameterType.DynamicType, data: Data, tailPointer: BigUInt) -> (bytesConsumed: Int?, value: Any?) {
        switch self {
        case .bytes:
            var totalConsumed = 0
            let pointer = Data(data[0..<32])
            totalConsumed = totalConsumed + 32
            let originalTail = BigUInt(pointer)
            let realTail = originalTail - tailPointer
            guard realTail >= BigUInt(32) else {break}
            guard let sliceStart = Int(String(realTail)) else {break}
            let lengthData = Data(data[sliceStart ..< sliceStart+32])
            guard let length = Int(String(BigUInt(lengthData))) else {break}
            let realData = Data(data[sliceStart+32 ..< sliceStart+32+length])
            return (totalConsumed, realData)
        case .string:
            var totalConsumed = 0
            let pointer = Data(data[0..<32])
            totalConsumed = totalConsumed + 32
            let originalTail = BigUInt(pointer)
            let realTail = originalTail - tailPointer
            if realTail == BigUInt(0) {
                return (32, "")
            }
//            guard realTail >= BigUInt(32) else {break}
            guard let sliceStart = Int(String(realTail)) else {break}
            let lengthData = Data(data[sliceStart ..< sliceStart+32])
            guard let length = Int(String(BigUInt(lengthData))) else {break}
            let realData = Data(data[sliceStart+32 ..< sliceStart+32+length])
            return (totalConsumed, String(data: realData, encoding: .utf8))
        case .dynamicArray(let type):
            var totalConsumed = 0
            let pointer = Data(data[0..<32])
            totalConsumed = totalConsumed + 32
            let originalTail = BigUInt(pointer)
            let realTail = originalTail - tailPointer
            guard realTail >= BigUInt(32) else {break}
            guard let sliceStart = Int(String(realTail)) else {break}
            let lengthData = Data(data[sliceStart ..< sliceStart+32])
            guard let length = Int(String(BigUInt(lengthData))) else {break}
            var returnArray = [Any]()
            var len = 0
            for i in 0..<length {
                let dataSlice = data[i*32 ..< (i+1)*32]
                let decoded = type.decode(expectedType: type, data: dataSlice, tailPointer: BigUInt(0))
                guard let value = decoded.value, let consumed = decoded.bytesConsumed else {break}
                len = len + consumed
                returnArray.append(value)
            }
            return (totalConsumed, returnArray)
        case .arrayOfDynamicTypes(let type, let length):
            return (nil, nil)
            var totalConsumed = 0
            let pointer = Data(data[0..<32])
            totalConsumed = totalConsumed + 32
            let originalTail = BigUInt(pointer)
            let realTail = originalTail - tailPointer
            guard realTail >= BigUInt(32) else {break}
            guard let sliceStart = Int(String(realTail)) else {break}
            let lengthData = Data(data[sliceStart ..< sliceStart+32])
            guard let length = Int(String(BigUInt(lengthData))) else {break}
            var returnArray = [Any]()
            var len = 0
            for i in 0..<length {
                let dataSlice = data[i*32 ..< (i+1)*32]
                let decoded = type.decode(expectedType: type, data: dataSlice, tailPointer: BigUInt(0))
                guard let value = decoded.value, let consumed = decoded.bytesConsumed else {break}
                len = len + consumed
                returnArray.append(value)
            }
            return (totalConsumed, returnArray)
        }
        return (nil, nil)
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
            var dataForProcessing = data
            var tailPointer = BigUInt(0)
            var returnArray = [String:Any]()
            var i = 0;
            for output in function.outputs{
                let expectedType = output.type
                switch expectedType {
                case .staticType(let type):
                    let decoded = type.decode(expectedType: type, data: dataForProcessing, tailPointer: BigUInt(0))
                    guard let value = decoded.value, let consumed = decoded.bytesConsumed else {break}
                    let name = "\(i)"
                    returnArray[name] = value
                    if output.name != "" {
                        returnArray[output.name] = value
                    }
                    i = i + 1
                    if dataForProcessing.count >= consumed {
                        dataForProcessing = Data(dataForProcessing[consumed...])
                        tailPointer = tailPointer + BigUInt(consumed)
                    } else {
                        return nil
                    }
                case .dynamicType(let type):
                    let decoded = type.decode(expectedType: type, data: dataForProcessing, tailPointer: tailPointer)
                    guard let value = decoded.value, let consumed = decoded.bytesConsumed else {break}
                    let name = "\(i)"
                    returnArray[name] = value
                    if output.name != "" {
                        returnArray[output.name] = value
                    }
                    i = i + 1
                    if dataForProcessing.count >= consumed {
                        dataForProcessing = Data(dataForProcessing[consumed...])
                        tailPointer = tailPointer + BigUInt(consumed)
                    } else {
                        return nil
                    }
                }
            }
            return returnArray
        }
    }
}

extension ABIElement {
    func decodeReturnedLogs(_ eventLog: EventLog) -> [String:Any]? {
        switch self {
        case .constructor(_):
            return nil
        case .event(let event):
            if event.anonymous {return nil}
            if eventLog.topics[0] != event.topic {
                return nil
            }
            var eventContent = [String: Any]()
            eventContent["name"]=event.name
            let logs = eventLog.topics
            var dataForProcessing = eventLog.data
            var tailPointer = BigUInt(0)
            var j = 1
            for i in 0 ..< event.inputs.count {
                let el = event.inputs[i]
                if el.indexed {
                    let elementData = logs[j]
                    j = j + 1
                    let expectedType = el.type
                    switch expectedType {
                    case .staticType(let type):
                        let decoded = type.decode(expectedType: type, data: elementData, tailPointer: BigUInt(0))
                        guard let value = decoded.value, let _ = decoded.bytesConsumed else {break}
                        let name = "\(i)"
                        eventContent[name] = value
                        if el.name != "" {
                            eventContent[el.name] = value
                        }
                    case .dynamicType(let type):
                        let decoded = type.decode(expectedType: type, data: elementData, tailPointer: BigUInt(0))
                        guard let value = decoded.value, let _ = decoded.bytesConsumed else {break}
                        let name = "\(i)"
                        eventContent[name] = value
                        if el.name != "" {
                            eventContent[el.name] = value
                        }
                    }
                } else {
                    let expectedType = el.type
                    switch expectedType {
                    case .staticType(let type):
                        let decoded = type.decode(expectedType: type, data: dataForProcessing, tailPointer: BigUInt(0))
                        guard let value = decoded.value, let consumed = decoded.bytesConsumed else {break}
                        let name = "\(i)"
                        eventContent[name] = value
                        if el.name != "" {
                            eventContent[el.name] = value
                        }
                        if dataForProcessing.count >= consumed {
                            dataForProcessing = Data(dataForProcessing[consumed...])
                            tailPointer = tailPointer + BigUInt(consumed)
                        } else {
                            return nil
                        }
                    case .dynamicType(let type):
                        let decoded = type.decode(expectedType: type, data: dataForProcessing, tailPointer: tailPointer)
                        guard let value = decoded.value, let consumed = decoded.bytesConsumed else {break}
                        let name = "\(i)"
                        eventContent[name] = value
                        if el.name != "" {
                            eventContent[el.name] = value
                        }
                        if dataForProcessing.count >= consumed {
                            dataForProcessing = Data(dataForProcessing[consumed...])
                            tailPointer = tailPointer + BigUInt(consumed)
                        } else {
                            return nil
                        }
                    }
                }
            }
            return eventContent
        case .fallback(_):
            return nil
        case .function(_):
            return nil
        }
    }
}
