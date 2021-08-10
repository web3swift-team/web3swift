//
//  Web3+ERC820.swift
//  web3swift-iOS
//
//  Created by Anton Grigorev on 15/12/2018.
//  Copyright © 2018 The Matter Inc. All rights reserved.
//

import Foundation
//import EthereumAddress

//Pseudo-introspection using a registry contract
protocol IERC820: IERC165 {
    func canImplementInterfaceForAddress(interfaceHash: Data, addr: EthereumAddress) throws -> Data
    func getInterfaceImplementer(addr: EthereumAddress, interfaceHash: Data) throws -> EthereumAddress
    func setInterfaceImplementer(from: EthereumAddress, addr: EthereumAddress, interfaceHash: Data, implementer: EthereumAddress) throws -> WriteTransaction
    func setManager(from: EthereumAddress, addr: EthereumAddress, newManager: EthereumAddress) throws -> WriteTransaction
    func interfaceHash(interfaceName: String) throws -> Data
    func updateERC165Cache(from: EthereumAddress, contract: EthereumAddress, interfaceId: [UInt8]) throws -> WriteTransaction
}
