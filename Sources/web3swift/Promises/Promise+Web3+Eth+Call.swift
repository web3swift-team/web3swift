//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation

extension Web3.Eth {

    public func callTransaction(_ transaction: EthereumTransaction, transactionOptions: TransactionOptions?) async throws -> Data {
        guard let request = EthereumTransaction.createRequest(method: .call, transaction: transaction, transactionOptions: transactionOptions) else {
            throw Web3Error.processingError(desc: "Transaction is invalid")
        }
        let response = try await web3.dispatch(request)

        guard let value: Data = response.getValue() else {
            throw Web3Error.nodeError(desc: response.error?.message ?? "Invalid value from Ethereum node")
        }
        return value
    }
}
