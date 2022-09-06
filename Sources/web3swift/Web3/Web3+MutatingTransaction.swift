//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import Core

/// Wrapper for `EthererumTransaction.data` property appropriate encoding.
public class WriteTransaction: ReadTransaction {

    // FIXME: Rewrite this to CodableTransaction
    public func send(password: String) async throws -> TransactionSendingResult {
        if let attachedKeystoreManager = self.web3.provider.attachedKeystoreManager {
            do {
                try Web3Signer.signTX(transaction: &transaction,
                                      keystore: attachedKeystoreManager,
                                      account: transaction.from ?? transaction.sender ?? EthereumAddress.contractDeploymentAddress(),
                                      password: password)
            } catch {
                throw Web3Error.inputError(desc: "Failed to locally sign a transaction")
            }
            return try await web3.eth.send(raw: transaction)
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
        case .manual(let nonce):
            return nonce
        }
    }
}
