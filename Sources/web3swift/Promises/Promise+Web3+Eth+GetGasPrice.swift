//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt

extension web3.Eth {
    public func gasPrice() async throws -> BigUInt {
        let request = JSONRPCRequestFabric.prepareRequest(.gasPrice, parameters: [])
        let response = try await web3.dispatch(request)

        guard let value: BigUInt = response.getValue() else {
            if response.error != nil {
                throw Web3Error.nodeError(desc: response.error!.message)
            }
            throw Web3Error.nodeError(desc: "Invalid value from Ethereum node")
        }
        return value

    }
}
