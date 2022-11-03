//
//  Created by Yaroslav Yashin.
//  Copyright © 2022 Yaroslav Yashin. All rights reserved.
//

import Foundation
import BigInt
import Core


extension Web3.Eth {
    public func block(by hash: Hash, fullTransactions: Bool = false) async throws -> Block {
        let request = APIRequest.getBlockByHash(hash, fullTransactions)
        return try await APIRequest.sendRequest(with: provider, for: request).result
    }

    public func block(by number: BlockNumber, fullTransactions: Bool = false) async throws -> Block {
        let request = APIRequest.getBlockByNumber(number, fullTransactions)
        return try await APIRequest.sendRequest(with: provider, for: request).result
    }
}
