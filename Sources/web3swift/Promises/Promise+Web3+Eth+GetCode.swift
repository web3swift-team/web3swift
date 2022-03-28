//
//  Promise+Web3+Eth+GetCode.swift
//  web3swift
//
//  Created by Ndriqim Haxhaj on 8/25/21.
//

import Foundation
import PromiseKit
import BigInt

extension web3.Eth {
    public func getCodePromise(address: EthereumAddress, onBlock: String = "latest") -> Promise<String> {
        let addr = address.address
        return getCodePromise(address: addr, onBlock: onBlock)
    }
    public func getCodePromise(address: String, onBlock: String = "latest") -> Promise<String> {
        let request = JSONRPCRequestFabric.prepareRequest(.getCode, parameters: [address.lowercased(), onBlock])
        let rp = web3.dispatch(request)
        let queue = web3.requestDispatcher.queue
        return rp.map(on: queue) { response in
            guard let value: String = response.getValue() else {
                if response.error != nil {
                    throw Web3Error.nodeError(desc: response.error!.message)
                }
                throw Web3Error.nodeError(desc: "Invalid value from Ethereum node")
            }
            return value
        }
    }
}
