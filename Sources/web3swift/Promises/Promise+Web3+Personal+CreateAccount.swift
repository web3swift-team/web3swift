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
    public func createAccountPromise(password:String = "web3swift") -> Promise<EthereumAddress> {
        let queue = web3.requestDispatcher.queue
        do {
            if self.web3.provider.attachedKeystoreManager == nil {
                let request = JSONRPCRequestFabric.prepareRequest(.createAccount, parameters: [password])
                return self.web3.dispatch(request).map(on: queue) {response in
                    guard let value: EthereumAddress = response.getValue() else {
                        if response.error != nil {
                            throw Web3Error.nodeError(desc: response.error!.message)
                        }
                        throw Web3Error.nodeError(desc: "Invalid value from Ethereum node")
                    }
                    return value
                }
            }
            throw Web3Error.inputError(desc: "Creating account in a local keystore with this method is not supported")
        } catch {
            let returnPromise = Promise<EthereumAddress>.pending()
            queue.async {
                returnPromise.resolver.reject(error)
            }
            return returnPromise.promise
        }
    }
}
