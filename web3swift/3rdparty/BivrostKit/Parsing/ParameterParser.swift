//
//  ParameterParser.swift
//  Bivrost
//
//  Created by Luis Reisewitz on 13.09.17.
//  Copyright © 2017 Gnosis. All rights reserved.
//
//

import Foundation

fileprivate typealias ParameterType = Contract.Element.ParameterType

struct ParameterParser {
    /// Parses the parameter type contained in a Input/Output dictionary.
    ///
    /// - Parameter json: Dictionary describing either an Input or an Output to 
    ///     a function or an event.
    /// - Returns: The corresponding parameter type.
    /// - Throws: Throws a BivrostError in case the json was malformed or there
    ///     was an error.
    static func parseParameterType(from json: [String: Any]) throws -> Contract.Element.ParameterType {
        guard let typeString = json[.type] as? String else {
            throw ParsingError.parameterTypeNotFound
        }
        return try parameterType(from: typeString)
    }
}

// Parsing Logic Pseudo Code:

// 1. if we find an exact full string match with any "atomic" type
//      return the matching type
//      Note: Recursive exit
//      possible types: address, uint, int, bool, function, bytes, string
// 2. else if we have a number at the end,
//      parse number
//      split number of from rest of string
//      get type for rest of string
//      add our length to the remainder type, if possible
//      possible types: bytes<M>, uint<M>, int<M>
// 3. else if we have [] at the end,
//      split [] off from rest of string
//      get type for rest of string
//         add our dynamic array to the remainder type, if possible
//         possible types: <fixed>[]
// 4. else if we have ] at the end (that is not covered above)
//      reverse search for next [
//      parse substring between into number
//         get type for rest of string
//         add our fixed length array to the remainder type, if possible
//      possible types: <fixed>[<M>]
// 5. if no valid type found (e.g. uint7 or empty string)
//      throw BivrostError.parameterTypeInvalid
// 6. Return detected type

fileprivate func parameterType(from string: String) throws -> ParameterType {
    // Step 1:
    let possibleType = try exactMatchType(from: string)
    // Step 2:
        ?? numberSuffixMatch(from: string)
    // Step3:
        ?? matchDynamicArray(from: string)
    // Step 4:
        ?? matchFixedArray(from: string)
    
    // Step 5
    guard let foundType = possibleType,
        foundType.isValid else {
            throw ParsingError.parameterTypeInvalid
    }
    
    // Step 6:
    return foundType
}

/// Types that are "atomic" can be matched exactly to these strings
fileprivate enum ExactMatchParameterType: String {
    // Static Types
    case address
    case uint
    case int
    case bool
    case function
    
    // Dynamic Types
    case bytes
    case string
}

fileprivate func exactMatchType(from string: String) -> ParameterType? {
    // Check all the exact matches by trying to create a ParameterTypeKey from it.
    switch ExactMatchParameterType(rawValue: string) {
        
    // Static Types
    case .address?:
        return .staticType(.address)
    case .uint?:
        return .staticType(.uint(bits: 256))
    case .int?:
        return .staticType(.int(bits: 256))
    case .bool?:
        return .staticType(.bool)
    case .function?:
        return .staticType(.function)
        
    // Dynamic Types
    case .bytes?:
        return .dynamicType(.bytes)
    case .string?:
        return .dynamicType(.string)
    default:
        // We could not find a type with an exact match.
        return nil
    }
}

fileprivate let numberSuffixRegex = "^(.*?)([1-9][0-9]*)$"

fileprivate func numberSuffixMatch(from string: String) throws -> ParameterType? {
    //  if we have a number at the end,
    //      parse number
    //      split number of from rest of string
    //      get type for rest of string
    //      add our length to the remainder type, if possible
    //      possible types: bytes<M>, uint<M>, int<M>

    let numberSuffixMatcher = try NSRegularExpression(pattern: numberSuffixRegex, options: [])
    let matches = numberSuffixMatcher.matches(in: string, options: [], range: string.fullNSRange)

    // If we don't have a match, this is not a number suffix match
    // 1st capture group is full string, 3rd is the numeric suffix,
    // 2nd group is the remaining string which we will parse further
    guard let firstMatch = matches.first,
        firstMatch.numberOfRanges == 3,
        let remainderRange = Range(firstMatch.range(at: 1), in: string),
        let lengthRange = Range(firstMatch.range(at: 2), in: string) else {
            return nil
    }
    guard let length = Int(string[lengthRange]) else {
        throw ParsingError.parameterTypeInvalid
    }
    
    let remainderString = String(string[remainderRange])
    let type = try parameterType(from: remainderString)
    
    // In a successful parsing case (e.g. type:"uint32") we get length=32 in
    // this function and we will then get an exact match for "uint" in the
    // `parameterType(from:)` method. This exact match is delivered to us as a
    // `.uint(bits: 256)`. We ignore the bits and set our own length.
    // bytes<M> will get matched as an exact dynamic type, but adding the numbers
    // converts this into a static type.
    switch type {
    case .staticType(.int(bits: 256)):
        return .staticType(.int(bits: length))
    case .staticType(.uint(bits: 256)):
        return .staticType(.uint(bits: length))
    case .dynamicType(.bytes):
        return .staticType(.bytes(length: length))
    default:
        throw ParsingError.parameterTypeInvalid
    }
}

