//
//  GasOracle.swift
//
//  Created by Yaroslav on 31.03.2022.
//  Copyright © 2022 web3swift. All rights reserved.
//

import Foundation
import BigInt

/// Oracle is the class to do a transaction fee suggestion
final public class Oracle {

    /// Web3 provider by which accessing to the blockchain
    private let web3Provider: Web3Provider

    private var feeHistory: FeeHistory?

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

    var forceDropCache = false

    var cacheTimeout: Double

    /// Oracle initializer
    /// - Parameters:
    ///   - provider: Web3 Ethereum provider
    ///   - block: Number of block from which counts starts backward
    ///   - blockCount: Count of block to calculate statistics
    ///   - percentiles: Percentiles of fees to which result of predictions will be split in
    public init(_ provider: Web3Provider, block: BlockNumber = .latest, blockCount: BigUInt = 20, percentiles: [Double] = [25, 50, 75], cacheTimeout: Double = 10) {
        self.web3Provider = provider
        self.block = block
        self.blockCount = blockCount
        self.percentiles = percentiles
        self.cacheTimeout = cacheTimeout
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

    private func suggestGasValues() async throws -> FeeHistory {
        /// This is some kind of cache.
        /// It stores about 10 seconds, than it rewrites it with newer data.

        /// We're explicitly checking that feeHistory is not nil before force unwrapping it.
        guard let feeHistory = feeHistory, !forceDropCache, feeHistory.timestamp.distance(to: Date()) < cacheTimeout else {
            // swiftlint: disable force_unwrapping
            let result: FeeHistory = try await combineRequest(request: .feeHistory(blockCount, block, percentiles))
            feeHistory = result
            return feeHistory!
            // swiftlint: enable force_unwrapping
        }

        return feeHistory
    }

    /// Suggesting tip values
    /// - Returns: `[percentile_1, percentile_2, percentile_3, ...].count == self.percentile.count`
    /// by default there's 3 percentile.
    private func suggestTipValue() async throws -> [BigUInt] {
        var rearrengedArray: [[BigUInt]] = []

        /// rearrange `[[min, middle, max]]` to `[[min], [middle], [max]]`
        try await suggestGasValues().reward
            .forEach { percentiles in
                percentiles.enumerated().forEach { index, percentile in
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

    private func suggestBaseFee() async throws -> [BigUInt] {
        self.feeHistory = try await suggestGasValues()
        return calculatePercentiles(for: feeHistory!.baseFeePerGas)
    }

    private func combineRequest<Result>(request: APIRequest) async throws-> Result where Result: APIResultType {
        let response: APIResponse<Result> = try await APIRequest.sendRequest(with: self.web3Provider, for: request)
        return response.result
    }

    private func suggestGasFeeLegacy() async throws -> [BigUInt] {
        var latestBlockNumber: BigUInt = 0
        switch block {
        case .latest:
            let block: BigUInt = try await combineRequest(request: .blockNumber)
            latestBlockNumber = block
        case let .exact(number): latestBlockNumber = number
        default: throw Web3Error.valueError(desc: "Unable to use '\(block)' policy to resolve block number to calculate gas fee suggestion.")
        }

        /// checking if latest block number is greater than number of blocks to take in account
        /// we're ignoring case when `latestBlockNumber` == `blockCount` since it's unlikely case
        /// which we could neglect
        guard latestBlockNumber > blockCount else { return [] }

        // TODO: Make me work with cache
        let blocks = try await withThrowingTaskGroup(of: Block.self, returning: [Block].self) { group in
            (latestBlockNumber - blockCount ... latestBlockNumber)
                .forEach { block in
                    group.addTask {
                        let result: Block = try await self.combineRequest(request: .getBlockByNumber(.exact(block), true))
                        return result
                    }
                }

            var collected = [Block]()

            for try await value in group {
                collected.append(value)
            }

            return collected
        }

        let lastNthBlockGasPrice = blocks.flatMap { b -> [CodableTransaction] in
            b.transactions.compactMap { t -> CodableTransaction? in
                guard case let .transaction(transaction) = t else { return nil }
                return transaction
            }
        }
            .compactMap { $0.meta?.gasPrice ?? 0 }

        return calculatePercentiles(for: lastNthBlockGasPrice)
    }
}

public extension Oracle {
    // MARK: - Base Fee
    /// Soften baseFee amount
    ///
    /// - Returns: `[percentile_1, percentile_2, percentile_3, ...].count == self.percentile.count`
    /// empty array if failed to predict. By default there's 3 percentile.
    func baseFeePercentiles() async -> [BigUInt] {
        guard let value = try? await suggestBaseFee() else { return [] }
        return value
    }

    // MARK: - Tip
    /// Tip amount
    ///
    /// - Returns: `[percentile_1, percentile_2, percentile_3, ...].count == self.percentile.count`
    /// empty array if failed to predict. By default there's 3 percentile.
    func tipFeePercentiles() async -> [BigUInt] {
        guard let value = try? await suggestTipValue() else { return [] }
        return value
    }

    // MARK: - Summary fees
    /// Summary fees amount
    ///
    /// - Returns: `[percentile_1, percentile_2, percentile_3, ...].count == self.percentile.count`
    /// nil if failed to predict. By default there's 3 percentile.
    func bothFeesPercentiles() async -> (baseFee: [BigUInt], tip: [BigUInt])? {
        var baseFeeArr: [BigUInt] = []
        var tipArr: [BigUInt] = []
        if let baseFee = try? await suggestBaseFee() {
            baseFeeArr = baseFee
        }
        if let tip = try? await suggestTipValue() {
            tipArr = tip
        }
        return (baseFee: baseFeeArr, tip: tipArr)
    }

    // MARK: - Legacy GasPrice
    /// Legacy gasPrice amount
    ///
    /// - Returns: `[percentile_1, percentile_2, percentile_3, ...].count == self.percentile.count`
    /// empty array if failed to predict. By default there's 3 percentile.
    func gasPriceLegacyPercentiles() async -> [BigUInt] {
        guard let value = try? await suggestGasFeeLegacy() else { return [] }
        return value
    }
}

extension Oracle {
    public struct FeeHistory {
        public let timestamp = Date()
        public let baseFeePerGas: [BigUInt]
        public let gasUsedRatio: [Double]
        public let oldestBlock: BigUInt
        public let reward: [[BigUInt]]
    }
}

extension Oracle.FeeHistory: Decodable {
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

extension Oracle.FeeHistory: APIResultType { }
