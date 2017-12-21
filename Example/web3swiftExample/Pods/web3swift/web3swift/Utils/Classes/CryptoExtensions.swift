//
//  CryptoExtensions.swift
//  web3swift
//
//  Created by Alexander Vlasov on 04.12.2017.
//  Copyright © 2017 Alexander Vlasov. All rights reserved.
//

import Foundation
import libsodium

public extension Data {
    public static func zero(_ data: inout Data) {
        let count = data.count
        data.withUnsafeMutableBytes { (dataPtr: UnsafeMutablePointer<UInt8>) in
            let rawPtr = UnsafeMutableRawPointer(dataPtr)
            sodium_memzero(rawPtr, count)
        }
    }
    public static func randomBytes(length: Int) -> Data? {
        var data = Data(count: length)
        for _ in 0...1024 {
            let result = data.withUnsafeMutableBytes {
                SecRandomCopyBytes(kSecRandomDefault, data.count, $0)
            }
            if result == errSecSuccess {
                return data
            }
        }
        return nil
    }
}

public func scrypt (password: String, salt: Data, length: Int, N: Int, R: Int, P: Int) -> Data? {
    let BytesMin = Int(crypto_generichash_bytes_min())
    let BytesMax = Int(crypto_generichash_bytes_max())
    if length < BytesMin || length > BytesMax {
        return nil
    }
    
    var output = Data(count: length)
    guard let passwordData = password.data(using: .utf8) else {return nil}
    let passwordLen = passwordData.count
    let saltLen = salt.count
    let result = output.withUnsafeMutableBytes { (outputPtr:UnsafeMutablePointer<UInt8>) -> Int32 in
        salt.withUnsafeBytes { (saltPointer:UnsafePointer<UInt8>) -> Int32 in
            passwordData.withUnsafeBytes{ (passwordPointer:UnsafePointer<UInt8>) -> Int32 in
                let res = crypto_pwhash_scryptsalsa208sha256_ll(passwordPointer, passwordLen,
                    saltPointer, saltLen,
                    UInt64(N), UInt32(R), UInt32(P),
                    outputPtr, length)
                return res
            }
        }
    }
    if result != 0 {
        return nil
    }
    return output
}

public func hex2bin (_ string: String) -> Data? {
    let str = string.lowercased().stripHexPrefix()
    let data = Data(Array<UInt8>(hex:str))
    if data.count == 0 {
        return nil
    }
    return data
    
}
