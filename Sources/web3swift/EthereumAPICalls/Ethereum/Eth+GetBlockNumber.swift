//
//  Created by Yaroslav Yashin.
//  Copyright © 2022 Yaroslav Yashin. All rights reserved.
//

import Foundation
import BigInt
import Core


extension web3.Eth {
    public func blockNumber() async throws -> BigUInt {
        let response: APIResponse<BigUInt> = try await APIRequest.sendRequest(with: web3.provider, for: .blockNumber)
        return response.result
    }
}
