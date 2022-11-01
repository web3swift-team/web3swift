//
//  File.swift
//  
//
//  Created by Jann Driessen on 01.11.22.
//

import Foundation
import BigInt

public protocol Policyable {
    func resolve(provider: Web3Provider, transaction: CodableTransaction?) async throws -> BigUInt
}
