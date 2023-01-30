//
//  HexDecodable+Extensions.swift
//  
//
//  Created by Yaroslav Yashin on 12.07.2022.
//

import Foundation
import BigInt

extension Int: LiteralInitableFromString { }

extension UInt: LiteralInitableFromString { }

extension BigInt: LiteralInitableFromString { }

extension BigUInt: LiteralInitableFromString { }

extension Data: LiteralInitableFromString {
    public static func fromHex(_ hex: String) -> Data? {
        let string = hex.lowercased().stripHexPrefix()
        let array = [UInt8](hex: string)
        if array.count == 0 {
            if hex == "0x" || hex == "" {
                return Data()
            } else {
                return nil
            }
        }
        return Data(array)
    }
}
