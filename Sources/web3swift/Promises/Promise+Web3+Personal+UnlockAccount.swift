//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt


extension web3.Personal {
    public func unlock(account: EthereumAddress, password: String = "web3swift", seconds: UInt = 300) async throws -> Bool {
        let addr = account.address
        return try await unlock(account: addr, password: password, seconds: seconds)
    }

    public func unlock(account: String, password: String = "web3swift", seconds: UInt = 300) async throws -> Bool {

        guard self.web3.provider.attachedKeystoreManager == nil else {
            throw Web3Error.inputError(desc: "Can not unlock a local keystore")
        }

        let parameters: [APIRequestParameterType] = [account.lowercased(), password, seconds]

        let request = JSONRPCRequestFabric.prepareRequest(.unlockAccount, parameters: parameters)

        let response = try await self.web3.dispatch(request)

        guard let value: Bool = response.getValue() else {
            if response.error != nil {
                throw Web3Error.nodeError(desc: response.error!.message)
            }
            throw Web3Error.nodeError(desc: "Invalid value from Ethereum node")
        }
        return value

    }
}
