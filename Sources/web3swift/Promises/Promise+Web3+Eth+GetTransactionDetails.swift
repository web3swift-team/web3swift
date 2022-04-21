//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import BigInt
import Foundation

extension Web3.Eth {
    public func transactionDetails(_ txhash: Data) async throws -> TransactionDetails {
        let hashString = txhash.toHexString().addHexPrefix()
        return try await self.transactionDetails(hashString)
    }

    public func transactionDetails(_ txhash: String) async throws -> TransactionDetails {
        let request = JSONRPCRequestFabric.prepareRequest(.getTransactionByHash, parameters: [txhash])
        let response = try await web3.dispatch(request)

        guard let value: TransactionDetails = response.getValue() else {
            throw Web3Error.nodeError(desc: response.error?.message ?? "Invalid value from Ethereum node")
        }
        return value

    }
}
