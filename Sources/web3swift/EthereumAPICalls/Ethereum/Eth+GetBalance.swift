//
//  Created by Yaroslav Yashin.
//  Copyright © 2022 Yaroslav Yashin. All rights reserved.
//

import Foundation
import Core
import BigInt

extension web3.Eth {
    public func getBalance(for address: EthereumAddress, onBlock: BlockNumber = .latest) async throws -> BigUInt {
        let requestCall: APIRequest = .getBalance(address.address, onBlock)
        let response: APIResponse<BigUInt> = try await APIRequest.sendRequest(with: web3.provider, for: requestCall)
        return response.result
    }
}
