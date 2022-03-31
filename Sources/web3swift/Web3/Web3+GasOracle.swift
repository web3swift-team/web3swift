//
//  Web3+GasOracle.swift
//  web3swift
//
//  Created by Yaroslav on 31.03.2022.
//  Copyright © 2022 web3swift. All rights reserved.
//

import Foundation
import BigInt

extension Web3 {
    /// Oracle is the class to of a transaction fee suggestion
    ///
    /// It designed for EIP-1559 transactions only.
    final public class Oracle {
        private var latestBlock: Block?

        /// Web3 provider by wich accessing to the blockchain
        private let web3Provider: web3

        /// Ethereum scope shortcut
        private var eth: web3.Eth { web3Provider.eth }

        /// Number of block to caltulate statistics
        public private(set) var blocksNumber: BigUInt

        /// Number of transacrtions to filter block for tip calculation
        public private(set) var transactionsNumber: BigUInt

        /// Oracle initializer
        /// - Parameters:
        ///   - provider: Web3 Ethereum provider
        ///   - blocksNumber: Number of block to caltulate statistics
        public init(_ provider: web3, blocksNumber: BigUInt = 20, transactionsNumber: BigUInt = 50) {
            web3Provider = provider
            self.blocksNumber = blocksNumber
            self.transactionsNumber = transactionsNumber
        }

        private func calcBaseFee(for block: Block?) -> BigUInt {
            guard let block = block else { return 0 }
            return Web3.calcBaseFee(block)
        }

        private func calculateStatistic(_ data: [BigUInt], _ statistic: Statistic) throws -> BigUInt {
            let sortedData = data.sorted()
            let noAnomalyArray = sortedData.cropAnomalyValues()

            guard !noAnomalyArray.isEmpty else { throw Web3Error.unknownError }

            switch statistic {
            // Force unwrapping is ok, since array checked for epmtiness above
            case .minimum: return noAnomalyArray.min()!
            case .mean: return noAnomalyArray.mean()!
            case .median: return noAnomalyArray.median()!
            case .maximum:
                // Checking that suggestedBaseFee are not lower than next
                // because in tne maximum statistic we should guarantee that transaction would pass in the next block
                return max(calcBaseFee(for: latestBlock), noAnomalyArray.max()!)
            }
        }

        private func suggestTipValue(_ statistic: Statistic) throws -> BigUInt {
            let latestBlockNumber = try eth.getBlockNumber()

            // TODO: Make me work with cache
            var block: Block

            repeat {
                block = try eth.getBlockByNumber(latestBlockNumber, fullTransactions: true)
            } while block.transactions.count < transactionsNumber

            // Storing last block to calculate baseFee of the next block
            latestBlock = block

            let transactionsTips = block.transactions
                .compactMap { t -> EthereumTransaction? in
                    guard case let .transaction(transaction) = t else { return nil }
                    return transaction
                }
                // TODO: Add filter for transaction types
                .map { $0.maxPriorityFeePerGas }

            return try calculateStatistic(transactionsTips, statistic)
        }

        private func suggestBaseFee(_ statistic: Statistic) throws -> BigUInt {
            let latestBlockNumber = try eth.getBlockNumber()

            // Assigning last block to object var to predict baseFee of the next block
            latestBlock = try eth.getBlockByNumber(latestBlockNumber)
            // TODO: Make me work with cache
            let lastNthBlocksBaseFees = try (latestBlockNumber - blocksNumber ... latestBlockNumber)
                .map { try eth.getBlockByNumber($0) }
                .filter { !$0.transactions.isEmpty }
                .map { $0.baseFeePerGas }

            return try calculateStatistic(lastNthBlocksBaseFees, statistic)
        }
    }
}

public extension Web3.Oracle {
    // MARK: - Base Fee
    /// Base fee amount based on last Nth blocks
    ///
    /// Normalized means that most high and most low value were droped from calculation.
    ///
    /// Nth block may include empty ones.
    ///
    /// - Parameter statistic: Statistic to apply for base fee calculation
    /// - Returns: Suggested base fee amount according to statistic, nil if failed to perdict
    func predictBaseFee(_ statistic: Statistic) -> BigUInt? {
        guard let value = try? suggestBaseFee(statistic) else { return nil }
        return value
    }

    // MARK: - Tip
    /// Maximum tip amount based on last block tips
    ///
    /// Normalized means that most high and most low value were droped from calculation.
    ///
    /// Account first of the latest block that have more than `transactionsNumber` value.
    ///
    /// - Parameter statistic: Statistic to apply for tip calculation
    /// - Returns: Suggested tip amount according to statistic, nil if failed to perdict
    func predictTip(_ statistic: Statistic) -> BigUInt? {
        guard let value = try? suggestTipValue(statistic) else { return nil }
        return value
    }

    // MARK: - Summary fees
    /// Method to get summary fees
    /// - Parameters:
    ///   - baseFee: Statistic to apply for baseFee
    ///   - tip: Statistic to apply for tip
    /// - Returns: Touple where [0] — base fee, [1] — tip, nil if failed to predict
    func predictBothFees(baseFee: Statistic, tip: Statistic) -> (BigUInt, BigUInt)? {
        guard let baseFee = try? suggestBaseFee(baseFee) else { return nil }
        guard let tip = try? suggestTipValue(tip) else { return nil }

        return (baseFee, tip)
    }
}

public extension Web3.Oracle {
    // TODO: Make me struct and incapsulate math within to make me extendable
    enum Statistic {
        /// Mininum statistic
        case minimum
        /// Mean statistic
        case mean
        /// Median statistic
        case median
        /// Maximum statistic
        case maximum
    }
}

extension Array {
    func cropAnomalyValues() -> Self {
        var tmpArr = self.dropFirst()
        tmpArr = self.dropLast()
        return Array(tmpArr)
    }
}

extension Array where Element: BinaryInteger {
    func mean() -> BigUInt? {
        guard !self.isEmpty else { return nil }
        return BigUInt(self.reduce(0, +)) / BigUInt(self.count)
    }

    func median() -> BigUInt? {
        guard !self.isEmpty else { return nil }

        let sorted_data = self.sorted()
        if self.count % 2 == 1 {
            return BigUInt(sorted_data[Int(floor(Double(self.count) / 2))])
        } else {
            return BigUInt(sorted_data[self.count / 2] + sorted_data[(self.count / 2) - 1] / 2)
        }
    }
}
