//
//  Created by Alex Vlasov on 25/10/2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation

extension ABI {

    public enum ParsingError: Swift.Error {
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

    fileprivate enum ElementType: String {
        case function
        case constructor
        case fallback
        case event
        case receive
        case error
    }

}

extension ABI.Record {
    public func parse() throws -> ABI.Element {
        let typeString = self.type ?? "function"
        guard let type = ABI.ElementType(rawValue: typeString) else {
            throw ABI.ParsingError.elementTypeInvalid
        }
        return try parseToElement(from: self, type: type)
    }
}

private func parseToElement(from abiRecord: ABI.Record, type: ABI.ElementType) throws -> ABI.Element {
    switch type {
    case .function:
        let function = try parseFunction(abiRecord: abiRecord)
        return ABI.Element.function(function)
    case .constructor:
        let constructor = try parseConstructor(abiRecord: abiRecord)
        return ABI.Element.constructor(constructor)
    case .fallback:
        let fallback = try parseFallback(abiRecord: abiRecord)
        return ABI.Element.fallback(fallback)
    case .event:
        let event = try parseEvent(abiRecord: abiRecord)
        return ABI.Element.event(event)
    case .receive:
        let receive = try parseReceive(abiRecord: abiRecord)
        return ABI.Element.receive(receive)
    case .error:
        let error = try parseError(abiRecord: abiRecord)
        return ABI.Element.error(error)
    }

}

private func parseFunction(abiRecord: ABI.Record) throws -> ABI.Element.Function {
    let inputs = try abiRecord.inputs?.map({ (input: ABI.Input) throws -> ABI.Element.InOut in
        let nativeInput = try input.parse()
        return nativeInput
    })
    let abiInputs = inputs ?? [ABI.Element.InOut]()
    let outputs = try abiRecord.outputs?.map({ (output: ABI.Output) throws -> ABI.Element.InOut in
        let nativeOutput = try output.parse()
        return nativeOutput
    })
    let abiOutputs = outputs ?? [ABI.Element.InOut]()
    let name = abiRecord.name ?? ""
    let payable = abiRecord.stateMutability == "payable" || abiRecord.payable == true
    let constant = abiRecord.constant == true || abiRecord.stateMutability == "view" || abiRecord.stateMutability == "pure"
    let functionElement = ABI.Element.Function(name: name, inputs: abiInputs, outputs: abiOutputs, constant: constant, payable: payable)
    return functionElement
}

private func parseFallback(abiRecord: ABI.Record) throws -> ABI.Element.Fallback {
    let payable = (abiRecord.stateMutability == "payable" || abiRecord.payable == true)
    let constant = abiRecord.constant == true || abiRecord.stateMutability == "view" || abiRecord.stateMutability == "pure"
    let functionElement = ABI.Element.Fallback(constant: constant, payable: payable)
    return functionElement
}

private func parseConstructor(abiRecord: ABI.Record) throws -> ABI.Element.Constructor {
    let inputs = try abiRecord.inputs?.map({ (input: ABI.Input) throws -> ABI.Element.InOut in
        let nativeInput = try input.parse()
        return nativeInput
    })
    let abiInputs = inputs ?? [ABI.Element.InOut]()
    let payable = abiRecord.stateMutability == "payable" || abiRecord.payable == true
    let functionElement = ABI.Element.Constructor(inputs: abiInputs, constant: false, payable: payable)
    return functionElement
}

private func parseEvent(abiRecord: ABI.Record) throws -> ABI.Element.Event {
    let inputs = try abiRecord.inputs?.map({ (input: ABI.Input) throws -> ABI.Element.Event.Input in
        let nativeInput = try input.parseForEvent()
        return nativeInput
    })
    let abiInputs = inputs ?? [ABI.Element.Event.Input]()
    let name = abiRecord.name ?? ""
    let anonymous = abiRecord.anonymous ?? false
    let functionElement = ABI.Element.Event(name: name, inputs: abiInputs, anonymous: anonymous)
    return functionElement
}

private func parseReceive(abiRecord: ABI.Record) throws -> ABI.Element.Receive {
    let inputs = try abiRecord.inputs?.map({ (input: ABI.Input) throws -> ABI.Element.InOut in
        let nativeInput = try input.parse()
        return nativeInput
    })
    let abiInputs = inputs ?? [ABI.Element.InOut]()
    let payable = abiRecord.stateMutability == "payable" || abiRecord.payable == true
    let functionElement = ABI.Element.Receive(inputs: abiInputs, payable: payable)
    return functionElement
}

private func parseError(abiRecord: ABI.Record) throws -> ABI.Element.EthError {
    let inputs = try abiRecord.inputs?.map({ (input: ABI.Input) throws -> ABI.Element.EthError.Input in
        let nativeInput = try input.parseForError()
        return nativeInput
    })
    let abiInputs = inputs ?? []
    let name = abiRecord.name ?? ""
    return ABI.Element.EthError(name: name, inputs: abiInputs)
}

extension ABI.Input {
    func parse() throws -> ABI.Element.InOut {
        let name = self.name ?? ""
        let parameterType = try ABITypeParser.parseTypeString(self.type)
        if case .tuple(types: _) = parameterType {
            let components = try self.components?.compactMap({ (inp: ABI.Input) throws -> ABI.Element.ParameterType in
                let input = try inp.parse()
                return input.type
            })
            let type = ABI.Element.ParameterType.tuple(types: components!)
            let nativeInput = ABI.Element.InOut(name: name, type: type)
            return nativeInput
        } else if case .array(type: .tuple(types: _), length: _) = parameterType {
            let components = try self.components?.compactMap({ (inp: ABI.Input) throws -> ABI.Element.ParameterType in
                let input = try inp.parse()
                return input.type
            })
            let tupleType = ABI.Element.ParameterType.tuple(types: components!)

            let newType: ABI.Element.ParameterType = .array(type: tupleType, length: 0)
            let nativeInput = ABI.Element.InOut(name: name, type: newType)
            return nativeInput
        } else {
            let nativeInput = ABI.Element.InOut(name: name, type: parameterType)
            return nativeInput
        }
    }

