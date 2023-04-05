//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import Web3Core

extension Web3.Personal {
    public func unlock(account: EthereumAddress, password: String, seconds: UInt = 300) async throws -> Bool {
        try await unlock(account: account.address, password: password, seconds: seconds)
    }

    public func unlock(account: Address, password: String, seconds: UInt = 300) async throws -> Bool {
        guard self.web3.provider.attachedKeystoreManager == nil else {
            throw Web3Error.inputError(desc: "Can not unlock a local keystore")
        }

        let requestCall: APIRequest = .unlockAccount(account, password, seconds)
        let response: APIResponse<Bool> = try await APIRequest.sendRequest(with: self.provider, for: requestCall)
        return response.result
    }
}

extension Bool: APIResultType { }
