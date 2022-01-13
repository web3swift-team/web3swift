//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import PromiseKit
//import EthereumAddress

extension web3.Web3Wallet {
    
    public func getAccounts() throws -> [EthereumAddress] {
        guard let signer = self.web3.signer else {
            throw Web3Error.walletError
        }
        return try Promise { resolver in
            signer.accounts { result in
                switch result {
                case .success(let accounts): resolver.fulfill(accounts)
                case .failure(let error): resolver.reject(error)
                }
            }
        }.wait()
    }
    
    public func getCoinbase() throws -> EthereumAddress {
        let accounts = try self.getAccounts()
        guard accounts.count > 0 else {
            throw Web3Error.walletError
        }
        return accounts[0]
    }
    
    public func signTX(transaction: inout EthereumTransaction, account: EthereumAddress, password: String = "web3swift") throws -> Bool {
        guard let signer = self.web3.signer else {
            throw Web3Error.walletError
        }
        do {
            transaction = try Promise { resolver in
                signer.sign(transaction: transaction, with: account, using: password) { result in
                    switch result {
                    case .success(let transaction): resolver.fulfill(transaction)
                    case .failure(let error): resolver.reject(error)
                    }
                }
            }.wait()
            return true
        } catch {
            if error is AbstractKeystoreError {
                throw Web3Error.keystoreError(err: error as! AbstractKeystoreError)
            }
            throw Web3Error.generalError(err: error)
        }
    }
    
    public func signPersonalMessage(_ personalMessage: String, account: EthereumAddress, password: String = "web3swift") throws -> Data {
        guard let data = Data.fromHex(personalMessage) else {
            throw Web3Error.dataError
        }
        return try self.signPersonalMessage(data, account: account, password: password)
    }
    
    public func signPersonalMessage(_ personalMessage: Data, account: EthereumAddress, password: String = "web3swift") throws -> Data {
        guard let signer = self.web3.signer else {
            throw Web3Error.walletError
        }
        do {
            return try Promise { resolver in
                signer.sign(message: personalMessage, with: account, using: password) { result in
                    switch result {
                    case .success(let data): resolver.fulfill(data)
                    case .failure(let error): resolver.reject(error)
                    }
                }
            }.wait()
        } catch {
            if error is AbstractKeystoreError {
                throw Web3Error.keystoreError(err: error as! AbstractKeystoreError)
            }
            throw Web3Error.generalError(err: error)
        }
    }

}
