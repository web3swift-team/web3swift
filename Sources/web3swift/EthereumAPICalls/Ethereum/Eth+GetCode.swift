//
//  Created by Yaroslav Yashin.
//  Copyright © 2022 Yaroslav Yashin. All rights reserved.
//

import Foundation
import Core
import BigInt

extension Web3.Eth { 
    public func code(for address: EthereumAddress, onBlock: BlockNumber = .latest) async throws -> Hash {
        try await APIRequest.sendRequest(with: self.provider, for: .getCode(address.address, onBlock)).result
    }
}
