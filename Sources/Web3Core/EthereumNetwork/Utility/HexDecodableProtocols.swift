//
//  HexDecodableProtocols.swift
//
//  Created by Yaroslav on 25.05.2022.
//

import BigInt
import Foundation

public protocol APIResultType: Decodable { }

extension Array: APIResultType where Element: APIResultType { }

extension String: APIResultType { }

/// This is utility protocol for decoding API Responses
///
/// You better not use it in any other part of a bit of code except `APIResponse<T>` decoding.
///
/// This protocols intention is to work around that Ethereum API cases, when almost all numbers are coming as strings.
/// More than that their notation (e.g. 0x12d) are don't fit with the default Numeric decoders behaviours.
/// So to work around that for generic cases we're going to force decode `APIResponse.result` field as `String`
/// and then initiate it
protocol LiteralInitiableFromString: APIResultType {
    init?(from hexString: String)
}

extension LiteralInitiableFromString where Self: IntegerInitableWithRadix {
    /// This initializer is intended to init `(U)Int` from hex string with `0x` prefix.
    init?(from hexString: String) {
        guard hexString.hasPrefix("0x") else { return nil }
        let tmpString = String(hexString.dropFirst(2))
        guard let value = Self(tmpString, radix: 16) else { return nil }
        self = value
    }
}
