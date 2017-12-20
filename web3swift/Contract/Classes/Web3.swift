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
    public var gas: BigUInt? = nil
    public var gasPrice: BigUInt? = nil
    public var value: BigUInt? = nil
    public init() {
    }
    public static func defaultOptions() -> Web3Options{
        var options = Web3Options()
        options.gas = BigUInt(21000)
        options.gasPrice = BigUInt(5000000000)
        options.value = BigUInt(0)
        return options
    }
    
    public static func merge(_ options:Web3Options?, with other:Web3Options?) -> Web3Options? {
        if (other == nil && options == nil) {
            return Web3Options.defaultOptions()
        }
        var newOptions = Web3Options.defaultOptions()
        if (other?.to != nil) {
            newOptions.to = other?.to
        } else {
            newOptions.to = options?.to
        }
        if (other?.from != nil) {
            newOptions.from = other?.from
        } else {
            newOptions.from = options?.from
        }
        if (other?.gas != nil) {
            newOptions.gas = other?.gas
        } else {
            newOptions.gas = options?.gas
        }
        if (other?.gasPrice != nil) {
            newOptions.gasPrice = other?.gasPrice
        } else {
            newOptions.gasPrice = options?.gasPrice
        }
        if (other?.value != nil) {
            newOptions.value = other?.value
        } else {
            newOptions.value = options?.value
        }
        return newOptions
    }
}

struct JSONRPCrequest: Encodable, ParameterEncoding  {
    var jsonrpc: String = "2.0"
    var method: String?
    var params: JSONRPCparams?
    var id: Int = Int(floor(Date().timeIntervalSince1970))
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


