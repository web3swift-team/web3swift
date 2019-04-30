//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import PromiseKit
//import EthereumAddress

extension web3.Personal {
    public func unlockAccountPromise(account: EthereumAddress, password:String = "web3swift", seconds: UInt64 = 300) -> Promise<Bool> {
        let addr = account.address
        return unlockAccountPromise(account: addr, password: password, seconds: seconds)
    }
    
    
    public func unlockAccountPromise(account: String, password:String = "web3swift", seconds: UInt64 = 300) -> Promise<Bool> {
        let queue = web3.requestDispatcher.queue
        do {
            if self.web3.provider.attachedKeystoreManager == nil {
                let request = JSONRPCRequestFabric.prepareRequest(.unlockAccount, parameters: [account.lowercased(), password, seconds])
                return self.web3.dispatch(request).map(on: queue) {response in
                    guard let value: Bool = response.getValue() else {
                        if response.error != nil {
                            throw Web3Error.nodeError(desc: response.error!.message)
                        }
                        throw Web3Error.nodeError(desc: "Invalid value from Ethereum node")
                    }
                    return value
                }
            }
            throw Web3Error.inputError(desc: "Can not unlock a local keystore")
        } catch {
            let returnPromise = Promise<Bool>.pending()
            queue.async {
                returnPromise.resolver.reject(error)
            }
            return returnPromise.promise
        }
    }
}
