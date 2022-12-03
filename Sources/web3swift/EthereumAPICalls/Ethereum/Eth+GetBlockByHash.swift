//
//  Created by Yaroslav Yashin.
//  Copyright © 2022 Yaroslav Yashin. All rights reserved.
//

import Foundation
import BigInt
import Web3Core

extension Web3.Eth {
    public func block(by hash: Data, fullTransactions: Bool = false) async throws -> Block {
        let request: APIRequest = .getBlockByHash(hash.toHexString().addHexPrefix(), fullTransactions)
        return try await APIRequest.sendRequest(with: provider, for: request).result
    }
}
