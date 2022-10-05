//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import Core


extension Web3.Eth {
    public func send(_ transaction: CodableTransaction) async throws -> TransactionSendingResult {
        let request: APIRequest = .sendTransaction(transaction)
        let response: APIResponse<Hash> = try await APIRequest.sendRequest(with: self.provider, for: request)
        return TransactionSendingResult(transaction: transaction, hash: response.result)
    }
}
