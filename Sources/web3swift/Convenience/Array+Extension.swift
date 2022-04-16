//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt

extension Array {
    public func split(intoChunksOf chunkSize: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: chunkSize).map {
            let endIndex = ($0.advanced(by: chunkSize) > self.count) ? self.count - $0 : chunkSize
            return Array(self[$0..<$0.advanced(by: endIndex)])
        }
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
    // TODO: Make me generic
    /// Calculates mean value of a dataset
    /// - Returns: Mean value of a dataset, nil if dataset is empty
    func mean() -> BigUInt? {
        guard !self.isEmpty else { return nil }
        return BigUInt(self.reduce(0, +)) / BigUInt(self.count)
    }


    /// Calculates percentile of dataset on which get called.
    /// - Parameter value: Percentile value.
    /// - Returns: Item from dataset that is belongs to given percentile, nil if dataset is empty.
    func percentile(of value: Double) -> Element? {
        guard !self.isEmpty else { return nil }

        let normalizedValue = value / 100 * Double(self.count)
        let index = Int(ceil(normalizedValue))

        let sorted_data = self.sorted()
        guard index < self.count else { return sorted_data[sorted_data.count - 1] }
        return sorted_data[index]
    }
}
