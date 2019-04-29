//
//  Tools.swift
//  BigInt
//
//  Created by Károly Lőrentey on 2017-7-23.
//  Copyright © 2017 Károly Lőrentey. All rights reserved.
//

import BigInt

@inline(never)
func noop<T>(_ value: T) {
    _ = value
}

// A basic low-quality random number generator.
struct PseudoRandomNumbers: Sequence, IteratorProtocol {
    typealias Element = BigUInt.Word
    var last: Element

    init(seed: Element) {
        self.last = seed
    }

    mutating func next() -> Element? {
        // Constants are from Knuth's MMIX and Numerical Recipes, respectively
        let a: Element = (Element.bitWidth == 8 ? 6364136223846793005 : 1664525)
        let c: Element = (Element.bitWidth == 8 ? 1442695040888963407 : 1013904223)
        last = a &* last &+ c
        return last
    }
}

func convertWords<S: Sequence>(_ wideWords: S) -> [UInt] where S.Element == UInt64 {
    return wideWords.flatMap { $0.words }
}

extension String {
    func repeated(_ count: Int) -> String {
        var result = ""
        for _ in 0 ..< count {
            result += self
        }
        return result
    }
}


