//
//  Created by Yaroslav Yashin.
//  Copyright © 2022 Yaroslav Yashin. All rights reserved.
//

import Foundation
import Core
import BigInt

extension web3.Eth { 
    public func code(for address: EthereumAddress, onBlock: BlockNumber = .latest) async throws -> Hash {
        let requestCall: APIRequest = .getCode(address.address, onBlock)
        let response: APIResponse<Hash> = try await APIRequest.sendRequest(with: self.provider, for: requestCall)
        return response.result
    }
}
