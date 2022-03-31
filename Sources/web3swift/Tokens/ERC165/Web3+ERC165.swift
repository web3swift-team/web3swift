//
//  Web3+ERC165.swift
//  web3swift-iOS
//
//  Created by Anton Grigorev on 15/12/2018.
//  Copyright © 2018 The Matter Inc. All rights reserved.
//

import Foundation

// Standard Interface Detection
protocol IERC165 {

    func supportsInterface(interfaceID: String) throws -> Bool

}
