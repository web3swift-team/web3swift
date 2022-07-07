//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation


extension web3.Eth {

    public func callTransaction(_ transaction: EthereumTransaction, transactionOptions: TransactionOptions?) async throws -> Data {
        guard let transactionParameters = transaction.encodeAsDictionary(from: transactionOptions?.from) else { throw Web3Error.dataError}
        let request: APIRequest = .call(transactionParameters, transactionOptions?.callOnBlock ?? .latest)
        let response: APIResponse<Data> = try await APIRequest.sendRequest(with: self.provider, for: request)
        return response.result
    }
}
