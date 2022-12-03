//
//  Created by Yaroslav Yashin.
//  Copyright © 2022 Yaroslav Yashin. All rights reserved.
//

import Foundation
import Web3Core
import BigInt

extension Web3.Eth {
    public func code(for address: EthereumAddress, onBlock: BlockNumber = .latest) async throws -> Hash {
        let request = APIRequest.getCode(address.address, onBlock)
        return try await APIRequest.sendRequest(with: provider, for: request).result
    }
}
