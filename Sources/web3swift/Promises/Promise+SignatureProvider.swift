//
//  Promise+SignatureProvider.swift
//  
//
//  Created by Ostap Danylovych on 14.01.2022.
//

import Foundation
import PromiseKit

extension SignatureProvider {
    public func accounts(on queue: DispatchQueue) -> Promise<[EthereumAddress]> {
        Promise { resolver in
            queue.async {
                accounts { result in
                    switch result {
                    case .success(let accounts): resolver.fulfill(accounts)
                    case .failure(let error): resolver.reject(error)
                    }
                }
            }
        }
    }
    
    public func sign(transaction: EthereumTransaction,
                     with account: EthereumAddress,
                     using password: String,
                     on queue: DispatchQueue) -> Promise<EthereumTransaction> {
        Promise { resolver in
            queue.async {
                sign(transaction: transaction, with: account, using: password) { result in
                    switch result {
                    case .success(let transaction): resolver.fulfill(transaction)
                    case .failure(let error): resolver.reject(error)
                    }
                }
            }
        }
    }
    
    public func sign(message: Data,
                     with account: EthereumAddress,
                     using password: String,
                     on queue: DispatchQueue) -> Promise<Data> {
        Promise { resolver in
            queue.async {
                sign(message: message, with: account, using: password) { result in
                    switch result {
                    case .success(let signedData): resolver.fulfill(signedData)
                    case .failure(let error): resolver.reject(error)
                    }
                }
            }
        }
    }
}
