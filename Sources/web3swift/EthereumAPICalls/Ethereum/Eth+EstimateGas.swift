//
//  Created by Yaroslav Yashin.
//  Copyright © 2022 Yaroslav Yashin. All rights reserved.
//

import Foundation
import BigInt
import Core


extension web3.Eth {
    public func estimateGas(for transaction: CodableTransaction, onBlock: BlockNumber = .latest) async throws -> BigUInt {
        let request: APIRequest = .estimateGas(transaction, onBlock)
        let response: APIResponse<BigUInt> = try await APIRequest.sendRequest(with: provider, for: request)
        
        switch transaction.gasLimitPolicy {
        case .automatic:
            return response.result
        case .limited(let limitValue):
            return limitValue < response.result ? limitValue: response.result
        case .manual(let exactValue):
            return exactValue
        case .withMargin:
            // MARK: - update value according margin
            return response.result
        }
    }
}
