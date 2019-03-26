//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation

/// Custom Web3 HTTP provider of Nodesmith nodes.
public final class NodesmithProvider: Web3HttpProvider {
    public init?(_ network:Networks, apiKey: String, keystoreManager manager: KeystoreManager? = nil) {
        let nodesmithEndpoint = "https://ethereum.api.nodesmith.io/v1/\(network.name)/jsonrpc?apiKey=\(apiKey)"
        let providerURL = URL(string: nodesmithEndpoint)
        super.init(providerURL!, network: network, keystoreManager: manager)
    }
}
