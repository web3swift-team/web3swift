//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import PromiseKit
//import EthereumAddress

extension web3.Eth {
    public func getAccountsPromise() -> Promise<[EthereumAddress]> {
        let queue = web3.requestDispatcher.queue
        if (self.web3.signer != nil) {
            return self.web3.signer!.accounts(on: queue)
        }
        let request = JSONRPCRequestFabric.prepareRequest(.getAccounts, parameters: [])
        let rp = web3.dispatch(request)
        return rp.map(on: queue ) { response in
            guard let value: [EthereumAddress] = response.getValue() else {
                if response.error != nil {
                    throw Web3Error.nodeError(desc: response.error!.message)
                }
                throw Web3Error.nodeError(desc: "Invalid value from Ethereum node")
            }
            return value
        }
    }
}
