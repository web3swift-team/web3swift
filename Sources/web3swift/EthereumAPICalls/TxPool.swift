//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import Core

extension web3.TxPool {
//    public func txPoolInspect() async throws -> [String: [String: [String: String]]] {
//        let request = JSONRPCRequestFabric.prepareRequest(.getTxPoolInspect, parameters: [])
//        let response = try await web3.dispatch(request)
//
//        guard let value: [String: [String: [String: String]]] = response.getValue() else {
//            if response.error != nil {
//                throw Web3Error.nodeError(desc: response.error!.message)
//            }
//            throw Web3Error.nodeError(desc: "Invalid value from Ethereum node")
//        }
//        return value
//
//    }

    public func txPoolStatus() async throws -> TxPoolStatus {
        let response: APIResponse<TxPoolStatus> = try await APIRequest.sendRequest(with: provider, for: .getTxPoolStatus)
        return response.result
    }

    public func txPoolContent() async throws -> TxPoolContent {
        let response: APIResponse<TxPoolContent> = try await APIRequest.sendRequest(with: provider, for: .getTxPoolContent)
        return response.result
    }
}
