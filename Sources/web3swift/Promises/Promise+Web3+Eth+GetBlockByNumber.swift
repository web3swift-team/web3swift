//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt

extension web3.Eth {
    public func getBlockByNumberPromise(_ number: UInt64, fullTransactions: Bool = false) async throws -> Block {
        let block = String(number, radix: 16).addHexPrefix()
        return try await getBlockByNumberPromise(block, fullTransactions: fullTransactions)
    }

    public func getBlockByNumberPromise(_ number: BigUInt, fullTransactions: Bool = false) async throws -> Block {
        let block = String(number, radix: 16).addHexPrefix()
        return try await getBlockByNumberPromise(block, fullTransactions: fullTransactions)
    }

    public func getBlockByNumberPromise(_ number: String, fullTransactions: Bool = false) async throws -> Block {
        let request = JSONRPCRequestFabric.prepareRequest(.getBlockByNumber, parameters: [number, fullTransactions])
        let response = try await web3.dispatch(request)

        guard let value: Block = response.getValue() else {
            if response.error != nil {
                throw Web3Error.nodeError(desc: response.error!.message)
            }
            throw Web3Error.nodeError(desc: "Invalid value from Ethereum node")
        }
        return value

    }
}
