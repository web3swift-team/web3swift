//
//  Created by Yaroslav Yashin.
//  Copyright © 2022 Yaroslav Yashin. All rights reserved.
//

import Foundation
import BigInt
import Core

extension Web3.Eth {
    public func ownedAccounts() async throws -> [EthereumAddress] {
        guard self.web3.provider.attachedKeystoreManager == nil else {
            return try self.web3.wallet.getAccounts()
        }
        let response: APIResponse<[EthereumAddress]> = try await APIRequest.sendRequest(with: web3.provider, for: .getAccounts)
        return response.result
    }
}
