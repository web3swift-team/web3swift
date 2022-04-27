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
    /// Oracle is the class to do a transaction fee suggestion
    final public class Oracle {

        /// Web3 provider by which accessing to the blockchain
        private let web3Provider: web3

        private var feeHistory: FeeHistory?

        /// Ethereum scope shortcut
        private var eth: web3.Eth { web3Provider.eth }

        /// Block to start getting history backward
        var block: BlockNumber

        /// Count of blocks to include in dataset
        var blockCount: BigUInt

        /// Percentiles
        ///
        /// This property set values by which dataset would be sliced.
        ///
        /// If you set it to `[25.0, 50.0, 75.0]` on any prediction property read you'll get
        /// `[71456911562, 92735433497, 105739785122]` which means that first item in array is more
        /// than 25% of the whole dataset, second one more than 50% of the dataset and third one
        /// more than 75% of the dataset.
        ///
        /// Another example: If you set it [100.0] you'll get the very highest value of a dataset e.g. max Tip amount.
        var percentiles: [Double]

        // TODO: Disabled until 3.0 version, coz will be enabled from 3.0.0.
//        var forceDropCache = false

        /// Oracle initializer
        /// - Parameters:
        ///   - provider: Web3 Ethereum provider
        ///   - block: Number of block from which counts starts backward
        ///   - blockCount: Count of block to calculate statistics
        ///   - percentiles: Percentiles of fees to which result of predictions will be split in
        public init(_ provider: web3, block: BlockNumber = .latest, blockCount: BigUInt = 20, percentiles: [Double] = [25, 50, 75]) {
            self.web3Provider = provider
            self.block = block
            self.blockCount = blockCount
            self.percentiles = percentiles
        }


        /// Returning one dimensional array from two dimensional array
        ///
        /// We've got `[[min],[middle],[max]]` 2 dimensional array
        /// we're getting `[min, middle, max].count == self.percentiles.count`,
        /// where each value are mean from the input percentile arrays
        ///
        /// - Parameter array: `[[min], [middle], [max]]` 2 dimensional array
        /// - Returns: `[min, middle, max].count == self.percentiles.count`
        private func soft(twoDimentsion array: [[BigUInt]]) -> [BigUInt] {
            array.compactMap { percentileArray -> [BigUInt]? in
                guard !percentileArray.isEmpty else { return nil }
                // swiftlint:disable force_unwrapping
                return [percentileArray.mean()!]
                // swiftlint:enable force_unwrapping
            }
            .flatMap { $0 }
        }

        /// Method calculates percentiles array based on `self.percetniles` value
        /// - Parameter data: Integer data from which percentiles should be calculated
        /// - Returns: Array of values which is in positions in dataset to given percentiles
        private func calculatePercentiles(for data: [BigUInt]) -> [BigUInt] {
            percentiles.compactMap { percentile in
                data.percentile(of: percentile)
            }
        }

        private func suggestGasValues() throws -> FeeHistory {
            // This is some kind of cache.
            // It stores about 9 seconds, than it rewrites it with newer data.
            // TODO: Disabled until 3.0 version, coz `distance` available from iOS 13.
//            guard feeHistory == nil, forceDropCache, feeHistory!.timestamp.distance(to: Date()) > cacheTimeout else { return feeHistory! }

            return try eth.feeHistory(blockCount: blockCount, block: block.hexValue, percentiles: percentiles)
        }

        /// Suggesting tip values
        /// - Returns: `[percentile_1, percentile_2, percentile_3, ...].count == self.percentile.count`
        /// by default there's 3 percentile.
        private func suggestTipValue() throws -> [BigUInt] {
            var rearrengedArray: [[BigUInt]] = []

            /// reaarange `[[min, middle, max]]` to `[[min], [middle], [max]]`
            try suggestGasValues().reward
                .forEach { percentiles in
                    percentiles.enumerated().forEach { (index, percentile) in
                        /// if `rearrengedArray` have not that enough items
                        /// as `percentiles` current item index
                        if rearrengedArray.endIndex <= index {
                            /// append its as an array
                            rearrengedArray.append([percentile])
                        } else {
                            /// append `percentile` value to appropriate `percentiles` array.
                            rearrengedArray[index].append(percentile)
                        }
                    }
                }
            return soft(twoDimentsion: rearrengedArray)
        }

        private func suggestBaseFee() throws -> [BigUInt] {
            self.feeHistory = try suggestGasValues()
            return calculatePercentiles(for: feeHistory!.baseFeePerGas)
        }

        private func suggestGasFeeLegacy() throws -> [BigUInt] {
            var latestBlockNumber: BigUInt = 0
            switch block {
            case .latest: latestBlockNumber = try eth.getBlockNumber()
            case let .exact(number): latestBlockNumber = number
            }

            /// checking if latest block number is greather than number of blocks to take in account
            /// we're ignoring case when `latestBlockNumber` == `blockCount` since it's unlikely case
            /// which we could neglect
            guard latestBlockNumber > blockCount else { return [] }

            // TODO: Make me work with cache
            let lastNthBlockGasPrice = try (latestBlockNumber - blockCount ... latestBlockNumber)
                .map { try eth.getBlockByNumber($0, fullTransactions: true) }
                .flatMap { b -> [EthereumTransaction] in
                    b.transactions.compactMap { t -> EthereumTransaction? in
                        guard case let .transaction(transaction) = t else { return nil }
                        return transaction
                    }
                }
                .map { $0.meta?.gasPrice ?? 0 }

            return calculatePercentiles(for: lastNthBlockGasPrice)
        }
    }
}

