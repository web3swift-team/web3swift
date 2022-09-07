//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import Core


extension web3.Eth {

    public func send(_ transaction: CodableTransaction) async throws -> TransactionSendingResult {
        // MARK: Sending Data flow
        let request: APIRequest = .sendTransaction(transaction)
        let response: APIResponse<Hash> = try await APIRequest.sendRequest(with: self.provider, for: request)

        let result = TransactionSendingResult(transaction: transaction, hash: response.result)
        return result
    }
}
