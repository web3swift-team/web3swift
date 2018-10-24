//
//  ABIElements.swift
//  web3swift
//
//  Created by Alexander Vlasov on 06.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt

public extension ABIv2 {
    // JSON Decoding
    public struct Input: Decodable {
        var name: String?
        var type: String
        var indexed: Bool?
        var components: [Input]?
        
        public func parse() throws -> ABIv2.Element.InOut {
            let name = self.name != nil ? self.name! : ""
            let parameterType = try ABIv2TypeParser.parseTypeString(self.type)
            if case .tuple(types: _) = parameterType {
                let components = try self.components?.compactMap({ (inp: ABIv2.Input) throws -> ABIv2.Element.ParameterType in
                    let input = try inp.parse()
                    return input.type
                })
                let type = ABIv2.Element.ParameterType.tuple(types: components!)
                let nativeInput = ABIv2.Element.InOut(name: name, type: type)
                return nativeInput
            }
            else {
                let nativeInput = ABIv2.Element.InOut(name: name, type: parameterType)
                return nativeInput
            }
        }
        
        func parseForEvent() throws -> ABIv2.Element.Event.Input{
            let name = self.name != nil ? self.name! : ""
            let parameterType = try ABIv2TypeParser.parseTypeString(self.type)
            let indexed = self.indexed == true
            return ABIv2.Element.Event.Input(name:name, type: parameterType, indexed: indexed)
        }
    }
    
    public struct Output: Decodable {
        var name: String?
        var type: String
        var components: [Output]?
        
        public func parse() throws -> ABIv2.Element.InOut {
            let name = self.name != nil ? self.name! : ""
            let parameterType = try ABIv2TypeParser.parseTypeString(self.type)
            switch parameterType {
            case .tuple(types: _):
                let components = try self.components?.compactMap({ (inp: ABIv2.Output) throws -> ABIv2.Element.ParameterType in
                    let input = try inp.parse()
                    return input.type
                })
                let type = ABIv2.Element.ParameterType.tuple(types: components!)
                let nativeInput = ABIv2.Element.InOut(name: name, type: type)
                return nativeInput
            case .array(type: let subtype, length: let length):
                switch subtype {
                case .tuple(types: _):
                    let components = try self.components?.compactMap({ (inp: ABIv2.Output) throws -> ABIv2.Element.ParameterType in
                        let input = try inp.parse()
                        return input.type
                    })
                    let nestedSubtype = ABIv2.Element.ParameterType.tuple(types: components!)
                    let properType = ABIv2.Element.ParameterType.array(type: nestedSubtype, length: length)
                    let nativeInput = ABIv2.Element.InOut(name: name, type: properType)
                    return nativeInput
                default:
                    let nativeInput = ABIv2.Element.InOut(name: name, type: parameterType)
                    return nativeInput
                }
            default:
                let nativeInput = ABIv2.Element.InOut(name: name, type: parameterType)
                return nativeInput
            }
        }
    }

    public struct Record: Decodable {
        var name: String?
        var type: String?
        var payable: Bool?
        var constant: Bool?
        var stateMutability: String?
        var inputs: [ABIv2.Input]?
        var outputs: [ABIv2.Output]?
        var anonymous: Bool?
        
        public func parse() throws -> ABIv2.Element {
            let typeString = self.type != nil ? self.type! : "function"
            guard let type = ABIv2.ElementType(rawValue: typeString) else {
                throw ABIv2.ParsingError.elementTypeInvalid
            }
            return try parseToElement(from: self, type: type)
        }
    }
    
    public enum Element {
        public enum ArraySize { //bytes for convenience
            case staticSize(UInt64)
            case dynamicSize
            case notArray
        }
        
        case function(Function)
        case constructor(Constructor)
        case fallback(Fallback)
        case event(Event)
        
        public struct InOut {
            public let name: String
            public let type: ParameterType
        }
        
        public struct Function {
            public let name: String?
            public let inputs: [InOut]
            public let outputs: [InOut]
            public let constant: Bool
            public let payable: Bool
        }
        
        public struct Constructor {
            let inputs: [InOut]
            let constant: Bool
            let payable: Bool
        }
        
        public struct Fallback {
            let constant: Bool
            let payable: Bool
        }
        
