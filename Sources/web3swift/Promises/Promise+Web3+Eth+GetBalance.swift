//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt

extension web3.Eth {
    public func getBalancePromise(address: EthereumAddress, onBlock: String = "latest") async throws -> BigUInt {
        let addr = address.address
        return try await getBalancePromise(address: addr, onBlock: onBlock)
    }
    public func getBalancePromise(address: String, onBlock: String = "latest") async throws -> BigUInt {
        let request = JSONRPCRequestFabric.prepareRequest(.getBalance, parameters: [address.lowercased(), onBlock])
        let response = await web3.dispatch(request)
        guard let value: BigUInt = response?.getValue() else {
            throw Web3Error.nodeError(desc: response?.error?.message ?? "Invalid value from Ethereum node")
        }
        return value
    }
}
