//
//  Utilities.swift
//
//
//  Created by Yaroslav Yashin on 11.07.2022.
//

import Foundation
import BigInt

public struct Utilities {

    /// Convert a public key to the corresponding ``EthereumAddress``. Accepts public keys in compressed (33 bytes), uncompressed (65 bytes)
    /// or uncompressed without prefix (64 bytes) format.
    ///
    /// - Parameter publicKey: compressed 33, non-compressed (65 bytes) or non-compressed without prefix (64 bytes)
    /// - Returns: 20 bytes of address data.
    static func publicToAddressData(_ publicKey: Data) -> Data? {
        var publicKey = publicKey
        if publicKey.count == 33 {
            guard
                (publicKey[0] == 2 || publicKey[0] == 3),
                let decompressedKey = SECP256K1.combineSerializedPublicKeys(keys: [publicKey], outputCompressed: false)
            else {
                return nil
            }
            publicKey = decompressedKey
        }

        if publicKey.count == 65 {
            guard publicKey[0] == 4 else {
                return nil
            }
            publicKey = publicKey[1...64]
        } else if publicKey.count != 64 {
            return nil
        }
        let sha3 = publicKey.sha3(.keccak256)
        let addressData = sha3[12...31]
        return addressData
    }

    /// Convert a public key to the corresponding ``EthereumAddress``. Accepts public keys in compressed (33 bytes), uncompressed (65 bytes)
    /// or uncompressed without prefix (64 bytes) format.
    ///
    /// - Parameter publicKey: compressed 33, non-compressed (65 bytes) or non-compressed without prefix (64 bytes)
    /// - Returns: `EthereumAddress` object.
    public static func publicToAddress(_ publicKey: Data) -> EthereumAddress? {
        guard let addressData = publicToAddressData(publicKey) else { return nil }
        let address = addressData.toHexString().addHexPrefix().lowercased()
        return EthereumAddress(address)
    }

    /// Convert the private key (32 bytes of Data) to compressed (33 bytes) or non-compressed (65 bytes) public key.
    public static func privateToPublic(_ privateKey: Data, compressed: Bool = false) -> Data? {
        guard let publicKey = SECP256K1.privateToPublic(privateKey: privateKey, compressed: compressed) else { return nil }
        return publicKey
    }

    /// Convert a public key to the corresponding ``EthereumAddress``. Accepts public keys in compressed (33 bytes), uncompressed (65 bytes)
    /// or uncompressed without prefix (64 bytes) format.
    ///
    /// - Parameter publicKey: compressed 33, non-compressed (65 bytes) or non-compressed without prefix (64 bytes)
    /// - Returns: `0x` prefixed hex string.
    public static func publicToAddressString(_ publicKey: Data) -> String? {
        guard let addressData = Utilities.publicToAddressData(publicKey) else { return nil }
        let address = addressData.toHexString().addHexPrefix().lowercased()
        return address
    }

    /// Converts address data (20 bytes) to the 0x prefixed hex string. Does not perform checksumming.
    static func addressDataToString(_ addressData: Data) -> String? {
        guard addressData.count == 20 else { return nil }
        return addressData.toHexString().addHexPrefix().lowercased()
    }

    /// Hashes a personal message by first padding it with the "\u{19}Ethereum Signed Message:\n" string and message length string.
    /// Should be used if some arbitrary information should be hashed and signed to prevent signing an Ethereum transaction
    /// by accident.
    public static func hashPersonalMessage(_ personalMessage: Data) -> Data? {
        var prefix = "\u{19}Ethereum Signed Message:\n"
        prefix += String(personalMessage.count)
        guard let prefixData = prefix.data(using: .ascii) else { return nil }
        var data = Data()
        if personalMessage.count >= prefixData.count && prefixData == personalMessage[0 ..< prefixData.count] {
            data.append(personalMessage)
        } else {
            data.append(prefixData)
            data.append(personalMessage)
        }
        let hash = data.sha3(.keccak256)
        return hash
    }

    /// Parse a user-supplied string using the number of decimals for particular Ethereum unit.
    /// If input is non-numeric or precision is not sufficient - returns nil.
    /// Allowed decimal separators are ".", ",".
    public static func parseToBigUInt(_ amount: String, units: Utilities.Units = .ether) -> BigUInt? {
        let unitDecimals = units.decimals
        return parseToBigUInt(amount, decimals: unitDecimals)
    }

