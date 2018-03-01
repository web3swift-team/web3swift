//
//  TypesEncoder.swift
//  web3swift
//
//  Created by Alexander Vlasov on 01.03.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt

public struct TypesEncoder {
    
}

extension TypesEncoder {
    public static func encode(types: [ABIElement.ParameterType], parameters: [AnyObject]) -> Data? {
        guard types.count == parameters.count else {return nil}
        var head = Data()
        var tail = Data()
        let headExpectedLength = 32*parameters.count
        var tailPointer = BigUInt(32)*BigUInt(types.count)
        
        for index in 0..<types.count {
            let input  = types[index]
            let parameter = parameters[index]
            var encodedParameter:Data
            if let parametersArray = parameter as? [AnyObject] {
                guard let encoded = input.encode(parametersArray) else {return nil}
                encodedParameter = encoded
            } else {
                guard let encoded = input.encode(parameter) else {return nil}
                encodedParameter = encoded
            }
            guard encodedParameter.count > 0 else {
                return nil
            }
            switch input {
            case .dynamicABIType(let type):
//                print("Dynamic encoding for data length of " + String(encodedParameter.count))
                guard let pointer = tailPointer.abiEncode(bits: 256) else {return nil}
                head.append(pointer)
                tail.append(encodedParameter)
                tailPointer = tailPointer + BigUInt(encodedParameter.count)
            case .staticABIType(let type):
//                print("Static encoding for data length of " + String(encodedParameter.count))
                head.append(encodedParameter)
            }
        }
        guard head.count == headExpectedLength else {return nil}
        head.append(tail)
        return head
    }
}
