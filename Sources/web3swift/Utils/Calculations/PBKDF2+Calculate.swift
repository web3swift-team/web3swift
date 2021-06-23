//
//  PBKDF2+Calculate.swift
//  web3swift
//
//  Created by Pavel on 23.06.2021.
//

import Foundation
import CommonCrypto

enum PBKDF2 {
    enum PBKDF2Error: Error {
        case failed
    }
    
    enum Variant: Int {
        case sha1
        case sha256
        case sha384
        case sha512

        var algorithm: Int {
            switch self {
            case .sha1:
                return kCCPRFHmacAlgSHA1
            case .sha256:
                return kCCPRFHmacAlgSHA256
            case .sha384:
                return kCCPRFHmacAlgSHA384
            case .sha512:
                return kCCPRFHmacAlgSHA512
            }
        }
    }
    
    static func calculate(password: Array<UInt8>, salt: Array<UInt8>, iterations: Int = 4096 /* c */, keyLength: Int? = nil /* dkLen */, variant: Variant = .sha256) throws -> Array<UInt8> {
        
        var derivedKey: Array<UInt8> = Array(repeating: 0, count: keyLength ?? 0)

        let passwordBytes = password.map { Int8($0) }
        let derivationStatus = CCKeyDerivationPBKDF(
            CCPBKDFAlgorithm(kCCPBKDF2),
            passwordBytes, password.count,
            salt, salt.count,
            CCPseudoRandomAlgorithm(CCPBKDFAlgorithm(variant.algorithm)),
            UInt32(iterations),
            &derivedKey,
            derivedKey.count)


        if derivationStatus != 0 {
            throw PBKDF2Error.failed
        }

        return derivedKey
    }
}
