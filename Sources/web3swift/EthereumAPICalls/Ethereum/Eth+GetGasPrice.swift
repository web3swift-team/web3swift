//
//  Created by Yaroslav Yashin.
//  Copyright © 2022 Yaroslav Yashin. All rights reserved.
//

import Foundation
import BigInt
import Core


extension Web3.Eth {
    public func gasPrice() async throws -> BigUInt {
        let response: APIResponse<BigUInt> = try await APIRequest.sendRequest(with: self.provider, for: .gasPrice)
        return response.result
    }
}
