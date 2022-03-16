//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt

extension web3.Personal {

    public func signPersonalMessagePromise(message: Data, from: EthereumAddress, password:String = "web3swift") async throws -> Data {
            guard let KeystoreManager = self.web3.provider.attachedKeystoreManager else {
                let hexData = message.toHexString().addHexPrefix()
                let request = JSONRPCRequestFabric.prepareRequest(.personalSign, parameters: [from.address.lowercased(), hexData])

                let response = await self.web3.dispatch(request)
                guard let value: Data = response?.getValue() else {
                    throw Web3Error.nodeError(desc: response?.error?.message ?? "Invalid value from Ethereum node")
                }
                return value
            }

            guard let signature = try Web3Signer.signPersonalMessage(message, keystore: KeystoreManager, account: from, password: password) else { throw Web3Error.inputError(desc: "Failed to locally sign a message") }
            return signature
    }
}
