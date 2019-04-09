//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation

public enum Web3Error: Error {
    case transactionSerializationError
    case connectionError
    case dataError
    case walletError
    case inputError(desc:String)
    case nodeError(desc:String)
    case processingError(desc:String)
    case keystoreError(err:AbstractKeystoreError)
    case generalError(err:Error)
    case unknownError
    
    var description : String {
        switch self {
            
        case .transactionSerializationError:
            return "Transaction Serialization Error"
        case .connectionError:
            return "Connection Error"
        case .dataError:
            return "Data Error"
        case .walletError:
            return "Wallet Error"
        case .inputError(let desc):
            return desc
        case .nodeError(let desc):
            return desc
        case .processingError(let desc):
            return desc
        case .keystoreError(let err):
            return err.localizedDescription
        case .generalError(let err):
            return err.localizedDescription
        case .unknownError:
            return "Unknown Error"
        }
    }
}

/// An arbitary Web3 object. Is used only to construct provider bound fully functional object by either supplying provider URL
/// or using pre-coded Infura nodes
public struct Web3 {
    
    /// Initialized provider-bound Web3 instance using a provider's URL. Under the hood it performs a synchronous call to get
    /// the Network ID for EIP155 purposes
    public static func new(_ providerURL: URL) -> web3? {
        guard let provider = Web3HttpProvider(providerURL) else {return nil}
        return web3(provider: provider)
    }
    
    /// Initialized Web3 instance bound to Infura's mainnet provider.
    public static func InfuraMainnetWeb3(accessToken: String? = nil) -> web3 {
        let infura = InfuraProvider(Networks.Mainnet, accessToken: accessToken)!
        return web3(provider: infura)
    }
    
    /// Initialized Web3 instance bound to Infura's rinkeby provider.
    public static func InfuraRinkebyWeb3(accessToken: String? = nil) -> web3 {
        let infura = InfuraProvider(Networks.Rinkeby, accessToken: accessToken)!
        return web3(provider: infura)
    }
    
    /// Initialized Web3 instance bound to Infura's ropsten provider.
    public static func InfuraRopstenWeb3(accessToken: String? = nil) -> web3 {
        let infura = InfuraProvider(Networks.Ropsten, accessToken: accessToken)!
        return web3(provider: infura)
    }
    
}

struct ResultUnwrapper {
    static func getResponse(_ response: [String: Any]?) throws -> Any {
        guard response != nil, let res = response else {
            throw Web3Error.connectionError
        }
        if let error = res["error"] {
            if let errString = error as? String {
                throw Web3Error.nodeError(desc: errString)
            } else if let errDict = error as? [String:Any] {
                if errDict["message"] != nil, let descr = errDict["message"]! as? String  {
                    throw Web3Error.nodeError(desc: descr)
                }
            }
            throw Web3Error.unknownError
        }
        guard let result = res["result"] else {
            throw Web3Error.dataError
        }
        return result
    }
}






