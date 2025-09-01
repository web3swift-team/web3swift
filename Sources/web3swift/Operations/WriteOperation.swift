//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import Web3Core

/// Wrapper for `EthererumTransaction.data` property appropriate encoding.
public class WriteOperation: ReadOperation {

    // FIXME: Rewrite this to CodableTransaction
    /// Sends signed or unsigned transaction for write operation.
    /// - Parameters:
    ///   - password: Password for the private key in the keystore manager attached to the provider
    ///   you set to `web3` passed in the initializer.
    ///   - policies: Determining the behaviour of how transaction attributes like gas limit and
    ///   nonce are resolved. Default value is ``Policies/auto``.
    ///   - sendRaw: If set to `true` transaction will be signed and sent using `eth_sendRawTransaction`.
    ///   Otherwise, no signing attempts will take place and the `eth_sendTransaction` RPC will be used instead.
    ///   Default value is `true`.
    public func writeToChain(password: String,
                             policies: Policies = .auto,
                             sendRaw: Bool = true) async throws -> TransactionSendingResult {
        try await resolvePolicies(policies)

        guard sendRaw else {
            return try await web3.eth.send(transaction)
        }

        try signTransaction(password: password)

        guard let transactionData = transaction.encode(for: .transaction) else {
            throw Web3Error.dataError
        }
        return try await web3.eth.send(raw: transactionData)
    }

    /// Resolves all policy-driven transaction attributes: gas limit, gas price, nonce.
    /// - Parameters:
    ///   - policies: Determining the behaviour of how transaction attributes like gas limit and
    ///   nonce are resolved. Default value is ``Policies/auto``.
    /// - Throws: Rethrows any error that occurs during policy resolution.
    public func resolvePolicies(_ policies: Policies) async throws {
        try await policyResolver.resolveAll(for: &transaction, with: policies)
    }

    /// Signs the transaction locally using the attached keystore manager.
    /// - Parameters:
    ///   - password: Password for the private key in the keystore manager attached to the provider
    ///   you set to `web3` passed in the initializer.
    /// - Throws:
    ///   - ``Web3Error/inputError`` if no keystore is attached to the provider,
    ///     or if signing fails with the provided password.
    @discardableResult
    public func signTransaction(password: String) throws -> CodableTransaction {
        guard let attachedKeystoreManager = web3.provider.attachedKeystoreManager else {
            throw Web3Error.inputError(
                desc: "Failed to locally sign a transaction. Web3 provider doesn't have keystore attached."
            )
        }

        do {
            try Web3Signer.signTX(
                transaction: &transaction,
                keystore: attachedKeystoreManager,
                account: transaction.from ?? transaction.sender ?? EthereumAddress.contractDeploymentAddress(),
                password: password
            )
            return transaction
        } catch {
            throw Web3Error.inputError(
                desc: "Failed to locally sign a transaction. \(error.localizedDescription)"
            )
        }
    }
}
