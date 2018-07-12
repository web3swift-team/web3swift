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

public protocol Web3Provider {
//    func send(request: JSONRPCrequest) -> [String:Any]?
//    func send(requests: [JSONRPCrequest]) -> [[String: Any]?]?
//    func sendWithRawResult(request: JSONRPCrequest) -> Data?
    func sendAsync(_ request: JSONRPCrequest, queue: DispatchQueue) -> Promise<JSONRPCresponse>
    func sendAsync(_ requests: JSONRPCrequestBatch, queue: DispatchQueue) -> Promise<JSONRPCresponseBatch>
    var network: Networks? {get set}
    var attachedKeystoreManager: KeystoreManager? {get set}
    var url: URL {get}
    var session: URLSession {get}
}

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
    
//    public func send(request: JSONRPCrequest) -> [String: Any]? {
//        if request.method == nil {
//            return nil
//        }
//        guard let response = self.syncPost(request) else {return nil}
//        guard let res = response as? [String: AnyObject] else {return nil}
////        print(res)
//        return res
//    }
//
//    public func send(requests: [JSONRPCrequest]) -> [[String: Any]?]? {
//        for request in requests {
//            if request.method == nil {
//                return nil
//            }
//        }
//        guard let response = self.syncPost(requests) else {return nil}
//        guard let res = response as? [[String: AnyObject]?] else {return nil}
////        print(res)
//        return res
//    }
//
//    public func sendWithRawResult(request: JSONRPCrequest) -> Data? {
//        if request.method == nil {
//            return nil
//        }
//        guard let response = self.syncPostRaw(request) else {return nil}
//        guard let res = response as? Data else {return nil}
//        return res
//    }
//
//    internal func syncPostRaw(_ request: JSONRPCrequest) -> Any? {
//        return Web3HttpProvider.syncPost(request, providerURL: self.url)
//    }
//
//    static func syncPostRaw(_ request: JSONRPCrequest, providerURL: URL) -> Any? {
//        guard let _ = try? JSONEncoder().encode(request) else {return nil}
//        //        print(String(data: try! JSONEncoder().encode(request), encoding: .utf8))
//        let headers: HTTPHeaders = [
//            "Content-Type": "application/json",
//            "Accept": "application/json"
//        ]
//        let response = Alamofire.request(providerURL, method: .post, parameters: nil, encoding: request, headers: headers).responseData()
//        switch response.result {
//        case .success(let resp):
//            return resp
//        case .failure(let err):
//            print(err)
//            return nil
//        }
//    }
//
//    internal func syncPost(_ request: JSONRPCrequest) -> Any? {
//        return Web3HttpProvider.syncPost(request, providerURL: self.url)
//    }
//
//    internal func syncPost(_ requests: [JSONRPCrequest]) -> Any? {
//        let batch = JSONRPCrequestBatch(requests: requests)
//        return Web3HttpProvider.syncPost(batch, providerURL: self.url)
//    }
//
//    static func syncPost(_ request: JSONRPCrequest, providerURL: URL) -> Any? {
//        guard let _ = try? JSONEncoder().encode(request) else {return nil}
////        print(String(data: try! JSONEncoder().encode(request), encoding: .utf8))
//        let headers: HTTPHeaders = [
//            "Content-Type": "application/json",
//            "Accept": "application/json"
//        ]
//        let response = Alamofire.request(providerURL, method: .post, parameters: nil, encoding: request, headers: headers).responseJSON()
//        switch response.result {
//        case .success(let resp):
//            return resp
//        case .failure(let err):
//            print(err)
//            return nil
//        }
//    }
//
//    static func syncPost(_ request: JSONRPCrequestBatch, providerURL: URL) -> Any? {
//        guard let _ = try? JSONEncoder().encode(request) else {return nil}
////        print(String(data: try! JSONEncoder().encode(request), encoding: .utf8))
//        let headers: HTTPHeaders = [
//            "Content-Type": "application/json",
//            "Accept": "application/json"
//        ]
//        let response = Alamofire.request(providerURL, method: .post, parameters: nil, encoding: request, headers: headers).responseJSON()
//        switch response.result {
//        case .success(let resp):
//            return resp
//        case .failure(let err):
//            print(err)
//            return nil
//        }
//    }
}

