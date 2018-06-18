//
//  Promise+Web3+Personal+UnlockAccount.swift
//  web3swift
//
//  Created by Alexander Vlasov on 18.06.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt
import PromiseKit

extension web3.Personal {
    func unlockAccountPromise(account: EthereumAddress, password:String = "BANKEXFOUNDATION", seconds: UInt64 = 300) -> Promise<Bool> {
        let addr = account.address
        return unlockAccountPromise(account: addr, password: password, seconds: seconds)
    }
    
    
    func unlockAccountPromise(account: String, password:String = "BANKEXFOUNDATION", seconds: UInt64 = 300) -> Promise<Bool> {
        let queue = web3.requestDispatcher.queue
        do {
            if self.web3.provider.attachedKeystoreManager == nil {
                let request = JSONRPCRequestFabric.prepareRequest(.unlockAccount, parameters: [account.lowercased(), password, seconds])
                return self.web3.dispatch(request).map(on: queue) {response in
                    guard let value: Bool = response.getValue() else {
                        if response.error != nil {
                            throw Web3Error.nodeError(response.error!.message)
                        }
                        throw Web3Error.nodeError("Invalid value from Ethereum node")
                    }
                    return value
                }
            }
            throw Web3Error.inputError("Can not unlock a local keystore")
        } catch {
            let returnPromise = Promise<Bool>.pending()
            queue.async {
                returnPromise.resolver.reject(error)
            }
            return returnPromise.promise
        }
    }
}
