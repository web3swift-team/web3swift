//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt


extension web3.Eth {
    public func blockNumber() async throws -> UInt {
        let requestCall: APIRequest = .blockNumber

        let response: APIResponse<UInt> = try await APIRequest.sendRequest(with: web3.provider, for: requestCall)

        return response.result
    }
}
