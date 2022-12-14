//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//
//  EIP-2718 Envelope Support by Mark Loit 2022

import Foundation
import BigInt

// EIP-2718 is an abstract envelope type
// All typed transactions should inherit from this type and not AbstractEnvelope
// This is just a convenience handle so we can extend with default implementations for EIP-2718 type transactions (currently EIP-2930 and EIP-1559)
protocol EIP2718Envelope: AbstractEnvelope {
    // type: -- Technically 'type' should be here, but it was promoted up to AbstractEnvelope, so we could wrap a LegacyTransaction as well
}

// Default implementation of some functions that are not likely to be different for any transaction type
extension EIP2718Envelope {
    public func getUnmarshalledSignatureData() -> SECP256K1.UnmarshaledSignature? {
        if self.r == 0 && self.s == 0 { return nil }
        guard let rData = self.r.serialize().setLengthLeft(32) else { return nil }
        guard let sData = self.s.serialize().setLengthLeft(32) else { return nil }
        return SECP256K1.UnmarshaledSignature(v: UInt8(self.v), r: rData, s: sData)
    }

    public mutating func setUnmarshalledSignatureData(_ unmarshalledSignature: SECP256K1.UnmarshaledSignature) {
        self.v = BigUInt(unmarshalledSignature.v) - 27 // our SECP256K1 lib is be hardcoded to return 27/28 instead of 0/1
        self.r = BigUInt(unmarshalledSignature.r)
        self.s = BigUInt(unmarshalledSignature.s)
    }
}
