//
//  Sequence+ABIExtension.swift
//  web3swift
//
//  Created by JeneaVranceanu on 12/07/2022.
//

import Foundation

public extension Sequence where Element == ABI.Element {
    /// Extracts all ``ABI/Element/Function`` objects and maps them to:
    /// - function name, e.g. `myFunction`;
    /// - function name with parameters if there are any, e.g. `myFunction()` or `myFunction(uint256)`
    /// - function signature, e.g. `0xabcdef00`.
    ///
    /// Functions with ``ABI/Element/Function/name`` value being `nil` will be skipped.
    /// - Returns: dictionary of mapped functions.
    /// Throws an error if there are two functions in the sequence with exactly the same name and input parameters.
    func getFunctions() throws -> [String: [ABI.Element.Function]] {
        var functions = [String: [ABI.Element.Function]]()

        func appendFunction(_ key: String, _ value: ABI.Element.Function) {
            var array = functions[key] ?? []
            array.append(value)
            functions[key] = array
        }

        for case let .function(function) in self where function.name != nil {
            appendFunction(function.name!, function)
            appendFunction(function.signature, function)
            appendFunction(function.methodString.addHexPrefix().lowercased(), function)

            /// ABI cannot have two functions with exactly the same name and input arguments
            if (functions[function.signature]?.count ?? 0) > 1 {
                throw ABIError.invalidFunctionOverloading("Given ABI is invalid: contains two functions with possibly different return values but exactly the same name and input parameters!")
            }
        }
        return functions
    }

    /// Filters out all ``ABI/Element/Event`` types and maps them to their names
    /// provided in ``ABI/Element/Event/name`` variable.
    /// - Returns: dictionary of all events mapped to their names.
    func getEvents() -> [String: ABI.Element.Event] {
        var events = [String: ABI.Element.Event]()
        for case let .event(event) in self {
            events[event.name] = event
        }
        return events
    }

    /// Filters out all ``ABI/Element/EthError`` types and maps them to their names
    /// provided in ``ABI/Element/EthError/name`` variable.
    /// - Returns: dictionary of all errors mapped to their names.
    func getErrors() -> [String: ABI.Element.EthError] {
        var errors = [String: ABI.Element.EthError]()
        for case let .error(error) in self {
            errors[error.name] = error
        }
        return errors
    }

    /// Filters out ``ABI/Element/Constructor``.
    /// If there are multiple of them the first encountered will be returned and if there are none a default constructor will be returned
    /// that accepts no input parameters.
    /// - Returns: the first ``ABI/Element/Constructor`` or default constructor with no input parameters.
    func getConstructor() -> ABI.Element.Constructor {
        for case let .constructor(constructor) in self {
            return constructor
        }
        return ABI.Element.Constructor(inputs: [], constant: false, payable: false)
    }
}
