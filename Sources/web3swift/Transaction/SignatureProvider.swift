//
//  SignatureProvider.swift
//  
//
//  Created by Ostap Danylovych on 12.01.2022.
//

import Foundation

public protocol SignatureProvider {
    func sign(transaction: EthereumTransaction, with account: EthereumAddress) throws
    func sign(message: Data, with account: EthereumAddress) throws
}
