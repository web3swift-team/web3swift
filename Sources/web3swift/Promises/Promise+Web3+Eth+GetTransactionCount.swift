//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import PromiseKit

extension web3.Eth {
    public func getTransactionCountPromise(address: EthereumAddress, onBlock: String = "latest") -> Promise<BigUInt> {
        let addr = address.address
        return getTransactionCountPromise(address: addr, onBlock: onBlock)
    }

    public func getTransactionCountPromise(address: String, onBlock: String = "latest") -> Promise<BigUInt> {
        let request = JSONRPCRequestFabric.prepareRequest(.getTransactionCount, parameters: [address.lowercased(), onBlock])
        let rp = web3.dispatch(request)
        let queue = web3.requestDispatcher.queue
        return rp.map(on: queue) { response in
            guard let value: BigUInt = response.getValue() else {
                if response.error != nil {
                    throw Web3Error.nodeError(desc: response.error!.message)
                }
                throw Web3Error.nodeError(desc: "Invalid value from Ethereum node")
            }
            return value
        }
    }
}
