//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt

extension web3.Eth {
    public func getAccountsPromise() async throws -> [EthereumAddress] {
        if web3.provider.attachedKeystoreManager != nil {
                return try self.web3.wallet.getAccounts()
        }


        let request = JSONRPCRequestFabric.prepareRequest(.getAccounts, parameters: [])
        let response = await web3.dispatch(request)

        guard let value: [EthereumAddress] = response?.getValue() else {
            if let responseError = response?.error {
                throw Web3Error.nodeError(desc: responseError.message)
            }
            throw Web3Error.nodeError(desc: "Invalid value from Ethereum node")
        }
        return value
    }
}
