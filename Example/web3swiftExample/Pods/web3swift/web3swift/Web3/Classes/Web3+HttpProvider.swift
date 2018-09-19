//
//  Web3+Provider.swift
//  web3swift
//
//  Created by Alexander Vlasov on 19.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt
import PromiseKit

/// Providers abstraction for custom providers (websockets, other custom private key managers). At the moment should not be used.
public protocol Web3Provider {
    func sendAsync(_ request: JSONRPCrequest, queue: DispatchQueue) -> Promise<JSONRPCresponse>
    func sendAsync(_ requests: JSONRPCrequestBatch, queue: DispatchQueue) -> Promise<JSONRPCresponseBatch>
    var network: Networks? {get set}
    var attachedKeystoreManager: KeystoreManager? {get set}
    var url: URL {get}
    var session: URLSession {get}
}


/// The default http provider.
public class Web3HttpProvider: Web3Provider {
    public var url: URL
    public var network: Networks?
    public var attachedKeystoreManager: KeystoreManager? = nil
    public var session: URLSession = {() -> URLSession in
        let config = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: config)
        return urlSession
    }()
    public init?(_ httpProviderURL: URL, network net: Networks? = nil, keystoreManager manager: KeystoreManager? = nil) {
        do {
            guard httpProviderURL.scheme == "http" || httpProviderURL.scheme == "https" else {return nil}
            url = httpProviderURL
            if net == nil {
                let request = JSONRPCRequestFabric.prepareRequest(.getNetwork, parameters: [])
                let response = try Web3HttpProvider.post(request, providerURL: httpProviderURL, queue: DispatchQueue.global(qos: .userInteractive), session: session).wait()
                if response.error != nil {
                    if response.message != nil {
                        print(response.message!)
                    }
                    return nil
                }
                guard let result: String = response.getValue(), let intNetworkNumber = Int(result) else {return nil}
                network = Networks.fromInt(intNetworkNumber)
                if network == nil {return nil}
            } else {
                network = net
            }
        } catch {
            return nil
        }
        attachedKeystoreManager = manager
    }
}

