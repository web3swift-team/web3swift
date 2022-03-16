//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt

extension web3.Eth {
    public func getTransactionDetailsPromise(_ txhash: Data) async throws -> TransactionDetails {
        let hashString = txhash.toHexString().addHexPrefix()
        return try await self.getTransactionDetailsPromise(hashString)
    }

    public func getTransactionDetailsPromise(_ txhash: String) async throws -> TransactionDetails {
        let request = JSONRPCRequestFabric.prepareRequest(.getTransactionByHash, parameters: [txhash])
        let response = await web3.dispatch(request)
        guard let value: TransactionDetails = response?.getValue() else {
            throw Web3Error.nodeError(desc: response?.error?.message ?? "Invalid value from Ethereum node")
        }
        return value
    }
}
