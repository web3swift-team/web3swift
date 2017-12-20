//
//  Web3.swift
//  web3swift
//
//  Created by Alexander Vlasov on 11.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import Foundation

import BigInt
import Alamofire
import PromiseKit

public struct Web3 {
    public static func newWeb3(_ providerURL: URL? = nil) -> web3? {
        if providerURL == nil {
            let provider = InfuraProvider()
            return web3(provider: provider)
        }
        else {
            return nil
        }
    }
}

public protocol Web3Provider{
    func send(transaction: EthereumTransaction, network: Networks) -> Promise<Data?>
    func call(transaction: EthereumTransaction, options: Web3Options?, network: Networks) -> Promise<Data?>
    func estimateGas(transaction: EthereumTransaction, options: Web3Options?, network: Networks) -> Promise<BigUInt?>
    func getNonce(_ address:EthereumAddress, network: Networks) -> Promise<BigUInt?>
}

public enum Networks {
    case Rinkeby
    case Mainnet
    
    var name: String {
        switch self {
        case .Rinkeby: return "rinkeby"
        case .Mainnet: return "mainnet"
        }
    }
    
    var chainID: BigUInt {
        switch self {
        case .Rinkeby: return BigUInt(4)
        case .Mainnet: return BigUInt(1)
        }
    }

    static let allValues = [Mainnet, Rinkeby]
}

public struct Web3Options {
    public var to: EthereumAddress? = nil
    public var from: EthereumAddress? = nil
    public var gas: BigUInt? = BigUInt(21000)
    public var gasPrice: BigUInt? = BigUInt(5000000000)
    public var value: BigUInt? = BigUInt(0)
    public init() {
    }
}

struct JSONRPCrequest: Encodable, ParameterEncoding  {
    var jsonrpc: String = "2.0"
    var method: String?
    var params: JSONRPCparams?
    var id: Int = 1
    var serializedParams: String? = nil
    
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        let jsonSerialization = try JSONEncoder().encode(self)
//        print(String(data: jsonSerialization, encoding: .utf8))
        var request = try urlRequest.asURLRequest()
        request.httpBody = jsonSerialization
        return request
    }
}

struct TransactionParameters: Codable {
    var data: String?
    var from: String
    var gas: String?
    var gasPrice: String?
    var to: String
    var value: String? = "0x0"
    
    init(from _from:String, to _to:String) {
        from = _from
        to = _to
    }
}

struct JSONRPCparams: Encodable{
    var params = [Any]()
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        for par in params {
            if let p = par as? TransactionParameters {
                try container.encode(p)
            } else if let p = par as? String {
                try container.encode(p)
            }
        }
    }
}


