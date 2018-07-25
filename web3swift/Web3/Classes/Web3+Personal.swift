//
//  Web3+Personal.swift
//  web3swift
//
//  Created by Alexander Vlasov on 14.04.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt
import Result

extension web3.Personal {
    

    
    public func signPersonalMessage(message: Data, from: EthereumAddress, password:String = "BANKEXFOUNDATION") -> Result<Data, Web3Error> {
        do {
            let result = try self.signPersonalMessagePromise(message: message, from: from, password: password).wait()
            return Result(result)
        } catch {
            return Result.failure(error as! Web3Error)
        }
    }
    
    public func unlockAccount(account: EthereumAddress, password:String = "BANKEXFOUNDATION", seconds: UInt64 = 300) -> Result<Bool, Web3Error> {
        do {
            let result = try self.unlockAccountPromise(account: account).wait()
            return Result(result)
        } catch {
            return Result.failure(error as! Web3Error)
        }
    }
    
    public func ecrecover(personalMessage: Data, signature: Data) -> Result<EthereumAddress, Web3Error> {
        guard let recovered = Web3.Utils.personalECRecover(personalMessage, signature: signature) else {
            return Result.failure(Web3Error.dataError)
        }
        return Result(recovered)
    }
    
    public func ecrecover(hash: Data, signature: Data) -> Result<EthereumAddress, Web3Error> {
        guard let recovered = Web3.Utils.hashECRecover(hash: hash, signature: signature) else {
            return Result.failure(Web3Error.dataError)
        }
        return Result(recovered)
    }
}
