//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import BigInt
import Foundation

extension Web3.Eth {
    public func transactionReceipt(_ txhash: Data) async throws -> TransactionReceipt {
        let hashString = txhash.toHexString().addHexPrefix()
        return try await self.transactionReceipt(hashString)
    }

    public func transactionReceipt(_ txhash: String) async throws -> TransactionReceipt {
        let request = JSONRPCRequestFabric.prepareRequest(.getTransactionReceipt, parameters: [txhash])
        let response = try await web3.dispatch(request)

        guard let value: TransactionReceipt = response.getValue() else {
            if response.error != nil {
                throw Web3Error.nodeError(desc: response.error!.message)
            }
            throw Web3Error.nodeError(desc: "Invalid value from Ethereum node")
        }
        return value

    }
}
