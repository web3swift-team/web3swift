//
//  Created by Yaroslav Yashin.
//  Copyright © 2022 Yaroslav Yashin. All rights reserved.
//

import Foundation
import BigInt
import Core

extension web3.Eth {
    func feeHistory(blockCount: BigUInt, block: BlockNumber, percentiles:[Double]) async throws -> Oracle.FeeHistory {
        let requestCall: APIRequest = .feeHistory(blockCount, block, percentiles)
        let response: APIResponse<Oracle.FeeHistory> = try await APIRequest.sendRequest(with: web3.provider, for: requestCall)
        return response.result
    }
}
