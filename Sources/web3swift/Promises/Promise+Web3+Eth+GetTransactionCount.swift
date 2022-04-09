//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt


extension web3.Eth {
    public func getTransactionCountPromise(address: EthereumAddress, onBlock: String = "latest") async throws -> BigUInt {
        let addr = address.address
        return try await getTransactionCountPromise(address: addr, onBlock: onBlock)
    }

    public func getTransactionCountPromise(address: String, onBlock: String = "latest") async throws -> BigUInt {
        let request = JSONRPCRequestFabric.prepareRequest(.getTransactionCount, parameters: [address.lowercased(), onBlock])
        let response = try await web3.dispatch(request)
        let queue = web3.requestDispatcher.queue

        guard let value: BigUInt = response.getValue() else {
            if response.error != nil {
                throw Web3Error.nodeError(desc: response.error!.message)
            }
            throw Web3Error.nodeError(desc: "Invalid value from Ethereum node")
        }
        return value
    }
}
