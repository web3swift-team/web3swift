//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt

extension BigUInt: EventFilterEncodable {
    public func eventFilterEncoded() -> String? {
        return self.abiEncode(bits: 256)?.toHexString().addHexPrefix()
    }
}

extension BigInt: EventFilterEncodable {
    public func eventFilterEncoded() -> String? {
        return self.abiEncode(bits: 256)?.toHexString().addHexPrefix()
    }
}

extension Data: EventFilterEncodable {
    public func eventFilterEncoded() -> String? {
        guard let padded = self.setLengthLeft(32) else {return nil}
        return padded.toHexString().addHexPrefix()
    }
}

extension EthereumAddress: EventFilterEncodable {
    public func eventFilterEncoded() -> String? {
        guard let padded = self.addressData.setLengthLeft(32) else {return nil}
        return padded.toHexString().addHexPrefix()
    }
}

extension String: EventFilterEncodable {
    public func eventFilterEncoded() -> String? {
        guard let data = self.data(using: .utf8) else {return nil}
        return data.sha3(.keccak256).toHexString().addHexPrefix()
    }
}
