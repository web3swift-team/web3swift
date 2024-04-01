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
    /// Converts hexadecimal string representation of some bytes into actual bytes.
    /// Notes:
    ///  - empty string will return `nil`;
    ///  - empty hex string, meaning it's equal to `"0x"`, will return empty `Data` object.
    /// - Parameter hex: bytes represented as string.
    /// - Returns: optional raw bytes.
    public static func fromHex(_ hex: String) -> Data? {
        let hex = hex.lowercased().trim()
        guard !hex.isEmpty else { return nil }
        guard hex != "0x" else { return Data() }
        let bytes = [UInt8](hex: hex.stripHexPrefix())
        return bytes.isEmpty ? nil : Data(bytes)
    }
}
