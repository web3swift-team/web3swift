//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import Core

/// Wrapper for `EthererumTransaction.data` property appropriate encoding.
public class WriteOperation: ReadOperation {

    // FIXME: Rewrite this to CodableTransaction
    public func writeToChain(password: String) async throws -> TransactionSendingResult {
        // TODO: might change to be dependency
        let resolver = PolicyResolver(provider: web3.provider)
        try await resolver.resolveAll(for: &transaction)
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

    // FIXME: Rewrite this to CodableTransaction
    func nonce(for policy: CodableTransaction.NoncePolicy, from: EthereumAddress) async throws -> BigUInt {
        switch policy {
        case .latest:
            return try await self.web3.eth.getTransactionCount(for: from, onBlock: .latest)
        case .pending:
            return try await self.web3.eth.getTransactionCount(for: from, onBlock: .pending)
        case .earliest:
            return try await self.web3.eth.getTransactionCount(for: from, onBlock: .earliest)
        case .exact(let nonce):
            return nonce
        }
    }
}
