//
//  Web3.swift
//  web3swift
//
//  Created by Alexander Vlasov on 11.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import Foundation
import Result

public enum Web3Error: Error {
    case transactionSerializationError
    case connectionError
    case dataError
    case walletError
    case inputError(String)
    case nodeError(String)
    case processingError(String)
    case keystoreError(AbstractKeystoreError)
    case generalError(Error)
    case unknownError
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
    static func getResponse(_ response: [String: Any]?) -> Result<Any, Web3Error> {
        guard response != nil, let res = response else {
            return Result.failure(Web3Error.connectionError)
        }
        if let error = res["error"] {
            if let errString = error as? String {
                return Result.failure(Web3Error.nodeError(errString))
            } else if let errDict = error as? [String:Any] {
                if errDict["message"] != nil, let descr = errDict["message"]! as? String  {
                    return Result.failure(Web3Error.nodeError(descr))
                }
            }
            return Result.failure(Web3Error.unknownError)
        }
        guard let result = res["result"] else {
            return Result.failure(Web3Error.dataError)
        }
        return Result(result)
    }
}






