//
//  Web3+Instance.swift
//  web3swift
//
//  Created by Alexander Vlasov on 19.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import Foundation
import PromiseKit
import BigInt

public struct web3 {
    var provider:Web3Provider
    public func send(request: JSONRPCrequest) -> Promise<[String: Any]?> {
        return self.provider.send(request: request)
    }
    public init(provider prov: Web3Provider) {
        provider = prov
    }
    public var eth: web3.Eth {
        let ethInstance = web3.Eth(provider : self.provider)
        return ethInstance
    }
    
    public struct Eth {
        var provider:Web3Provider
        public init(provider prov: Web3Provider) {
            provider = prov
        }
    }

}
