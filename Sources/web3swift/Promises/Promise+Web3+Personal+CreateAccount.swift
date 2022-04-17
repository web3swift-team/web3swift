//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt

extension web3.Personal {
    public func createAccountPromise(password: String = "web3swift") async throws -> EthereumAddress {

        guard self.web3.provider.attachedKeystoreManager == nil else {
            throw Web3Error.inputError(desc: "Creating account in a local keystore with this method is not supported")
        }

        let request = JSONRPCRequestFabric.prepareRequest(.createAccount, parameters: [password])
        let response = try await self.web3.dispatch(request)

        guard let value: EthereumAddress = response.getValue() else {
            if response.error != nil {
                throw Web3Error.nodeError(desc: response.error!.message)
            }
            throw Web3Error.nodeError(desc: "Invalid value from Ethereum node")
        }
        return value

    }
}
