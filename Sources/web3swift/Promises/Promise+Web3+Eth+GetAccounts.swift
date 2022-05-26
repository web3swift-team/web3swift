//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt

extension web3.Eth {
    public func ownedAccounts() async throws -> [EthereumAddress] {
        guard self.web3.provider.attachedKeystoreManager == nil else {
            return try self.web3.wallet.getAccounts()
        }

        let requestCall: APIRequest = .getAccounts

        let response: APIResponse<[EthereumAddress]> = try await APIRequest.sendRequest(with: web3.provider, for: requestCall)

        return response.result
    }
}
