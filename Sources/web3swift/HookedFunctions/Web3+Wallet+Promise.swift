//
//  Web3+Wallet+Promise.swift
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
        return Promise { resolver in
            signer.accounts { result in
                switch result {
                case .success(let accounts): resolver.fulfill(accounts)
                case .failure(let error): resolver.reject(error)
                }
            }
        }
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
        return Promise { resolver in
            signer.sign(transaction: transaction, with: account, using: password) { result in
                switch result {
                case .success(let transaction):
                    resolver.fulfill(transaction)
                case .failure(let error):
                    if error is AbstractKeystoreError {
                        resolver.reject(Web3Error.keystoreError(err: error as! AbstractKeystoreError))
                    } else {
                        resolver.reject(Web3Error.generalError(err: error))
                    }
                }
            }
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
        return Promise { resolver in
            signer.sign(message: personalMessage, with: account, using: password) { result in
                switch result {
                case .success(let data):
                    resolver.fulfill(data)
                case .failure(let error):
                    if error is AbstractKeystoreError {
                        resolver.reject(Web3Error.keystoreError(err: error as! AbstractKeystoreError))
                    }
                    resolver.reject(Web3Error.generalError(err: error))
                }
            }
        }
    }
}
