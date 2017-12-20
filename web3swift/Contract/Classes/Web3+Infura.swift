//
//  Web3+Provider.swift
//  web3swift
//
//  Created by Alexander Vlasov on 19.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import Foundation
import AwaitKit
import PromiseKit
import Alamofire
import Sodium
import BigInt

public struct InfuraProvider:Web3Provider {
    public var accessToken:String? = nil
    public init(){
        
    }
    enum supportedPostMethods: String {
        case eth_estimateGas = "eth_estimateGas"
        case eth_sendRawTransaction = "eth_sendRawTransaction"
    }
    
    enum supportedGetMethods: String{
        case eth_call = "eth_call"
        case eth_getTransactionCount = "eth_getTransactionCount"
    }
    
    public func send(transaction: EthereumTransaction, network: Networks) -> Promise<Data?> {
        return async {
            guard let request = EthereumTransaction.createRawTransaction(transaction: transaction) else {return nil}
            let response = try await(self.postToInfura(request, network: network)!)
            print(response)
            guard let res = response as? [String: Any], let resultString = res["result"] as? String else {return nil}
            let sodium = Sodium()
            guard let returnedData = sodium.utils.hex2bin(resultString.stripHexPrefix().lowercased()) else {return nil}
            return returnedData
        }
    }
    
    public func call(transaction: EthereumTransaction, options: Web3Options?, network: Networks) -> Promise<Data?> {
        return async {
            guard let req = EthereumTransaction.createRequest(method: "eth_call", transaction: transaction, onBlock: "latest", options: options) else {return nil}
            let response = try await(self.postToInfura(req, network: network)!)
//            print(response)
            guard let res = response as? [String: Any], let resultString = res["result"] as? String else {return nil}
            let sodium = Sodium()
            guard let returnedData = sodium.utils.hex2bin(resultString.stripHexPrefix().lowercased()) else {return nil}
            return returnedData
        }
    }
    
    public func estimateGas(transaction: EthereumTransaction, options: Web3Options?, network: Networks) -> Promise<BigUInt?> {
        return async {
            guard let req = EthereumTransaction.createRequest(method: "eth_estimateGas", transaction: transaction, onBlock: "latest", options: options) else {return nil}
            var infuraReq = req
            let params = [req.params?.params[0]] as Array<Encodable>
            let pars = JSONRPCparams(params: params)
            infuraReq.params = pars
            let response = try await(self.postToInfura(infuraReq, network: network)!)
            print(response)
            guard let res = response as? [String: Any], let resultString = res["result"] as? String else {return nil}
            guard let biguint = BigUInt(resultString.stripHexPrefix(), radix: 16) else {return nil}
            return biguint
        }
    }
    
    public func getNonce(_ address:EthereumAddress, network: Networks = .Mainnet) -> Promise<BigUInt?> {
        return async {
            var req = JSONRPCrequest()
            req.method = "eth_getTransactionCount"
            let params = [address.address.lowercased(), "latest"] as Array<Encodable>
            let pars = JSONRPCparams(params: params)
            req.params = pars
            let response = try await(self.postToInfura(req, network: network)!)
            print(response)
            guard let res = response as? [String: Any], let resultString = res["result"] as? String else {return nil}
            guard let biguint = BigUInt(resultString.stripHexPrefix(), radix: 16) else {return nil}
            return biguint
        }
    }
    
    internal func getToInfura(_ request: JSONRPCrequest, network: Networks = .Mainnet) -> Promise<Any>? {
        guard let method = request.method else {return nil}
        let requestURL = "https://api.infura.io/v1/jsonrpc/"+network.name+"/"+method
        guard let pars = request.params else {return nil}
        guard let encoded = try? JSONEncoder().encode(pars) else {return nil}
        guard let serialized = String(data: encoded, encoding: .utf8) else {return nil}
        var requestParameters = ["params" : serialized as Any]
        if self.accessToken != nil {
            requestParameters["token"] = self.accessToken!
        }
        return Alamofire.request(requestURL, parameters: requestParameters, encoding: URLEncoding.default).responseJSON()
    }
    
    internal func postToInfura(_ request: JSONRPCrequest, network: Networks) -> Promise<Any>? {
//        let requestURL = "https://api.infura.io/v1/jsonrpc/"+network.name
        var requestURL = "https://"+network.name + ".infura.io/"
        if self.accessToken != nil {
            requestURL = requestURL + self.accessToken!
        }
        guard let _ = try? JSONEncoder().encode(request) else {return nil}
//        print(String(data: requestJSON, encoding: .utf8))
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        return Alamofire.request(requestURL, method: .post, parameters: nil, encoding: request, headers: headers).responseJSON()
    }
    
}

