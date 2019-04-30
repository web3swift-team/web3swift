//
//  Created by Alex Vlasov on 25/10/2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt

public extension ABI {
    // JSON Decoding
    struct Input: Decodable {
        public var name: String?
        public var type: String
        public var indexed: Bool?
        public var components: [Input]?
    }
    
    struct Output: Decodable {
        public var name: String?
        public var type: String
        public var components: [Output]?
    }
    
    struct Record: Decodable {
        public var name: String?
        public var type: String?
        public var payable: Bool?
        public var constant: Bool?
        public var stateMutability: String?
        public var inputs: [ABI.Input]?
        public var outputs: [ABI.Output]?
        public var anonymous: Bool?
    }
    
    enum Element {
        public enum ArraySize { //bytes for convenience
            case staticSize(UInt64)
            case dynamicSize
            case notArray
        }
        
        case function(Function)
        case constructor(Constructor)
        case fallback(Fallback)
        case event(Event)
        
        public enum StateMutability {
            case payable
            case mutating
            case view
            case pure
            
            var isConstant: Bool {
                switch self {
                case .payable:
                    return false
                case .mutating:
                    return false
                default:
                    return true
                }
            }
            
            var isPayable: Bool {
                switch self {
                case .payable:
                    return true
                default:
                    return false
                }
            }
        }
        
        public struct InOut {
            public let name: String
            public let type: ParameterType
            
            public init(name: String, type: ParameterType) {
                self.name = name
                self.type = type
            }
        }
        
        public struct Function {
            public let name: String?
            public let inputs: [InOut]
            public let outputs: [InOut]
            public let stateMutability: StateMutability? = nil
            public let constant: Bool
            public let payable: Bool
            
            public init(name: String?, inputs: [InOut], outputs: [InOut], constant: Bool, payable: Bool) {
                self.name = name
                self.inputs = inputs
                self.outputs = outputs
                self.constant = constant
                self.payable = payable
            }
        }
        
        public struct Constructor {
            public let inputs: [InOut]
            public let constant: Bool
            public let payable: Bool
            public init(inputs: [InOut], constant: Bool, payable: Bool) {
                self.inputs = inputs
                self.constant = constant
                self.payable = payable
            }
        }
        
        public struct Fallback {
            public let constant: Bool
            public let payable: Bool
            
            public init(constant: Bool, payable: Bool) {
                self.constant = constant
                self.payable = payable
            }
        }
        
        public struct Event {
            public let name: String
            public let inputs: [Input]
            public let anonymous: Bool
            
            public init(name: String, inputs: [Input], anonymous: Bool) {
                self.name = name
                self.inputs = inputs
                self.anonymous = anonymous
            }
            
            public struct Input {
                public let name: String
                public let type: ParameterType
                public let indexed: Bool
                
                public init(name: String, type: ParameterType, indexed: Bool) {
                    self.name = name
                    self.type = type
                    self.indexed = indexed
                }
            }
        }
    }
}

extension ABI.Element {
    public func encodeParameters(_ parameters: [AnyObject]) -> Data? {
        switch self {
        case .constructor(let constructor):
            guard parameters.count == constructor.inputs.count else {return nil}
            guard let data = ABIEncoder.encode(types: constructor.inputs, values: parameters) else {return nil}
            return data
        case .event(_):
            return nil
        case .fallback(_):
            return nil
        case .function(let function):
            guard parameters.count == function.inputs.count else {return nil}
            let signature = function.methodEncoding
            guard let data = ABIEncoder.encode(types: function.inputs, values: parameters) else {return nil}
            return signature + data
        }
    }
}

extension ABI.Element {
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
            guard let values = ABIDecoder.decode(types: function.outputs, data: data) else {return nil}
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
            guard let values = ABIDecoder.decode(types: function.inputs, data: data) else {return nil}
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
            guard let values = ABIDecoder.decode(types: function.inputs, data: data) else {return nil}
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

extension ABI.Element.Event {
    public func decodeReturnedLogs(eventLogTopics: [Data], eventLogData: Data) -> [String:Any]? {
        guard let eventContent = ABIDecoder.decodeLog(event: self, eventLogTopics: eventLogTopics, eventLogData: eventLogData) else {return nil}
        return eventContent
    }
}


