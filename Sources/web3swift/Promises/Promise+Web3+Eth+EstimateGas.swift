//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt

extension web3.Eth {

    public func estimateGas(for transaction: EthereumTransaction, transactionOptions: TransactionOptions?) async throws -> BigUInt {

        guard let request = EthereumTransaction.createRequest(method: .estimateGas, transaction: transaction, transactionOptions: transactionOptions) else {
            throw Web3Error.processingError(desc: "Transaction is invalid")
        }
        let response = try await web3.dispatch(request)

        guard let value: BigUInt = response.getValue() else {
            if response.error != nil {
                throw Web3Error.nodeError(desc: response.error!.message)
            }
            throw Web3Error.nodeError(desc: "Invalid value from Ethereum node")
        }

        if let policy = transactionOptions?.gasLimit {
            switch policy {
            case .automatic:
                return value
            case .limited(let limitValue):
                return limitValue < value ? limitValue: value
            case .manual(let exactValue):
                return exactValue
            case .withMargin:
                // MARK: - update value according margin
                return value
            }
        } else {
            return value
        }

    }
}
