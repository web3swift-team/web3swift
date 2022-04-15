//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import PromiseKit

extension web3.Eth {
    public func getBlockNumberPromise() -> Promise<BigUInt> {
        let request = JSONRPCRequestFabric.prepareRequest(.blockNumber, parameters: [])
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
