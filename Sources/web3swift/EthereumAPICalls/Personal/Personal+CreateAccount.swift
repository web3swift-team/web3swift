//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import Core

extension Web3.Personal {
    public func createAccount(password: String ) async throws -> EthereumAddress {
        guard self.eth.provider.keystoreManager == nil else {
            throw Web3Error.inputError(desc: "Creating account in a local keystore with this method is not supported")
        }

        let requestCall: APIRequest = .createAccount(password)
        let response: APIResponse<EthereumAddress> = try await APIRequest.sendRequest(with: self.provider, for: requestCall)
        return response.result
    }
}
