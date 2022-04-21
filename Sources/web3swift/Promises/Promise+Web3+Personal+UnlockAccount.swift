//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import BigInt
import Foundation

extension Web3.Personal {
    public func unlock(account: EthereumAddress, password: String = "web3swift", seconds: UInt64 = 300) async throws -> Bool {
        let addr = account.address
        return try await unlock(account: addr, password: password, seconds: seconds)
    }

    public func unlock(account: String, password: String = "web3swift", seconds: UInt64 = 300) async throws -> Bool {

        guard self.web3.provider.attachedKeystoreManager == nil else {
            throw Web3Error.inputError(desc: "Can not unlock a local keystore")
        }

        let request = JSONRPCRequestFabric.prepareRequest(.unlockAccount, parameters: [account.lowercased(), password, seconds])

        let response = try await self.web3.dispatch(request)

        guard let value: Bool = response.getValue() else {
            throw Web3Error.nodeError(desc: response.error?.message ?? "Invalid value from Ethereum node")
        }
        return value

    }
}
