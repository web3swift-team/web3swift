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
    /// Sends raw transaction for write operation.
    /// - Parameters:
    ///   - password: Password for private key.
    ///   - policies: Custom policies for how to resolve (optional). Default is auto.
    public func writeToChain(password: String, policies: Policies = .auto) async throws -> TransactionSendingResult {
        try await policyResolver.resolveAll(for: &transaction, with: policies)
        if let attachedKeystoreManager = self.web3.provider.attachedKeystoreManager {
            do {
                try Web3Signer.signTX(transaction: &transaction,
                                      keystore: attachedKeystoreManager,
                                      account: transaction.from ?? transaction.sender ?? EthereumAddress.contractDeploymentAddress(),
                                      password: password)
            } catch {
                throw Web3Error.inputError(desc: "Failed to locally sign a transaction")
            }
            guard let transactionData = transaction.encode(for: .transaction) else { throw Web3Error.dataError }
            return try await web3.eth.send(raw: transactionData)
        }
        // MARK: Sending Data flow
        return try await web3.eth.send(transaction)
    }
}
