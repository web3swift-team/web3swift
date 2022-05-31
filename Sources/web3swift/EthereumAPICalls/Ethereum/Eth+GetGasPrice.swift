//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt


extension web3.Eth {
    public func gasPrice() async throws -> BigUInt {
        let response: APIResponse<BigUInt> = try await APIRequest.sendRequest(with: self.provider, for: .gasPrice)
        return response.result
    }
}
