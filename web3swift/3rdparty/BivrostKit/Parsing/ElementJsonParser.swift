//
//  ElementJsonParser.swift
//  Bivrost
//
//  Created by Luis Reisewitz on 13.09.17.
//  Copyright © 2017 Gnosis. All rights reserved.
//
//

fileprivate typealias Element = Contract.Element
fileprivate typealias FunctionInput = Element.Function.Input
fileprivate typealias FunctionOutput = Element.Function.Output
fileprivate typealias EventInput = Element.Event.Input

fileprivate enum ElementType: String {
    case function
    case constructor
    case fallback
    case event
}

struct ElementJsonParser {
    /// Parses a single contract element json into an initialised Contract.Element.
    ///
    /// - Parameter json: Should be a valid JSON object containing the fields for
    ///     the element, according to
    ///     https://github.com/ethereum/wiki/wiki/Ethereum-Contract-ABI#json
    /// - Returns: An initialised contract element struct.
    /// - Throws: Throws if the json was malformed, e.g. a required field was missing.
    static func parseContractElement(from json: [String: Any]) throws -> Contract.Element {
        // `type` can be omitted, defaulting to "function"
        let typeString = json[.type] as? String ?? "function"
        
        guard let type = ElementType(rawValue: typeString) else {
            throw ParsingError.elementTypeInvalid
        }
        return try parseElement(with: type, from: json)
    }
}

// MARK: - Private Element Parsing
extension ElementJsonParser {
    fileprivate static func parseElement(with type: ElementType, from json: [String: Any]) throws -> Contract.Element {
        switch type {
        case .function:
            return .function(try parseFunction(from: json))
        case .constructor:
            return .constructor(try parseConstructor(from: json))
        case .fallback:
            return .fallback(try parseFallback(from: json))
        case .event:
            return .event(try parseEvent(from: json))
        }
    }
    
    fileprivate static func parseFunction(from json: [String: Any]) throws -> Contract.Element.Function {
        let constant = parseConstant(from: json)
        let payable = parsePayable(from: json)
        let inputs = try parseFunctionInputs(from: json)
        let outputs = try parseFunctionOutputs(from: json)
        let name = try parseName(from: json)
        return Element.Function(name: name, inputs: inputs, outputs: outputs, constant: constant, payable: payable)
    }
    
    fileprivate static func parseConstructor(from json: [String: Any]) throws -> Element.Constructor {
        let constant = parseConstant(from: json)
        let payable = parsePayable(from: json)
        let inputs = try parseFunctionInputs(from: json)
        return Element.Constructor(inputs: inputs, constant: constant, payable: payable)
    }
    
    fileprivate static func parseFallback(from json: [String: Any]) throws -> Element.Fallback {
        let constant = parseConstant(from: json)
        let payable = parsePayable(from: json)
        return Element.Fallback(constant: constant, payable: payable)
    }
    
    fileprivate static func parseEvent(from json: [String: Any]) throws -> Element.Event {
        let name = try parseName(from: json)
        let inputs = try parseEventInputs(from: json)
        let anonymous = parseAnonymous(from: json)
        return Element.Event(name: name, inputs: inputs, anonymous: anonymous)
    }
    
    private static func parseName(from json: [String: Any]) throws -> String {
        guard let name = json[.name] as? String else {
            throw ParsingError.elementNameInvalid
        }
        return name
    }
}

// MARK: - Private Function Field parsing
extension ElementJsonParser {
    fileprivate static func parseConstant(from json: [String: Any]) -> Bool {
        return json[.constant] as? Bool ?? false
    }
    
    fileprivate static func parsePayable(from json: [String: Any]) -> Bool {
        return json[.payable] as? Bool ?? false
    }
    
    /// Parses the list of function inputs contained in a Json dictionary.
    ///
    /// - Parameter json: Dictionary describing a function. This dictionary should
    ///     include the key `inputs`. Otherwise an empty list is returned.
    /// - Returns: The list of `FunctionInput`s or an empty list.
    /// - Throws: Throws a BivrostError in case the json was malformed or there
    ///     was an error.
    fileprivate static func parseFunctionInputs(from json: [String: Any]) throws -> [FunctionInput] {
        let jsonInputs = json[.inputs] as? [[String: Any]] ?? []
        return try jsonInputs.map { try ElementJsonParser.parseFunctionInput(from: $0) }
    }
    
    /// Parses the function input contained in the Json dictionary.
    ///
    /// - Parameter json: Dictionary describing an Input to a function.
    /// - Returns: The corresponding FunctionInput.
    /// - Throws: Throws a BivrostError in case the json was malformed or there
    ///     was an error.
    private static func parseFunctionInput(from json: [String: Any]) throws -> FunctionInput {
        guard let name = json[.name] as? String else {
            throw ParsingError.functionInputInvalid
        }
        
        let type = try ParameterParser.parseParameterType(from: json)
        return FunctionInput(name: name, type: type)
    }
    
    /// Parses the list of function outputs contained in a Json dictionary.
    ///
    /// - Parameter json: Dictionary describing a function. This dictionary should
    ///     include the key `outputs`. Otherwise an empty list is returned.
    /// - Returns: The list of `FunctionOutput`s or an empty list.
    /// - Throws: Throws a BivrostError in case the json was malformed or there
    ///     was an error.
    fileprivate static func parseFunctionOutputs(from json: [String: Any]) throws -> [FunctionOutput] {
        let jsonOutputs = json[.outputs] as? [[String: Any]] ?? []
        return try jsonOutputs.map { try ElementJsonParser.parseFunctionOutput(from: $0) }
    }
    
    /// Parses the function output contained in the Json dictionary.
    ///
    /// - Parameter json: Dictionary describing an Output to a function.
    /// - Returns: The corresponding FunctionOutput.
    /// - Throws: Throws a BivrostError in case the json was malformed or there
    ///     was an error.
    private static func parseFunctionOutput(from json: [String: Any]) throws -> FunctionOutput {
        guard let name = json[.name] as? String else {
            throw ParsingError.functionOutputInvalid
        }

        let type = try ParameterParser.parseParameterType(from: json)
        return FunctionOutput(name: name, type: type)
    }
}

// MARK: - Private Event Field Parsing
extension ElementJsonParser {
    fileprivate static func parseAnonymous(from json: [String: Any]) -> Bool {
        return json[.anonymous] as? Bool ?? false
    }
    
    /// Returns a list of event inputs from a json dictionary representing a
    /// single contract element.
    ///
    /// - Parameter json: Should include the key `inputs` on a top level.
    /// - Returns: A list of event inputs mapped from that json. Empty list is
    ///     returned if there are no inputs defined in the json.
    /// - Throws: Throws if at least one of these inputs was malformed.
    fileprivate static func parseEventInputs(from json: [String: Any]) throws -> [EventInput] {
        let jsonInputs = json[.inputs] as? [[String: Any]] ?? []
        return try jsonInputs.map { try ElementJsonParser.parseEventInput(from: $0) }
    }

    /// Returns the event input from the json dictionary representing a single
    /// event input.
    ///
    /// - Parameter json: Dictionary describing the input to an event.
    /// - Returns: The corresponding.
    /// - Throws: Throws if the input was malformed.
    private static func parseEventInput(from json: [String: Any]) throws -> EventInput {
        guard let name = json[.name] as? String,
            let indexed = json[.indexed] as? Bool else {
                throw ParsingError.eventInputInvalid
        }
        
        let type = try ParameterParser.parseParameterType(from: json)
        return EventInput(name: name, type: type, indexed: indexed)
    }
}
