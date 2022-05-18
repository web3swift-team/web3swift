//  Package: web3swift
//  Created by Alex Vlasov.
//  Copyright © 2022 Yaroslav Yashin. All rights reserved.

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
public protocol JSONRPCParameter: Encodable { }

protocol JSONParameterElement: Encodable { }

extension Int: JSONRPCParameter { }

extension UInt: JSONRPCParameter { }

// FIXME: Drop all non default types support
extension UInt64: JSONRPCParameter { }

extension Double: JSONRPCParameter { }

extension String: JSONRPCParameter { }

extension Bool: JSONRPCParameter { }

extension Array: JSONRPCParameter where Element: JSONParameterElement { }

extension TransactionParameters: JSONRPCParameter { }

extension EventFilterParameters: JSONRPCParameter { }

extension Double: JSONParameterElement { }

extension Int: JSONParameterElement { }

// FIXME: Drop all non default types support
extension UInt64: JSONParameterElement { }

extension String: JSONParameterElement { }

/**
 Enum to compose request to the node params.

 In most cases request params are passed to Ethereum JSON RPC request as array of mixed type values, such as `[12,"this",true]`,
 thus this is not appropriate API design we have what we have.

 Meanwhile swift don't provide strict way to compose such array it gives some hacks to solve this task
 and one of them is using `RawRepresentable` protocol.

 Conforming this protocol gives designated type ability to represent itself in `String` representation in any way.

 So in our case we're using such to implement custom `encode` method to any used in node request params types.

 Latter is required to encode array of `RPCParameter` to not to `[RPCParameter.int(1)]`, but to `[1]`.

 Here's an example of using this enum in field.
 ```swift
 let jsonRPCParams: [JSONRPCParameter] = [
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
public enum RPCParameter {
    case int(Int)
    case intArray([Int])

    case uint(UInt64)
    case uintArray([UInt64])

    case double(Double)
    case doubleArray([Double])

    case string(String)
    case stringArray([String])

    case bool(Bool)
    case transaction(TransactionParameters)
    case eventFilter(EventFilterParameters)
}


extension RPCParameter: RawRepresentable {
    /**
     This init required by `RawRepresentable` protocol, which is requred to encode mixed type values array in JSON.

     This protocol used to implement custom `encode` method for that enum,
     which is encodes array of self into array of self assotiated values.

     You're totally free to use explicit and more convenience member init as `RPCParameter.int(12)` in your code.
     */
    public init?(rawValue: JSONRPCParameter) {
        /// force casting in this switch is safe because
        /// each `rawValue` forced to casts only in exact case which is runs based on `rawValues` type
        // swiftlint:disable force_cast
        switch type(of: rawValue) {
        case is Int.Type: self = .int(rawValue as! Int)
        case is [Int].Type: self = .intArray(rawValue as! [Int])

        case is UInt64.Type: self = .uint(rawValue as! UInt64)
        case is [UInt64].Type: self = .uintArray(rawValue as! [UInt64])

        case is String.Type: self = .string(rawValue as! String)
        case is [String].Type: self = .stringArray(rawValue as! [String])

        case is Double.Type: self = .double(rawValue as! Double)
        case is [Double].Type: self = .doubleArray(rawValue as! [Double])

        case is Bool.Type: self = .bool(rawValue as! Bool)
        case is TransactionParameters.Type: self = .transaction(rawValue as! TransactionParameters)
        case is EventFilterParameters.Type: self = .eventFilter(rawValue as! EventFilterParameters)
        default: return nil
        }
        // swiftlint:enable force_cast
    }

    /// Returning associated value of the enum case.
    public var rawValue: JSONRPCParameter {
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
        case let .transaction(value): return value
        case let .eventFilter(value): return value
        }
    }
}

extension RPCParameter: Encodable {
    /**
     This encoder encodes `RPCParameter` assotiated value ignoring self value

     This is required to encode mixed types array, like

     ```swift
     let someArray: [RPCParameter] = [
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

        case is UInt64.Type: try enumContainer.encode(rawValue as! UInt64)
        case is [UInt64].Type: try enumContainer.encode(rawValue as! [UInt64])

        case is String.Type: try enumContainer.encode(rawValue as! String)
        case is [String].Type: try enumContainer.encode(rawValue as! [String])

        case is Double.Type: try enumContainer.encode(rawValue as! Double)
        case is [Double].Type: try enumContainer.encode(rawValue as! [Double])

        case is Bool.Type: try enumContainer.encode(rawValue as! Bool)
        case is TransactionParameters.Type: try enumContainer.encode(rawValue as! TransactionParameters)
        case is EventFilterParameters.Type: try enumContainer.encode(rawValue as! EventFilterParameters)
        default: break /// can't be executed, coz possible `self.rawValue` types are strictly defined in it's inplementation.`
        }
        // swiftlint:enable force_cast
    }
}