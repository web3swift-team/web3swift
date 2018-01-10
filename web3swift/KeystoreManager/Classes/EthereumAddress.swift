//
//  EthereumAddress.swift
//  web3swift
//
//  Created by Alexander Vlasov on 07.01.2018.
//

import Foundation
import BigInt

public struct EthereumAddress: Equatable {
    public var isValid: Bool {
        get {
            return (self.addressData.count == 20);
        }
    }
    var _address: String
    
    public static func ==(lhs: EthereumAddress, rhs: EthereumAddress) -> Bool {
        return lhs.address.lowercased() == rhs.address.lowercased()
    }
    
    public var addressData: Data {
        get {
            let dataArray = Array<UInt8>(hex: _address.lowercased().stripHexPrefix())
            guard let d = Data(dataArray).setLengthLeft(20)
                else {
                    return Data()
            }
            return d
        }
    }
    public var address:String {
        get {
            return EthereumAddress.toChecksumAddress(_address)!
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
    
    public init(_ addressString:String) {
        _address = addressString
    }
}
