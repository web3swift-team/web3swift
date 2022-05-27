//
//  Promise+Web3+Eth+GetCode.swift
//  web3swift
//
//  Created by Ndriqim Haxhaj on 8/25/21.
//

import Foundation

import BigInt

extension web3.Eth {
    public func code(for address: EthereumAddress, onBlock: BlockNumber) async throws -> Hash {
        try await code(for : address.address, onBlock: onBlock)
    }
    
    public func code(for address: Address, onBlock: BlockNumber) async throws -> Hash {
        let requestCall: APIRequest = .getCode(address, onBlock)
        let response: APIResponse<Hash> = try await APIRequest.sendRequest(with: self.provider, for: requestCall)
        return response.result
    }
}
