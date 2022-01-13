//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
//import EthereumAddress

extension web3.Web3Wallet {
    
    public func getAccounts(_ cb: @escaping (Result<[EthereumAddress], Error>) -> Void) {
        guard let signer = self.web3.signer else {
            cb(.failure(Web3Error.walletError))
            return
        }
        signer.accounts(cb)
    }
    
    public func getCoinbase(_ cb: @escaping (Result<EthereumAddress, Error>) -> Void) {
        self.getAccounts { result in
            switch result {
            case .success(let accounts):
                guard accounts.count > 0 else {
                    cb(.failure(Web3Error.walletError))
                    return
                }
                cb(.success(accounts[0]))
            case .failure(let error):
                cb(.failure(error))
            }
        }
    }
    
    public func signTX(transaction: EthereumTransaction, account: EthereumAddress, password: String = "web3swift", _ cb: @escaping (Result<EthereumTransaction, Error>) -> Void) {
        guard let signer = self.web3.signer else {
            cb(.failure(Web3Error.walletError))
            return
        }
        signer.sign(transaction: transaction, with: account, using: password) { result in
            switch result {
            case .success(let transaction):
                cb(.success(transaction))
            case .failure(let error):
                if error is AbstractKeystoreError {
                    cb(.failure(Web3Error.keystoreError(err: error as! AbstractKeystoreError)))
                } else {
                    cb(.failure(Web3Error.generalError(err: error)))
                }
            }
        }
    }
    
    public func signPersonalMessage(_ personalMessage: String, account: EthereumAddress, password: String = "web3swift", _ cb: @escaping (Result<Data, Error>) -> Void) {
        guard let data = Data.fromHex(personalMessage) else {
            cb(.failure(Web3Error.dataError))
            return
        }
        self.signPersonalMessage(data, account: account, password: password, cb)
    }
    
    public func signPersonalMessage(_ personalMessage: Data, account: EthereumAddress, password: String = "web3swift", _ cb: @escaping (Result<Data, Error>) -> Void) {
        guard let signer = self.web3.signer else {
            cb(.failure(Web3Error.walletError))
            return
        }
        signer.sign(message: personalMessage, with: account, using: password) { result in
            switch result {
            case .success(let data):
                cb(.success(data))
            case .failure(let error):
                if error is AbstractKeystoreError {
                    cb(.failure(Web3Error.keystoreError(err: error as! AbstractKeystoreError)))
                } else {
                    cb(.failure(Web3Error.generalError(err: error)))
                }
            }
        }
    }

}
