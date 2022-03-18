//
//  Web3+ERC820.swift
//  web3swift-iOS
//
//  Created by Anton Grigorev on 15/12/2018.
//  Copyright © 2018 The Matter Inc. All rights reserved.
//

import Foundation

//Pseudo-introspection using a registry contract
protocol IERC820: IERC165 {
    func canImplementInterfaceForAddress(interfaceHash: Data, addr: EthereumAddress) async throws -> Data
    func getInterfaceImplementer(addr: EthereumAddress, interfaceHash: Data) async throws -> EthereumAddress
    func setInterfaceImplementer(from: EthereumAddress, addr: EthereumAddress, interfaceHash: Data, implementer: EthereumAddress) async throws -> WriteTransaction
    func setManager(from: EthereumAddress, addr: EthereumAddress, newManager: EthereumAddress) async throws -> WriteTransaction
    func interfaceHash(interfaceName: String) async throws -> Data
    func updateERC165Cache(from: EthereumAddress, contract: EthereumAddress, interfaceId: [UInt8]) async throws -> WriteTransaction
}
