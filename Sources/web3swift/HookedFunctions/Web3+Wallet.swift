//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation

extension web3.Web3Wallet {
    public func getAccounts() throws -> [EthereumAddress] {
        try getAccountsPromise().wait()
    }
    
    public func getCoinbase() throws -> EthereumAddress {
        try getCoinbasePromise().wait()
    }
    
    public func signTX(transaction: inout EthereumTransaction, account: EthereumAddress, password: String = "web3swift") throws -> Bool {
        transaction = try signTXPromise(transaction: transaction, account: account, password: password).wait()
        return true
    }
    
    public func signPersonalMessage(_ personalMessage: String, account: EthereumAddress, password: String = "web3swift") throws -> Data {
        try signPersonalMessagePromise(personalMessage, account: account, password: password).wait()
    }
    
    public func signPersonalMessage(_ personalMessage: Data, account: EthereumAddress, password: String = "web3swift") throws -> Data {
        try signPersonalMessagePromise(personalMessage, account: account, password: password).wait()
    }
}
