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
    public var address: String {
        switch self.type {
        case .normal:
            return EthereumAddress.toChecksumAddress(_address)!
        case .contractDeployment:
            return "0x"
        }
    }

    public static func toChecksumAddress(_ addr: String) -> String? {
        let address = addr.lowercased().stripHexPrefix()
        guard let hash = address.data(using: .ascii)?.sha3(.keccak256).toHexString().stripHexPrefix() else {return nil}
        var ret = "0x"

        for (i, char) in address.enumerated() {
            let startIdx = hash.index(hash.startIndex, offsetBy: i)
            let endIdx = hash.index(hash.startIndex, offsetBy: i+1)
            let hashChar = String(hash[startIdx..<endIdx])
            let c = String(char)
            guard let int = Int(hashChar, radix: 16) else {return nil}
            if (int >= 8) {
                ret += c.uppercased()
            } else {
                ret += c
            }
        }
        return ret
    }

    public static func contractDeploymentAddress() -> EthereumAddress {
        return EthereumAddress("0x", type: .contractDeployment)!
    }
}

/// In swift structs it's better to implement initializers in extension
/// Since it's make available syntetized initializer then for free.
extension EthereumAddress {
    public init?(_ addressString:String, type: AddressType = .normal, ignoreChecksum: Bool = false) {
        switch type {
        case .normal:
            guard let data = Data.fromHex(addressString) else {return nil}
            guard data.count == 20 else {return nil}
            if !addressString.hasHexPrefix() {
                return nil
            }
            if (!ignoreChecksum) {
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
                    guard checksummedAddress == addressString else {return nil}
                    self._address = data.toHexString().addHexPrefix()
                    self.type = .normal
                    return
                }
            } else {
                self._address = data.toHexString().addHexPrefix()
                self.type = .normal
                return
            }
        case .contractDeployment:
            self._address = "0x"
            self.type = .contractDeployment
        }
    }

    public init?(_ addressData:Data, type: AddressType = .normal) {
        guard addressData.count == 20 else {return nil}
        self._address = addressData.toHexString().addHexPrefix()
        self.type = type
    }

}

extension EthereumAddress: Hashable { }
