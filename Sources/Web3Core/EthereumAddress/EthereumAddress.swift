//
//  EthereumAddress.swift
//  EthereumAddress
//
//  Created by Alex Vlasov on 25/10/2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import CryptoSwift

public struct EthereumAddress: Equatable {
    public enum AddressType {
        case normal
        case contractDeployment
    }

    public var isValid: Bool {
        get {
            switch self.type {
            case .normal:
                return (self.addressData.count == 20)
            case .contractDeployment:
                return true
            }
        }
    }
    var _address: String
    public var type: AddressType = .normal
    public static func ==(lhs: EthereumAddress, rhs: EthereumAddress) -> Bool {
        return lhs.addressData == rhs.addressData && lhs.type == rhs.type
    }

    /// Raw representation of the address.
    /// If the ``type`` is ``EthereumAddress/AddressType/contractDeployment`` an empty `Data` object is returned.
    public var addressData: Data {
        get {
            switch self.type {
            case .normal:
                guard let dataArray = Data.fromHex(_address) else {return Data()}
                return dataArray
            case .contractDeployment:
                return Data()
            }
        }
    }

    /// Checksummed address with `0x` HEX prefix.
    /// If the ``type`` is ``EthereumAddress/AddressType/contractDeployment`` only `0x` prefix is returned.
    public var address: String {
        switch self.type {
        case .normal:
            return EthereumAddress.toChecksumAddress(_address)!
        case .contractDeployment:
            return "0x"
        }
    }

    /// Validates and checksumms given `addr`.
    /// If given string is not an address, incomplete address or is invalid validation will fail and `nil` will be returned.
    /// - Parameter addr: address in string format, case insensitive, `0x` prefix is not required.
    /// - Returns: validates and checksumms the address. Returns `nil` if checksumm has failed or given string cannot be
    /// represented as `ASCII` data. Otherwise, checksummed address is returned with `0x` prefix.
    public static func toChecksumAddress(_ addr: String) -> String? {
        let address = addr.lowercased().stripHexPrefix()
        guard let hash = address.data(using: .ascii)?.sha3(.keccak256).toHexString().stripHexPrefix() else { return nil }
        var ret = "0x"

        for (i, char) in address.enumerated() {
            let startIdx = hash.index(hash.startIndex, offsetBy: i)
            let endIdx = hash.index(hash.startIndex, offsetBy: i+1)
            let hashChar = String(hash[startIdx..<endIdx])
            let c = String(char)
            guard let int = Int(hashChar, radix: 16) else { return nil }
            if int >= 8 {
                ret += c.uppercased()
            } else {
                ret += c
            }
        }
        return ret
    }

    /// Creates a special ``EthereumAddress`` that serves the purpose of the receiver, or `to` address of a transaction if it is a
    /// smart contract deployment.
    /// - Returns: special instance with type ``EthereumAddress/AddressType/contractDeployment`` and
    /// empty ``EthereumAddress/address``.
    public static func contractDeploymentAddress() -> EthereumAddress {
        EthereumAddress("0x", type: .contractDeployment)!
    }
}

/// In swift structs it's better to implement initializers in extension
/// Since it's make available synthesized initializer then for free.
extension EthereumAddress {
    public init?(_ addressString: String, type: AddressType = .normal, ignoreChecksum: Bool = false) {
        switch type {
        case .normal:
            guard let data = Data.fromHex(addressString) else { return nil }
            guard data.count == 20 else { return nil }
            if !addressString.hasHexPrefix() {
                return nil
            }
            if !ignoreChecksum {
                // check for checksum
                if data.toHexString() == addressString.stripHexPrefix() {
                    self._address = data.toHexString().addHexPrefix()
                    self.type = .normal
                    return
                } else if data.toHexString().uppercased() == addressString.stripHexPrefix() {
                    self._address = data.toHexString().addHexPrefix()
                    self.type = .normal
                    return
                } else {
                    let checksummedAddress = EthereumAddress.toChecksumAddress(data.toHexString().addHexPrefix())
                    guard checksummedAddress == addressString else { return nil }
                    self._address = data.toHexString().addHexPrefix()
                    self.type = .normal
                    return
                }
            } else {
                self._address = data.toHexString().addHexPrefix()
                self.type = .normal
                return
            }
        // TODO: Where it ever set?
        case .contractDeployment:
            self._address = "0x"
            self.type = .contractDeployment
        }
    }

    public init?(_ addressData: Data, type: AddressType = .normal) {
        guard addressData.count == 20 else { return nil }
        self._address = addressData.toHexString().addHexPrefix()
        self.type = type
    }

}

extension EthereumAddress: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        self.init(stringValue)!
    }

    public func encode(to encoder: Encoder) throws {
        let value = self.address.lowercased()
        var signleValuedCont = encoder.singleValueContainer()
        try signleValuedCont.encode(value)
    }
}

extension EthereumAddress: Hashable { }

extension EthereumAddress: APIResultType { }

// MARK: - CustomStringConvertible

extension EthereumAddress: CustomStringConvertible {
    /// Used when converting an instance to a string
    public var description: String {
        var toReturn = ""
        toReturn += "EthereumAddress" + "\n"
        toReturn += "type: " + String(describing: type) + "\n"
        toReturn += "address: " + String(describing: address) + "\n"
        return toReturn
    }
}
