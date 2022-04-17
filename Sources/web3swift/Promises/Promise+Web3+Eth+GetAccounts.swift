//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt

extension web3.Eth {
    public func getAccountsPromise() async throws -> [EthereumAddress] {

        guard self.web3.provider.attachedKeystoreManager == nil else {
            return try self.web3.wallet.getAccounts()
        }

        let request = JSONRPCRequestFabric.prepareRequest(.getAccounts, parameters: [])
        let response = try await web3.dispatch(request)

        guard let value: [EthereumAddress] = response.getValue() else {
            if response.error != nil {
                throw Web3Error.nodeError(desc: response.error!.message)
            }
            throw Web3Error.nodeError(desc: "Invalid value from Ethereum node")
        }
        return value

    }
}
