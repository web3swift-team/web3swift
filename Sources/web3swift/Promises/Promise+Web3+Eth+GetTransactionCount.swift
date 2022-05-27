//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation


extension web3.Eth {
    public func getTransactionCount(for address: EthereumAddress, onBlock: BlockNumber) async throws -> UInt {
        try await getTransactionCount(address: address.address, onBlock: onBlock)
    }

    public func getTransactionCount(address: Address, onBlock: BlockNumber) async throws -> UInt {
        let requestCall: APIRequest = .getTransactionCount(address, onBlock)
        let response: APIResponse<UInt> = APIRequest.sendRequest(with: self.provider, for: requestCall)
        return response.result
    }
}
