//
//  Created by Yaroslav Yashin.
//  Copyright © 2022 Yaroslav Yashin. All rights reserved.
//

import Foundation
import BigInt
import Core

extension Web3.Eth {
    public func transactionReceipt(_ txHash: Data) async throws -> TransactionReceipt {
        try await transactionReceipt(txHash.toHexString().addHexPrefix())
    }

    public func transactionReceipt(_ txHash: String) async throws -> TransactionReceipt {
        try await APIRequest.sendRequest(with: self.provider,
                                         for: .getTransactionReceipt(txHash)).result
    }
}
