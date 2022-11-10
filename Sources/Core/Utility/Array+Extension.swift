//
//  Extensions.swift
//  EthereumAddress
//
//  Created by Alex Vlasov on 25/10/2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt

extension Array where Element == UInt8 {
    init(hex: String) {
        self.init()
        self.reserveCapacity(hex.unicodeScalars.lazy.underestimatedCount)
        var buffer: UInt8?
        var skip = hex.hasPrefix("0x") ? 2 : 0
        for char in hex.unicodeScalars.lazy {
            guard skip == 0 else {
                skip -= 1
                continue
            }
            guard char.value >= 48 && char.value <= 102 else {
                removeAll()
                return
            }
            let v: UInt8
            let c: UInt8 = UInt8(char.value)
            switch c {
            case let c where c <= 57:
                v = c - 48
            case let c where c >= 65 && c <= 70:
                v = c - 55
            case let c where c >= 97:
                v = c - 87
            default:
                removeAll()
                return
            }
            if let b = buffer {
                append(b << 4 | v)
                buffer = nil
            } else {
                buffer = v
            }
        }
        if let b = buffer {
            append(b)
        }
    }

    func toHexString() -> String {
        return `lazy`.reduce("") {
            var s = String($1, radix: 16)
            if s.count == 1 {
                s = "0" + s
            }
            return $0 + s
        }
    }
}

extension Array {
    public func split(intoChunksOf chunkSize: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: chunkSize).map {
            let endIndex = ($0.advanced(by: chunkSize) > self.count) ? self.count - $0 : chunkSize
            return Array(self[$0..<$0.advanced(by: endIndex)])
        }
    }
}

extension Array where Element: Comparable {
    /// Sorts array and drops first and last values.
    /// - Returns: Sorted array without first and last values, nil if `array.count` <= 1
    func cropAnomalyValues() -> Self? {
        var sortedArray = self.sorted()
        // Array should at least have two values to pass that formations.
        guard sortedArray.count > 1 else { return nil }
        sortedArray.removeLast()
        sortedArray.removeFirst()
        return sortedArray
    }
}

// MARK: - For Oracle
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
