//
//  RequestParameter+RawRepresentable.swift
//
//
//  Created by Yaroslav Yashin on 12.07.2022.
//

import Foundation

extension RequestParameter: RawRepresentable {

    /// This init is required by ``RawRepresentable`` protocol, which is required
    /// to encode mixed type values array in JSON.
    ///
    /// This protocol is used to implement custom `encode` method for that enum,
    /// which encodes an array of self-assosiated values.
    ///
    /// You're totally free to use explicit and more convenience member init as `RequestParameter.int(12)` in your code.
    /// - Parameter rawValue: one of the supported types like `Int`, `UInt` etc.
    init?(rawValue: APIRequestParameterType) {
        /// force casting in this switch is safe because
        /// each `rawValue` forced to casts only in exact case which is runs based on `rawValues` type
        // swiftlint:disable force_cast

        switch type(of: rawValue) {
        case is Int.Type: self = .int(rawValue as! Int)
        case is [Int].Type: self = .intArray(rawValue as! [Int])

        case is UInt.Type: self = .uint(rawValue as! UInt)
        case is [UInt].Type: self = .uintArray(rawValue as! [UInt])

        case is String.Type: self = .string(rawValue as! String)
        case is [String].Type: self = .stringArray(rawValue as! [String])

        case is Double.Type: self = .double(rawValue as! Double)
        case is [Double].Type: self = .doubleArray(rawValue as! [Double])

        case is Bool.Type: self = .bool(rawValue as! Bool)
        case is [Bool].Type: self = .boolArray(rawValue as! [Bool])

        case is [CodableTransaction].Type: self = .transaction(rawValue as! CodableTransaction)
        case is [EventFilterParameters].Type: self = .eventFilter(rawValue as! EventFilterParameters)
        default: return nil
        }
        // swiftlint:enable force_cast
    }

    /// Returning associated value of the enum case.
    var rawValue: APIRequestParameterType {
        // cases can't be merged, coz it causes compile error since it couldn't predict exact type that will be returned.
        switch self {
        case let .int(value): return value
        case let .intArray(value): return value

        case let .uint(value): return value
        case let .uintArray(value): return value

        case let .string(value): return value
        case let .stringArray(value): return value

        case let .double(value): return value
        case let .doubleArray(value): return value

        case let .bool(value): return value
        case let .boolArray(value): return value

        case let .transaction(value): return value
        case let .eventFilter(value): return value
        }
    }
}
