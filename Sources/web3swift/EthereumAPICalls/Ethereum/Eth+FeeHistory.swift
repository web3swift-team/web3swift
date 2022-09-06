//
//  Created by Yaroslav Yashin.
//  Copyright © 2022 Yaroslav Yashin. All rights reserved.
//

import Foundation
import BigInt
import Core

extension Web3.Oracle.FeeHistory: APIResultType { }

extension web3.Eth {
    func feeHistory(blockCount: BigUInt, block: BlockNumber, percentiles:[Double]) async throws -> Web3.Oracle.FeeHistory {
        let requestCall: APIRequest = .feeHistory(blockCount, block, percentiles)
        let response: APIResponse<Web3.Oracle.FeeHistory> = try await APIRequest.sendRequest(with: web3.provider, for: requestCall)
        return response.result
    }
}
