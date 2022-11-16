//
//  Created by Yaroslav Yashin.
//  Copyright © 2022 Yaroslav Yashin. All rights reserved.
//

import Foundation
import BigInt
import Core

extension Web3.Eth {
    public func block(by hash: Data, fullTransactions: Bool = false) async throws -> Block {
        let requestCall: APIRequest = .getBlockByHash(hash.toHexString().addHexPrefix(), fullTransactions)
        return try await APIRequest.sendRequest(with: self.provider, for: requestCall).result
    }
}
