//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import BigInt
import Foundation

extension Web3.Eth {
    public func ownedAccounts() async throws -> [EthereumAddress] {

        guard self.web3.provider.attachedKeystoreManager == nil else {
            return try self.web3.wallet.getAccounts()
        }

        let request = JSONRPCRequestFabric.prepareRequest(.getAccounts, parameters: [])
        let response = try await web3.dispatch(request)

        guard let value: [EthereumAddress] = response.getValue() else {
            throw Web3Error.nodeError(desc: response.error?.message ?? "Invalid value from Ethereum node")
        }
        return value

    }
}
