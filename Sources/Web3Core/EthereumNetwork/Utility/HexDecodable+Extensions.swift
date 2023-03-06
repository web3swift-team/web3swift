//
//  HexDecodable+Extensions.swift
//
//
//  Created by Yaroslav Yashin on 12.07.2022.
//

import Foundation
import BigInt

extension Int: LiteralInitiableFromString { }

extension UInt: LiteralInitiableFromString { }

extension BigInt: LiteralInitiableFromString { }

extension BigUInt: LiteralInitiableFromString { }

extension Data: LiteralInitiableFromString {
    public static func fromHex(_ hex: String) -> Data? {
        let string = hex.lowercased().stripHexPrefix()
        let array = [UInt8](hex: string)
        if (array.count == 0) {
            return (hex == "0x" || hex.isEmpty) ? Data() : nil
        }
        return Data(array)
    }
}
