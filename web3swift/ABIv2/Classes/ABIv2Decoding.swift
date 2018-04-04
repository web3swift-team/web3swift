//
//  ABIv2Decoding.swift
//  web3swift
//
//  Created by Alexander Vlasov on 04.04.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt

public struct ABIv2Decoder {
    
}

extension ABIv2Decoder {
    public static func decode(types: [ABIv2.Element.InOut], data: Data) -> [AnyObject]? {
        let params = types.flatMap { (el) -> ABIv2.Element.ParameterType in
            return el.type
        }
        let tuple = ABIv2.Element.ParameterType.tuple(types: params, dynamic: false)
        let (v, _) = decodeTypesTuple(tuple: tuple, data: data)
        guard let values = v, values.count == types.count else {return nil}
        return values
    }
    
    public static func decodeSignleType(type: ABIv2.Element.ParameterType, data: Data, pointer: UInt64 = 0) -> (value: AnyObject?, bytesConsumed: UInt64?) {
        switch type {
        case .uint(let bits):
            guard data.count >= pointer + 32 else {break}
            let mod = BigUInt(1) << bits
            let dataSlice = Data(data[pointer ..< pointer+32])
            let v = BigUInt(dataSlice) % mod
            return (v as AnyObject, type.memoryUsage)
        case .int(let bits):
            guard data.count >= pointer + 32 else {break}
            let mod = BigInt(1) << bits
            let dataSlice = Data(data[pointer ..< pointer+32])
            let v = BigInt.fromTwosComplement(data: dataSlice) % mod
            return (v as AnyObject, type.memoryUsage)
        case .address:
            guard data.count >= pointer + 32 else {break}
            let dataSlice = Data(data[pointer+12 ..< pointer+32])
            return (EthereumAddress(dataSlice) as AnyObject, type.memoryUsage)
        case .bool:
            guard data.count >= pointer + 32 else {break}
            let dataSlice = Data(data[pointer ..< pointer+32])
            let v = BigUInt(dataSlice)
            if v == BigUInt(1) {
                return (true as AnyObject, type.memoryUsage)
            } else if (v == BigUInt(0)) {
                return (false as AnyObject, type.memoryUsage)
            }
        case .bytes(let length):
            guard data.count >= pointer + 32 else {break}
            let dataSlice = Data(data[pointer ..< pointer+length])
            return (dataSlice as AnyObject, type.memoryUsage)
        case .string:
            guard data.count >= pointer + 32 else {break}
            var dataSlice = Data(data[pointer ..< pointer+32])
            let ptr = UInt64(BigUInt(dataSlice))
            guard data.count >= ptr + 32 else {break}
            dataSlice = Data(data[ptr ..< ptr + 32])
            let length = UInt64(BigUInt(dataSlice))
            dataSlice = Data(data[ptr + 32 ..< ptr + 32 + length])
            guard let string = String(data: dataSlice, encoding: .utf8) else {break}
            return (string as AnyObject, type.memoryUsage)
        case .dynamicBytes:
            guard data.count >= pointer + 32 else {break}
            var dataSlice = Data(data[pointer ..< pointer+32])
            let ptr = UInt64(BigUInt(dataSlice))
            guard data.count >= ptr + 32 else {break}
            dataSlice = Data(data[ptr ..< ptr + 32])
            let length = UInt64(BigUInt(dataSlice))
            guard data.count >= ptr + 32 + length else {break}
            dataSlice = Data(data[ptr + 32 ..< ptr + 32 + length])
            return (dataSlice as AnyObject, type.memoryUsage)
        case .array(type: let subType, length: let length):
            switch type.arraySize {
            case .dynamicSize:
                guard data.count >= pointer + 32 else {break}
                var dataSlice = Data(data[pointer ..< pointer+32])
                let ptr = UInt64(BigUInt(dataSlice))
                guard data.count >= ptr + 32 else {break}
                dataSlice = Data(data[ptr ..< ptr + 32])
                let length = UInt64(BigUInt(dataSlice))
                guard data.count >= ptr + subType.memoryUsage*length else {break}
                dataSlice = Data(data[ptr + 32 ..< ptr + subType.memoryUsage*length])
                var subpointer = ptr + 32;
                var toReturn = [AnyObject]()
                for _ in 0 ..< length {
                    let (v, c) = decodeSignleType(type: subType, data: data, pointer: subpointer)
                    guard let valueUnwrapped = v, let consumedUnwrapped = c else {break}
                    toReturn.append(valueUnwrapped)
                    subpointer = subpointer + consumedUnwrapped
                }
                return (toReturn as AnyObject, type.memoryUsage)
            case .staticSize(let staticLength):
                guard length == staticLength else {break}
                let types = [ABIv2.Element.ParameterType](repeating: subType, count: Int(length))
                let tuple = ABIv2.Element.ParameterType.tuple(types: types, dynamic: false)
                let (v, c) = decodeTypesTuple(tuple: tuple, data: data, pointer: pointer)
                guard let valueUnwrapped = v, let consumedUnwrapped = c else {break}
                return (valueUnwrapped as AnyObject, consumedUnwrapped)
            case .notArray:
                break
            }
        case .tuple(types: let subTypes, dynamic: let dynamic):
            let (v, c) = decodeTypesTuple(tuple: type, data: data, pointer: pointer)
            guard let valueUnwrapped = v, let consumedUnwrapped = c else {break}
            return (valueUnwrapped as AnyObject, consumedUnwrapped)
        case .function:
            guard data.count >= pointer + 32 else {break}
            let dataSlice = Data(data[pointer+8 ..< pointer+32])
            return (dataSlice as AnyObject, type.memoryUsage)
        }
        return (nil, nil)
    }
    
