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
    func derive(path: String, warns: Bool, transactionChecker: TransactionChecker) async throws -> HDNode?
}

public enum BIP44Error: Error, Equatable {
    /// The selected path doesn't fulfill BIP44 standard, you can derive the root key anyway
    case warning
}

public protocol TransactionChecker {
    /**
     It verifies if the provided `address` has at least one transaction
     - Parameter address: to be queried
     - Throws: any error related to query the blockchain provider
     - Returns: true if the `address` has at least one transaction, false otherwise
     */
    func hasTransactions(address: String) async throws -> Bool
}

extension HDNode: BIP44 {
    public func derive(path: String, warns: Bool = true, transactionChecker: TransactionChecker) async throws -> HDNode? {
        if warns {
            guard let account = path.accountFromPath else {
                return nil
            }
            if account == 0 {
                return derive(path: path, derivePrivateKey: true)
            } else {
                for searchAccount in 0..<account {
                    let maxUnusedAddressIndexes = 20
                    var hasTransactions = false
                    for searchAddressIndex in 0..<maxUnusedAddressIndexes {
                        if let searchPath = path.newPath(account: searchAccount, addressIndex: searchAddressIndex),
                           let childNode = derive(path: searchPath, derivePrivateKey: true),
                           let ethAddress = Utilities.publicToAddress(childNode.publicKey) {
                            hasTransactions = try await transactionChecker.hasTransactions(address: ethAddress.address)
                            if hasTransactions {
                                break
                            }
                        }
                    }
                    if !hasTransactions {
                        throw BIP44Error.warning
                    }
                }
                return derive(path: path, derivePrivateKey: true)
            }
        } else {
            return derive(path: path, derivePrivateKey: true)
        }
    }
}

extension String {
    /// Verifies if current value matches BIP44 path standard
    var isBip44Path: Bool {
        do {
            let pattern = "^m/44'/\\d+'/\\d+'/[0-1]/\\d+$"
            let regex = try NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
            let matches = regex.numberOfMatches(in: self, range: NSRange(location: 0, length: utf16.count))
            return matches == 1
        } catch {
            return false
        }
    }

    /// Returns the account from the path if the string contains a well formed BIP44 path
    var accountFromPath: Int? {
        guard isBip44Path else {
            return nil
        }
        let components = components(separatedBy: "/")
        let accountIndex = 3
        let rawAccount = components[accountIndex].trimmingCharacters(in: CharacterSet(charactersIn: "'"))
        guard let account = Int(rawAccount) else {
            return nil
        }
        return account
    }

    /**
     Transforms a bip44 path into a new one changing `account` & `index`. The resulting one will have the change value equal to `0` to represent external chain. Format `m/44'/coin_type'/account'/change/address_index`
     - Parameter account: the new `account` to use
     - Parameter addressIndex: the new `addressIndex` to use
     - Returns: a valid bip44 path with the provided `account`, `addressIndex`and external `change` or nil otherwise
    */
    func newPath(account: Int, addressIndex: Int) -> String? {
        guard isBip44Path else {
            return nil
        }
        var components = components(separatedBy: "/")
        let accountPosition = 3
        components[accountPosition] = "\(account)'"
        let changePosition = 4
        components[changePosition] = "0"
        let addressIndexPosition = 5
        components[addressIndexPosition] = "\(addressIndex)"
        return components.joined(separator: "/")
    }
}
