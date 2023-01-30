//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import Web3Core

extension Web3.Personal {

    /**
     *Locally or remotely sign a message (arbitrary data) with the private key. To avoid potential signing of a transaction the message is first prepended by a special header and then hashed.*

     - parameters:
         - message: Message Data
         - from: Use a private key that corresponds to this account
         - password: Password for account if signing locally

     - returns:
        - Result object

     - important: This call is synchronous

     */
    public func signPersonalMessage(message: Data, from: EthereumAddress, password: String) async throws -> Data {
        let result = try await self.signPersonal(message: message, from: from, password: password)
        return result
    }

    /**
     *Unlock an account on the remote node to be able to send transactions and sign messages.*

     - parameters:
         - account: EthereumAddress of the account to unlock
         - password: Password to use for the account
         - seconds: Time interval before automatic account lock by Ethereum node

     - returns:
        - Result object

     - important: This call is synchronous. Does nothing if private keys are stored locally.

     */
    public func unlockAccount(account: EthereumAddress, password: String, seconds: UInt = 300) async throws -> Bool {
        let result = try await self.unlock(account: account, password: password)
        return result
    }

    /**
     *Recovers a signer of some message. Message is first prepended by special prefix (check the "signPersonalMessage" method description) and then hashed.*

     - parameters:
         - personalMessage: Message Data
         - signature: Serialized signature, 65 bytes

     - returns:
        - Result object

     */
    public func ecrecover(personalMessage: Data, signature: Data) throws -> EthereumAddress {
        guard let recovered = Utilities.personalECRecover(personalMessage, signature: signature) else {
            throw Web3Error.dataError
        }
        return recovered
    }

    /**
     *Recovers a signer of some hash. Checking what is under this hash is on behalf of the user.*

     - parameters:
        - hash: Signed hash
        - signature: Serialized signature, 65 bytes

     - returns:
        - Result object

     */
    public func ecrecover(hash: Data, signature: Data) throws -> EthereumAddress {
        guard let recovered = Utilities.hashECRecover(hash: hash, signature: signature) else {
            throw Web3Error.dataError
        }
        return recovered
    }
}
