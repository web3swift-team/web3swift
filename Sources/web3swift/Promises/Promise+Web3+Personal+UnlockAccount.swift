//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt

extension web3.Personal {
    public func unlockAccountPromise(account: EthereumAddress, password:String = "web3swift", seconds: UInt64 = 300) async throws -> Bool {
            guard self.web3.provider.attachedKeystoreManager == nil else {
                throw Web3Error.inputError(desc: "Can not unlock a local keystore")
            }

            let request = JSONRPCRequestFabric.prepareRequest(.unlockAccount, parameters: [account.address.lowercased(), password, seconds])
            let response = await self.web3.dispatch(request)

            guard let value: Bool = response?.getValue() else {
                throw Web3Error.nodeError(desc: response?.error?.message ?? "Invalid value from Ethereum node")
            }
            return value
        }
}
