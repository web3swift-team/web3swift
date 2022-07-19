//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import Core

extension TransactionDetails: APIResultType { }

extension web3.Eth {
    public func transactionDetails(_ txhash: Data) async throws -> TransactionDetails {
        try await self.transactionDetails(txhash.toHexString().addHexPrefix())
    }

    public func transactionDetails(_ txhash: Hash) async throws -> TransactionDetails {
        let requestCall: APIRequest = .getTransactionByHash(txhash)
        let response: APIResponse<TransactionDetails> = try await APIRequest.sendRequest(with: self.provider, for: requestCall)
        return response.result
    }
}