    func parseForEvent() throws -> ABI.Element.Event.Input {
        let name = self.name ?? ""
        let parameterType = try ABITypeParser.parseTypeString(self.type)
        let indexed = self.indexed == true
        return ABI.Element.Event.Input(name: name, type: parameterType, indexed: indexed)
    }

    func parseForError() throws -> ABI.Element.EthError.Input {
        let name = self.name ?? ""
        let parameterType = try ABITypeParser.parseTypeString(self.type)
        return ABI.Element.EthError.Input(name: name, type: parameterType)
    }
}

extension ABI.Output {
    func parse() throws -> ABI.Element.InOut {
        let name = self.name != nil ? self.name! : ""
        let parameterType = try ABITypeParser.parseTypeString(self.type)
        switch parameterType {
        case .tuple(types: _):
            let components = try self.components?.compactMap({ (inp: ABI.Output) throws -> ABI.Element.ParameterType in
                let input = try inp.parse()
                return input.type
            })
            let type = ABI.Element.ParameterType.tuple(types: components!)
            let nativeInput = ABI.Element.InOut(name: name, type: type)
            return nativeInput
        case .array(type: let subtype, length: let length):
            switch subtype {
            case .tuple(types: _):
                let components = try self.components?.compactMap({ (inp: ABI.Output) throws -> ABI.Element.ParameterType in
                    let input = try inp.parse()
                    return input.type
                })
                let nestedSubtype = ABI.Element.ParameterType.tuple(types: components!)
                let properType = ABI.Element.ParameterType.array(type: nestedSubtype, length: length)
                let nativeInput = ABI.Element.InOut(name: name, type: properType)
                return nativeInput
            default:
                let nativeInput = ABI.Element.InOut(name: name, type: parameterType)
                return nativeInput
            }
        default:
            let nativeInput = ABI.Element.InOut(name: name, type: parameterType)
            return nativeInput
        }
    }
}
