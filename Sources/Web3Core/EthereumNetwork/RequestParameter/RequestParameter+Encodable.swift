//
//  RequestParameter+Encodable.swift
//
//
//  Created by Yaroslav Yashin on 12.07.2022.
//

import Foundation

extension RequestParameter: Encodable {

    /// This encoder encodes `RequestParameter` associated value ignoring self value
    ///
    /// This is required to encode mixed types array, like
    ///
    /// ```swift
    /// let someArray: [RequestParameter] = [
    ///     .init(rawValue: 12)!,
    ///     .init(rawValue: "this")!,
    ///     .init(rawValue: 12.2)!,
    ///     .init(rawValue: [12.2, 12.4])!
    /// ]
    /// let encoded = try JSONEncoder().encode(someArray)
    /// print(String(data: encoded, encoding: .utf8)!)
    /// //> [12,\"this\",12.2,[12.2,12.4]]`
    /// ```
    /// - Parameter encoder: The encoder to write data to.
    func encode(to encoder: Encoder) throws {
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

        case is CodableTransaction.Type: try enumContainer.encode(rawValue as! CodableTransaction)
        case is EventFilterParameters.Type: try enumContainer.encode(rawValue as! EventFilterParameters)
        default: break /// can't be executed, coz possible `self.rawValue` types are strictly defined in it's implementation.`
        }
        // swiftlint:enable force_cast
    }
}
