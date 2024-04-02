//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import Web3Core

extension Web3.TxPool {
    public func txPoolStatus() async throws -> TxPoolStatus {
        let response: APIResponse<TxPoolStatus> = try await APIRequest.sendRequest(with: provider, for: .getTxPoolStatus)
        return response.result
    }

    public func txPoolContent() async throws -> TxPoolContent {
        let response: APIResponse<TxPoolContent> = try await APIRequest.sendRequest(with: provider, for: .getTxPoolContent)
        return response.result
    }
}
