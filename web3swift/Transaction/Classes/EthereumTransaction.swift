//
//  EthereumTransaction.swift
//  web3swift
//
//  Created by Alexander Vlasov on 05.12.2017.
//  Copyright © 2017 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt

public struct EthereumTransaction: CustomStringConvertible {
    public var nonce: BigUInt
    public var gasPrice: BigUInt = BigUInt("5000000000", radix: 10)!
    public var gasLimit: BigUInt = BigUInt(0)
    public var to: EthereumAddress
    public var value: BigUInt
    public var data: Data
    public var v: BigUInt = BigUInt(1)
    public var r: BigUInt = BigUInt(0)
    public var s: BigUInt = BigUInt(0)
    public var chainID: BigUInt? = nil
    
    public init (nonce: BigUInt, to: EthereumAddress, value: BigUInt, data: Data, chainID: BigUInt) {
        self.nonce = nonce
        self.to = to
        self.value = value
        self.data = data
        self.v = chainID
        self.chainID = chainID
    }
    
    public init(gasPrice: BigUInt, gasLimit: BigUInt, to: EthereumAddress, value: BigUInt, data: Data) {
        self.nonce = BigUInt(0)
        self.gasPrice = gasPrice
        self.gasLimit = gasLimit
        self.value = value
        self.data = data
        self.to = to
    }
    
    public init(to: EthereumAddress, data: Data, options: Web3Options) {
        let defaults = Web3Options.defaultOptions()
        self.nonce = BigUInt(0)
        if options.gasPrice != nil {
            self.gasPrice = options.gasPrice!
        } else {
            self.gasPrice = defaults.gasPrice!
        }
        if options.gas != nil {
            self.gasLimit = options.gas!
        } else {
            self.gasLimit = defaults.gas!
        }
        if options.value != nil {
            self.value = options.value!
        } else {
            self.value = defaults.value!
        }
        self.to = to
        self.data = data
    }
    
    
    public init (nonce: BigUInt, gasPrice: BigUInt, gasLimit: BigUInt, to: EthereumAddress, value: BigUInt, data: Data, v: BigUInt, r: BigUInt, s: BigUInt) {
        self.nonce = nonce
        self.gasPrice = gasPrice
        self.gasLimit = gasLimit
        self.to = to
        self.value = value
        self.data = data
        self.v = v
        self.r = r
        self.s = s
    }
    
    public var inferedChainID: BigUInt? {
        get{
            if (self.r == BigUInt(0) && self.s == BigUInt(0)) {
                return self.v
            } else if (self.v == BigUInt(27) || self.v == BigUInt(28)) {
                return nil
            } else {
                return ((self.v - BigUInt(1)) / BigUInt(2)) - BigUInt(17)
            }
        }
    }
    
    public var description: String {
        get {
            var toReturn = ""
            toReturn = toReturn + "Transaction" + "\n"
            toReturn = toReturn + "Nonce: " + String(self.nonce) + "\n"
            toReturn = toReturn + "Gas price: " + String(self.gasPrice) + "\n"
            toReturn = toReturn + "Gas limit: " + String(describing: self.gasLimit) + "\n"
            toReturn = toReturn + "To: " + self.to.address  + "\n"
            toReturn = toReturn + "Value: " + String(self.value) + "\n"
            toReturn = toReturn + "Data: " + self.data.toHexString().addHexPrefix().lowercased() + "\n"
            toReturn = toReturn + "v: " + String(self.v) + "\n"
            toReturn = toReturn + "r: " + String(self.r) + "\n"
            toReturn = toReturn + "s: " + String(self.s) + "\n"
            toReturn = toReturn + "Intrinsic chainID: " + String(describing:self.chainID) + "\n"
            toReturn = toReturn + "Infered chainID: " + String(describing:self.inferedChainID) + "\n"
            toReturn = toReturn + "sender: " + String(describing: self.sender)  + "\n"
            return toReturn
        }
        
    }
    public var sender: EthereumAddress? {
        get {
            guard let publicKey = self.recoverPublicKey() else {return nil}
            return Web3.Utils.publicToAddress(publicKey)
        }
    }
    
    public func recoverPublicKey() -> Data? {
        if (self.r == BigUInt(0) && self.s == BigUInt(0)) {
            return nil
        }
        var normalizedV:BigUInt = BigUInt(0)
        if (self.chainID != nil && self.chainID != BigUInt(0)) {
            normalizedV = self.v - BigUInt(35) - self.chainID! - self.chainID!
        } else {
            normalizedV = self.v - BigUInt(27)
        }
        guard let vData = normalizedV.serialize().setLengthLeft(1) else {return nil}
        guard let rData = r.serialize().setLengthLeft(32) else {return nil}
        guard let sData = s.serialize().setLengthLeft(32) else {return nil}
        guard let signatureData = SECP256K1.marshalSignature(v: vData, r: rData, s: sData) else {return nil}
        guard let hash = self.hash(forSignature: true, chainID: self.chainID) else {return nil}
        guard let publicKey = SECP256K1.recoverPublicKey(hash: hash, signature: signatureData) else {return nil}
        return publicKey
    }
    
