//
//  Created by Yaroslav Yashin.
//  Copyright © 2022 Yaroslav Yashin. All rights reserved.
//

import Foundation
import BigInt
import Web3Core

extension Web3.Eth {
    public func ownedAccounts() async throws -> [EthereumAddress] {
        guard web3.provider.attachedKeystoreManager == nil else {
            return try web3.wallet.getAccounts()
        }
        return try await APIRequest.sendRequest(with: web3.provider, for: .getAccounts).result
    }
}
