//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt

extension web3.Eth {
    public func getBlockNumberPromise() async throws -> BigUInt {
        let request = JSONRPCRequestFabric.prepareRequest(.blockNumber, parameters: [])
        let response = await web3.dispatch(request)
        guard let value: BigUInt = response?.getValue() else {
            throw Web3Error.nodeError(desc: response?.error?.message ?? "Invalid value from Ethereum node")
        }
        return value
    }
}
