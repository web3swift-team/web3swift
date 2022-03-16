//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt

extension web3.Web3Wallet {
    
    public func getAccounts() throws -> [EthereumAddress] {
        guard let keystoreManager = self.web3.provider.attachedKeystoreManager else {
            throw Web3Error.walletError
        }
        guard let ethAddresses = keystoreManager.addresses else {
            throw Web3Error.walletError
        }
        return ethAddresses
    }
    
    public func getCoinbase() throws -> EthereumAddress {
        guard let address = try self.getAccounts().first else {
            throw Web3Error.walletError
        }
        return address
    }

    public func signTX(transaction:inout EthereumTransaction, account: EthereumAddress, password: String = "web3swift") throws -> Bool {
        do {
            guard let keystoreManager = self.web3.provider.attachedKeystoreManager else {
                throw Web3Error.walletError
            }
            try Web3Signer.signTX(transaction: &transaction, keystore: keystoreManager, account: account, password: password)
            return true
        } catch {
            if let absError = error as? AbstractKeystoreError {
                throw Web3Error.keystoreError(err: absError)
            } else {
                throw Web3Error.generalError(err: error)
            }
        }
    }

    public func signPersonalMessage(_ personalMessage: String, account: EthereumAddress, password: String = "web3swift") throws -> Data {
        guard let data = Data.fromHex(personalMessage) else
        {
            throw Web3Error.dataError
        }
        return try self.signPersonalMessage(data, account: account, password: password)
    }

    public func signPersonalMessage(_ personalMessage: Data, account: EthereumAddress, password: String = "web3swift") throws -> Data {
        do {
            guard let keystoreManager = self.web3.provider.attachedKeystoreManager else
            {
                throw Web3Error.walletError
            }
            guard let data = try Web3Signer.signPersonalMessage(personalMessage, keystore: keystoreManager, account: account, password: password) else {
                throw Web3Error.walletError
            }
            return data
        }
        catch{
            if let absError = error as? AbstractKeystoreError {
                throw Web3Error.keystoreError(err: absError)
            } else {
                throw Web3Error.generalError(err: error)
            }
        }
    }

}
