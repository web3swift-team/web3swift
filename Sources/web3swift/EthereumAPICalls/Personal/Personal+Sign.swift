//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import Web3Core

extension Web3.Personal {

    public func signPersonal(message: Data, from: EthereumAddress, password: String) async throws -> Data {
        guard let attachedKeystoreManager = self.web3.provider.attachedKeystoreManager else {
            let hexData = message.toHexString().addHexPrefix()
            let request: APIRequest = .personalSign(from.address.lowercased(), hexData)
            let response: APIResponse<Data> = try await APIRequest.sendRequest(with: provider, for: request)
            return response.result
        }

        guard let signature = try Web3Signer.signPersonalMessage(message, keystore: attachedKeystoreManager, account: from, password: password) else {
            throw Web3Error.inputError(desc: "Failed to locally sign a message")
        }

        return signature
    }
}
