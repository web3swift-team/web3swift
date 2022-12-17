//
//  BIP44.swift
//  Created by Alberto Penas Amor on 15/12/22.
//

import Foundation

public protocol BIP44 {
    /**
     Derive an `HDNode` based on the provided `path`. The function will throws `BIP44Error.warning` if it was invoked with `warns` as true and the root key doesn't have a previous child with at least one transaction, using false the child node will be derived directly not throwing. This function needs to query the blockchain history when `warns`is true,  so it can throw network errors.
        
    - Parameter path: valid BIP32 path.
    - Parameter warns: true to be warned about following BIP44 standard, false otherwise.
    - Throws: `BIP44Error.warning` if the child key shouldn't be used according to BIP44 standard.
    - Returns: an HDNode child key for the provided `path` if it can be created, otherwise nil
     */
    func derive(path: String, warns: Bool) async throws -> HDNode?
}

public enum BIP44Error: Equatable {
    /// The selected path doesn't fulfill BIP44 standard, you can derive the root key anyway
    case warning
}

extension HDNode: BIP44 {
    public func derive(path: String, warns: Bool = true) async throws -> HDNode? {
        if warns {
            // https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki#account-discovery
            return nil
        } else {
            return derive(path: path, derivePrivateKey: true)
        }
    }
}
