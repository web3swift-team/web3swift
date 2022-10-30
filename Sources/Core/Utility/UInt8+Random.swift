//
//  File.swift
//  
//
//  Created by Ronald Mannak on 10/29/22.
//

import Foundation

#if os(Linux)
extension FixedWidthInteger {
    public static func randomData() -> Self {
        return Self.random(in: .min ... .max)
    }

    public static func randomData<T>(using generator: inout T) -> Self
        where T : RandomNumberGenerator
    {
        return Self.random(in: .min ... .max, using: &generator)
    }
}

extension Array where Element: FixedWidthInteger {
    public static func randomData(count: Int) -> [Element] {
        var array: [Element] = .init(repeating: 0, count: count)
        (0..<count).forEach { array[$0] = Element.random() }
        return array
    }

    public static func randomData<T>(count: Int, using generator: inout T) -> [Element]
        where T: RandomNumberGenerator
    {
        var array: [Element] = .init(repeating: 0, count: count)
        (0..<count).forEach { array[$0] = Element.random() }
        return array
    }
}
#endif
