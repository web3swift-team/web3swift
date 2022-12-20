//
//  Created by Yaroslav Yashin.
//  Copyright © 2022 Yaroslav Yashin. All rights reserved.
//

import Foundation
import BigInt
import Web3Core

public protocol IEth {
    var provider: Web3Provider { get }
    func callTransaction(_ transaction: CodableTransaction) async throws -> Data
    func send(_ transaction: CodableTransaction) async throws -> TransactionSendingResult
    func send(raw data: Data) async throws -> TransactionSendingResult

    func estimateGas(for transaction: CodableTransaction, onBlock: BlockNumber) async throws -> BigUInt
    func feeHistory(blockCount: BigUInt, block: BlockNumber, percentiles: [Double]) async throws -> Oracle.FeeHistory
    func ownedAccounts() async throws -> [EthereumAddress]
    func getBalance(for address: EthereumAddress, onBlock: BlockNumber) async throws -> BigUInt

    func block(by hash: Data, fullTransactions: Bool) async throws -> Block
    func block(by number: BlockNumber, fullTransactions: Bool) async throws -> Block
    func block(by hash: Hash, fullTransactions: Bool) async throws -> Block
    func blockNumber() async throws -> BigUInt

    func code(for address: EthereumAddress, onBlock: BlockNumber) async throws -> Hash

    func gasPrice() async throws -> BigUInt

    func getTransactionCount(for address: EthereumAddress, onBlock: BlockNumber) async throws -> BigUInt

    func transactionDetails(_ txHash: Data) async throws -> TransactionDetails
    func transactionReceipt(_ txHash: Data) async throws -> TransactionReceipt
}
