//
//  SignatureProvider.swift
//  
//
//  Created by Ostap Danylovych on 12.01.2022.
//

import Foundation

public typealias SignatureProviderCallback<R> = (Result<R, Error>) -> Void

public protocol SignatureProvider {
    func accounts(_ cb: @escaping SignatureProviderCallback<[EthereumAddress]>)
    func sign(transaction: EthereumTransaction,
              with account: EthereumAddress,
              using password: String,
              _ cb: @escaping SignatureProviderCallback<EthereumTransaction>)
    func sign(message: Data,
              with account: EthereumAddress,
              using password: String,
              _ cb: @escaping SignatureProviderCallback<Data>)
}
