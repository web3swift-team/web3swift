//
//  Created by Yaroslav Yashin.
//  Copyright © 2022 Yaroslav Yashin. All rights reserved.
//

import Foundation
import BigInt
import Core

extension web3.Eth {
    public func transactionReceipt(_ txhash: Data) async throws -> TransactionReceipt {
        let requestCall: APIRequest = .getTransactionReceipt(txhash.toHexString().addHexPrefix())
        let response: APIResponse<TransactionReceipt> = try await APIRequest.sendRequest(with: self.provider, for: requestCall)
        return response.result
    }
}