        public struct Event {
            let name: String
            let inputs: [Input]
            let anonymous: Bool
            
            struct Input {
                let name: String
                let type: ParameterType
                let indexed: Bool
            }
        }
    }
}

public extension ABIv2.Element {
    public func encodeParameters(_ parameters: [AnyObject]) -> Data? {
        switch self {
        case .constructor(let constructor):
            guard parameters.count == constructor.inputs.count else {return nil}
            guard let data = ABIv2Encoder.encode(types: constructor.inputs, values: parameters) else {return nil}
            return data
        case .event(_):
            return nil
        case .fallback(_):
            return nil
        case .function(let function):
            guard parameters.count == function.inputs.count else {return nil}
            let signature = function.methodEncoding
            guard let data = ABIv2Encoder.encode(types: function.inputs, values: parameters) else {return nil}
            return signature + data
        }
    }
}

public extension ABIv2.Element {
    public func decodeReturnData(_ data: Data) -> [String:Any]? {
        switch self {
        case .constructor(_):
            return nil
        case .event(_):
            return nil
        case .fallback(_):
            return nil
        case .function(let function):
            if (data.count == 0 && function.outputs.count == 1) {
                let name = "0"
                let value = function.outputs[0].type.emptyValue
                var returnArray = [String:Any]()
                returnArray[name] = value
                if function.outputs[0].name != "" {
                    returnArray[function.outputs[0].name] = value
                }
                return returnArray
            }
            
            guard function.outputs.count*32 <= data.count else {return nil}
            var returnArray = [String:Any]()
            var i = 0;
            guard let values = ABIv2Decoder.decode(types: function.outputs, data: data) else {return nil}
            for output in function.outputs {
                let name = "\(i)"
                returnArray[name] = values[i]
                if output.name != "" {
                    returnArray[output.name] = values[i]
                }
                i = i + 1
            }
            return returnArray
        }
    }
    
    public func decodeInputData(_ rawData: Data) -> [String: Any]? {
        var data = rawData
        var sig: Data? = nil
        switch rawData.count % 32 {
        case 0:
            break
        case 4:
            sig = rawData[0 ..< 4]
            data = Data(rawData[4 ..< rawData.count])
        default:
            return nil
        }
        switch self {
        case .constructor(let function):
            if (data.count == 0 && function.inputs.count == 1) {
                let name = "0"
                let value = function.inputs[0].type.emptyValue
                var returnArray = [String:Any]()
                returnArray[name] = value
                if function.inputs[0].name != "" {
                    returnArray[function.inputs[0].name] = value
                }
                return returnArray
            }
            
            guard function.inputs.count*32 <= data.count else {return nil}
            var returnArray = [String:Any]()
            var i = 0;
            guard let values = ABIv2Decoder.decode(types: function.inputs, data: data) else {return nil}
            for input in function.inputs {
                let name = "\(i)"
                returnArray[name] = values[i]
                if input.name != "" {
                    returnArray[input.name] = values[i]
                }
                i = i + 1
            }
            return returnArray
        case .event(_):
            return nil
        case .fallback(_):
            return nil
        case .function(let function):
            if sig != nil && sig != function.methodEncoding {
                return nil
            }
            if (data.count == 0 && function.inputs.count == 1) {
                let name = "0"
                let value = function.inputs[0].type.emptyValue
                var returnArray = [String:Any]()
                returnArray[name] = value
                if function.inputs[0].name != "" {
                    returnArray[function.inputs[0].name] = value
                }
                return returnArray
            }
            
            guard function.inputs.count*32 <= data.count else {return nil}
            var returnArray = [String:Any]()
            var i = 0;
            guard let values = ABIv2Decoder.decode(types: function.inputs, data: data) else {return nil}
            for input in function.inputs {
                let name = "\(i)"
                returnArray[name] = values[i]
                if input.name != "" {
                    returnArray[input.name] = values[i]
                }
                i = i + 1
            }
            return returnArray
        }
    }
}

public extension ABIv2.Element.Event {
    public func decodeReturnedLogs(_ eventLog: EventLog) -> [String:Any]? {
        guard let eventContent = ABIv2Decoder.decodeLog(event: self, eventLog: eventLog) else {return nil}
        return eventContent
    }
}


