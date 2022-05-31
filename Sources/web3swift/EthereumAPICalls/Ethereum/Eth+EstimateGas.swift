//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt


extension web3.Eth {

    public func estimateGas(for transaction: EthereumTransaction, transactionOptions: TransactionOptions?) async throws -> BigUInt {
        // FIXME: Add appropriate error
        guard let transactionParameters = transaction.encodeAsDictionary(from: transactionOptions?.from) else { throw Web3Error.unknownError }

        let request: APIRequest = .estimateGas(transactionParameters, transactionOptions?.callOnBlock ?? .latest)
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
