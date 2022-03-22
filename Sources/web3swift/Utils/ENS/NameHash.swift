//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import CryptoSwift

public struct NameHash {
    public static func normalizeDomainName(_ domain: String) -> String? {
        // TODO use ICU4C library later for domain name normalization, althoug f**k it for now, it's few megabytes large piece
        let normalized = domain.lowercased()
        return normalized
    }

    public static func nameHash(_ domain: String) -> Data? {
        guard let normalized = NameHash.normalizeDomainName(domain) else {return nil}
        return namehash(normalized)
    }

    static func namehash(_ name: String) -> Data? {
        if name == "" {
            return Data(repeating: 0, count: 32)
        }
        let parts = name.split(separator: ".")
        guard parts.count > 0 else {
            return nil
        }
        guard let lowerLevel = parts.first else {
            return nil
        }
        var remainder = ""
        if parts.count > 1 {
            remainder = parts[1 ..< parts.count].joined(separator: ".")
        }
        // TODO here some better normalization can happen
        var hashData = Data()
        guard let remainderHash = namehash(remainder) else {
            return nil
        }
        guard let labelData = lowerLevel.data(using: .utf8) else {
            return nil
        }
        hashData.append(remainderHash)
        hashData.append(labelData.sha3(.keccak256))
        let hash = hashData.sha3(.keccak256)
        print(name)
        print(hash.toHexString())
        return hash
    }
}
