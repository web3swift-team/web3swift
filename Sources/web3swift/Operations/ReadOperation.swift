//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import Web3Core

// FIXME: Rewrite this to CodableTransaction

/// Wrapper for `EthererumTransaction.data` property appropriate encoding.
public class ReadOperation {
    public var transaction: CodableTransaction
    public var contract: EthereumContract
    public var method: String
    public var data: Data? { transaction.data }

    var policyResolver: PolicyResolver
    var web3: Web3

    // FIXME: Rewrite this to CodableTransaction
    public init(transaction: CodableTransaction = CodableTransaction.emptyTransaction,
                web3 web3Instance: Web3,
                contract: EthereumContract,
                method: String = "fallback") {
        self.transaction = transaction
        self.web3 = web3Instance
        self.contract = contract
        self.method = method
        if let network = self.web3.provider.network {
            self.transaction.chainID = network.chainID
        }
        self.policyResolver = PolicyResolver(provider: web3.provider)
    }

    // TODO: Remove type erasing here, some broad wide protocol should be added instead
    public func callContractMethod() async throws -> [String: Any] {
        // MARK: Read data from ABI flow
        // FIXME: This should be dropped, and after `execute()` call, just to decode raw data.
        let data: Data = try await self.web3.eth.callTransaction(transaction)
        if self.method == "fallback" {
            let resultHex = data.toHexString().addHexPrefix()
            return ["result": resultHex]
        }
        guard let decodedData = self.contract.decodeReturnData(self.method, data: data) else {
            throw Web3Error.processingError(desc: "Can not decode returned parameters")
        }
        return decodedData
    }
}