public extension Web3.Oracle {
    // MARK: - Base Fee
    /// Soften baseFee amount
    ///
    /// - Returns: `[percentile_1, percentile_2, percentile_3, ...].count == self.percentile.count`
    /// empty array if failed to predict. By default there's 3 percentile.
    var baseFeePercentiles: [BigUInt] {
        guard let value = try? suggestBaseFee() else { return [] }
        return value
    }

    // MARK: - Tip
    /// Tip amount
    ///
    /// - Returns: `[percentile_1, percentile_2, percentile_3, ...].count == self.percentile.count`
    /// empty array if failed to predict. By default there's 3 percentile.
    var tipFeePercentiles: [BigUInt] {
        guard let value = try? suggestTipValue() else { return [] }
        return value
    }

    // MARK: - Summary fees
    /// Summary fees amount
    ///
    /// - Returns: `[percentile_1, percentile_2, percentile_3, ...].count == self.percentile.count`
    /// nil if failed to predict. By default there's 3 percentile.
    var bothFeesPercentiles: (baseFee: [BigUInt], tip: [BigUInt])? {
        var baseFeeArr: [BigUInt] = []
        var tipArr: [BigUInt] = []
        if let baseFee = try? suggestBaseFee() {
            baseFeeArr = baseFee
        }
        if let tip = try? suggestTipValue() {
            tipArr = tip
        }
        return (baseFee: baseFeeArr, tip: tipArr)
    }

    // MARK: - Legacy GasPrice
    /// Legacy gasPrice amount
    ///
    /// - Returns: `[percentile_1, percentile_2, percentile_3, ...].count == self.percentile.count`
    /// empty array if failed to predict. By default there's 3 percentile.
    var gasPriceLegacyPercentiles: [BigUInt] {
        guard let value = try? suggestGasFeeLegacy() else { return [] }
        return value
    }
}

extension Web3.Oracle {
    struct FeeHistory {
        let timestamp = Date()
        let baseFeePerGas: [BigUInt]
        let gasUsedRatio: [Double]
        let oldestBlock: BigUInt
        let reward: [[BigUInt]]
    }
}

extension Web3.Oracle.FeeHistory: Decodable {
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


public extension Web3 {
    /// Enum for convenient type safe work with block number
    enum BlockNumber {
        /// Latest block of a chain
        case latest
        /// Exact block number
        case exact(BigUInt)

        /// Block number as a string
        ///
        /// Could be `hexString` either `latest`
        internal var hexValue: String {
            switch self {
            case .latest: return "latest"
            case let .exact(number): return String(number, radix: 16).addHexPrefix()
            }
        }
    }
}
