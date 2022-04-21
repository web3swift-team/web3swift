//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import BigInt
import Foundation

extension Web3.Eth {
    public func blockBy(number: UInt64, fullTransactions: Bool = false) async throws -> Block {
        let block = String(number, radix: 16).addHexPrefix()
        return try await blockBy(number: block, fullTransactions: fullTransactions)
    }

    public func blockBy(number: BigUInt, fullTransactions: Bool = false) async throws -> Block {
        let block = String(number, radix: 16).addHexPrefix()
        return try await blockBy(number: block, fullTransactions: fullTransactions)
    }

    public func blockBy(number: String, fullTransactions: Bool = false) async throws -> Block {
        let request = JSONRPCRequestFabric.prepareRequest(.getBlockByNumber, parameters: [number, fullTransactions])
        let response = try await web3.dispatch(request)

        guard let value: Block = response.getValue() else {
            throw Web3Error.nodeError(desc: response.error?.message ?? "Invalid value from Ethereum node")
        }
        return value

    }
}
