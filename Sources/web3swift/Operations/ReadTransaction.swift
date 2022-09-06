//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import Core

// FIXME: Rewrite this to CodableTransaction

/// Wrapper for `EthererumTransaction.data` property appropriate encoding.
public class ReadOperation {
    public var transaction: CodableTransaction
    public var contract: EthereumContract
    public var method: String
    public private (set) var data: Data?

    var web3: web3

    // FIXME: Rewrite this to CodableTransaction
    public init(transaction: CodableTransaction = CodableTransaction.emptyTransaction,
                web3 web3Instance: web3,
                contract: EthereumContract,
                method: String = "fallback") {
        self.transaction = transaction
        self.web3 = web3Instance
        self.contract = contract
        self.method = method
        if let network = self.web3.provider.network {
            self.transaction.chainID = network.chainID
        }
    }

    // FIXME: Update all properties of transaction relating gon contract specifics.
    public func prepareTransaction() {

    }

    public func execute() async throws -> Data {
        let data: Data = try await self.web3.eth.callTransaction(transaction)
        return data
    }


    // FIXME: This is wrong naming, because this method doesn't decode,
    // it's merging Transactions Oprions sending request (Transaction with appropriate binary data) to contract, get's Data response
    // and only then it decodes it.
    // It should be splitted in this way up to three (merge, send, decode)
    // TODO: Remove type erasing here, some broad wide protocol should be added instead
    // FIXME: Rewrite this to CodableTransaction
    public func decodedData() async throws -> [String: Any] {
        // MARK: Read data from ABI flow
        // FIXME: This should be dropped, and after `execute()` call, just to decode raw data.
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
    // FIXME: Useless wrapper, delete me
    public func call() async throws -> [String: Any] {
        return try await self.decodedData()
    }
}
