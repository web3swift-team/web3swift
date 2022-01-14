//
//  Promise+Web3+Wallet.swift
//  
//
//  Created by Ostap Danylovych on 13.01.2022.
//

import Foundation
import PromiseKit

extension web3.Web3Wallet {
    public func getAccountsPromise() -> Promise<[EthereumAddress]> {
        guard let signer = self.web3.signer else {
            return Promise(error: Web3Error.walletError)
        }
        return signer.accounts(on: web3.requestDispatcher.queue)
    }
    
    public func getCoinbasePromise() -> Promise<EthereumAddress> {
        self.getAccountsPromise().map { accounts in
            guard accounts.count > 0 else {
                throw Web3Error.walletError
            }
            return accounts[0]
        }
    }
    
    public func signTXPromise(transaction: EthereumTransaction, account: EthereumAddress, password: String = "web3swift") throws -> Promise<EthereumTransaction> {
        guard let signer = self.web3.signer else {
            return Promise(error: Web3Error.walletError)
        }
        let queue = web3.requestDispatcher.queue
        let signedPromise = signer.sign(transaction: transaction, with: account, using: password, on: queue)
        return signedPromise.recover(on: queue) { error -> Promise<EthereumTransaction> in
            if error is AbstractKeystoreError {
                throw Web3Error.keystoreError(err: error as! AbstractKeystoreError)
            }
            throw Web3Error.generalError(err: error)
        }
    }
    
    public func signPersonalMessagePromise(_ personalMessage: String, account: EthereumAddress, password: String = "web3swift") -> Promise<Data> {
        guard let data = Data.fromHex(personalMessage) else {
            return Promise(error: Web3Error.dataError)
        }
        return self.signPersonalMessagePromise(data, account: account, password: password)
    }
    
    public func signPersonalMessagePromise(_ personalMessage: Data, account: EthereumAddress, password: String = "web3swift") -> Promise<Data> {
        guard let signer = self.web3.signer else {
            return Promise(error: Web3Error.walletError)
        }
        let queue = web3.requestDispatcher.queue
        let signedPromise = signer.sign(message: personalMessage, with: account, using: password, on: queue)
        return signedPromise.recover(on: queue) { error -> Promise<Data> in
            if error is AbstractKeystoreError {
                throw Web3Error.keystoreError(err: error as! AbstractKeystoreError)
            }
            throw Web3Error.generalError(err: error)
        }
    }
}
