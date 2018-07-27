//
//  Web3+HookedWallet.swift
//  web3swift
//
//  Created by Alexander Vlasov on 07.01.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//
import Foundation
import BigInt
import Result

extension web3.Web3Wallet {
    
    public func getAccounts() -> Result<[EthereumAddress], Web3Error> {
        guard let keystoreManager = self.web3.provider.attachedKeystoreManager else {
            return Result.failure(Web3Error.walletError)
        }
        guard let ethAddresses = keystoreManager.addresses else {
            return Result.failure(Web3Error.walletError)
        }
        return Result(ethAddresses)
    }
    
    public func getCoinbase() -> Result<EthereumAddress, Web3Error> {
        let result = self.getAccounts()
        switch result {
        case .failure(let error):
            return Result.failure(error)
        case .success(let addresses):
            guard addresses.count > 0 else {
                return Result.failure(Web3Error.walletError)
            }
            return Result(addresses[0])
        }
    }
    
    public func signTX(transaction:inout EthereumTransaction, account: EthereumAddress, password: String = "BANKEXFOUNDATION") -> Result<Bool, Web3Error> {
        do {
            guard let keystoreManager = self.web3.provider.attachedKeystoreManager else {
                return Result.failure(Web3Error.walletError)
            }
            try Web3Signer.signTX(transaction: &transaction, keystore: keystoreManager, account: account, password: password)
            print(transaction)
            return Result(true)
        } catch {
            if error is AbstractKeystoreError {
            return Result.failure(Web3Error.keystoreError(error as! AbstractKeystoreError))
            }
            return Result.failure(Web3Error.generalError(error))
        }
    }
    
    public func signPersonalMessage(_ personalMessage: String, account: EthereumAddress, password: String = "BANKEXFOUNDATION") -> Result<Data, Web3Error> {
        guard let data = Data.fromHex(personalMessage) else
        {
            return Result.failure(Web3Error.dataError)
        }
        return self.signPersonalMessage(data, account: account, password: password)
    }
    
    public func signPersonalMessage(_ personalMessage: Data, account: EthereumAddress, password: String = "BANKEXFOUNDATION") -> Result<Data, Web3Error> {
        do {
            guard let keystoreManager = self.web3.provider.attachedKeystoreManager else
            {
                return Result.failure(Web3Error.walletError)
            }
            guard let data = try Web3Signer.signPersonalMessage(personalMessage, keystore: keystoreManager, account: account, password: password) else {
                return Result.failure(Web3Error.walletError)
            }
            return Result(data)
        }
        catch{
            if error is AbstractKeystoreError {
                return Result.failure(Web3Error.keystoreError(error as! AbstractKeystoreError))
            }
            return Result.failure(Web3Error.generalError(error))
        }
    }

}
