//
//  Web3+GasOracle.swift
//  web3swift
//
//  Created by Yaroslav on 31.03.2022.
//  Copyright © 2022 web3swift. All rights reserved.
//

import Foundation
import BigInt

extension web3.Eth {
    /// Oracle is the class to do a transaction fee suggestion
    final public class Oracle {

        /// Web3 provider by which accessing to the blockchain
        private let web3Provider: web3

        private var feeHistory: FeeHistory?

        /// Ethereum scope shortcut
        private var eth: web3.Eth { web3Provider.eth }

        /// Block to start getting history
        var block: String

        /// Count of blocks to calculate statistics
        var blockCount: BigUInt

        /// Count of transactions to filter block for tip calculation
        var percentiles: [Double]

        /// Oracle initializer
        /// - Parameters:
        ///   - provider: Web3 Ethereum provider
        ///   - block: Number of block from which counts starts
        ///   - blockCount: Count of block to calculate statistics
        ///   - percentiles: Percentiles of fees which will split in fees history
        public init(_ provider: web3, block: String = "latest", blockCount: BigUInt = 20, percentiles: [Double] = [10, 50, 90]) {
            self.web3Provider = provider
            self.block = block
            self.blockCount = blockCount
            self.percentiles = percentiles
        }

//        private func calcBaseFee(for block: Block?) -> BigUInt {
//            guard let block = block else { return 0 }
//            return Web3.calcBaseFee(block) ?? 0
//        }

        private func calculateStatistic(for statistic: Statistic, data: [BigUInt]) throws -> BigUInt {
            let noAnomalyArray = data.cropAnomalyValues()

            // FIXME: Set appropriate error thrown.
            guard let unwrappedArray = noAnomalyArray, !unwrappedArray.isEmpty else { throw Web3Error.unknownError }

            switch statistic {
            // Force unwrapping is ok, since array checked for epmtiness above
            // swiftlint:disable force_unwrapping
            case .minimum: return unwrappedArray.min()!
            case .mean: return unwrappedArray.mean()!
            case .median: return unwrappedArray.mean()!
            case .maximum:
                // Checking that suggestedBaseFee is not lower than it will be in the next block
                // because in the maximum statistic we should guarantee that transaction would be included in it.
//                return max(calcBaseFee(for: latestBlock), unwrappedArray.max()!)
                return unwrappedArray.max()!
            }
            // swiftlint:enable force_unwrapping
        }

        private func soft(twoDimentsion array: [[BigUInt]]) -> [BigUInt] {
            /// We've got `[[min],[middle],[max]]` 2 dimensional array
            /// we're getting `[min, middle, max].count == self.percentiles.count`,
            /// where each value are mean from the input percentile array
            array.compactMap { percentileArray -> [BigUInt]? in
                guard !percentileArray.isEmpty else { return nil }
                // swiftlint:disable force_unwrapping
                return [percentileArray.mean()!]
                // swiftlint:enable force_unwrapping
            }
            .flatMap { $0 }
        }

        private func calculatePercentiles(for data: [BigUInt]) -> [BigUInt] {
            percentiles.compactMap { percentile in
                data.percentile(of: percentile)
            }
        }

        private func suggestGasValues() throws -> FeeHistory {
            // This is some kind of cache.
            // It stores about 9 seconds, than it rewrites it with newer data.
            // TODO: Disabled until 3.0 version, coz `distance` available from iOS 13.
//            guard feeHistory != nil, feeHistory!.timestamp.distance(to: Date()) < cacheTimeout else { return feeHistory! }

            return try eth.feeHistory(blockCount: blockCount, block: block, percentiles: percentiles)
        }

        /// Suggesting tip values
        /// - Returns: `[percentile 1, percentile 2, percentile 3].count == self.percentile.count`
        /// by default there's 3 percentile.
        private func suggestTipValue() throws -> [BigUInt] {
            /// reaarange `[[min, middle, max]]` to `[[min], [middle], [max]]`
            let rearrengedArray = try suggestGasValues().reward
                .map { internalArray -> [BigUInt] in
                    var newArray = [BigUInt]()
                    internalArray.enumerated().forEach { newArray[$0] = $1 }
                    return newArray
                }
            return soft(twoDimentsion: rearrengedArray)
        }

        private func suggestBaseFee() throws -> [BigUInt] {
            calculatePercentiles(for: try suggestGasValues().baseFeePerGas)
        }