/// Parses the string (backwards) and returns the dynamic array defined by the string.
///
/// - Parameter string: The type string to match.
/// - Returns: nil if not a match for dynamic array suffix.
/// - Throws: Throws if it's a match, but the wrapped type cannot be parsed or wrapped.
fileprivate func matchDynamicArray(from string: String) throws -> ParameterType? {
    // if we have [] at the end,
    //      split [] off from rest of string
    //      get type for rest of string
    //         add our dynamic array to the remainder type, if possible
    //         possible types: <fixed>[]
    
    guard string.hasSuffix("[]") else {
        return nil
    }
    // String ends with []. We now cut off the remainder string and parse the type for that
    let endOfStringIndex = string.endIndex
    let endOfRemainderIndex = string.index(endOfStringIndex, offsetBy: -2)
    let remainderString = String(string[string.startIndex..<endOfRemainderIndex])
    
    let type = try parameterType(from: remainderString)
    // Right now dynamic arrays cannot contain dynamic types, so make sure
    // this does not happen
    guard case .staticType(let unwrappedType) = type else {
        throw ParsingError.parameterTypeInvalid
    }
    return .dynamicType(.array(unwrappedType))
}

fileprivate func matchFixedArray(from string: String) throws -> ParameterType? {
    //  if we have ] at the end (that is not covered above)
    //      reverse search for next [
    //      parse substring between into number
    //         get type for rest of string
    //         add our fixed length array to the remainder type, if possible
    //      possible types: <fixed>[<M>]
    
    // If the string does not end with ] or does not include an opening bracket
    // abort and return nil (does not match)
    guard string.hasSuffix("]"),
        let indexOfOpeningBracket = string.lastIndex(of: "[") else {
            return nil
    }
    // We want to get the contents between the two brackets, but without the brackets
    let indexOfClosingBracket = string.index(string.endIndex, offsetBy: -1)
    let lengthSubstring = string[string.index(indexOfOpeningBracket, offsetBy: 1) ..< indexOfClosingBracket]
    // Check that we actually have a length between the brackets
    guard !lengthSubstring.isEmpty else {
        return nil
    }
    // If the contents of the brackets cannot be parsed to int, we throw
    guard let length = Int(lengthSubstring) else {
        throw ParsingError.parameterTypeInvalid
    }
    
    // We cut off brackets and get the base type for the remainderString
    let remainderString = String(string[string.startIndex..<indexOfOpeningBracket])
    let type = try parameterType(from: remainderString)

    // Right now fixed length arrays can only contain static types, so make sure
    // we have one of those
    guard case .staticType(let unwrappedType) = type else {
        throw ParsingError.parameterTypeInvalid
    }

    return ParameterType.staticType(.array(unwrappedType, length: length))
}

// MARK: - AbiEncoding
protocol AbiEncoding {
    var abiRepresentation: String { get }
}

extension ParameterType: AbiEncoding {
    var abiRepresentation: String {
        switch self {
        case .staticType(let type):
            return type.abiRepresentation
        case .dynamicType(let type):
            return type.abiRepresentation
        }
    }
}

extension ParameterType.StaticType: AbiEncoding {
    var abiRepresentation: String {
        switch self {
        case .uint(let bits):
            return "uint\(bits)"
        case .int(let bits):
            return "int\(bits)"
        case .address:
            return "address"
        case .bool:
            return "bool"
        case .bytes(let length):
            return "bytes\(length)"
        case .function:
            return "function"
        case let .array(type, length):
            return "\(type.abiRepresentation)[\(length)]"
        }
    }
}

extension ParameterType.DynamicType: AbiEncoding {
    var abiRepresentation: String {
        switch self {
        case .bytes:
            return "bytes"
        case .string:
            return "string"
        case .array(let type):
            return "\(type.abiRepresentation)[]"
        }
    }
}
