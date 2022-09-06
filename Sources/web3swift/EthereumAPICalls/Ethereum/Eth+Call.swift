//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import Core


extension web3.Eth {

    // FIXME: Rewrite this to CodableTransaction
    // FIXME: Not working yet.
    public func callTransaction(_ transaction: CodableTransaction) async throws -> Data {
        // FIXME: Make me CodableTransaction
        let request: APIRequest = .call(transaction, transaction.callOnBlock ?? .latest)
        let response: APIResponse<Data> = try await APIRequest.sendRequest(with: self.provider, for: request)
        return response.result
    }
}
