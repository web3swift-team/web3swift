//  web3swift
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
    
    static public func generateMnemonicsFromEntropy(entropy: Data, language: BIP39Language = BIP39Language.english) -> String  {
        let wordList = generateMnemonicsFrom(entropy: entropy)
        let separator = language.separator
        return wordList.joined(separator: separator)
    }

    static public func generateMnemonicsFrom(entropy: Data, language: BIP39Language = BIP39Language.english) -> [String]  {
        let entropy_bit_size = entropy.count * 8
        let checksum_length = entropy_bit_size / 32
        
        var entropy_bits = bitarray(from: entropy)
        print("array: \(entropy_bits)")
        guard let checksumTest = generateChecksum(entropyBytes: entropy, checksumLength: checksum_length) else {
            return []
        }
        entropy_bits += checksumTest
        return entropy_bits
            .split(every: 11)
            .compactMap { binary in
            Int(binary, radix: 2)
        }
        .map { index in
            language.words[index]
        }
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
        let checksum = String(checksumData, radix: 2).leftPadding(toLength: checksumLength, withPad: "0")
        return checksum
    }
    
    /**
    Initializes a new mnemonics set with the provided bitsOfEntropy.

    - Parameters:
       - bitsOfEntropy: 128 - 12 words, 192 - 18 words , 256 - 24 words in output.
       - language: words language, default english

    - Returns: random 12-24 words, that represent new Mnemonic phrase.
    */
    
    /// Initializes a new mnemonics set with the provided bitsOfEntropy.
    /// - Parameters:
    ///   - bitsOfEntropy: 128 - 12 words, 192 - 18 words , 256 - 24 words in output.
    ///   - language: words language, default english
    static public func generateMnemonics(bitsOfEntropy: Int, language: BIP39Language = BIP39Language.english) -> String? {
        guard bitsOfEntropy >= 128 && bitsOfEntropy <= 256 && bitsOfEntropy.isMultiple(of: 32) else {return nil}
        let entropy = Data.randomBytes(length: bitsOfEntropy/8)
        return generateMnemonicsFromEntropy(entropy: entropy, language: language)
    }

    static public func generateMnemonics(entropy: Int, language: BIP39Language = BIP39Language.english) -> [String]? {
        guard entropy >= 128 && entropy <= 256 && entropy.isMultiple(of: 32) else {return nil}
        let entropy = Data.randomBytes(length: entropy/8)
        return generateMnemonicsFrom(entropy: entropy, language: language)
    }

    static public func mnemonicsToEntropy(_ mnemonics: [String], language: BIP39Language = BIP39Language.english) -> Data? {
        guard mnemonics.count >= 12 && mnemonics.count.isMultiple(of: 3) && mnemonics.count <= 24 else {return nil}
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
    
    static public func seedFromMmemonics(_ mnemonics: [String], password: String = "", language: BIP39Language = BIP39Language.english) -> Data? {
        if mnemonicsToEntropy(mnemonics, language: language) == nil {
            return nil
        }
        guard let mnemData = mnemonics.joined(separator: language.separator).decomposedStringWithCompatibilityMapping.data(using: .utf8) else {return nil}
        let salt = "mnemonic" + password
        guard let saltData = salt.decomposedStringWithCompatibilityMapping.data(using: .utf8) else {return nil}
        guard let seedArray = try? PKCS5.PBKDF2(password: mnemData.bytes, salt: saltData.bytes, iterations: 2048, keyLength: 64, variant: HMAC.Variant.sha2(.sha512)).calculate() else {return nil}
        return Data(seedArray)
    }
    
    static public func seedFromEntropy(_ entropy: Data, password: String = "", language: BIP39Language = BIP39Language.english) -> Data? {
        let mnemonics = generateMnemonicsFrom(entropy: entropy, language: language)
        return seedFromMmemonics(mnemonics, password: password, language: language)
    }
}
