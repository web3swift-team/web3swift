//
//  DataConversion.swift
//  web3swift
//
//  Created by Alexander Vlasov on 16.06.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import PromiseKit
import BigInt

extension web3.Eth {
    public func getBalancePromise(address: EthereumAddress, onBlock: String = "latest") -> Promise<BigUInt> {
        let addr = address.address
        return getBalancePromise(address: addr, onBlock: onBlock)
    }
    public func getBalancePromise(address: String, onBlock: String = "latest") -> Promise<BigUInt> {
        let request = JSONRPCRequestFabric.prepareRequest(.getBalance, parameters: [address.lowercased(), onBlock])
        let rp = web3.dispatch(request)
        let queue = web3.requestDispatcher.queue
        return rp.map(on: queue ) { response in
            guard let value: BigUInt = response.getValue() else {
                if response.error != nil {
                    throw Web3Error.nodeError(response.error!.message)
                }
                throw Web3Error.nodeError("Invalid value from Ethereum node")
            }
            return value
        }
    }
}
