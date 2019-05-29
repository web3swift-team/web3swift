//
//  Created by Alex Vlasov on 25/10/2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt

public struct ABIDecoder {
    
}

extension ABIDecoder {
    public static func decode(types: [ABI.Element.InOut], data: Data) -> [AnyObject]? {
        let params = types.compactMap { (el) -> ABI.Element.ParameterType in
            return el.type
        }
        return decode(types: params, data: data)
    }
    
    public static func decode(types: [ABI.Element.ParameterType], data: Data) -> [AnyObject]? {
        //        print("Full data: \n" + data.toHexString())
        var toReturn = [AnyObject]()
        var consumed: UInt64 = 0
        for i in 0 ..< types.count {
            let (v, c) = decodeSignleType(type: types[i], data: data, pointer: consumed)
            guard let valueUnwrapped = v, let consumedUnwrapped = c else {return nil}
            toReturn.append(valueUnwrapped)
            consumed = consumed + consumedUnwrapped
        }
        guard toReturn.count == types.count else {return nil}
        return toReturn
    }
    
    public static func decodeSignleType(type: ABI.Element.ParameterType, data: Data, pointer: UInt64 = 0) -> (value: AnyObject?, bytesConsumed: UInt64?) {
        let (elData, nextPtr) = followTheData(type: type, data: data, pointer: pointer)
        guard let elementItself = elData, let nextElementPointer = nextPtr else {
            return (nil, nil)
        }
        switch type {
        case .uint(let bits):
            //            print("Uint256 element itself: \n" + elementItself.toHexString())
            guard elementItself.count >= 32 else {break}
            let mod = BigUInt(1) << bits
            let dataSlice = elementItself[0 ..< 32]
            let v = BigUInt(dataSlice) % mod
            //            print("Uint256 element is: \n" + String(v))
            return (v as AnyObject, type.memoryUsage)
        case .int(let bits):
            //            print("Int256 element itself: \n" + elementItself.toHexString())
            guard elementItself.count >= 32 else {break}
            let mod = BigInt(1) << bits
            let dataSlice = elementItself[0 ..< 32]
            let v = BigInt.fromTwosComplement(data: dataSlice) % mod
            //            print("Int256 element is: \n" + String(v))
            return (v as AnyObject, type.memoryUsage)
        case .address:
            //            print("Address element itself: \n" + elementItself.toHexString())
            guard elementItself.count >= 32 else {break}
            let dataSlice = elementItself[12 ..< 32]
            let address = EthereumAddress(dataSlice)
            //            print("Address element is: \n" + String(address.address))
            return (address as AnyObject, type.memoryUsage)
        case .bool:
            //            print("Bool element itself: \n" + elementItself.toHexString())
            guard elementItself.count >= 32 else {break}
            let dataSlice = elementItself[0 ..< 32]
            let v = BigUInt(dataSlice)
            //            print("Address element is: \n" + String(v))
            if v == BigUInt(36) ||
                v == BigUInt(32) ||
                v == BigUInt(28) ||
                v == BigUInt(1) {
                return (true as AnyObject, type.memoryUsage)
            } else if v == BigUInt(35) ||
                v == BigUInt(31) ||
                v == BigUInt(27) ||
                v == BigUInt(0) {
                return (false as AnyObject, type.memoryUsage)
            }
        case .bytes(let length):
            //            print("Bytes32 element itself: \n" + elementItself.toHexString())
            guard elementItself.count >= 32 else {break}
            let dataSlice = elementItself[0 ..< length]
            //            print("Bytes32 element is: \n" + String(dataSlice.toHexString()))
            return (dataSlice as AnyObject, type.memoryUsage)
        case .string:
            //            print("String element itself: \n" + elementItself.toHexString())
            guard elementItself.count >= 32 else {break}
            var dataSlice = elementItself[0 ..< 32]
            let length = UInt64(BigUInt(dataSlice))
            guard elementItself.count >= 32+length else {break}
            dataSlice = elementItself[32 ..< 32 + length]
            guard let string = String(data: dataSlice, encoding: .utf8) else {break}
            //            print("String element is: \n" + String(string))
            return (string as AnyObject, type.memoryUsage)
        case .dynamicBytes:
            //            print("Bytes element itself: \n" + elementItself.toHexString())
            guard elementItself.count >= 32 else {break}
            var dataSlice = elementItself[0 ..< 32]
            let length = UInt64(BigUInt(dataSlice))
            guard elementItself.count >= 32+length else {break}
            dataSlice = elementItself[32 ..< 32 + length]
            //            print("Bytes element is: \n" + String(dataSlice.toHexString()))
            return (dataSlice as AnyObject, type.memoryUsage)
        case .array(type: let subType, length: let length):
            switch type.arraySize {
            case .dynamicSize:
                //                print("Dynamic array element itself: \n" + elementItself.toHexString())
                if subType.isStatic {
                    // uint[] like, expect length and elements
                    guard elementItself.count >= 32 else {break}
                    var dataSlice = elementItself[0 ..< 32]
                    let length = UInt64(BigUInt(dataSlice))
                    guard elementItself.count >= 32 + subType.memoryUsage*length else {break}
                    dataSlice = elementItself[32 ..< 32 + subType.memoryUsage*length]
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
                    // in principle is true for tuple[], so will work for string[] too
                    guard elementItself.count >= 32 else {break}
                    var dataSlice = elementItself[0 ..< 32]
                    let length = UInt64(BigUInt(dataSlice))
                    guard elementItself.count >= 32 else {break}
                    dataSlice = Data(elementItself[32 ..< elementItself.count])
                    var subpointer: UInt64 = 0;
                    var toReturn = [AnyObject]()
                    //                    print("Dynamic array sub element itself: \n" + dataSlice.toHexString())
                    for _ in 0 ..< length {
                        let (v, c) = decodeSignleType(type: subType, data: dataSlice, pointer: subpointer)
                        guard let valueUnwrapped = v, let consumedUnwrapped = c else {break}
                        toReturn.append(valueUnwrapped)
                        subpointer = subpointer + consumedUnwrapped
                    }
                    return (toReturn as AnyObject, nextElementPointer)
                }
            case .staticSize(let staticLength):
                //                print("Static array element itself: \n" + elementItself.toHexString())
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
        case .tuple(types: let subTypes):
            //            print("Tuple element itself: \n" + elementItself.toHexString())
            var toReturn = [AnyObject]()
            var consumed:UInt64 = 0
            for i in 0 ..< subTypes.count {
                let (v, c) = decodeSignleType(type: subTypes[i], data: elementItself, pointer: consumed)
                guard let valueUnwrapped = v, let consumedUnwrapped = c else {return (nil, nil)}
                toReturn.append(valueUnwrapped)
                consumed = consumed + consumedUnwrapped
            }
            //            print("Tuple element is: \n" + String(describing: toReturn))
            if type.isStatic {
                return (toReturn as AnyObject, consumed)
            } else {
                return (toReturn as AnyObject, nextElementPointer)
            }
        case .function:
            //            print("Function element itself: \n" + elementItself.toHexString())
            guard elementItself.count >= 32 else {break}
            let dataSlice = elementItself[8 ..< 32]
            //            print("Function element is: \n" + String(dataSlice.toHexString()))
            return (dataSlice as AnyObject, type.memoryUsage)
        }
        return (nil, nil)
    }
    
    fileprivate static func followTheData(type: ABI.Element.ParameterType, data: Data, pointer: UInt64 = 0) -> (elementEncoding: Data?, nextElementPointer: UInt64?) {
        //        print("Follow the data: \n" + data.toHexString())
        //        print("At pointer: \n" + String(pointer))
        if type.isStatic {
            guard data.count >= pointer + type.memoryUsage else {return (nil, nil)}
            let elementItself = data[pointer ..< pointer + type.memoryUsage]
            let nextElement = pointer + type.memoryUsage
            //            print("Got element itself: \n" + elementItself.toHexString())
            //            print("Next element pointer: \n" + String(nextElement))
            return (Data(elementItself), nextElement)
        } else {
            guard data.count >= pointer + type.memoryUsage else {return (nil, nil)}
            let dataSlice = data[pointer ..< pointer + type.memoryUsage]
            let bn = BigUInt(dataSlice)
            if bn > UINT64_MAX || bn >= data.count {
                // there are ERC20 contracts that use bytes32 intead of string. Let's be optimistic and return some data
                if case .string = type {
                    let nextElement = pointer + type.memoryUsage
                    let preambula = BigUInt(32).abiEncode(bits: 256)!
                    return (preambula + Data(dataSlice), nextElement)
                } else if case .dynamicBytes = type {
                    let nextElement = pointer + type.memoryUsage
                    let preambula = BigUInt(32).abiEncode(bits: 256)!
                    return (preambula + Data(dataSlice), nextElement)
                }
                return (nil, nil)
            }
            let elementPointer = UInt64(bn)
            let elementItself = data[elementPointer ..< UInt64(data.count)]
            let nextElement = pointer + type.memoryUsage
            //            print("Got element itself: \n" + elementItself.toHexString())
            //            print("Next element pointer: \n" + String(nextElement))
            return (Data(elementItself), nextElement)
        }
    }
    
    public static func decodeLog(event: ABI.Element.Event, eventLogTopics: [Data], eventLogData: Data) -> [String:Any]? {
        if event.topic != eventLogTopics[0] && !event.anonymous {
            return nil
        }
        var eventContent = [String: Any]()
        eventContent["name"]=event.name
        let logs = eventLogTopics
        let dataForProcessing = eventLogData
        let indexedInputs = event.inputs.filter { (inp) -> Bool in
            return inp.indexed
        }
        if (logs.count == 1 && indexedInputs.count > 0) {
            return nil
        }
        let nonIndexedInputs = event.inputs.filter { (inp) -> Bool in
            return !inp.indexed
        }
        let nonIndexedTypes = nonIndexedInputs.compactMap { (inp) -> ABI.Element.ParameterType in
            return inp.type
        }
        guard logs.count == indexedInputs.count + 1 else {return nil}
        var indexedValues = [AnyObject]()
        for i in 0 ..< indexedInputs.count {
            let data = logs[i+1]
            let input = indexedInputs[i]
            if !input.type.isStatic || input.type.isArray || input.type.memoryUsage != 32 {
                let (v, _) = ABIDecoder.decodeSignleType(type: .bytes(length: 32), data: data)
                guard let valueUnwrapped = v else {return nil}
                indexedValues.append(valueUnwrapped)
            } else {
                let (v, _) = ABIDecoder.decodeSignleType(type: input.type, data: data)
                guard let valueUnwrapped = v else {return nil}
                indexedValues.append(valueUnwrapped)
            }
        }
        let v = ABIDecoder.decode(types: nonIndexedTypes, data: dataForProcessing)
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