    public var txhash: String? {
        get{
            guard self.sender != nil else {return nil}
            guard let hash = self.hash(forSignature: false, chainID: self.chainID) else {return nil}
            let txid = hash.toHexString().addHexPrefix().lowercased()
            return txid
        }
    }
    
    public var txid: String? {
        get {
            return self.txhash
        }
    }
    
    func encode(forSignature:Bool = false, chainID: BigUInt? = nil) -> Data? {
        if (forSignature) {
            if chainID != nil  {
                let fields = [self.nonce, self.gasPrice, self.gasLimit, self.to.addressData, self.value, self.data, chainID!, BigUInt(0), BigUInt(0)] as [AnyObject]
                return RLP.encode(fields)
            }
            else if self.chainID != nil  {
                let fields = [self.nonce, self.gasPrice, self.gasLimit, self.to.addressData, self.value, self.data, self.chainID!, BigUInt(0), BigUInt(0)] as [AnyObject]
                return RLP.encode(fields)
            } else {
                let fields = [self.nonce, self.gasPrice, self.gasLimit, self.to.addressData, self.value, self.data] as [AnyObject]
                return RLP.encode(fields)
            }
        } else {
            let fields = [self.nonce, self.gasPrice, self.gasLimit, self.to.addressData, self.value, self.data, self.v, self.r, self.s] as [AnyObject]
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
        let gasPriceEncoding = self.gasPrice.abiEncode(bits: 256)
        params.gasPrice = gasPriceEncoding.head?.toHexString().addHexPrefix().stripLeadingZeroes()
        let valueEncoding = self.value.abiEncode(bits: 256)
        params.value = valueEncoding.head?.toHexString().addHexPrefix().stripLeadingZeroes()
        if (self.data != Data()) {
            params.data = self.data.toHexString().addHexPrefix()
        } else {
            params.data = "0x"
        }
        return params
    }
    
    public func hash(forSignature:Bool = false, chainID: BigUInt? = nil) -> Data? {
        guard let encoded = self.encode(forSignature: forSignature, chainID: chainID) else {return nil}
        let hash = encoded.sha3(.keccak256)
        return hash
    }
    
    private mutating func attemptSignature(privateKey: Data, chainID: BigUInt? = nil) -> Bool {
        guard let hash = self.hash(forSignature: true, chainID: chainID) else {
            return false
        }
        let signature  = SECP256K1.signForRecovery(hash: hash, privateKey: privateKey)
        guard let compressedSignature = signature.compressed else {return false}
        guard let unmarshalledSignature = SECP256K1.unmarshalSignature(signatureData: compressedSignature) else {
            return false
        }
        if (chainID != nil ) {
            self.v = BigUInt(unmarshalledSignature.v) + BigUInt(35) + chainID! + chainID!
        } else if (self.chainID != nil ) {
            self.v = BigUInt(unmarshalledSignature.v) + BigUInt(35) + self.chainID! + self.chainID!
        } else {
            self.v = BigUInt(unmarshalledSignature.v) + BigUInt(27)
        }
        self.r = BigUInt(Data(unmarshalledSignature.r))
        self.s = BigUInt(Data(unmarshalledSignature.s))
        let originalPublicKey = SECP256K1.privateToPublic(privateKey: privateKey)
        let recoveredPublicKey = self.recoverPublicKey()
        if (originalPublicKey != recoveredPublicKey) {
            return false
        }
        return true
    }
    
    public mutating func sign(privateKey: Data, chainID: BigUInt? = nil) -> Bool {
        for _ in 0..<1024 {
            let result = self.attemptSignature(privateKey: privateKey, chainID: chainID)
            if (result) {
                return true
            }
        }
        return false
    }
    
    static func fromJSON(_ json: [String: Any]) -> EthereumTransaction? {
        guard let options = Web3Options.fromJSON(json) else {return nil}
        guard let toString = json["to"] as? String else {return nil}
        let to = EthereumAddress(toString)
        if (!to.isValid) {
            return nil
        }
        guard let dataString = json["data"] as? String, let data = Data.fromHex(dataString) else {return nil}
        return EthereumTransaction(to: to, data: data, options: options)
    }
    
    static func createRequest(method: JSONRPCmethod, transaction: EthereumTransaction, onBlock: String? = nil, options: Web3Options?) -> JSONRPCrequest? {
        var request = JSONRPCrequest()
        request.method = method
        guard let from = options?.from else {return nil}
        guard let txParams = transaction.encodeAsDictionary(from: from) else {return nil}
        var params = [txParams] as Array<Encodable>
        if method.requiredNumOfParameter == 2 && onBlock != nil {
            params.append(onBlock as Encodable)
        }
        let pars = JSONRPCparams(params: params)
        request.params = pars
        if !request.isValid {return nil}
        return request
    }
    
    static func createRawTransaction(transaction: EthereumTransaction) -> JSONRPCrequest? {
        guard transaction.sender != nil else {return nil}
        guard let encodedData = transaction.encode() else {return nil}
        let hex = encodedData.toHexString().addHexPrefix().lowercased()
        var request = JSONRPCrequest()
        request.method = JSONRPCmethod.sendRawTransaction
        let params = [hex] as Array<Encodable>
        let pars = JSONRPCparams(params: params)
        request.params = pars
        if !request.isValid {return nil}
        return request
    }
}
