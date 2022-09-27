//
//  Created by Yaroslav Yashin.
//  Copyright © 2022 Yaroslav Yashin. All rights reserved.
//

import Foundation
import BigInt
import Core


extension Web3.Eth {
    public func block(by hash: Data, fullTransactions: Bool = false) async throws -> Block {
        guard let hexString = String(data: hash, encoding: .utf8)?.addHexPrefix() else { throw Web3Error.dataError }
        let requestCall: APIRequest = .getBlockByHash(hash.toHexString().addHexPrefix(), fullTransactions)
        let response: APIResponse<Block> = try await APIRequest.sendRequest(with: self.provider, for: requestCall)
        return response.result
    }
}
