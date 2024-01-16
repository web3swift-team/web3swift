//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import Web3Core

extension Web3.Web3Wallet {

    /// A list of addresses available in the attached keystore.
    /// - Returns: a list of addresses or an error.
    public func getAccounts() throws -> [EthereumAddress] {
        guard let keystoreManager = self.web3.provider.attachedKeystoreManager else {
            throw Web3Error.walletError(desc: "Missing `attachedKeystoreManager`. Make sure you set up the `Web3Provider` correctly.")
        }
        guard let ethAddresses = keystoreManager.addresses else {
            throw Web3Error.walletError(desc: "Attached keystore is empty. `keystoreManager.addresses` returns `nil`.")
        }
        return ethAddresses
    }

    public func getCoinbase() throws -> EthereumAddress {
        let addresses = try self.getAccounts()
        guard addresses.count > 0 else {
            throw Web3Error.walletError(desc: "Attached keystore is empty. `keystoreManager.addresses` returns an array with length 0.")
        }
        return addresses[0]
    }

    public func signTX(transaction: inout CodableTransaction, account: EthereumAddress, password: String ) throws -> Bool {
        do {
            guard let keystoreManager = self.web3.provider.attachedKeystoreManager else {
                throw Web3Error.walletError(desc: "Missing `attachedKeystoreManager`. Make sure you set up the `Web3Provider` correctly.")
            }
            try Web3Signer.signTX(transaction: &transaction, keystore: keystoreManager, account: account, password: password)
            return true
        } catch {
            if let error = error as? AbstractKeystoreError {
                throw Web3Error.keystoreError(err: error)
            }
            throw Web3Error.generalError(err: error)
        }
    }

    /// Execute `personal_sign` for given arbitrary message.
    /// - Parameters:
    ///   - personalMessage: message. Must be hex formatted: message -> to 'UTF-8 bytes' -> to hex string!
    ///   - account: signer address.
    ///   - password: web3 attached keystore password.
    /// - Returns: signature for the given message or throws an error.
    public func signPersonalMessage(_ personalMessage: String, account: EthereumAddress, password: String ) throws -> Data {
        guard let data = Data.fromHex(personalMessage) else {
            throw Web3Error.dataError(desc: "Given personalMessage must be a valid hex string. Data.fromHex(personalMessage) failed returning `nil`.")
        }
        return try self.signPersonalMessage(data, account: account, password: password)
    }

    public func signPersonalMessage(_ personalMessage: Data, account: EthereumAddress, password: String ) throws -> Data {
        do {
            guard let keystoreManager = self.web3.provider.attachedKeystoreManager else {
                throw Web3Error.walletError(desc: "Missing `attachedKeystoreManager`. Make sure you set up the `Web3Provider` correctly.")
            }
            guard let data = try Web3Signer.signPersonalMessage(personalMessage, keystore: keystoreManager, account: account, password: password) else {
                // FIXME: not so useful description to be honest
                throw Web3Error.walletError(desc: "Returned signature is `nil`. Utilities.hashPersonalMessage or SECP256K1.signForRecovery failed.")
            }
            return data
        } catch {
            if error is AbstractKeystoreError {
                throw Web3Error.keystoreError(err: error as! AbstractKeystoreError)
            }
            throw Web3Error.generalError(err: error)
        }
    }

}
