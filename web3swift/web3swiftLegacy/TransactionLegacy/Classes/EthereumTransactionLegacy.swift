//
//  EthereumTransaction.swift
//  web3swift
//
//  Created by Alexander Vlasov on 05.12.2017.
//  Copyright © 2017 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt
import SwiftRLP
import secp256k1_swift
import EthereumAddress

extension EthereumTransaction {
    
    @available(*, deprecated, message: "Don't use Web3Options")
    public init(to: EthereumAddress, data: Data, options: Web3Options) {
        let defaults = Web3Options.defaultOptions()
        let merged = Web3Options.merge(defaults, with: options)
        self.nonce = BigUInt(0)
        self.gasLimit = merged!.gasLimit!
        self.gasPrice = merged!.gasPrice!
        self.value = merged!.value!
        self.to = to
        self.data = data
    }
    
    @available(*, deprecated, message: "Use TransactionOptions instead")
    public func mergedWithOptions(_ options: Web3Options) -> EthereumTransaction {
        var tx = self;
        if options.gasPrice != nil {
            tx.gasPrice = options.gasPrice!
        }
        if options.gasLimit != nil {
            tx.gasLimit = options.gasLimit!
        }
        if options.value != nil {
            tx.value = options.value!
        }
        if options.to != nil {
            tx.to = options.to!
        }
        return tx
    }
    
    @available(*, deprecated, message: "This method uses Web3Options inside that was deprecated")
    static func fromJSON(_ json: [String: Any]) -> EthereumTransaction? {
        guard let options = Web3Options.fromJSON(json) else {return nil}
        guard let toString = json["to"] as? String else {return nil}
        var to: EthereumAddress
        if toString == "0x" || toString == "0x0" {
            to = EthereumAddress.contractDeploymentAddress()
        } else {
            guard let ethAddr = EthereumAddress(toString) else {return nil}
            to = ethAddr
        }
//        if (!to.isValid) {
//            return nil
//        }
        var dataString = json["data"] as? String
        if (dataString == nil) {
            dataString = json["input"] as? String
        }
        guard dataString != nil, let data = Data.fromHex(dataString!) else {return nil}
        var transaction = EthereumTransaction(to: to, data: data, options: options)
        if let nonceString = json["nonce"] as? String {
            guard let nonce = BigUInt(nonceString.stripHexPrefix(), radix: 16) else {return nil}
            transaction.nonce = nonce
        }
        if let vString = json["v"] as? String {
            guard let v = BigUInt(vString.stripHexPrefix(), radix: 16) else {return nil}
            transaction.v = v
        }
        if let rString = json["r"] as? String {
            guard let r = BigUInt(rString.stripHexPrefix(), radix: 16) else {return nil}
            transaction.r = r
        }
        if let sString = json["s"] as? String {
            guard let s = BigUInt(sString.stripHexPrefix(), radix: 16) else {return nil}
            transaction.s = s
        }
        if let valueString = json["value"] as? String {
            guard let value = BigUInt(valueString.stripHexPrefix(), radix: 16) else {return nil}
            transaction.value = value
        }
        let inferedChainID = transaction.inferedChainID
        if (transaction.inferedChainID != nil && transaction.v >= BigUInt(37)) {
            transaction.chainID = inferedChainID
        }
        return transaction
    }
    
    @available(*, deprecated, message: "This method uses Web3Options inside that was deprecated")
    static func createRequest(method: JSONRPCmethod, transaction: EthereumTransaction, onBlock: String? = nil, options: Web3Options?) -> JSONRPCrequest? {
        var request = JSONRPCrequest()
        request.method = method
//        guard let from = options?.from else {return nil}
        guard var txParams = transaction.encodeAsDictionary(from: options?.from) else {return nil}
        if method == .estimateGas || options?.gasLimit == nil {
            txParams.gas = nil
        }
        var params = [txParams] as Array<Encodable>
        if method.requiredNumOfParameters == 2 && onBlock != nil {
            params.append(onBlock as Encodable)
        }
        let pars = JSONRPCparams(params: params)
        request.params = pars
        if !request.isValid {return nil}
        return request
    }
}
