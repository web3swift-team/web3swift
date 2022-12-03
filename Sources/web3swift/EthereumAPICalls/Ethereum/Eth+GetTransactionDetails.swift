//
//  Created by Yaroslav Yashin.
//  Copyright © 2022 Yaroslav Yashin. All rights reserved.
//

import Foundation
import BigInt
import Web3Core

extension Web3.Eth {
    public func transactionDetails(_ txHash: Data) async throws -> TransactionDetails {
        let request = APIRequest.getTransactionByHash(txHash.toHexString().addHexPrefix())
        return try await APIRequest.sendRequest(with: provider, for: request).result
    }
}
