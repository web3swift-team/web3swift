//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import Core


extension web3.Eth {

    // FIXME: Rewrite this to EthereumTransaction
    // FIXME: Not working yet.
    public func callTransaction(_ transaction: EthereumTransaction, transactionOptions: TransactionOptions?) async throws -> Data {
        // MARK: Read data from ABI flow
        guard let transactionParameters = transaction.encodeAsDictionary(from: transactionOptions?.from) else { throw Web3Error.dataError}
        let request: APIRequest = .call(transactionParameters, transactionOptions?.callOnBlock ?? .latest)
        let response: APIResponse<Data> = try await APIRequest.sendRequest(with: self.provider, for: request)
        return response.result
    }
}
