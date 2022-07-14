//
//  Web3Provider.swift
//  
//
//  Created by Yaroslav Yashin on 11.07.2022.
//

import Foundation

/// Providers abstraction for custom providers (websockets, other custom private key managers). At the moment should not be used.
public protocol Web3Provider {
    var network: Networks? {get set}
    var attachedKeystoreManager: KeystoreManager? {get set}
    var url: URL {get}
    var session: URLSession {get}
}
