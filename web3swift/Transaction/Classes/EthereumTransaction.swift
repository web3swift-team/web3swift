//
//  EthereumTransaction.swift
//  web3swift
//
//  Created by Alexander Vlasov on 05.12.2017.
//  Copyright © 2017 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt

public struct EthereumAddress {
    public var isValid: Bool {
        get {
            return (self.addressData.count == 20);
        }
    }
    var _address: String
    
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


public struct EthereumTransaction {
    var nonce: BigUInt
    var gasprice: BigUInt = BigUInt(3000000000)
    var gasLimit: BigUInt = BigUInt(0)
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
    var sender: EthereumAddress? {
        get {
            if (self.r == BigUInt(0) && self.s == BigUInt(0)) {
                return nil
            }
            var normalizedV:BigUInt = BigUInt(0)
            if (chainID != nil && chainID != BigUInt(0)) {
                normalizedV = v - BigUInt(35) - chainID! - chainID!
            } else {
                normalizedV = v - BigUInt(25)
            }
            guard let vData = normalizedV.serialize().setLengthLeft(1) else {return nil}
            guard let rData = r.serialize().setLengthLeft(32) else {return nil}
            guard let sData = s.serialize().setLengthLeft(32) else {return nil}
            guard let signatureData = SECP256K1.marshalSignature(v: vData, r: rData, s: sData) else {return nil}
            guard let hash = self.hash(forSignature: true, chainID: self.chainID) else {return nil}
            guard let publicKey = SECP256K1.recoverPublicKey(hash: hash, signature: signatureData) else {return nil}
            return Web3.Utils.publicToAddress(publicKey)
        }
    }
    var txhash: String? {
        get{
            guard self.sender != nil else {return nil}
            guard let hash = self.hash(forSignature: false, chainID: self.chainID) else {return nil}
            let txid = hash.toHexString().addHexPrefix().lowercased()
            return txid
        }
    }
    
    var txid: String? {
        get {
            return self.txhash
        }
    }
    
    func encode(forSignature:Bool = false, chainID: BigUInt? = nil) -> Data? {
        if (forSignature) {
            if chainID != nil {
                let fields = [self.nonce, self.gasprice, self.gasLimit, self.to.addressData, self.value, self.data, chainID!, BigUInt(0), BigUInt(0)] as [AnyObject]
                return RLP.encode(fields)
            }
            else {
                let fields = [self.nonce, self.gasprice, self.gasLimit, self.to.addressData, self.value, self.data] as [AnyObject]
                return RLP.encode(fields)
            }
        } else {
            let fields = [self.nonce, self.gasprice, self.gasLimit, self.to.addressData, self.value, self.data, self.v, self.r, self.s] as [AnyObject]
            return RLP.encode(fields)
        }
    }
    
    func encodeAsDictionary(from: EthereumAddress) -> TransactionParameters? {
        if (!from.isValid) {
            return nil
        }
        
        var params = TransactionParameters(from: from.address.lowercased(),
                                           to: self.to.address.lowercased())
        let gasEncoding = self.gasLimit.abiEncode(bits: 256)
        params.gas = gasEncoding.head?.toHexString().addHexPrefix().stripLeadingZeroes()
        let gasPriceEncoding = self.gasprice.abiEncode(bits: 256)
        params.gasPrice = gasPriceEncoding.head?.toHexString().addHexPrefix().stripLeadingZeroes()
        let valueEncoding = self.value.abiEncode(bits: 256)
        params.value = valueEncoding.head?.toHexString().addHexPrefix().stripLeadingZeroes()
        if (self.data != Data()) {
            params.data = self.data.toHexString().addHexPrefix()
        }
        return params
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
    
    static func createRequest(method: String, transaction: EthereumTransaction, onBlock: String = "latest", options: Web3Options?) -> JSONRPCrequest? {
        var request = JSONRPCrequest()
        request.method = method
        guard let from = options?.from else {return nil}
        guard let txParams = transaction.encodeAsDictionary(from: from) else {return nil}
        let params = [txParams, onBlock] as Array<Encodable>
        let pars = JSONRPCparams(params: params)
        guard let encoded = try? JSONEncoder().encode(pars) else {return nil}
        guard let serialized = String(data: encoded, encoding: .utf8) else {return nil}
        request.params = serialized
        return request
    }
    
    static func createRawTransaction(transaction: EthereumTransaction) -> JSONRPCrequest? {
        guard transaction.sender != nil else {return nil}
        guard let encodedData = transaction.encode() else {return nil}
        let hex = encodedData.toHexString().addHexPrefix().lowercased()
        var request = JSONRPCrequest()
        request.method = "eth_sendRawTransaction"
        let params = [hex] as Array<Encodable>
        let pars = JSONRPCparams(params: params)
        guard let encoded = try? JSONEncoder().encode(pars) else {return nil}
        guard let serialized = String(data: encoded, encoding: .utf8) else {return nil}
        print(serialized)
        request.params = serialized
        return request
    }
}
