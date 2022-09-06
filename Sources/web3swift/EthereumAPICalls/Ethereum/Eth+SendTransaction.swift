//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import Core


extension web3.Eth {

    public func send(_ transaction: CodableTransaction, password: String) async throws -> TransactionSendingResult {
        if let attachedKeystoreManager = self.web3.provider.attachedKeystoreManager {
            var tmpTransaction = transaction
            do {
                try Web3Signer.signTX(transaction: &tmpTransaction,
                                      keystore: attachedKeystoreManager,
                                      account: tmpTransaction.from ?? tmpTransaction.sender ?? EthereumAddress.contractDeploymentAddress(),
                                      password: password)
            } catch {
                throw Web3Error.inputError(desc: "Failed to locally sign a transaction")
            }
            return try await self.web3.eth.send(raw: tmpTransaction.encode(for: .transaction)!)
        }

        // MARK: Sending Data flow
        let request: APIRequest = .sendTransaction(transaction)
        let response: APIResponse<Hash> = try await APIRequest.sendRequest(with: self.provider, for: request)

        let result = TransactionSendingResult(transaction: transaction, hash: response.result)
        return result
    }
}
