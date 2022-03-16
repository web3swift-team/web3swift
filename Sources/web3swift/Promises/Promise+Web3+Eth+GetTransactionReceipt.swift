//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt

extension web3.Eth {
    public func getTransactionReceiptPromise(_ txhash: Data) async throws -> TransactionReceipt {
        let hashString = txhash.toHexString().addHexPrefix()
        return try await self.getTransactionReceiptPromise(hashString)
    }

    public func getTransactionReceiptPromise(_ txhash: String) async throws -> TransactionReceipt {
        let request = JSONRPCRequestFabric.prepareRequest(.getTransactionReceipt, parameters: [txhash])
        
        let response = await web3.dispatch(request)
        guard let value: TransactionReceipt = response?.getValue() else {
            throw Web3Error.nodeError(desc: response?.error?.message ?? "Invalid value from Ethereum node")
        }
        return value
    }
}
