//
//  Created by Yaroslav Yashin.
//  Copyright © 2022 Yaroslav Yashin. All rights reserved.
//

import Foundation
import BigInt
import Core


extension Web3.Eth {
    public func estimateGas(for transaction: CodableTransaction, onBlock: BlockNumber = .latest) async throws -> BigUInt {
        let request: APIRequest = .estimateGas(transaction, onBlock)
        let response: APIResponse<BigUInt> = try await APIRequest.sendRequest(with: provider, for: request)
        return response.result
    }
}
