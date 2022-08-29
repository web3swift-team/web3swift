//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import Core

public protocol EventFilterComparable {
    func isEqualTo(_ other: AnyObject) -> Bool
}

public protocol EventFilterEncodable {
    func eventFilterEncoded() -> String?
}

public protocol EventFilterable: EventFilterComparable, EventFilterEncodable { }

extension BigUInt: EventFilterable {
    public func eventFilterEncoded() -> String? {
        return self.abiEncode(bits: 256)?.toHexString().addHexPrefix()
    }
}

extension BigInt: EventFilterable {
    public func eventFilterEncoded() -> String? {
        return self.abiEncode(bits: 256)?.toHexString().addHexPrefix()
    }
}

extension Data: EventFilterable {
    public func eventFilterEncoded() -> String? {
        guard let padded = self.setLengthLeft(32) else {return nil}
        return padded.toHexString().addHexPrefix()
    }
}

extension EthereumAddress: EventFilterable {
    public func eventFilterEncoded() -> String? {
        guard let padded = self.addressData.setLengthLeft(32) else {return nil}
        return padded.toHexString().addHexPrefix()
    }
}

extension String: EventFilterable {
    public func eventFilterEncoded() -> String? {
        guard let data = self.data(using: .utf8) else {return nil}
        return data.sha3(.keccak256).toHexString().addHexPrefix()
    }
}
