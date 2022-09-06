//
//  Created by Yaroslav Yashin.
//  Copyright © 2022 Yaroslav Yashin. All rights reserved.
//

import Foundation
import Core


extension web3.Eth {
    public func callTransaction(_ transaction: CodableTransaction) async throws -> Data {
        let request: APIRequest = .call(transaction, transaction.callOnBlock ?? .latest)
        let response: APIResponse<Data> = try await APIRequest.sendRequest(with: self.provider, for: request)
        return response.result
    }
}
