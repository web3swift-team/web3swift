//
//  Created by Yaroslav Yashin.
//  Copyright © 2022 Yaroslav Yashin. All rights reserved.
//

import Foundation
import BigInt
import Core

extension Web3.Eth {
    public func transactionDetails(_ txHash: Data) async throws -> TransactionDetails {
        try await transactionDetails(txHash.toHexString().addHexPrefix())
    }

    public func transactionDetails(_ txHash: String) async throws -> TransactionDetails {
        try await APIRequest.sendRequest(with: self.provider, for: .getTransactionByHash(txHash)).result
    }
}
