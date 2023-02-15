//
//  IntegerInitableWithRadix.swift
//
//
//  Created by Yaroslav Yashin on 12.07.2022.
//

import Foundation
import BigInt

public protocol IntegerInitableWithRadix {
    init?<S: StringProtocol>(_ text: S, radix: Int)
}

extension Int: IntegerInitableWithRadix { }

extension UInt: IntegerInitableWithRadix { }

extension BigInt: IntegerInitableWithRadix { }

extension BigUInt: IntegerInitableWithRadix { }
