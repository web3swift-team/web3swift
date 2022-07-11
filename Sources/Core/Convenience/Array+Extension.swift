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
