//
//  CryptoExtensions.swift
//  web3swift
//
//  Created by Alexander Vlasov on 04.12.2017.
//  Copyright © 2017 Alexander Vlasov. All rights reserved.
//

import Foundation
//import libsodium
import scrypt

func toByteArray<T>(_ value: T) -> [UInt8] {
    var value = value
    return withUnsafeBytes(of: &value) { Array($0) }
}

public func scrypt (password: String, salt: Data, length: Int, N: Int, R: Int, P: Int) -> Data? {
    guard let passwordData = password.data(using: .utf8) else {return nil}
    guard let deriver = try? Scrypt(password: passwordData.bytes, salt: salt.bytes, dkLen: length, N: N, r: R, p: P) else {return nil}
    guard let result = try? deriver.calculate() else {return nil}
    return Data(result)
}
