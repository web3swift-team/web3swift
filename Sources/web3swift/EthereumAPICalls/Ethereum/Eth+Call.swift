//
//  Created by Yaroslav Yashin.
//  Copyright © 2022 Yaroslav Yashin. All rights reserved.
//

import Foundation
import Web3Core

extension Web3.Eth {
    public func callTransaction(_ transaction: CodableTransaction) async throws -> Data {
        let request = APIRequest.call(transaction, transaction.callOnBlock ?? .latest)
        return try await APIRequest.sendRequest(with: provider, for: request).result
    }
}