    /// Parse a string using the number of decimals.
    /// If input is non-numeric or precision is not sufficient - returns nil.
    /// Allowed decimal separators are ".", ",".
    public static func parseToBigUInt(_ amount: String, decimals: Int = 18) -> BigUInt? {
        let separators = CharacterSet(charactersIn: ".,")
        let components = amount.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: separators)
        guard components.count == 1 || components.count == 2 else { return nil }
        let unitDecimals = decimals
        guard let beforeDecPoint = BigUInt(components[0], radix: 10) else { return nil }
        var mainPart = beforeDecPoint * BigUInt(10).power(unitDecimals)
        if components.count == 2 {
            let numDigits = components[1].count
            guard numDigits <= unitDecimals else { return nil }
            guard let afterDecPoint = BigUInt(components[1], radix: 10) else { return nil }
            let extraPart = afterDecPoint * BigUInt(10).power(unitDecimals-numDigits)
            mainPart += extraPart
        }
        return mainPart
    }

    /// Formats a `BigInt` object to `String`. The supplied number is first divided into integer and decimal part based on `units` value,
    /// then limits the decimal part to `formattingDecimals` symbols and uses a `decimalSeparator` as a separator.
    /// Fallbacks to scientific format if higher precision is required.
    ///
    /// - Parameters:
    ///   - bigNumber: number to format;
    ///   - units: unit to format number to;
    ///   - formattingDecimals: the number of decimals that should be in the final formatted number;
    ///   - decimalSeparator: decimals separator;
    ///   - fallbackToScientific: if should fallback to scienctific representation like `1.23e-10`.
    /// - Returns: formatted number or `nil` if formatting was not possible.
    public static func formatToPrecision(_ bigNumber: BigInt, units: Utilities.Units = .ether, formattingDecimals: Int = 4, decimalSeparator: String = ".", fallbackToScientific: Bool = false) -> String {
        let magnitude = bigNumber.magnitude
        let formatted = formatToPrecision(magnitude, units: units, formattingDecimals: formattingDecimals, decimalSeparator: decimalSeparator, fallbackToScientific: fallbackToScientific)
        switch bigNumber.sign {
        case .plus:
            return formatted
        case .minus:
            return "-" + formatted
        }
    }

    /// Formats a `BigUInt` object to `String`. The supplied number is first divided into integer and decimal part based on `units` value,
    /// then limits the decimal part to `formattingDecimals` symbols and uses a `decimalSeparator` as a separator.
    /// Fallbacks to scientific format if higher precision is required.
    ///
    /// - Parameters:
    ///   - bigNumber: number to format;
    ///   - units: unit to format number to;
    ///   - formattingDecimals: the number of decimals that should be in the final formatted number;
    ///   - decimalSeparator: decimals separator;
    ///   - fallbackToScientific: if should fallback to scienctific representation like `1.23e-10`.
    /// - Returns: formatted number or `nil` if formatting was not possible.
    public static func formatToPrecision(_ bigNumber: BigUInt, units: Utilities.Units = .ether, formattingDecimals: Int = 4, decimalSeparator: String = ".", fallbackToScientific: Bool = false) -> String {
        guard bigNumber != 0 else {
            return "0"
        }
        let unitDecimals = units.decimals
        var toDecimals = formattingDecimals
        if unitDecimals < toDecimals {
            toDecimals = unitDecimals
        }
        let divisor = BigUInt(10).power(unitDecimals)
        let (quotient, remainder) = bigNumber.quotientAndRemainder(dividingBy: divisor)

        guard toDecimals != 0 else {
            return "\(quotient)"
        }

        let remainderStr = "\(remainder)"
        let fullPaddedRemainder = remainderStr.leftPadding(toLength: unitDecimals, withPad: "0")
        let remainderPadded = fullPaddedRemainder[0..<toDecimals]

        guard remainderPadded == String(repeating: "0", count: toDecimals) else {
            return "\(quotient)" + decimalSeparator + remainderPadded
        }

        if fallbackToScientific {
            return formatToScientificRepresentation(remainderStr, remainder: fullPaddedRemainder, decimals: formattingDecimals, decimalSeparator: decimalSeparator)
        }

        guard quotient == 0 else {
            return "\(quotient)"
        }

        return "\(quotient)" + decimalSeparator + remainderPadded
    }

    private static func formatToScientificRepresentation(_ remainder: String, remainder fullPaddedRemainder: String, decimals: Int, decimalSeparator: String) -> String {
        var remainder = remainder
        var firstDigit = 0
        for char in fullPaddedRemainder {
            if char == "0" {
                firstDigit += 1
            } else {
                let firstDecimalUnit = String(fullPaddedRemainder[firstDigit ..< firstDigit + 1])
                var remainingDigits = ""
                let numOfRemainingDecimals = fullPaddedRemainder.count - firstDigit - 1
                if numOfRemainingDecimals <= 0 {
                    remainingDigits = ""
                } else if numOfRemainingDecimals > decimals {
                    let end = firstDigit + 1 + decimals > fullPaddedRemainder.count ? fullPaddedRemainder.count : firstDigit + 1 + decimals
                    remainingDigits = String(fullPaddedRemainder[firstDigit + 1 ..< end])
                } else {
                    remainingDigits = String(fullPaddedRemainder[firstDigit + 1 ..< fullPaddedRemainder.count])
                }
                if !remainingDigits.isEmpty {
                    remainder = firstDecimalUnit + decimalSeparator + remainingDigits
                } else {
                    remainder = firstDecimalUnit
                }
                firstDigit += 1
                break
            }
        }
        return remainder + "e-" + String(firstDigit)
    }

    /// Recover the Ethereum address from recoverable secp256k1 signature. Message is first hashed using the "personal hash" protocol.
    /// BE WARNED - changing a message will result in different Ethereum address, but not in error.
    ///
    /// Input parameters should be hex Strings.
    static func personalECRecover(_ personalMessage: String, signature: String) -> EthereumAddress? {
        guard let data = Data.fromHex(personalMessage) else { return nil }
        guard let sig = Data.fromHex(signature) else { return nil }
        return Utilities.personalECRecover(data, signature: sig)
    }

    /// Recover the Ethereum address from recoverable secp256k1 signature. Message is first hashed using the "personal hash" protocol.
    /// BE WARNED - changing a message will result in different Ethereum address, but not in an error.
    public static func personalECRecover(_ personalMessage: Data, signature: Data) -> EthereumAddress? {
        guard let hash = Utilities.hashPersonalMessage(personalMessage) else { return nil }
        return hashECRecover(hash: hash, signature: signature)
    }

    /// Recover the Ethereum address from recoverable secp256k1 signature.
    /// Takes a hash of some message. What message is hashed should be checked by user separately.
    public static func hashECRecover(hash: Data, signature: Data) -> EthereumAddress? {
        if signature.count != 65 { return nil }
        let rData = signature[0..<32].bytes
        let sData = signature[32..<64].bytes
        var vData = signature[64]
        if vData >= 27 && vData <= 30 {
            vData -= 27
        } else if vData >= 31 && vData <= 34 {
            vData -= 31
        } else if vData >= 35 && vData <= 38 {
            vData -= 35
        }
        guard let signatureData = SECP256K1.marshalSignature(v: vData, r: rData, s: sData) else { return nil }
        guard let publicKey = SECP256K1.recoverPublicKey(hash: hash, signature: signatureData) else { return nil }
        return Utilities.publicToAddress(publicKey)
    }

    /// returns Ethereum variant of sha3 (keccak256) of data. Returns nil is data is empty
    static func keccak256(_ data: Data) -> Data? {
        if data.count == 0 { return nil }
        return data.sha3(.keccak256)
    }

    /// returns Ethereum variant of sha3 (keccak256) of data. Returns nil is data is empty
    static func sha3(_ data: Data) -> Data? {
        if data.count == 0 { return nil }
        return data.sha3(.keccak256)
    }

    /// returns sha256 of data. Returns nil is data is empty
    static func sha256(_ data: Data) -> Data? {
        if data.count == 0 { return nil }
        return data.sha256()
    }

    /// Unmarshals a 65 byte recoverable EC signature into internal structure.
    static func unmarshalSignature(signatureData: Data) -> SECP256K1.UnmarshaledSignature? {
        if signatureData.count != 65 { return nil }
        let bytes = signatureData.bytes
        let r = Array(bytes[0..<32])
        let s = Array(bytes[32..<64])
        return SECP256K1.UnmarshaledSignature(v: bytes[64], r: Data(r), s: Data(s))
    }

    /// Marshals the V, R and S signature parameters into a 65 byte recoverable EC signature.
    static func marshalSignature(v: UInt8, r: [UInt8], s: [UInt8]) -> Data? {
        guard r.count == 32, s.count == 32 else { return nil }
        var completeSignature = Data(r)
        completeSignature.append(Data(s))
        completeSignature.append(Data([v]))
        return completeSignature
    }

    /// Marshals internal signature structure into a 65 byte recoverable EC signature.
    static func marshalSignature(unmarshalledSignature: SECP256K1.UnmarshaledSignature) -> Data {
        var completeSignature = Data(unmarshalledSignature.r)
        completeSignature.append(Data(unmarshalledSignature.s))
        completeSignature.append(Data([unmarshalledSignature.v]))
        return completeSignature
    }
}

extension Utilities {
    /// Various units used in Ethereum ecosystem
    public enum Units {
        case wei
        case kwei
        case babbage
        case femtoether
        case mwei
        case lovelace
        case picoether
        case gwei
        case shannon
        case nanoether
        case nano
        case microether
        case szabo
        case micro
        case finney
        case milliether
        case milli
        case ether
        case kether
        case grand
        case mether
        case gether
        case tether
        case custom(Int)

        public var decimals: Int {
            switch self {
            case .wei:
                return 0
            case .kwei, .babbage, .femtoether:
                return 3
            case .mwei, .lovelace, .picoether:
                return 6
            case .gwei, .shannon, .nanoether, .nano:
                return 9
            case .microether, .szabo, .micro:
                return 12
            case .finney, .milliether, .milli:
                return 15
            case .ether:
                return 18
            case .kether, .grand:
                return 21
            case .mether:
                return 24
            case .gether:
                return 27
            case .tether:
                return 30
            case .custom(let decimals):
                return max(0, decimals)
            }
        }
    }
}
