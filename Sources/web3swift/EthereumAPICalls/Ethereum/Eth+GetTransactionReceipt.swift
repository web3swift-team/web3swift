//
//  Created by Yaroslav Yashin.
//  Copyright © 2022 Yaroslav Yashin. All rights reserved.
//

import Foundation
import BigInt
import Core

extension Web3.Eth {
    public func transactionReceipt(_ txhash: Data) async throws -> TransactionReceipt {
        guard let hexString = String(data: txhash, encoding: .utf8)?.addHexPrefix() else { throw Web3Error.dataError }
        let requestCall: APIRequest = .getTransactionReceipt(hexString)
        let response: APIResponse<TransactionReceipt> = try await APIRequest.sendRequest(with: self.provider, for: requestCall)
        return response.result
    }
}
