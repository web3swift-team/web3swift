//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt

@objc(BigUInt)
public final class _ObjCBigUInt: NSObject{
    private (set) var biguint: BigUInt?
    
    public init(value: String) {
        self.biguint = BigUInt(value)
    }
    
    public init(value: String, radix: Int) {
        self.biguint = BigUInt(value, radix: radix)
    }
    
    init(value: BigUInt) {
        self.biguint = value
    }
    
    public func toString(radix: Int = 10) -> NSString {
        guard let val = self.biguint else {return "" as NSString}
        return String(val, radix: radix) as NSString
    }
}
