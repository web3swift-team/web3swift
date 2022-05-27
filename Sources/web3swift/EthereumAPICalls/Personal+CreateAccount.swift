//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt


extension web3.Personal {
    public func createAccount(password: String = "web3swift") async throws -> EthereumAddress {
        guard self.web3.provider.attachedKeystoreManager == nil else {
            throw Web3Error.inputError(desc: "Creating account in a local keystore with this method is not supported")
        }

        let requestCall: APIRequest = .createAccount(password)
        let response: APIResponse<EthereumAddress> = try await APIRequest.sendRequest(with: self.provider, for: requestCall)
        return response.result
    }
}
