//
//  ABIParser.swift
//  web3swift
//
//  Created by Alexander Vlasov on 06.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import Foundation

public extension ABIv2 {
    
    public enum ParsingError: Error {
        case invalidJsonFile
        case elementTypeInvalid
        case elementNameInvalid
        case functionInputInvalid
        case functionOutputInvalid
        case eventInputInvalid
        case parameterTypeInvalid
        case parameterTypeNotFound
        case abiInvalid
    }
    
    enum TypeParsingExpressions {
        static var typeEatingRegex = "^((u?int|bytes)([1-9][0-9]*)|(address|bool|string|tuple|bytes)|(\\[([1-9][0-9]*)\\]))"
        static var arrayEatingRegex = "^(\\[([1-9][0-9]*)?\\])?.*$"
    }


    enum ElementType: String {
        case function
        case constructor
        case fallback
        case event
    }

}

func parseToElement(from abiRecord: ABIv2.Record, type: ABIv2.ElementType) throws -> ABIv2.Element {
    switch type {
    case .function:
        let function = try parseFunction(abiRecord: abiRecord)
        return ABIv2.Element.function(function)
    case .constructor:
        let constructor = try parseConstructor(abiRecord: abiRecord)
        return ABIv2.Element.constructor(constructor)
    case .fallback:
        let fallback = try parseFallback(abiRecord: abiRecord)
        return ABIv2.Element.fallback(fallback)
    case .event:
        let event = try parseEvent(abiRecord: abiRecord)
        return ABIv2.Element.event(event)
    }

}

func parseFunction(abiRecord:ABIv2.Record) throws -> ABIv2.Element.Function {
    let inputs = try abiRecord.inputs?.map({ (input:ABIv2.Input) throws -> ABIv2.Element.InOut in
        let nativeInput = try input.parse()
        return nativeInput
    })
    let abiInputs = inputs != nil ? inputs! : [ABIv2.Element.InOut]()
    let outputs = try abiRecord.outputs?.map({ (output:ABIv2.Output) throws -> ABIv2.Element.InOut in
        let nativeOutput = try output.parse()
        return nativeOutput
    })
    let abiOutputs = outputs != nil ? outputs! : [ABIv2.Element.InOut]()
    let name = abiRecord.name != nil ? abiRecord.name! : ""
    let payable = abiRecord.stateMutability != nil ?
        (abiRecord.stateMutability == "payable" || abiRecord.payable!) : false
    let constant = (abiRecord.constant == true || abiRecord.stateMutability == "view" || abiRecord.stateMutability == "pure")
    let functionElement = ABIv2.Element.Function(name: name, inputs: abiInputs, outputs: abiOutputs, constant: constant, payable: payable)
    return functionElement
}

func parseFallback(abiRecord:ABIv2.Record) throws -> ABIv2.Element.Fallback {
    let payable = (abiRecord.stateMutability == "payable" || abiRecord.payable!)
    var constant = abiRecord.constant == true
    if (abiRecord.stateMutability == "view" || abiRecord.stateMutability == "pure") {
        constant = true
    }
    let functionElement = ABIv2.Element.Fallback(constant: constant, payable: payable)
    return functionElement
}

func parseConstructor(abiRecord:ABIv2.Record) throws -> ABIv2.Element.Constructor {
    let inputs = try abiRecord.inputs?.map({ (input:ABIv2.Input) throws -> ABIv2.Element.InOut in
        let nativeInput = try input.parse()
        return nativeInput
    })
    let abiInputs = inputs != nil ? inputs! : [ABIv2.Element.InOut]()
    var payable = false
    if (abiRecord.payable != nil) {
        payable = abiRecord.payable!
    }
    if (abiRecord.stateMutability == "payable") {
        payable = true
    }
    let constant = false
    let functionElement = ABIv2.Element.Constructor(inputs: abiInputs, constant: constant, payable: payable)
    return functionElement
}

fileprivate func parseEvent(abiRecord:ABIv2.Record) throws -> ABIv2.Element.Event {
    let inputs = try abiRecord.inputs?.map({ (input:ABIv2.Input) throws -> ABIv2.Element.Event.Input in
        let nativeInput = try input.parseForEvent()
        return nativeInput
    })
    let abiInputs = inputs != nil ? inputs! : [ABIv2.Element.Event.Input]()
    let name = abiRecord.name != nil ? abiRecord.name! : ""
    let anonymous = abiRecord.anonymous != nil ? abiRecord.anonymous! : false
    let functionElement = ABIv2.Element.Event(name: name, inputs: abiInputs, anonymous: anonymous)
    return functionElement
}

