//
//  Web3+Methods.swift
//  web3swift
//
//  Created by Alexander Vlasov on 21.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import Foundation

public enum JSONRPCmethod: String, Encodable {
    
    case gasPrice = "eth_gasPrice"
    case blockNumber = "eth_blockNumber"
    case getNetwork = "net_version"
    
    case sendRawTransaction = "eth_sendRawTransaction"
    case estimateGas = "eth_estimateGas"
    case call = "eth_call"
    case getTransactionCount = "eth_getTransactionCount"
    case getBalance = "eth_getBalance"
    case getCode = "eth_getCode"
    case getStorageAt = "eth_getStorageAt"
    
    case getTransactionByHash = "eth_getTransactionByHash"
    case getTransactionReceipt = "eth_getTransactionReceipt"
    
    case getAccounts = "eth_accounts"
    
    public var requiredNumOfParameter: Int {
        get {
            switch self {
            case .call:
                return 2
            case .getTransactionCount:
                return 2
            case .getBalance:
                return 2
            case .getStorageAt:
                return 2
            case .getCode:
                return 2
            case .gasPrice:
                return 0
            case .blockNumber:
                return 0
            case .getNetwork:
                return 0
            case .getAccounts:
                return 0
            default:
                return 1
            }
        }
    }
}
