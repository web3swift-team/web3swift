//
//  EthereumStringEncodingExtensions.swift
//  web3swift
//
//  Created by Alexander Vlasov on 09.05.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
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
        return self.toHexString().addHexPrefix()
    }
}

extension EthereumAddress: EventFilterEncodable {
    public func eventFilterEncoded() -> String? {
        return self.address
    }
}

extension String: EventFilterEncodable {
    public func eventFilterEncoded() -> String? {
        guard let data = self.data(using: .utf8) else {return nil}
        return data.sha3(.keccak256).toHexString().addHexPrefix()
    }
}