    public static func decodeTypesTuple(tuple: ABIv2.Element.ParameterType, data: Data, pointer: UInt64 = 0) -> (values: [AnyObject]?, bytesConsumed: UInt64?) {
        guard case .tuple(types: let types, dynamic: _) = tuple else {return (nil, nil)}
        var toReturn = [AnyObject]()
        var consumed:UInt64 = 0
        for i in 0 ..< types.count {
            let (v, c) = decodeSignleType(type: types[i], data: data, pointer: consumed)
            guard let valueUnwrapped = v, let consumedUnwrapped = c else {return (nil, nil)}
            toReturn.append(valueUnwrapped)
            consumed = consumed + consumedUnwrapped
        }
        return (toReturn, consumed)
    }
    
    public static func decodeLog(event: ABIv2.Element.Event, eventLog: EventLog) -> [String:Any]? {
        if event.topic != eventLog.topics[0] && !event.anonymous {
            return nil
        }
        var eventContent = [String: Any]()
        eventContent["name"]=event.name
        let logs = eventLog.topics
        let dataForProcessing = eventLog.data
        if (logs.count == 1 && event.inputs.count > 0) {
            return nil
        }
        let indexedInputs = event.inputs.filter { (inp) -> Bool in
            return inp.indexed
        }
        let nonIndexedInputs = event.inputs.filter { (inp) -> Bool in
            return !inp.indexed
        }
        let nonIndexedTypes = nonIndexedInputs.flatMap { (inp) -> ABIv2.Element.ParameterType in
            return inp.type
        }
        guard logs.count == indexedInputs.count + 1 else {return nil}
        var indexedValues = [AnyObject]()
        for i in 0 ..< indexedInputs.count {
            let data = logs[i+1]
            let input = indexedInputs[i]
            if !input.type.isStatic || input.type.isArray || input.type.memoryUsage != 32 {
                let (v, _) = ABIv2Decoder.decodeSignleType(type: .bytes(length: 32), data: data)
                guard let valueUnwrapped = v else {return nil}
                indexedValues.append(valueUnwrapped)
            } else {
                let (v, _) = ABIv2Decoder.decodeSignleType(type: input.type, data: data)
                guard let valueUnwrapped = v else {return nil}
                indexedValues.append(valueUnwrapped)
            }
        }
        let (v, _) = ABIv2Decoder.decodeTypesTuple(tuple: ABIv2.Element.ParameterType.tuple(types: nonIndexedTypes, dynamic: false), data: dataForProcessing)
        guard let nonIndexedValues = v else {return nil}
        var indexedInputCounter = 0
        var nonIndexedInputCounter = 0
        for i in 0 ..< event.inputs.count {
            let el = event.inputs[i]
            if el.indexed {
                let name = "\(i)"
                let value = indexedValues[indexedInputCounter]
                eventContent[name] = value
                if el.name != "" {
                    eventContent[el.name] = value
                }
                indexedInputCounter = indexedInputCounter + 1
            } else {
                let name = "\(i)"
                let value = nonIndexedValues[nonIndexedInputCounter]
                eventContent[name] = value
                if el.name != "" {
                    eventContent[el.name] = value
                }
                nonIndexedInputCounter = nonIndexedInputCounter + 1
            }
        }
        return eventContent
    }
}
