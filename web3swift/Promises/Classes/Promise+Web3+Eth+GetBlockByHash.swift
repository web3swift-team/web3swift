//
//  Promise+Web3+Eth+GetBlockByHash.swift
//  web3swift
//
//  Created by Alexander Vlasov on 17.06.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
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
        let request = JSONRPCRequestFabric.prepareRequest(.getBlockByHash, parameters: [hash])
        let rp = web3.dispatch(request)
        let queue = web3.requestDispatcher.queue
        return rp.map(on: queue ) { response in
            guard let value: [String: AnyObject] = response.getValue() else {
                throw Web3Error.nodeError("Invalid value from Ethereum node")
            }
            let reencoded = try JSONSerialization.data(withJSONObject: value, options: JSONSerialization.WritingOptions(rawValue: 0))
            let details = try JSONDecoder().decode(Block.self, from: reencoded)
            return details
        }
    }
}
