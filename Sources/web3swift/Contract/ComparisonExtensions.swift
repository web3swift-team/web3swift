//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
//import EthereumAddress

extension BigUInt: EventFilterComparable {
    public func isEqualTo(_ other: AnyObject) -> Bool {
        switch other {
        case let oth as BigUInt:
            return self == oth
        case let oth as BigInt:
            return self.magnitude == oth.magnitude && self.signum() == oth.signum()
        default:
            return false
        }
    }
}

extension BigInt: EventFilterComparable {
    public func isEqualTo(_ other: AnyObject) -> Bool {
        switch other {
        case let oth as BigInt:
            return self == oth
        case let oth as BigUInt:
            return self.magnitude == oth.magnitude && self.signum() == oth.signum()
        default:
            return false
        }
    }
}

extension String: EventFilterComparable {
    public func isEqualTo(_ other: AnyObject) -> Bool {
        switch other {
        case let oth as String:
            guard let data = self.data(using: .utf8) else {return false}
            guard let otherData = oth.data(using: .utf8) else {return false}
            let hash = data.sha3(.keccak256)
            let otherHash = otherData.sha3(.keccak256)
            return hash == otherHash
        case let oth as Data:
            guard let data = self.data(using: .utf8) else {return false}
            let hash = data.sha3(.keccak256)
            let otherHash = oth.sha3(.keccak256)
            return hash == otherHash
        default:
            return false
        }
    }
}

extension Data: EventFilterComparable {
    public func isEqualTo(_ other: AnyObject) -> Bool {
        switch other {
        case let oth as String:
            guard let data = Data.fromHex(oth) else {return false}
            if self == data {
                return true
            }
            let hash = data.sha3(.keccak256)
            return self == hash
        case let oth as Data:
            if self == oth {
                return true
            }
            let hash = oth.sha3(.keccak256)
            return self == hash
        default:
            return false
        }
    }
}

extension EthereumAddress: EventFilterComparable {
    public func isEqualTo(_ other: AnyObject) -> Bool {
        switch other {
        case let oth as String:
            let addr = EthereumAddress(oth)
            return self == addr
        case let oth as Data:
            let addr = EthereumAddress(oth)
            return self == addr
        case let oth as EthereumAddress:
            return self == oth
        default:
            return false
        }
    }
}

