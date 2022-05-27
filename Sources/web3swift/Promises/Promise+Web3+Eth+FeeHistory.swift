//
//  Promise+Web3+Eth+FeeHistory.swift
//  web3swift
//
//  Created by Yaroslav on 11.04.2022.
//  Copyright © 2022 web3swift. All rights reserved.
//

import Foundation
import BigInt

extension Web3.Oracle.FeeHistory: APIResultType { }

extension web3.Eth {
    func feeHistory(blockCount: UInt, block: BlockNumber, percentiles:[Double]) async throws -> Web3.Oracle.FeeHistory {
        let requestCall: APIRequest = .feeHistory(blockCount, block, percentiles)
        let response: APIResponse<Web3.Oracle.FeeHistory> = try await APIRequest.sendRequest(with: web3.provider, for: requestCall)
        return response.result
    }
}
