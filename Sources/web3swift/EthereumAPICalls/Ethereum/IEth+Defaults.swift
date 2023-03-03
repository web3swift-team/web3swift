//
//  IEth+Defaults.swift
//
//  Created by JeneaVranceanu on 07.12.2022.
//

import Foundation
import BigInt
import Web3Core

public extension IEth {
    func callTransaction(_ transaction: CodableTransaction) async throws -> Data {
        let request = APIRequest.call(transaction, transaction.callOnBlock ?? .latest)
        return try await APIRequest.sendRequest(with: provider, for: request).result
    }
}

public extension IEth {
    func estimateGas(for transaction: CodableTransaction) async throws -> BigUInt {
        try await estimateGas(for: transaction, onBlock: .latest)
    }

    func estimateGas(for transaction: CodableTransaction, onBlock: BlockNumber) async throws -> BigUInt {
        let request = APIRequest.estimateGas(transaction, onBlock)
        return try await APIRequest.sendRequest(with: provider, for: request).result
    }
}

public extension IEth {
    func transactionReceipt(_ txHash: Data) async throws -> TransactionReceipt {
        let request = APIRequest.getTransactionReceipt(txHash.toHexString().addHexPrefix())
        return try await APIRequest.sendRequest(with: provider, for: request).result
    }
}

public extension IEth {
    func transactionDetails(_ txHash: Data) async throws -> TransactionDetails {
        let request = APIRequest.getTransactionByHash(txHash.toHexString().addHexPrefix())
        return try await APIRequest.sendRequest(with: provider, for: request).result
    }
}

public extension IEth {
    func getTransactionCount(for address: EthereumAddress) async throws -> BigUInt {
        try await getTransactionCount(for: address, onBlock: .latest)
    }

    func getTransactionCount(for address: EthereumAddress, onBlock: BlockNumber) async throws -> BigUInt {
        let request = APIRequest.getTransactionCount(address.address, onBlock)
        return try await APIRequest.sendRequest(with: provider, for: request).result
    }
}

public extension IEth {
    func gasPrice() async throws -> BigUInt {
        try await APIRequest.sendRequest(with: self.provider, for: .gasPrice).result
    }
}

public extension IEth {
    func code(for address: EthereumAddress) async throws -> Hash {
        try await code(for: address, onBlock: .latest)
    }

    func code(for address: EthereumAddress, onBlock: BlockNumber) async throws -> Hash {
        let request = APIRequest.getCode(address.address, onBlock)
        return try await APIRequest.sendRequest(with: provider, for: request).result
    }
}

public extension IEth {
    func blockNumber() async throws -> BigUInt {
        try await APIRequest.sendRequest(with: provider, for: .blockNumber).result
    }
}

public extension IEth {
    func block(by hash: Hash) async throws -> Block {
        try await block(by: hash, fullTransactions: false)
    }

    func block(by hash: Hash, fullTransactions: Bool) async throws -> Block {
        let request = APIRequest.getBlockByHash(hash, fullTransactions)
        return try await APIRequest.sendRequest(with: provider, for: request).result
    }

    func block(by number: BlockNumber) async throws -> Block {
        try await block(by: number, fullTransactions: false)
    }

    func block(by number: BlockNumber, fullTransactions: Bool) async throws -> Block {
        let request = APIRequest.getBlockByNumber(number, fullTransactions)
        return try await APIRequest.sendRequest(with: provider, for: request).result
    }

    func block(by hash: Data) async throws -> Block {
        try await block(by: hash, fullTransactions: false)
    }

    func block(by hash: Data, fullTransactions: Bool) async throws -> Block {
        let request: APIRequest = .getBlockByHash(hash.toHexString().addHexPrefix(), fullTransactions)
        return try await APIRequest.sendRequest(with: provider, for: request).result
    }
}

public extension IEth {
    func getBalance(for address: EthereumAddress) async throws -> BigUInt {
        try await getBalance(for: address, onBlock: .latest)
    }

    func getBalance(for address: EthereumAddress, onBlock: BlockNumber) async throws -> BigUInt {
        let request = APIRequest.getBalance(address.address, onBlock)
        return try await APIRequest.sendRequest(with: provider, for: request).result
    }
}

public extension IEth {
    func ownedAccounts() async throws -> [EthereumAddress] {
        if let addresses = provider.attachedKeystoreManager?.addresses {
            return addresses
        }
        return try await APIRequest.sendRequest(with: provider, for: .getAccounts).result
    }
}

public extension IEth {
    func feeHistory(blockCount: BigUInt, block: BlockNumber, percentiles: [Double]) async throws -> Oracle.FeeHistory {
        let request = APIRequest.feeHistory(blockCount, block, percentiles)
        return try await APIRequest.sendRequest(with: provider, for: request).result
    }
}

public extension IEth {
    func send(_ transaction: CodableTransaction) async throws -> TransactionSendingResult {
        let request = APIRequest.sendTransaction(transaction)
        let response: APIResponse<Hash> = try await APIRequest.sendRequest(with: provider, for: request)
        return TransactionSendingResult(transaction: transaction, hash: response.result)
    }

    func send(raw data: Data) async throws -> TransactionSendingResult {
        guard let transaction = CodableTransaction(rawValue: data) else {
            // FIXME: When the PR is merged add this description to dataError ->
            // Description to add:
            // Link to PR:
            throw Web3Error.dataError
        }
        let request = APIRequest.sendRawTransaction(data.toHexString().addHexPrefix())
        let response: APIResponse<Hash> = try await APIRequest.sendRequest(with: provider, for: request)
        return TransactionSendingResult(transaction: transaction, hash: response.result)
    }
}

// MARK: - Supporting models and extensions

public struct TransactionSendingResult {
    public var transaction: CodableTransaction
    public var hash: String
}
