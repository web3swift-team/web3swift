//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import PromiseKit

extension web3.Eth {
    public func getBlockByHashPromise(_ hash: Data, fullTransactions: Bool = false) -> Promise<Block> {
        let hashString = hash.toHexString().addHexPrefix()
        return getBlockByHashPromise(hashString, fullTransactions: fullTransactions)
    }
    
    public func getBlockByHashPromise(_ hash: String, fullTransactions: Bool = false) -> Promise<Block> {
        let request = JSONRPCRequestFabric.prepareRequest(.getBlockByHash, parameters: [hash, fullTransactions])
        let rp = web3.dispatch(request)
        let queue = web3.requestDispatcher.queue
        return rp.map(on: queue ) { response in
            guard let value: Block = response.getValue() else {
                if response.error != nil {
                    throw Web3Error.nodeError(desc: response.error!.message)
                }
                throw Web3Error.nodeError(desc: "Invalid value from Ethereum node")
            }
            return value
        }
    }
}
