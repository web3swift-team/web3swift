//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt

extension web3.TxPool {
    public func getInspect() async throws -> [String:[String:[String:String]]] {
        try await self.getInspectPromise()
    }

    public func getStatus() async throws -> TxPoolStatus {
        try await self.getStatusPromise()
    }

    public func getContent() async throws -> TxPoolContent {
        try await self.getContentPromise()
    }
}
