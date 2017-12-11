//
//  EthereumTransaction.swift
//  web3swift
//
//  Created by Alexander Vlasov on 05.12.2017.
//  Copyright © 2017 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt
import SECP256K1

struct EthereumAddress {
    var isValid: Bool {
        get {
            return (self.addressData.count == 20);
        }
    }
    var _address: String
    
    var addressData: Data {
        get {
            let dataArray = Array<UInt8>(hex: _address.lowercased().stripHexPrefix())
            return  Data(dataArray)
        }
    }
    var address:String {
        get {
            return EthereumAddress.toChecksumAddress(_address)!
        }
    }
    
    static func toChecksumAddress(_ addr:String) -> String? {
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
    
    init(_ addressString:String) {
        _address = addressString
    }
}


struct EthereumTransaction {
    var nonce: BigUInt
    var gasprice: BigUInt = BigUInt(3000000000)
    var startgas: BigUInt = BigUInt(0)
    var to: EthereumAddress
    var value: BigUInt
    var data: Data
    var v: BigUInt = BigUInt(1)
    var r: BigUInt = BigUInt(0)
    var s: BigUInt = BigUInt(0)
    var chainID: BigUInt? {
        get{
            if (self.r == BigUInt(0) && self.s == BigUInt(0)) {
                return self.v
            } else if (self.v == BigUInt(27) || self.v == BigUInt(28)) {
                return nil
            } else {
                return ((self.v - BigUInt(1)) / BigUInt(2)) - BigUInt(17)
            }
        }
        set(newChainID) {
            self.chainID = newChainID
        }
    }
    
    func encode(forSignature:Bool = false, chainID: BigUInt? = nil) -> Data? {
        if (forSignature) {
            if chainID != nil {
                let fields = [self.nonce, self.gasprice, self.startgas, self.to.addressData, self.value, self.data, chainID!, BigUInt(0), BigUInt(0)] as [AnyObject]
                return RLP.encode(fields)
            }
            else {
                let fields = [self.nonce, self.gasprice, self.startgas, self.to.addressData, self.value, self.data] as [AnyObject]
                return RLP.encode(fields)
            }
        } else {
            let fields = [self.nonce, self.gasprice, self.startgas, self.to.addressData, self.value, self.data, self.v, self.r, self.s] as [AnyObject]
            return RLP.encode(fields)
        }
    }
    
    func encodeAsDictionary(from: EthereumAddress) -> [String: String]? {
        var returnDictionary = [String:String]()
        if (!from.isValid) {
            return nil
        }
        returnDictionary["from"] = from.address
        returnDictionary["to"] = self.to.address.lowercased()
        returnDictionary["gas"] = self.startgas.abiEncode(bits: 256)?.toHexString()
        returnDictionary["gasPrice"] = self.gasprice.abiEncode(bits: 256)?.toHexString()
        returnDictionary["value"] = self.value.abiEncode(bits: 256)?.toHexString()
        returnDictionary["data"] = self.data.toHexString()
        return returnDictionary
    }
    
    func hash(forSignature:Bool = false, chainID: BigUInt? = nil) -> Data? {
        guard let encoded = self.encode(forSignature: forSignature, chainID: chainID) else {return nil}
        return encoded.sha3(.keccak256)
    }
    
    mutating func sign(privateKey: Data, chainID: BigUInt? = nil) -> Bool {
        guard let hash = self.hash(forSignature: true, chainID: chainID) else {return false}
        let signature  = SECP256K1.signForRecovery(hash: hash, privateKey: privateKey)
        guard let compressedSignature = signature.compressed else {return false}
        guard let unmarshalledSignature = SECP256K1.unmarshalSignature(signatureData: compressedSignature) else {return false}
        if (chainID != nil) {
            self.v = BigUInt(unmarshalledSignature.v) + BigUInt(35) + chainID! + chainID!
        } else {
            self.v = BigUInt(unmarshalledSignature.v) + BigUInt(27)
        }
        self.r = BigUInt(Data(unmarshalledSignature.r))
        self.s = BigUInt(Data(unmarshalledSignature.s))
        return true
    }
}
