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
import BigInt

public class InfuraProvider: Web3Provider {
    public var accessToken:String? = nil
    public var network: Networks? = .Rinkeby
    public var attachedKeystoreManager: KeystoreManagerV3? = nil
    public init() {
        
    }
    enum supportedPostMethods: String {
        case eth_estimateGas = "eth_estimateGas"
        case eth_sendRawTransaction = "eth_sendRawTransaction"
    }
    
    enum supportedGetMethods: String{
        case eth_call = "eth_call"
        case eth_getTransactionCount = "eth_getTransactionCount"
    }
    public func send(request: JSONRPCrequest) -> Promise<[String: Any]?> {
        return async {
            let response = try await(self.postToInfura(request)!)
            guard let res = response as? [String: Any] else {return nil}
            print(res)
            return res
        }
    }
    
    internal func getToInfura(_ request: JSONRPCrequest) -> Promise<Any>? {
        guard request.isValid else {return nil}
        guard let method = request.method else {return nil}
        let requestURL = "https://api.infura.io/v1/jsonrpc/"+(self.network?.name)!+"/"+method.rawValue
        guard let pars = request.params else {return nil}
        guard let encoded = try? JSONEncoder().encode(pars) else {return nil}
        guard let serialized = String(data: encoded, encoding: .utf8) else {return nil}
        var requestParameters = ["params" : serialized as Any]
        if self.accessToken != nil {
            requestParameters["token"] = self.accessToken!
        }
        return Alamofire.request(requestURL, parameters: requestParameters, encoding: URLEncoding.default).responseJSON()
    }
    
    internal func postToInfura(_ request: JSONRPCrequest) -> Promise<Any>? {
//        let requestURL = "https://api.infura.io/v1/jsonrpc/"+network.name
        var requestURL = "https://"+(self.network?.name)! + ".infura.io/"
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

