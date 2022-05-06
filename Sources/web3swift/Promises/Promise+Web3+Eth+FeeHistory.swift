//
//  Promise+Web3+Eth+FeeHistory.swift
//  web3swift
//
//  Created by Yaroslav on 11.04.2022.
//  Copyright © 2022 web3swift. All rights reserved.
//

import Foundation
import PromiseKit
import BigInt

extension web3.Eth {
    func feeHistory(blockCount: BigUInt, block: String, percentiles:[Double]) throws -> Web3.Oracle.FeeHistory {
        let request = JSONRPCRequestFabric.prepareRequest(.feeHistory, parameters: [blockCount.description.addHexPrefix(), block, percentiles])
        let rp = web3.dispatch(request)
        let queue = web3.requestDispatcher.queue
        return try rp.map(on: queue) { response in
            guard let value: Web3.Oracle.FeeHistory = response.getValue() else {
                if response.error != nil {
                    throw Web3Error.nodeError(desc: response.error!.message)
                }
                throw Web3Error.nodeError(desc: "Invalid value from Ethereum node")
            }
            return value
        }.wait()
    }
}
