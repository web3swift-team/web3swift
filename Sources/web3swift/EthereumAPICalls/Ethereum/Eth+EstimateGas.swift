//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import Core


extension web3.Eth {

    // FIXME: Rewrite this to CodableTransaction
    public func estimateGas(for transaction: CodableTransaction, transactionOptions: TransactionOptions?) async throws -> BigUInt {

        // FIXME: Something wrong with this. We should not to get parameters + options in one method.
        let request: APIRequest = .estimateGas(transaction, transactionOptions?.callOnBlock ?? .latest)
        let response: APIResponse<BigUInt> = try await APIRequest.sendRequest(with: provider, for: request)

        if let policy = transactionOptions?.gasLimit {
            switch policy {
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
        } else {
            return response.result
        }
    }
}
