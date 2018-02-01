//
//  Web3+Provider.swift
//  web3swift
//
//  Created by Alexander Vlasov on 19.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import Foundation
import Alamofire
import Alamofire_Synchronous
import BigInt

public class Web3HttpProvider: Web3Provider {
    public var url: URL
    public var network: Networks?
    public var attachedKeystoreManager: KeystoreManager? = nil
    public init?(_ httpProviderURL: URL, network net: Networks? = nil, keystoreManager manager: KeystoreManager? = nil) {
        guard httpProviderURL.scheme == "http" || httpProviderURL.scheme == "https" else {return nil}
        url = httpProviderURL
        if net == nil {
            var request = JSONRPCrequest()
            request.method = JSONRPCmethod.getNetwork
            let params = [] as Array<Encodable>
            let pars = JSONRPCparams(params: params)
            request.params = pars
            let response = Web3HttpProvider.syncPost(request, providerURL: httpProviderURL)
            if response == nil {
                return nil
            }
            guard let res = response as? [String: Any] else {return nil}
            if let error = res["error"] as? String {
                print(error as String)
                return nil
            }
            guard let result = res["result"] as? String, let intNetworkNumber = Int(result) else {return nil}
            network = Networks.fromInt(intNetworkNumber)
            if network == nil {return nil}
        } else {
            network = net
        }
        attachedKeystoreManager = manager
    }
    
    public func sendSync(request: JSONRPCrequest) -> [String: Any]? {
        if request.method == nil {
            return nil
        }
        guard let response = self.syncPost(request) else {return nil}
        guard let res = response as? [String: Any] else {return nil}
        print(res)
        return res
    }
    
    internal func syncPost(_ request: JSONRPCrequest) -> Any? {
        return Web3HttpProvider.syncPost(request, providerURL: self.url)
    }
    
    static func syncPost(_ request: JSONRPCrequest, providerURL: URL) -> Any? {
        guard let _ = try? JSONEncoder().encode(request) else {return nil}
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        let response = Alamofire.request(providerURL, method: .post, parameters: nil, encoding: request, headers: headers).responseJSON()
        switch response.result {
        case .success(let resp):
            return resp
        case .failure(let err):
            print(err)
            return nil
        }
    }
}

