//
//  Web3+APIRequestParameter.swift
//  Web3swift
//
//  Created by Yaroslav on 24.05.2022.
//

import Foundation

/// Protocol to restrict supported types which can be passed into `JSONRPCRequest` to a node.
///
/// You **must not** conform any type to that protocol.
///
/// Due to internal logic and swift itself restrictions, there's lack of encoding generic types
/// so current implementation of `JSONRPCParameter`s belongs on hardcoded supported types.
///
/// Conformance of that protocol by a custom type will be silently failed to encode (e.g. there won't be in request).
///
/// Please see `RPCParameter` documentation for more details.
public protocol APIRequestParameterType: Encodable { }

protocol APIRequestParameterElementType: Encodable { }

extension Int: APIRequestParameterType { }

extension UInt: APIRequestParameterType { }

extension Double: APIRequestParameterType { }

extension String: APIRequestParameterType { }

extension Bool: APIRequestParameterType { }

extension Array: APIRequestParameterType where Element: APIRequestParameterElementType { }

extension TransactionParameters: APIRequestParameterType { }

extension EventFilterParameters: APIRequestParameterType { }

extension Int: APIRequestParameterElementType { }

extension UInt: APIRequestParameterElementType { }

extension Double: APIRequestParameterElementType { }

extension String: APIRequestParameterElementType { }

extension Bool: APIRequestParameterElementType { }

/**
 Enum to compose request to the node params.

 In most cases request params are passed to Ethereum JSON RPC request as array of mixed type values, such as `[12,"this",true]`,
 thus this is not appropriate API design we have what we have.

 Meanwhile swift don't provide strict way to compose such array it gives some hacks to solve this task
 and one of them is using `RawRepresentable` protocol.

 Conforming this protocol gives designated type ability to represent itself in `String` representation in any way.

 So in our case we're using such to implement custom `encode` method to any used in node request params types.

 Latter is required to encode array of `RequestParameter` to not to `[RequestParameter.int(1)]`, but to `[1]`.

 Here's an example of using this enum in field.
 ```swift
 let jsonRPCParams: [APIRequestParameterType] = [
    .init(rawValue: 12)!,
    .init(rawValue: "this")!,
    .init(rawValue: 12.2)!,
    .init(rawValue: [12.2, 12.4])!
 ]
 let encoded = try JSONEncoder().encode(jsonRPCParams)
 print(String(data: encoded, encoding: .utf8)!)
 //> [12,\"this\",12.2,[12.2,12.4]]`
 ```
 */
public enum RequestParameter {
    case int(Int)
    case intArray([Int])

    case uint(UInt)
    case uintArray([UInt])

    case double(Double)
    case doubleArray([Double])

    case string(String)
    case stringArray([String])

    case bool(Bool)
    case boolArray([Bool])
    
    case transaction(TransactionParameters)
    case eventFilter(EventFilterParameters)
}


extension RequestParameter: RawRepresentable {
    /**
     This init required by `RawRepresentable` protocol, which is requred to encode mixed type values array in JSON.

     This protocol used to implement custom `encode` method for that enum,
     which is encodes array of self into array of self assotiated values.

     You're totally free to use explicit and more convenience member init as `RequestParameter.int(12)` in your code.
     */
    public init?(rawValue: APIRequestParameterType) {
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

        case is TransactionParameters.Type: self = .transaction(rawValue as! TransactionParameters)
        case is EventFilterParameters.Type: self = .eventFilter(rawValue as! EventFilterParameters)
        default: return nil
        }
        // swiftlint:enable force_cast
    }

    /// Returning associated value of the enum case.
    public var rawValue: APIRequestParameterType {
        // cases can't be merged, coz it cause compiler error since it couldn't predict what exact type on exact case will be returned.
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

extension RequestParameter: Encodable {
    /**
     This encoder encodes `RequestParameter` assotiated value ignoring self value

     This is required to encode mixed types array, like

     ```swift
     let someArray: [RequestParameter] = [
        .init(rawValue: 12)!,
        .init(rawValue: "this")!,
        .init(rawValue: 12.2)!,
        .init(rawValue: [12.2, 12.4])!
     ]
     let encoded = try JSONEncoder().encode(someArray)
     print(String(data: encoded, encoding: .utf8)!)
     //> [12,\"this\",12.2,[12.2,12.4]]`
     ```
     */
    public func encode(to encoder: Encoder) throws {
        var enumContainer = encoder.singleValueContainer()
        /// force casting in this switch is safe because
        /// each `rawValue` forced to casts only in exact case which is runs based on `rawValue` type
        // swiftlint:disable force_cast
        switch type(of: self.rawValue) {
        case is Int.Type: try enumContainer.encode(rawValue as! Int)
        case is [Int].Type: try enumContainer.encode(rawValue as! [Int])

        case is UInt.Type: try enumContainer.encode(rawValue as! UInt)
        case is [UInt].Type: try enumContainer.encode(rawValue as! [UInt])

        case is String.Type: try enumContainer.encode(rawValue as! String)
        case is [String].Type: try enumContainer.encode(rawValue as! [String])

        case is Double.Type: try enumContainer.encode(rawValue as! Double)
        case is [Double].Type: try enumContainer.encode(rawValue as! [Double])

        case is Bool.Type: try enumContainer.encode(rawValue as! Bool)
        case is [Bool].Type: try enumContainer.encode(rawValue as! [Bool])

        case is TransactionParameters.Type: try enumContainer.encode(rawValue as! TransactionParameters)
        case is EventFilterParameters.Type: try enumContainer.encode(rawValue as! EventFilterParameters)
        default: break /// can't be executed, coz possible `self.rawValue` types are strictly defined in it's inplementation.`
        }
        // swiftlint:enable force_cast
    }
}
