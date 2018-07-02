//
//  CryptoExtensions.swift
//  web3swift
//
//  Created by Alexander Vlasov on 04.12.2017.
//  Copyright © 2017 Alexander Vlasov. All rights reserved.
//

import Foundation
import libsodium

func toByteArray<T>(_ value: T) -> [UInt8] {
    var value = value
    return withUnsafeBytes(of: &value) { Array($0) }
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
