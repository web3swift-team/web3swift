//
//  Web3Legacy+Instance.swift
//  web3swift
//
//  Created by Anton Grigorev on 21.11.2018.
//  Copyright © 2018 The Matter Inc. All rights reserved.
//

import Foundation

extension web3 {
    @available(*, deprecated, message: "Use ERC721 separate class")
    public class ERC721: Web3OptionsInheritable {
        var provider:Web3Provider
        //        weak var web3: web3?
        var web3: web3
        public var options: Web3Options {
            return self.web3.options
        }
        public init(provider prov: Web3Provider, web3 web3instance: web3) {
            provider = prov
            web3 = web3instance
        }
    }
}
