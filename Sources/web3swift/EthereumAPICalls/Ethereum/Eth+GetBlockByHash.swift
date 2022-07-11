//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import Core


extension web3.Eth {
    public func block(by hash: Data, fullTransactions: Bool = false) async throws -> Block {
        try await block(by: hash.toHexString().addHexPrefix(), fullTransactions: fullTransactions)
    }

    public func block(by hash: String, fullTransactions: Bool = false) async throws -> Block {
        let requestCall: APIRequest = .getBlockByHash(hash, fullTransactions)
        let response: APIResponse<Block> = try await APIRequest.sendRequest(with: self.provider, for: requestCall)
        return response.result
    }
}
