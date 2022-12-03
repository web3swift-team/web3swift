//
//  Created by Yaroslav Yashin.
//  Copyright © 2022 Yaroslav Yashin. All rights reserved.
//

import Foundation
import BigInt
import Web3Core

extension Web3.Eth {
    func feeHistory(blockCount: BigUInt, block: BlockNumber, percentiles: [Double]) async throws -> Oracle.FeeHistory {
        let request = APIRequest.feeHistory(blockCount, block, percentiles)
        return try await APIRequest.sendRequest(with: web3.provider, for: request).result
    }
}
