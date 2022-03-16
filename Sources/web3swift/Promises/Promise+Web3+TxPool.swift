//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt

extension web3.TxPool {
    public func getInspectPromise() async throws -> [String:[String:[String:String]]] {
        let request = JSONRPCRequestFabric.prepareRequest(.getTxPoolInspect, parameters: [])
        let response = await web3.dispatch(request)
        guard let value: [String:[String:[String:String]]] = response?.getValue() else {
            throw Web3Error.nodeError(desc: response?.error?.message ?? "Invalid value from Ethereum node")
        }
        return value
    }

    public func getStatusPromise() async throws -> TxPoolStatus {
        let request = JSONRPCRequestFabric.prepareRequest(.getTxPoolStatus, parameters: [])
        let response = await web3.dispatch(request)
        guard let value: TxPoolStatus = response?.result as? TxPoolStatus else {
            throw Web3Error.nodeError(desc:response?.error?.message ?? "Invalid value from Ethereum node")
        }
        return value
    }

    public func getContentPromise() async throws -> TxPoolContent {
        let request = JSONRPCRequestFabric.prepareRequest(.getTxPoolContent, parameters: [])
        let response = await web3.dispatch(request)

        guard let value: TxPoolContent = response?.getValue() else {
            throw Web3Error.nodeError(desc: response?.error?.message ?? "Invalid value from Ethereum node")
        }
        return value
    }
}
