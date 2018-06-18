//
//  Promise+Web3+Eth+GetAccounts.swift
//  web3swift
//
//  Created by Alexander Vlasov on 17.06.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt
import PromiseKit

extension web3.Eth {
    public func getAccountsPromise() -> Promise<[EthereumAddress]> {
        let queue = web3.requestDispatcher.queue
        if (self.web3.provider.attachedKeystoreManager != nil) {
            let promise = Promise<[EthereumAddress]>.pending()
            queue.async {
                let result = self.web3.wallet.getAccounts()
                switch result {
                case .success(let allAccounts):
                    promise.resolver.fulfill(allAccounts)
                case .failure(let error):
                    promise.resolver.reject(error)
                }
            }
            return promise.promise
        }
        let request = JSONRPCRequestFabric.prepareRequest(.getAccounts, parameters: [])
        let rp = web3.dispatch(request)
        return rp.map(on: queue ) { response in
            guard let value: [EthereumAddress] = response.getValue() else {
                if response.error != nil {
                    throw Web3Error.nodeError(response.error!.message)
                }
                throw Web3Error.nodeError("Invalid value from Ethereum node")
            }
            return value
        }
    }
}
