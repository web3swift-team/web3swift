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
    public func writeToChain(password: String, policies: Policies = .auto, sendRaw: Bool = true) async throws -> TransactionSendingResult {
        try await policyResolver.resolveAll(for: &transaction, with: policies)

        guard sendRaw else {
            return try await web3.eth.send(transaction)
        }

        guard let attachedKeystoreManager = web3.provider.attachedKeystoreManager else {
            throw Web3Error.inputError(desc: "Failed to locally sign a transaction. Web3 provider doesn't have keystore attached.")
        }

        do {
            try Web3Signer.signTX(transaction: &transaction,
                                  keystore: attachedKeystoreManager,
                                  account: transaction.from ?? transaction.sender ?? EthereumAddress.contractDeploymentAddress(),
                                  password: password)
        } catch {
            throw Web3Error.inputError(desc: "Failed to locally sign a transaction. \(error.localizedDescription)")
        }
        guard let transactionData = transaction.encode(for: .transaction) else { throw Web3Error.dataError }
        return try await web3.eth.send(raw: transactionData)
    }
}
