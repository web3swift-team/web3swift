//
//  Array+extensions.swift
//  
//
//  Created by Yaroslav Yashin on 11.07.2022.
//

import Foundation
import BigInt

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
