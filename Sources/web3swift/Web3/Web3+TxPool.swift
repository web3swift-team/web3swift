//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt

extension web3.TxPool {
    public func getInspect() async throws -> [String: [String: [String: String]]] {
        let result = try await self.getInspectPromise()
        return result
    }

    public func getStatus() async throws -> TxPoolStatus {
        let result = try await self.getStatusPromise()
        return result
    }

    public func getContent() async throws -> TxPoolContent {
        let result = try await self.getContentPromise()
        return result
    }
}
