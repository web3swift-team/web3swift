//
//  Promise+Web3+Eth+GetCode.swift
//  web3swift
//
//  Created by Ndriqim Haxhaj on 8/25/21.
//

import Foundation

import BigInt

extension web3.Eth {
    public func code(for address: EthereumAddress, onBlock: String = "latest") async throws -> String {
        let addr = address.address
        return try await code(for : addr, onBlock: onBlock)
    }
    public func code(for address: String, onBlock: String = "latest") async throws -> String {
        let request = JSONRPCRequestFabric.prepareRequest(.getCode, parameters: [address.lowercased(), onBlock])
        let response = try await web3.dispatch(request)

        guard let value: String = response.getValue() else {
            if response.error != nil {
                throw Web3Error.nodeError(desc: response.error!.message)
            }
            throw Web3Error.nodeError(desc: "Invalid value from Ethereum node")
        }
        return value

    }
}
