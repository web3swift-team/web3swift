//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import BigInt
import Foundation

extension Web3.TxPool {
    public func txPoolInspect() async throws -> [String: [String: [String: String]]] {
        let request = JSONRPCRequestFabric.prepareRequest(.getTxPoolInspect, parameters: [])
        let response = try await web3.dispatch(request)

        guard let value: [String: [String: [String: String]]] = response.getValue() else {
            if response.error != nil {
                throw Web3Error.nodeError(desc: response.error!.message)
            }
            throw Web3Error.nodeError(desc: "Invalid value from Ethereum node")
        }
        return value

    }

    public func txPoolStatus() async throws -> TxPoolStatus {
        let request = JSONRPCRequestFabric.prepareRequest(.getTxPoolStatus, parameters: [])
        let response = try await web3.dispatch(request)

        guard let value: TxPoolStatus = response.result as? TxPoolStatus else {
            if response.error != nil {
                throw Web3Error.nodeError(desc: response.error!.message)
            }
            throw Web3Error.nodeError(desc: "Invalid value from Ethereum node")
        }
        return value

    }

    public func txPoolContent() async throws -> TxPoolContent {
        let request = JSONRPCRequestFabric.prepareRequest(.getTxPoolContent, parameters: [])
        let response = try await web3.dispatch(request)

        guard let value: TxPoolContent = response.getValue() else {
            if response.error != nil {
                throw Web3Error.nodeError(desc: response.error!.message)
            }
            throw Web3Error.nodeError(desc: "Invalid value from Ethereum node")
        }
        return value

    }
}