        private func suggestGasFeeLegacy(_ statistic: Statistic) throws -> BigUInt {
            let latestBlockNumber = try eth.getBlockNumber()

            // Assigning last block to object var to predict baseFee of the next block
//            latestBlock = try eth.getBlockByNumber(latestBlockNumber)
            // TODO: Make me work with cache
            let lastNthBlockGasPrice = try (latestBlockNumber - blockCount ... latestBlockNumber)
                .map { try eth.getBlockByNumber($0, fullTransactions: true) }
                .flatMap { b -> [EthereumTransaction] in
                    b.transactions.compactMap { t -> EthereumTransaction? in
                        guard case let .transaction(transaction) = t else { return nil }
                        return transaction
                    }
                }
                .map { $0.gasPrice }

            return try calculateStatistic(for: statistic, data: lastNthBlockGasPrice)
        }
    }
}

public extension web3.Eth.Oracle {
    // MARK: - Base Fee
    /// Base fee amount based on last Nth blocks
    ///
    /// Normalized means that most high and most low value were droped from calculation.
    ///
    /// Nth block may include empty ones.
    ///
    /// - Parameter statistic: Statistic to apply for base fee calculation
    /// - Returns: Suggested base fee amount according to statistic, nil if failed to perdict
    func predictBaseFee() -> [BigUInt] {
        guard let value = try? suggestBaseFee() else { return [] }
        return value
    }

    // MARK: - Tip
    /// Maximum tip amount based on last block tips
    ///
    /// Normalized means that most high and most low value were droped from calculation.
    ///
    /// Method calculates the suggested tip based on the most recent block that contains more than transactionsCount transactions
    ///
    /// - Parameter statistic: Statistic to apply for tip calculation
    /// - Returns: Suggested tip amount according to statistic, nil if failed to perdict
    func predictTip() -> [BigUInt] {
        guard let value = try? suggestTipValue() else { return [] }
        return value
    }

    // MARK: - Summary fees
    /// Method to get summary fees
    /// - Parameters:
    ///   - baseFee: Statistic to apply for baseFee
    ///   - tip: Statistic to apply for tip
    /// - Returns: Tuple where `baseFee` — base fee, `tip` — tip, nil if failed to predict
    func predictBothFees() -> (baseFee: [BigUInt], tip: [BigUInt])? {
        guard let baseFee = try? suggestBaseFee() else { return nil }
        guard let tip = try? suggestTipValue() else { return nil }

        return (baseFee: baseFee, tip: tip)
    }

    // MARK: - Legacy GasPrice
    /// Method to get legacy gas price
    /// - Parameter statistic: Statistic to apply for gas price
    /// - Returns: Suggested gas price amount according to statistic, nil if failed to predict
//    func predictGasPriceLegacy() -> BigUInt? {
//        guard let value = try? suggestGasFeeLegacy() else { return nil}
//        return value
//    }
}

public extension web3.Eth.Oracle {
    // TODO: Make me struct and encapsulate math within to make me extendable
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

public extension web3.Eth.Oracle {
    struct FeeHistory {
        let timestamp = Date()
        let baseFeePerGas: [BigUInt]
        let gasUsedRatio: [Double]
        let oldestBlock: BigUInt
        let reward: [[BigUInt]]
    }
}

extension web3.Eth.Oracle.FeeHistory: Decodable {
    enum CodingKeys: String, CodingKey {
        case baseFeePerGas
        case gasUsedRatio
        case oldestBlock
        case reward
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        self.baseFeePerGas = try values.decodeHex([BigUInt].self, forKey: .baseFeePerGas)
        self.gasUsedRatio = try values.decode([Double].self, forKey: .gasUsedRatio)
        self.oldestBlock = try values.decodeHex(BigUInt.self, forKey: .oldestBlock)
        self.reward = try values.decodeHex([[BigUInt]].self, forKey: .reward)
    }
}

extension Array where Element: Comparable {

    /// Sorts array and drops most and least values.
    /// - Returns: Sorted array without most and least values, nil if `array.count` <= 2
    func cropAnomalyValues() -> Self? {
        var sortedArray = self.sorted()
        // Array should at least counts two to pass that formations.
        guard sortedArray.count > 1 else { return nil }
        sortedArray.removeLast()
        sortedArray.removeFirst()
        return sortedArray
    }
}

extension Array where Element: BinaryInteger {
    func mean() -> BigUInt? {
        guard !self.isEmpty else { return nil }
        return BigUInt(self.reduce(0, +)) / BigUInt(self.count)
    }

    func percentile(of value: Double) -> BigUInt? {
        guard !self.isEmpty else { return nil }

        let sorted_data = self.sorted()
//        if self.count % 2 == 1 {
            return BigUInt(sorted_data[Int(floor(Double(self.count) / value / 10))])
//        } else {
//            return BigUInt(sorted_data[self.count / Int(value) / 10] + sorted_data[(self.count / Int(value) / 10) - 1] /( value) / 10)
//        }
    }
}
