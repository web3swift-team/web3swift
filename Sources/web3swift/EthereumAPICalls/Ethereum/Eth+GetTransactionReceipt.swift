//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import Core

extension TransactionReceipt: APIResultType { }

extension web3.Eth {
    public func transactionReceipt(_ txhash: Data) async throws -> TransactionReceipt {
        try await self.transactionReceipt(txhash.toHexString().addHexPrefix())
    }

    public func transactionReceipt(_ txhash: Hash) async throws -> TransactionReceipt {
        let requestCall: APIRequest = .getTransactionReceipt(txhash)
        let response: APIResponse<TransactionReceipt> = try await APIRequest.sendRequest(with: self.provider, for: requestCall)
        return response.result
    }
}
