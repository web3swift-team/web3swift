//
//  Created by Yaroslav Yashin.
//  Copyright © 2022 Yaroslav Yashin. All rights reserved.
//

import Foundation
import BigInt
import Core

extension web3.Eth {
    public func transactionDetails(_ txhash: Data) async throws -> TransactionDetails {
        let requestCall: APIRequest = .getTransactionByHash(txhash.toHexString().addHexPrefix())
        let response: APIResponse<TransactionDetails> = try await APIRequest.sendRequest(with: self.provider, for: requestCall)
        return response.result
    }
}
