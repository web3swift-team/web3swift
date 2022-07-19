//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import Core
import BigInt

extension web3.Eth {
    public func getBalance(for address: EthereumAddress, onBlock: BlockNumber = .latest) async throws -> BigUInt {
        try await getBalance(for: address.address, onBlock: onBlock)
    }

    public func getBalance(for address: Address, onBlock: BlockNumber = .latest) async throws -> BigUInt {
        let requestCall: APIRequest = .getBalance(address, onBlock)
        let response: APIResponse<BigUInt> = try await APIRequest.sendRequest(with: web3.provider, for: requestCall)
        return response.result
    }
}
