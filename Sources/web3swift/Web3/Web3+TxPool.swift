//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt

extension web3.TxPool {
    public func getInspect() throws -> [String: [String: [String: String]]] {
        let result = try self.getInspectPromise().wait()
        return result
    }

    public func getStatus() throws -> TxPoolStatus {
        let result = try self.getStatusPromise().wait()
        return result
    }

    public func getContent() throws -> TxPoolContent {
        let result = try self.getContentPromise().wait()
        return result
    }
}
