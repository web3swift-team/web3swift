//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import CryptoSwift

public enum BIP39Language {
    case english
    case chinese_simplified
    case chinese_traditional
    case japanese
    case korean
    case french
    case italian
    case spanish

    public var words: [String] {
        switch self {
        case .english:
            return englishWords
        case .chinese_simplified:
            return simplifiedchineseWords
        case .chinese_traditional:
            return traditionalchineseWords
        case .japanese:
            return japaneseWords
        case .korean:
            return koreanWords
        case.french:
            return frenchWords
        case .italian:
            return italianWords
        case .spanish:
            return spanishWords
        }
    }
    public var separator: String {
        switch self {
        case .japanese:
            return "\u{3000}"
        default:
            return " "
        }
    }

    init?(language: String) {
        switch language {
        case "english":
            self = .english
        case "chinese_simplified":
            self = .chinese_simplified
        case "chinese_traditional":
            self = .chinese_traditional
        case "japanese":
            self = .japanese
        case "korean":
            self = .korean
        case "french":
            self = .french
        case "italian":
            self = .italian
        case "spanish":
            self = .spanish
        default:
            return nil
        }
    }
}

public class BIP39 {

    /// Generates a mnemonic phrase length of which depends on the provided `bitsOfEntropy`.
    /// Returned value is a single string where words are joined by ``BIP39Language/separator``.
    /// Keep in mind that different languages may have different separators.
    /// - Parameters:
    ///   - bitsOfEntropy: 128 - 12 words, 160 - 15 words, and up to 256 - 24 words as output. The value must be a multiple of 32.
    ///   - language: words language, default is set to english.
    /// - Returns: mnemonic phrase as a single string containing 12, 15, 18, 21 or 24 words.
    public static func generateMnemonics(bitsOfEntropy: Int, language: BIP39Language = .english) throws -> String? {
        let entropy = try entropyOf(size: bitsOfEntropy)
        return generateMnemonicsFromEntropy(entropy: entropy, language: language)
    }

    /// Generates a mnemonic phrase length of which depends on the provided `entropy`.
    /// - Parameters:
    ///   - entropy: 128 - 12 words, 192 - 18 words, 256 - 24 words in output.
    ///   - language: words language, default is set to english.
    /// - Returns: mnemonic phrase as an array containing 12, 15, 18, 21 or 24 words.
    /// `nil` is returned in cases like wrong `entropy` value (e.g. `entropy` is not a multiple of 32).
    public static func generateMnemonics(entropy: Int, language: BIP39Language = .english) throws -> [String] {
        let entropy = try entropyOf(size: entropy)
        return generateMnemonicsFrom(entropy: entropy, language: language)
    }

    private static func entropyOf(size: Int) throws -> Data {
        let isCorrectSize = size >= 128 && size <= 256 && size.isMultiple(of: 32)
        let randomBytesCount = size / 8
        guard
            isCorrectSize,
            let entropy = Data.randomBytes(length: randomBytesCount)
        else {
            throw AbstractKeystoreError.noEntropyError("BIP39. \(!isCorrectSize ? "Requested entropy of wrong bits size: \(size). Expected: 128 <= size <= 256, size % 32 == 0." : "Failed to generate \(randomBytesCount) of random bytes.")")
        }
        return entropy
    }

    static func bitarray(from data: Data) -> String {
        data.map {
            let binary = String($0, radix: 2)
            let padding = String(repeating: "0", count: 8 - binary.count)
            return padding + binary
        }.joined()
    }

    static func generateChecksum(entropyBytes inputData: Data, checksumLength: Int) -> String? {
        guard let checksumData = inputData.sha256().bitsInRange(0, checksumLength) else {
            return nil
        }
        return String(checksumData, radix: 2).leftPadding(toLength: checksumLength, withPad: "0")
    }

    public static func generateMnemonicsFromEntropy(entropy: Data, language: BIP39Language = .english) -> String? {
        guard entropy.count >= 16, entropy.count & 4 == 0 else { return nil }
        let separator = language.separator
        let wordList = generateMnemonicsFrom(entropy: entropy)
        return wordList.joined(separator: separator)
    }

    public static func generateMnemonicsFrom(entropy: Data, language: BIP39Language = .english) -> [String] {
        let entropyBitSize = entropy.count * 8
        let checksum_length = entropyBitSize / 32

        var entropy_bits = bitarray(from: entropy)

        guard let checksumTest = generateChecksum(entropyBytes: entropy, checksumLength: checksum_length) else {
            return []
        }
        entropy_bits += checksumTest
        return entropy_bits
            .split(intoChunksOf: 11)
            .compactMap { binary in
                Int(binary, radix: 2)
            }
            .map { index in
                language.words[index]
            }
    }

    public static func mnemonicsToEntropy(_ mnemonics: String, language: BIP39Language = .english) -> Data? {
        let wordList = mnemonics.components(separatedBy: language.separator)
        return mnemonicsToEntropy(wordList, language: language)
    }

    public static func mnemonicsToEntropy(_ mnemonics: [String], language: BIP39Language = .english) -> Data? {
        guard 12...24 ~= mnemonics.count && mnemonics.count.isMultiple(of: 3) else { return nil }
        var bitString = ""
        for word in mnemonics {
            guard let idx = language.words.firstIndex(of: word) else {
                return nil
            }
            let stringForm = String(UInt16(idx), radix: 2).leftPadding(toLength: 11, withPad: "0")
            bitString.append(stringForm)
        }
        let stringCount = bitString.count
        if !stringCount.isMultiple(of: 33) {
            return nil
        }
        let entropyBits = bitString[0 ..< (bitString.count - bitString.count/33)]
        let checksumBits = bitString[(bitString.count - bitString.count/33) ..< bitString.count]
        guard let entropy = entropyBits.interpretAsBinaryData() else {
            return nil
        }
        let checksum = String(entropy.sha256().bitsInRange(0, checksumBits.count)!, radix: 2).leftPadding(toLength: checksumBits.count, withPad: "0")
        if checksum != checksumBits {
            return nil
        }
        return entropy
    }

    public static func seedFromMmemonics(_ mnemonics: [String], password: String = "", language: BIP39Language = .english) -> Data? {
        let wordList = mnemonics.joined(separator: language.separator)
        return seedFromMmemonics(wordList, password: password, language: language)
    }

    public static func seedFromMmemonics(_ mnemonics: String, password: String = "", language: BIP39Language = .english) -> Data? {
        guard mnemonicsToEntropy(mnemonics, language: language) != nil else {
            return nil
        }
        return dataFrom(mnemonics: mnemonics, password: password)
    }

    private static func dataFrom(mnemonics: String, password: String) -> Data? {
        guard let mnemData = mnemonics.decomposedStringWithCompatibilityMapping.data(using: .utf8) else { return nil }
        let salt = "mnemonic" + password
        guard let saltData = salt.decomposedStringWithCompatibilityMapping.data(using: .utf8) else { return nil }
        guard let seedArray = try? PKCS5.PBKDF2(password: mnemData.bytes, salt: saltData.bytes, iterations: 2048, keyLength: 64, variant: HMAC.Variant.sha2(.sha512)).calculate() else { return nil }
        return Data(seedArray)
    }

    public static func seedFromEntropy(_ entropy: Data, password: String = "", language: BIP39Language = .english) -> Data? {
        guard let mnemonics = generateMnemonicsFromEntropy(entropy: entropy, language: language) else {
            return nil
        }
        return seedFromMmemonics(mnemonics, password: password, language: language)
    }
}
