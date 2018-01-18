//
//  Web3.swift
//  web3swift
//
//  Created by Alexander Vlasov on 11.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import Foundation

import BigInt

public struct Web3 {
    public static func newWeb3(_ providerURL: URL) -> web3? {
        guard let provider = Web3HttpProvider(providerURL) else {return nil}
        return web3(provider: provider)
    }
    
    public static func InfuraRinkebyWeb3(accessToken: String? = nil) -> web3 {
        let infura = InfuraProvider(Networks.Rinkeby, accessToken: accessToken)!
        return web3(provider: infura)
    }
    public static func InfuraMainnetWeb3(accessToken: String? = nil) -> web3 {
        let infura = InfuraProvider(Networks.Mainnet, accessToken: accessToken)!
        return web3(provider: infura)
    }
}

public protocol Web3Provider {
//    func send(request: JSONRPCrequest) -> Promise<[String: Any]?>
    func sendSync(request: JSONRPCrequest) -> [String:Any]?
    var network: Networks? {get}
    var attachedKeystoreManager: KeystoreManager? {get set}
    var url: URL {get}
}

public enum Networks {
    case Rinkeby
    case Mainnet
    case Ropsten
    case Kovan
    case Custom(networkID: BigUInt)
    
    var name: String {
        switch self {
        case .Rinkeby: return "rinkeby"
        case .Ropsten: return "ropsten"
        case .Mainnet: return "mainnet"
        case .Kovan: return "kovan"
        case .Custom: return ""
        }
    }
    
    var chainID: BigUInt {
        switch self {
        case .Custom(let networkID): return networkID
        case .Mainnet: return BigUInt(1)
        case .Ropsten: return BigUInt(3)
        case .Rinkeby: return BigUInt(4)
        case .Kovan: return BigUInt(42)
        }
    }

    static let allValues = [Mainnet, Rinkeby]
    
    static func fromInt(_ networkID:Int) -> Networks? {
        switch networkID {
        case 1:
            return Networks.Mainnet
        case 3:
            return Networks.Ropsten
        case 4:
            return Networks.Rinkeby
        case 42:
            return Networks.Kovan
        default:
            return Networks.Custom(networkID: BigUInt(networkID))
        }
    }
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
        options.gas = BigUInt("90000", radix: 10)!
        options.gasPrice = BigUInt("5000000000", radix:10)!
        options.value = BigUInt(0)
        return options
    }
    
    public static func fromJSON(_ json: [String: Any]) -> Web3Options? {
        var options = Web3Options()
        if let gas = json["gas"] as? String, let gasBiguint = BigUInt(gas.stripHexPrefix().lowercased(), radix: 16) {
            options.gas = gasBiguint
        }
        if let gasPrice = json["gasPrice"] as? String, let gasPriceBiguint = BigUInt(gasPrice.stripHexPrefix().lowercased(), radix: 16) {
            options.gas = gasPriceBiguint
        }
        if let value = json["value"] as? String, let valueBiguint = BigUInt(value.stripHexPrefix().lowercased(), radix: 16) {
            options.value = valueBiguint
        }
        if let fromString = json["from"] as? String {
            let addressFrom = EthereumAddress(fromString)
            if addressFrom.isValid {
                options.from = addressFrom
            }
        }
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




