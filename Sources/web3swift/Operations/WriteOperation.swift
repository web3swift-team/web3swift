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
        try await transaction.resolve(provider: web3.provider)
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
    
    public func depploy(password: String) async throws -> TransactionSendingResult {
        //TODO: optimize/cleanup
        try await transaction.resolve(provider: web3.provider)

        guard let attachedKeystoreManager = self.web3.provider.attachedKeystoreManager else {
            throw Web3Error.inputError(desc: "Failed to locally sign a transaction")
        }

        do {
            //TODO: optimize/cleanup
//            transaction.unsign()
            let account = transaction.from ?? transaction.sender ?? EthereumAddress.contractDeploymentAddress()
            var privateKey = try attachedKeystoreManager.UNSAFE_getPrivateKeyData(password: password, account: account)
            defer { Data.zero(&privateKey) }
            try transaction.sign(privateKey: privateKey, useExtraEntropy: false)
        } catch {
            throw Web3Error.inputError(desc: "Failed to locally sign a transaction")
        }

        //TODO: optimize/cleanup
        guard let transactionData = transaction.encode(for: .transaction) else { throw Web3Error.dataError }
//        let vectorHash = transaction.hash!.toHexString().addHexPrefix()
//        print(vectorHash)

        //TODO: optimize/cleanup
        return try await web3.eth.send(raw: transactionData)
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
