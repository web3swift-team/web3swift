//
//  Promise+Web3+Eth+GetTransactionDetails.swift
//  web3swift
//
//  Created by Alexander Vlasov on 17.06.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt
import PromiseKit

extension web3.Eth {
    public func getTransactionDetailsPromise(_ txhash: Data) -> Promise<TransactionDetails> {
        let hashString = txhash.toHexString().addHexPrefix()
        return self.getTransactionDetailsPromise(hashString)
    }
    
    public func getTransactionDetailsPromise(_ txhash: String) -> Promise<TransactionDetails> {
        let request = JSONRPCRequestFabric.prepareRequest(.getTransactionByHash, parameters: [txhash])
        let rp = web3.dispatch(request)
        let queue = web3.requestDispatcher.queue
        return rp.map(on: queue ) { response in
            guard let value: TransactionDetails = response.getValue() else {
                throw Web3Error.nodeError("Invalid value from Ethereum node")
            }
            return value
//            guard let details = TransactionDetails(value) else {
//                throw Web3Error.processingError("Can not deserialize transaction details")
//            }
//            return details
//            let reencoded = try JSONSerialization.data(withJSONObject: value, options: JSONSerialization.WritingOptions(rawValue: 0))
//            let details = try JSONDecoder().decode(TransactionDetails.self, from: reencoded)
//            return details
        }
    }
}
