//
//  Web3+ERC1400.swift
//  web3swift-iOS
//
//  Created by Anton Grigorev on 14/12/2018.
//  Copyright © 2018 The Matter Inc. All rights reserved.
//

import Foundation
import BigInt
import EthereumAddress
import PromiseKit

// ERC1400 = ERC20 + IERC1400
protocol IERC1400 {
    
    // Document Management
    func getDocument(name: Data) throws -> (String, Data)
    func setDocument(name: Data, uri: String, documentHash: Data) throws -> WriteTransaction
    
    // Token Information
    func balanceOfByPartition(partition: Data, tokenHolder: EthereumAddress) throws -> BigUInt
    func partitionsOf(tokenHolder: EthereumAddress) throws -> [Data]
    
    // Transfers
    func transferWithData(from: EthereumAddress, to: EthereumAddress, amount: String, data: [UInt8]) throws -> WriteTransaction
    func transferFromWithData(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, amount: String, data: [UInt8]) throws -> WriteTransaction
    
    // Partition Token Transfers
    func transferByPartition(partition: Data, from: EthereumAddress, to: EthereumAddress, amount: String, data: [UInt8]) throws -> WriteTransaction
    func operatorTransferByPartition(partition: Data, from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, amount: String, data: [UInt8]) throws -> WriteTransaction
    
    // Controller Operation
    func isControllable() throws -> Bool
    func controllerTransfer(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, amount: String, data: [UInt8], operatorData: [UInt8]) throws -> WriteTransaction
    func controllerRedeem(from: EthereumAddress, to: EthereumAddress, amount: String, data: [UInt8], operatorData: [UInt8]) throws -> WriteTransaction
    
    // Operator Management
    func authorizeOperator(operator: EthereumAddress) throws -> WriteTransaction
    func revokeOperator(operator: EthereumAddress) throws -> WriteTransaction
    func authorizeOperatorByPartition(partition: Data, operator: EthereumAddress) throws -> WriteTransaction
    func revokeOperatorByPartition(partition: Data, operator: EthereumAddress) throws -> WriteTransaction
    
    // Operator Information
    func isOperator(operator: EthereumAddress, tokenHolder: EthereumAddress) throws -> Bool
    func isOperatorForPartition(partition: Data, operator: EthereumAddress, tokenHolder: EthereumAddress) throws -> Bool
    
    // Token Issuance
    func isIssuable() throws -> Bool
    func issue(from: EthereumAddress, tokenHolder: EthereumAddress, amount: String, data: [UInt8]) -> WriteTransaction
    func issueByPartition(partition: Data, from: EthereumAddress, tokenHolder: EthereumAddress, amount: String, data: [UInt8]) -> WriteTransaction
    
    // Token Redemption
    func redeem(from: EthereumAddress, amount: String, data: [UInt8]) throws -> WriteTransaction
    func redeemFrom(tokenHolder: EthereumAddress, from: EthereumAddress, amount: String, data: [UInt8]) throws -> WriteTransaction
    func redeemByPartition(partition: Data, from: EthereumAddress, amount: String, data: [UInt8]) throws -> WriteTransaction
    func operatorRedeemByPartition(partition: Data, tokenHolder: EthereumAddress, from: EthereumAddress, amount: String, operatorData: [UInt8]) throws -> WriteTransaction
    
    // Transfer Validity
    func canTransfer(to: EthereumAddress, amount: String, data: [UInt8]) throws -> ([UInt8], Data)
    func canTransferFrom(originalOwner: EthereumAddress, to: EthereumAddress, amount: String, data: [UInt8]) throws -> ([UInt8], Data)
    func canTransferByPartition(originalOwner: EthereumAddress, to: EthereumAddress, partition: Data, amount: String, data: [UInt8]) throws -> ([UInt8], Data, Data)
}

// This namespace contains functions to work with ERC1400 tokens.
// variables are lazyly evaluated or global token information (name, ticker, total supply)
// can be imperatively read and saved
