//
//  RequestParameter.swift
//  
//
//  Created by Yaroslav Yashin on 12.07.2022.
//

import Foundation

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
enum RequestParameter {
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