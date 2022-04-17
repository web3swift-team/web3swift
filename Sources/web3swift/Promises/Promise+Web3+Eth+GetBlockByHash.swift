//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt

extension web3.Eth {
    public func block(for hash: Data, fullTransactions: Bool = false) async throws -> Block {
        let hashString = hash.toHexString().addHexPrefix()
        return try await block(for: hashString, fullTransactions: fullTransactions)
    }

    public func block(for hash: String, fullTransactions: Bool = false) async throws -> Block {
        let request = JSONRPCRequestFabric.prepareRequest(.getBlockByHash, parameters: [hash, fullTransactions])
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
