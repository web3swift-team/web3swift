//
//  APIRequest+ComputedProperties.swift
//
//
//  Created by Yaroslav Yashin on 12.07.2022.
//

import Foundation

extension APIRequest {
    var method: REST {
         .POST
    }

   public var encodedBody: Data {
        let request = RequestBody(method: call, params: parameters)
        // this is safe to force try this here
        // Because request must failed to compile if it not conformable with `Encodable` protocol
        return try! JSONEncoder().encode(request)
    }

    var parameters: [RequestParameter] {
        switch self {
        case .gasPrice, .blockNumber, .getNetwork, .getAccounts, .getTxPoolStatus, .getTxPoolContent:
            return [RequestParameter]()

        case .estimateGas(let transactionParameters, let blockNumber):
            return [.transaction(transactionParameters), .string(blockNumber.description)]

        case let .sendRawTransaction(hash):
            return [.string(hash)]

        case let .sendTransaction(transactionParameters):
            return [.transaction(transactionParameters)]

        case .getTransactionByHash(let hash):
            return [.string(hash)]

        case .getTransactionReceipt(let receipt):
            return [.string(receipt)]

        case .getLogs(let eventFilterParameters):
            return [.eventFilter(eventFilterParameters)]

        case .personalSign(let address, let string):
            return [.string(address), .string(string)]

        case .call(let transactionParameters, let blockNumber):
            return [.transaction(transactionParameters), .string(blockNumber.description)]

        case .getTransactionCount(let address, let blockNumber):
            return [.string(address), .string(blockNumber.description)]

        case .getBalance(let address, let blockNumber):
            return [.string(address), .string(blockNumber.description)]

        case .getStorageAt(let address, let bigUInt, let blockNumber):
            return [.string(address), .string(bigUInt.hexString), .string(blockNumber.description)]

        case .getCode(let address, let blockNumber):
            return [.string(address), .string(blockNumber.description)]

        case .getBlockByHash(let hash, let bool):
            return [.string(hash), .bool(bool)]

        case .getBlockByNumber(let block, let bool):
            return [.string(block.description), .bool(bool)]

        case .feeHistory(let uInt, let blockNumber, let array):
            return [.string(uInt.hexString), .string(blockNumber.description), .doubleArray(array)]

        case .createAccount(let string):
            return [.string(string)]

        case .unlockAccount(let address, let string, let uInt):
            return [.string(address), .string(string), .uint(uInt ?? 0)]
        }
    }

    public var call: String {
        switch self {
        case .gasPrice: return "eth_gasPrice"
        case .blockNumber: return "eth_blockNumber"
        case .getNetwork: return "net_version"
        case .getAccounts: return "eth_accounts"
        case .sendRawTransaction: return "eth_sendRawTransaction"
        case .sendTransaction: return "eth_sendTransaction"
        case .getTransactionByHash: return "eth_getTransactionByHash"
        case .getTransactionReceipt: return "eth_getTransactionReceipt"
        case .personalSign: return "eth_sign"
        case .getLogs: return "eth_getLogs"
        case .call: return "eth_call"
        case .estimateGas: return "eth_estimateGas"
        case .getTransactionCount: return "eth_getTransactionCount"
        case .getBalance: return "eth_getBalance"
        case .getStorageAt: return "eth_getStorageAt"
        case .getCode: return "eth_getCode"
        case .getBlockByHash: return "eth_getBlockByHash"
        case .getBlockByNumber: return "eth_getBlockByNumber"
        case .feeHistory: return "eth_feeHistory"

        case .unlockAccount: return "personal_unlockAccount"
        case .createAccount: return "personal_createAccount"
        case .getTxPoolStatus: return "txpool_status"
        case .getTxPoolContent: return "txpool_content"
        }
    }
}
