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

public struct Web3 {
    public static func newWeb3(_ providerURL: URL? = nil) -> web3? {
        if providerURL == nil {
            var infura = InfuraProvider()
            infura.network = .Rinkeby
            return web3(provider: infura)
        }
        else {
            return nil
        }
    }
    
    public static func InfuraRinkebyWeb3(accessToken: String? = nil) -> web3 {
        let infura = InfuraProvider()
        infura.network = .Rinkeby
        infura.accessToken = accessToken
        return web3(provider: infura)
    }
    public static func InfuraMainnetWeb3(accessToken: String? = nil) -> web3 {
        let infura = InfuraProvider()
        infura.network = .Mainnet
        infura.accessToken = accessToken
        return web3(provider: infura)
    }
}

public protocol Web3Provider {
//    func send(request: JSONRPCrequest) -> Promise<[String: Any]?>
    func sendSync(request: JSONRPCrequest) -> [String:Any]?
    var network: Networks? {get}
    var attachedKeystoreManager: KeystoreManagerV3? {get set}
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




