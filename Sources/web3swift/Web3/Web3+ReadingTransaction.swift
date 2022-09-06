//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import Core

// FIXME: Rewrite this to CodableTransaction

/// Wrapper for `EthererumTransaction.data` property appropriate encoding.
public class ReadTransaction {
    public var transaction = CodableTransaction.emptyTransaction
    public var contract: EthereumContract
    public var method: String

    var web3: web3

    // FIXME: Rewrite this to CodableTransaction
    public init(web3 web3Instance: web3,
                contract: EthereumContract,
                method: String = "fallback",
                transactionOptions: CodableTransaction? = nil) {
        self.web3 = web3Instance
        self.contract = contract
        self.method = method
        if let network = self.web3.provider.network {
            self.transaction.chainID = network.chainID
        }
    }

    // FIXME: This is wrong naming, because this method doesn't decode,
    // it's merging Transactions Oprions sending request (Transaction with appropriate binary data) to contract, get's Data response
    // and only then it decodes it.
    // It should be splitted in this way up to three (merge, send, decode)
    // TODO: Remove type erasing here, some broad wide protocol should be added instead
    // FIXME: Rewrite this to CodableTransaction
    public func decodedData() async throws -> [String: Any] {
        // MARK: Read data from ABI flow
        let data: Data = try await self.web3.eth.callTransaction(transaction)

        if self.method == "fallback" {
            let resultHex = data.toHexString().addHexPrefix()
            return ["result": resultHex as Any]
        }
        guard let decodedData = self.contract.decodeReturnData(self.method, data: data) else {
            throw Web3Error.processingError(desc: "Can not decode returned parameters")
        }
        return decodedData
    }

    // FIXME: Rewrite this to CodableTransaction
    public func estimateGas() async throws -> BigUInt {
        return try await self.web3.eth.estimateGas(for: transaction)
    }

    // FIXME: Rewrite this to CodableTransaction
    // FIXME: Useless wrapper, delete me
    public func call() async throws -> [String: Any] {
        return try await self.decodedData()
    }
}
