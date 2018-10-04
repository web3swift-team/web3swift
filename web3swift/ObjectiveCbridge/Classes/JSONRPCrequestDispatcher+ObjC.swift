//
//  JSONRPCrequestDispatcher.swift
//  web3swift-iOS
//
//  Created by Anton Grigorev on 19.09.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation

@objc(JSONRPCrequestDispatcher)
public final class _ObjCJSONRPCrequestDispatcher: NSObject {
    
    private (set) var jsonRPCrequestDispatcher: JSONRPCrequestDispatcher?
    
    // TODO: -DispatchQueue
    init(provider: _ObjCWeb3HttpProvider, queue: DispatchQueue, policy: _ObjCDispatchPolicy) {
        guard let provider = provider.web3Provider else {return}
        let _policy: JSONRPCrequestDispatcher.DispatchPolicy
        switch policy.value {
        case 0:
            _policy = JSONRPCrequestDispatcher.DispatchPolicy.NoBatching
        default:
            _policy = JSONRPCrequestDispatcher.DispatchPolicy.Batch(Int(policy.batchValue))
        }
        self.jsonRPCrequestDispatcher = JSONRPCrequestDispatcher(provider: provider, queue: queue, policy: _policy)
    }
    
    struct _ObjCDispatchPolicy {
        var value: UInt32 = 0
        var batchValue: UInt32 = 0
        init(_ val: UInt32, batchVal: UInt32 = 0) {
            value = val
            if val != 0 {
                batchValue = batchVal
            }
        }
        
    }
    
}
