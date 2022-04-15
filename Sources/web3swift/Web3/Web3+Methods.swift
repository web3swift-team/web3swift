//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation

public enum JSONRPCmethod: String, Encodable {

    // 0 parameter in call
    case gasPrice = "eth_gasPrice"
    case blockNumber = "eth_blockNumber"
    case getNetwork = "net_version"
    case getAccounts = "eth_accounts"
    case getTxPoolStatus = "txpool_status"
    case getTxPoolContent = "txpool_content"
    case getTxPoolInspect = "txpool_inspect"
    case estimateGas = "eth_estimateGas"

    // 1 parameter in call
    case sendRawTransaction = "eth_sendRawTransaction"
    case sendTransaction = "eth_sendTransaction"
    case getTransactionByHash = "eth_getTransactionByHash"
    case getTransactionReceipt = "eth_getTransactionReceipt"
    case personalSign = "eth_sign"
    case unlockAccount = "personal_unlockAccount"
    case createAccount = "personal_createAccount"
    case getLogs = "eth_getLogs"

    // 2 parameters in call
    case call = "eth_call"
    case getTransactionCount = "eth_getTransactionCount"
    case getBalance = "eth_getBalance"
    case getStorageAt = "eth_getStorageAt"
    case getCode = "eth_getCode"
    case getBlockByHash = "eth_getBlockByHash"
    case getBlockByNumber = "eth_getBlockByNumber"

    // 3 parameters in call
    case feeHistory = "eth_feeHistory"

    public var requiredNumOfParameters: Int {
        switch self {
        case .gasPrice,
                .blockNumber,
                .getNetwork,
                .getAccounts,
                .getTxPoolStatus,
                .getTxPoolContent,
                .getTxPoolInspect:
            return 0
        case .sendRawTransaction,
                .sendTransaction,
                .getTransactionByHash,
                .getTransactionReceipt,
                .personalSign,
                .unlockAccount,
                .createAccount,
                .getLogs,
                .estimateGas:
            return 1
        case .call,
                .getTransactionCount,
                .getBalance,
                .getStorageAt,
                .getCode,
                .getBlockByHash,
                .getBlockByNumber:
            return 2
        case .feeHistory:
            return 3
        }
    }
}

public struct JSONRPCRequestFabric {
    public static func prepareRequest(_ method: JSONRPCmethod, parameters: [Encodable]) -> JSONRPCrequest {
        var request = JSONRPCrequest()
        request.method = method
        let pars = JSONRPCparams(params: parameters)
        request.params = pars
        return request
    }

    public static func prepareRequest(_ method: InfuraWebsocketMethod, parameters: [Encodable]) -> InfuraWebsocketRequest {
        var request = InfuraWebsocketRequest()
        request.method = method
        let pars = JSONRPCparams(params: parameters)
        request.params = pars
        return request
    }
}
