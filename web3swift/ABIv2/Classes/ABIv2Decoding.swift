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
        print("Full data: \n" + data.toHexString())
        let params = types.flatMap { (el) -> ABIv2.Element.ParameterType in
            return el.type
        }
        var toReturn = [AnyObject]()
        var consumed:UInt64 = 0
        for i in 0 ..< params.count {
            let (v, c) = decodeSignleType(type: params[i], data: data, pointer: consumed)
            guard let valueUnwrapped = v, let consumedUnwrapped = c else {return nil}
            toReturn.append(valueUnwrapped)
            consumed = consumed + consumedUnwrapped
        }
        guard toReturn.count == types.count else {return nil}
        return toReturn
//        if types.count == 1, case .tuple(let tupleTypes) = types[0].type {
//            let (v, _) = decodeTypesTuple(tuple: types[0].type, data: data)
//            guard let values = v, values.count == tupleTypes.count else {return nil}
//            let toReturn = [values] as [AnyObject]
//            return toReturn
//        }
//        let params = types.flatMap { (el) -> ABIv2.Element.ParameterType in
//            return el.type
//        }
//        let tuple = ABIv2.Element.ParameterType.tuple(types: params)
//        let (v, _) = decodeTypesTuple(tuple: tuple, data: data)
//
//        return values
    }
    
    public static func decodeSignleType(type: ABIv2.Element.ParameterType, data: Data, pointer: UInt64 = 0) -> (value: AnyObject?, bytesConsumed: UInt64?) {
        let (elData, nextPtr) = followTheData(type: type, data: data, pointer: pointer)
        guard let elementItself = elData, let nextElementPointer = nextPtr else {
            return (nil, nil)
        }
        switch type {
        case .uint(let bits):
            print("Uint256 element itself: \n" + elementItself.toHexString())
            guard elementItself.count >= 32 else {break}
            let mod = BigUInt(1) << bits
            let dataSlice = elementItself[0 ..< 32]
            let v = BigUInt(dataSlice) % mod
            return (v as AnyObject, type.memoryUsage)
        case .int(let bits):
            print("Int256 element itself: \n" + elementItself.toHexString())
            guard elementItself.count >= 32 else {break}
            let mod = BigInt(1) << bits
            let dataSlice = elementItself[0 ..< 32]
            let v = BigInt.fromTwosComplement(data: dataSlice) % mod
            return (v as AnyObject, type.memoryUsage)
        case .address:
            print("Address element itself: \n" + elementItself.toHexString())
            guard elementItself.count >= 32 else {break}
            let dataSlice = elementItself[12 ..< 32]
            return (EthereumAddress(dataSlice) as AnyObject, type.memoryUsage)
        case .bool:
            print("Bool element itself: \n" + elementItself.toHexString())
            guard elementItself.count >= 32 else {break}
            let dataSlice = elementItself[0 ..< 32]
            let v = BigUInt(dataSlice)
            if v == BigUInt(1) {
                return (true as AnyObject, type.memoryUsage)
            } else if (v == BigUInt(0)) {
                return (false as AnyObject, type.memoryUsage)
            }
        case .bytes(let length):
            print("Bytes32 element itself: \n" + elementItself.toHexString())
            guard elementItself.count >= 32 else {break}
            let dataSlice = elementItself[0 ..< length]
            return (dataSlice as AnyObject, type.memoryUsage)
        case .string:
            print("String element itself: \n" + elementItself.toHexString())
            guard elementItself.count >= 32 else {break}
            var dataSlice = elementItself[0 ..< 32]
            let length = UInt64(BigUInt(dataSlice))
            guard elementItself.count >= 32+length else {break}
            dataSlice = elementItself[32 ..< 32 + length]
            guard let string = String(data: dataSlice, encoding: .utf8) else {break}
            return (string as AnyObject, type.memoryUsage)
        case .dynamicBytes:
            print("Bytes element itself: \n" + elementItself.toHexString())
            guard elementItself.count >= 32 else {break}
            var dataSlice = elementItself[0 ..< 32]
            let length = UInt64(BigUInt(dataSlice))
            guard elementItself.count >= 32+length else {break}
            dataSlice = elementItself[32 ..< 32 + length]
            return (dataSlice as AnyObject, type.memoryUsage)
        case .array(type: let subType, length: let length):
            switch type.arraySize {
            case .dynamicSize:
                print("Dynamic array element itself: \n" + elementItself.toHexString())
                if subType.isStatic {
                    // uint[] like, expect length and elements
                    guard elementItself.count >= 32 else {break}
                    var dataSlice = elementItself[0 ..< 32]
                    let length = UInt64(BigUInt(dataSlice))
                    guard elementItself.count >= 32 + subType.memoryUsage*length else {break}
                    dataSlice = elementItself[32 ..< subType.memoryUsage*length]
                    var subpointer: UInt64 = 32;
                    var toReturn = [AnyObject]()
                    for _ in 0 ..< length {
                        let (v, c) = decodeSignleType(type: subType, data: elementItself, pointer: subpointer)
                        guard let valueUnwrapped = v, let consumedUnwrapped = c else {break}
                        toReturn.append(valueUnwrapped)
                        subpointer = subpointer + consumedUnwrapped
                    }
                    return (toReturn as AnyObject, type.memoryUsage)
                } else {
                    // dynamic array of dynamic types is not yet supported
                    break
                }
            case .staticSize(let staticLength):
                print("Static array element itself: \n" + elementItself.toHexString())
                guard length == staticLength else {break}
                var toReturn = [AnyObject]()
                var consumed:UInt64 = 0
                for _ in 0 ..< length {
                    let (v, c) = decodeSignleType(type: subType, data: elementItself, pointer: consumed)
                    guard let valueUnwrapped = v, let consumedUnwrapped = c else {return (nil, nil)}
                    toReturn.append(valueUnwrapped)
                    consumed = consumed + consumedUnwrapped
                }
                if subType.isStatic {
                    return (toReturn as AnyObject, consumed)
                } else {
                    return (toReturn as AnyObject, nextElementPointer)
                }
            case .notArray:
                break
            }
//            switch type.arraySize {
//            case .dynamicSize:
//
//                guard data.count >= pointer + 32 else {break}
//                var dataSlice = Data(data[pointer ..< pointer+32])
//                let ptr = UInt64(BigUInt(dataSlice))
//                guard data.count >= ptr + 32 else {break}
//                if subType.isStatic {
//                    dataSlice = Data(data[ptr ..< ptr + 32])
//                    let length = UInt64(BigUInt(dataSlice))
//                    guard data.count >= ptr + subType.memoryUsage*length else {break}
//                    dataSlice = Data(data[ptr + 32 ..< ptr + subType.memoryUsage*length])
//                    var subpointer = ptr + 32;
//                    var toReturn = [AnyObject]()
//                    for _ in 0 ..< length {
//                        let (v, c) = decodeSignleType(type: subType, data: data, pointer: subpointer)
//                        guard let valueUnwrapped = v, let consumedUnwrapped = c else {break}
//                        toReturn.append(valueUnwrapped)
//                        subpointer = subpointer + consumedUnwrapped
//                    }
//                    return (toReturn as AnyObject, type.memoryUsage)
//                } else {
//                    dataSlice = Data(data[ptr ..< UInt64(data.count)])
//                    var subpointer:UInt64 = 0;
//                    var toReturn = [AnyObject]()
//                    for _ in 0 ..< length {
//                        let (v, c) = decodeSignleType(type: subType, data: dataSlice, pointer: subpointer)
//                        guard let valueUnwrapped = v, let consumedUnwrapped = c else {break}
//                        toReturn.append(valueUnwrapped)
//                        subpointer = subpointer + consumedUnwrapped
//                    }
//                    return (toReturn as AnyObject, type.memoryUsage)
//                }
//            case .staticSize(let staticLength):
//                guard length == staticLength else {break}
//                let types = [ABIv2.Element.ParameterType](repeating: subType, count: Int(length))
//                let tuple = ABIv2.Element.ParameterType.tuple(types: types)
//                let dataSlice = Data(data[pointer ..< pointer + length*subType.memoryUsage])
////                let (v, c) = decodeTypesTuple(tuple: tuple, data: data, pointer: pointer)
//                let (v, c) = decodeTypesTuple(tuple: tuple, data: dataSlice, pointer: 0)
//                guard let valueUnwrapped = v, let consumedUnwrapped = c else {break}
//                return (valueUnwrapped as AnyObject, consumedUnwrapped)
//            case .notArray:
//                break
//            }
        case .tuple(types: let subTypes):
            print("Tuple element itself: \n" + elementItself.toHexString())
            var toReturn = [AnyObject]()
            var consumed:UInt64 = pointer
            for i in 0 ..< subTypes.count {
                let (v, c) = decodeSignleType(type: subTypes[i], data: elementItself, pointer: consumed)
                guard let valueUnwrapped = v, let consumedUnwrapped = c else {return (nil, nil)}
                toReturn.append(valueUnwrapped)
                consumed = consumed + consumedUnwrapped
            }
            return (toReturn as AnyObject, consumed)
        case .function:
            guard data.count >= pointer + 32 else {break}
            let dataSlice = Data(data[pointer+8 ..< pointer+32])
            return (dataSlice as AnyObject, type.memoryUsage)
        }
        return (nil, nil)
    }
    
    public static func decodeTypesTuple(tuple: ABIv2.Element.ParameterType, data: Data, pointer: UInt64 = 0) -> (values: [AnyObject]?, bytesConsumed: UInt64?) {
        guard case .tuple(types: let types) = tuple else {return (nil, nil)}
        var toReturn = [AnyObject]()
        var consumed:UInt64 = pointer
        let (elData, nextPtr) = followTheData(type: tuple, data: data, pointer: pointer)
        guard let elementData = elData, let nextPointer = nextPtr else {
            return (nil, nil)
        }
        print("Tuple element itself: \n" + data.toHexString())
        for i in 0 ..< types.count {
            let (v, c) = decodeSignleType(type: types[i], data: data, pointer: consumed)
            guard let valueUnwrapped = v, let consumedUnwrapped = c else {return (nil, nil)}
            toReturn.append(valueUnwrapped)
            consumed = consumed + consumedUnwrapped
        }
        return (toReturn, consumed)
//        if tuple.isStatic {
//
//        } else {
//            return (toReturn, nextPointer)
//        }
        
//        if tuple.isStatic {
//            for i in 0 ..< types.count {
//                let (v, c) = decodeSignleType(type: types[i], data: data, pointer: consumed)
//                guard let valueUnwrapped = v, let consumedUnwrapped = c else {return (nil, nil)}
//                toReturn.append(valueUnwrapped)
//                consumed = consumed + consumedUnwrapped
//            }
//        } else {
//            guard data.count >= consumed + 32 else {return (nil, nil)}
//            var dataSlice = Data(data[consumed ..< consumed+32])
//            let ptr = UInt64(BigUInt(dataSlice))
//            guard data.count >= ptr + 32 else {return (nil, nil)}
//            dataSlice = Data(data[ptr ..< UInt64(data.count)])
//            for i in 0 ..< types.count {
//                let (v, c) = decodeSignleType(type: types[i], data: dataSlice, pointer: consumed)
//                guard let valueUnwrapped = v, let consumedUnwrapped = c else {return (nil, nil)}
//                toReturn.append(valueUnwrapped)
//                consumed = consumed + consumedUnwrapped
//            }
//        }
//        return (toReturn, consumed)
    }
    
    
    
    fileprivate static func followTheData(type: ABIv2.Element.ParameterType, data: Data, pointer: UInt64 = 0) -> (elementEncoding: Data?, nextElementPointer: UInt64?) {
        print("Follow the data: \n" + data.toHexString())
        print("At pointer: \n" + String(pointer))
        if type.isStatic {
            guard data.count >= pointer + type.memoryUsage else {return (nil, nil)}
            let elementItself = data[pointer ..< pointer + type.memoryUsage]
            let nextElement = pointer + type.memoryUsage
            print("Got element itself: \n" + elementItself.toHexString())
            print("Next element pointer: \n" + String(nextElement))
            return (Data(elementItself), nextElement)
        } else {
            guard data.count >= pointer + type.memoryUsage else {return (nil, nil)}
            let dataSlice = data[pointer ..< pointer + type.memoryUsage]
            let elementPointer = UInt64(BigUInt(dataSlice))
            let elementItself = data[elementPointer ..< UInt64(data.count)]
            let nextElement = pointer + type.memoryUsage
            print("Got element itself: \n" + elementItself.toHexString())
            print("Next element pointer: \n" + String(nextElement))
            return (Data(elementItself), nextElement)
        }
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
        let (v, _) = ABIv2Decoder.decodeTypesTuple(tuple: ABIv2.Element.ParameterType.tuple(types: nonIndexedTypes), data: dataForProcessing)
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
