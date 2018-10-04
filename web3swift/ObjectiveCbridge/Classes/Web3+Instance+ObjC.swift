//
//  Web3Instnace+ObjectiveC.swift
//  web3swift
//
//  Created by Alexander Vlasov on 08.08.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation

@objc(web3)
public final class _ObjCweb3: NSObject {
    private (set) var _web3: web3?
    
    // TODO: - OperationQueue
    init(provider prov: _ObjCWeb3HttpProvider, requestDispatcher: _ObjCJSONRPCrequestDispatcher = Optional.none!) {
        guard let prov = prov.web3Provider else {return}
        self._web3 = web3(provider: prov, queue: nil, requestDispatcher: requestDispatcher.jsonRPCrequestDispatcher)
    }
    
    init(web3: web3) {
        self._web3 = web3
    }
    
    public var web3Eth: _ObjCweb3Eth {
        return _ObjCweb3Eth(web3: self)
    }
}

