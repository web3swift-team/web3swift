//
//  Scrypt+Calculate.swift
//  web3swift
//
//  Created by Pavel on 23.06.2021.
//  Copyright © 2021 Matter Labs. All rights reserved.
//

import Foundation
import libscrypt

enum Scrypt {
    
    enum ScryptError: Error {
        case invalidLength
        case invalidParameters
        case emptySalt
        case unknownError(code: Int32)
    }
    
    static func calculate(password: Array<UInt8>, salt: Array<UInt8>, dkLen: Int, N: Int, r: Int, p: Int) throws -> [UInt8] {

        guard dkLen > 0, UInt64(dkLen) <= 137_438_953_440 else {
            throw ScryptError.invalidLength
        }
        guard r > 0, p > 0, r * p < 1_073_741_824, N.isPowerOfTwo else {
            throw ScryptError.invalidParameters
        }
        var rv = [UInt8](repeating: 0, count: dkLen)
        var result: Int32 = -1
        try rv.withUnsafeMutableBufferPointer { bufptr in
            try password.withUnsafeBufferPointer { passwd in
                
                try salt.withUnsafeBufferPointer { saltptr in
                    guard !saltptr.isEmpty else {
                        throw ScryptError.emptySalt
                    }
                    result = libscrypt_scrypt(
                        passwd.baseAddress!, passwd.count,
                        saltptr.baseAddress!, saltptr.count,
                        UInt64(N), UInt32(r), UInt32(p),
                        bufptr.baseAddress!, dkLen
                    )
                }
            }
        }
        guard result == 0 else {
            throw ScryptError.unknownError(code: result)
        }
        return rv
    }
}


private extension BinaryInteger {
    var isPowerOfTwo: Bool {
        (self > 0) && (self & (self - 1) == 0)
    }
}

