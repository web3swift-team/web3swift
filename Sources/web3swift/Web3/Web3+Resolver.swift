//
//  Web3+Resolver.swift
//
//
//  Created by Jann Driessen on 01.11.22.
//

import Foundation
import BigInt
import Web3Core

public class PolicyResolver {
    private let provider: Web3Provider

    public init(provider: Web3Provider) {
        self.provider = provider
    }

    public func resolveAll(for tx: inout CodableTransaction, with policies: Policies = .auto) async throws {
        if tx.from != nil || tx.sender != nil {
            // Nonce should be resolved first - as this might be needed for some
            // tx's gas estimation
            tx.nonce = try await resolveNonce(for: tx, with: policies.noncePolicy)
        } else {
            throw Web3Error.valueError(desc: "Could not be resolved with both from and sender are nil")
        }

        tx.gasLimit = try await resolveGasEstimate(for: tx, with: policies.gasLimitPolicy)

        if case .eip1559 = tx.type {
            tx.maxFeePerGas = await resolveGasBaseFee(for: policies.maxFeePerGasPolicy)
            tx.maxPriorityFeePerGas = await resolveGasPriorityFee(for: policies.maxPriorityFeePerGasPolicy)
        } else {
            tx.gasPrice = await resolveGasPrice(for: policies.gasPricePolicy)
        }
    }

    public func resolveGasBaseFee(for policy: ValueResolutionPolicy) async -> BigUInt {
        switch policy {
        case .automatic:
            return await Oracle(provider).baseFeePercentiles().max() ?? 0
        case .manual(let value):
            return value
        }
    }

    public func resolveGasEstimate(for transaction: CodableTransaction, with policy: ValueResolutionPolicy) async throws -> BigUInt {
        switch policy {
        case .automatic:
            return try await estimateGas(for: transaction)
        case .manual(let value):
            return value
        }
    }

    public func resolveGasPrice(for policy: ValueResolutionPolicy) async -> BigUInt {
        switch policy {
        case .automatic:
            return await Oracle(provider).gasPriceLegacyPercentiles().max() ?? 0
        case .manual(let value):
            return value
        }
    }

    public func resolveGasPriorityFee(for policy: ValueResolutionPolicy) async -> BigUInt {
        switch policy {
        case .automatic:
            return await Oracle(provider).tipFeePercentiles().max() ?? 0
        case .manual(let value):
            return value
        }
    }

    public func resolveNonce(for tx: CodableTransaction, with policy: NoncePolicy) async throws -> BigUInt {
        switch policy {
        case .pending, .latest, .earliest:
            guard let address = tx.from ?? tx.sender else { throw Web3Error.valueError() }
            let request: APIRequest = .getTransactionCount(address.address, tx.callOnBlock ?? .latest)
            let response: APIResponse<BigUInt> = try await APIRequest.sendRequest(with: provider, for: request)
            return response.result
        case .exact(let value):
            return value
        }
    }
}

// MARK: - Private

extension PolicyResolver {
    private func estimateGas(for transaction: CodableTransaction) async throws -> BigUInt {
        let request: APIRequest = .estimateGas(transaction, transaction.callOnBlock ?? .latest)
        let response: APIResponse<BigUInt> = try await APIRequest.sendRequest(with: provider, for: request)
        return response.result
    }
}
