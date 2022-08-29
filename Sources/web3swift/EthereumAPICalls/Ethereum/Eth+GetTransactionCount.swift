//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import Core


extension web3.Eth {
    public func getTransactionCount(for address: EthereumAddress, onBlock: BlockNumber) async throws -> BigUInt {
        try await getTransactionCount(address: address.address, onBlock: onBlock)
    }

    public func getTransactionCount(address: Address, onBlock: BlockNumber) async throws -> BigUInt {
        let requestCall: APIRequest = .getTransactionCount(address, onBlock)
        let response: APIResponse<BigUInt> = try await APIRequest.sendRequest(with: self.provider, for: requestCall)
        return response.result
    }
}
