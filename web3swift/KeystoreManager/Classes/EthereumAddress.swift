//
//  EthereumAddress.swift
//  web3swift
//
//  Created by Alexander Vlasov on 07.01.2018.
//

import Foundation
import BigInt

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
//        return lhs.address.lowercased() == rhs.address.lowercased() && lhs.type == rhs.type
    }
    
    public var addressData: Data {
        get {
            switch self.type {
            case .normal:
                guard let dataArray = Data.fromHex(_address) else {return Data()}
                return dataArray
//                guard let d = dataArray.setLengthLeft(20) else { return Data()}
//                return d
            case .contractDeployment:
                return Data()
            }
        }
    }
    public var address:String {
        switch self.type {
        case .normal:
            return EthereumAddress.toChecksumAddress(_address)!
        case .contractDeployment:
            return "0x"
        }
    }
    
    public static func toChecksumAddress(_ addr:String) -> String? {
        let address = addr.lowercased().stripHexPrefix()
        guard let hash = address.data(using: .ascii)?.sha3(.keccak256).toHexString().stripHexPrefix() else {return nil}
        var ret = "0x"
        
        for (i,char) in address.enumerated() {
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
    
    public init?(_ addressString:String, type: AddressType = .normal, ignoreChecksum: Bool = false) {
        switch type {
        case .normal:
            guard let data = Data.fromHex(addressString) else {return nil}
            guard data.count == 20 else {return nil}
            if (!ignoreChecksum && data.toHexString().addHexPrefix() != addressString) {
                let checksummedAddress = EthereumAddress.toChecksumAddress(data.toHexString().addHexPrefix())
                guard checksummedAddress == addressString else {return nil}
            }
            self._address = data.toHexString().addHexPrefix()
            self.type = .normal
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
    
    public static func contractDeploymentAddress() -> EthereumAddress {
        return EthereumAddress("0x", type: .contractDeployment)!
    }
}
