//
//  Web3+Methods.swift
//  web3swift
//
//  Created by Alexander Vlasov on 21.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import Foundation

public enum JSONRPCmethod: String, Encodable {
    
    case sendRawTransaction = "eth_sendRawTransaction"
    case estimateGas = "eth_estimateGas"
    case call = "eth_call"
    case getTransactionCount = "eth_getTransactionCount"
    
    public var requiredNumOfParameter: Int {
        get {
            switch self {
            case .sendRawTransaction:
                return 1
            case .call:
                return 2
            case .getTransactionCount:
                return 2
            case .estimateGas:
                return 2
            default:
                return 1
            }
        }
    }
}
