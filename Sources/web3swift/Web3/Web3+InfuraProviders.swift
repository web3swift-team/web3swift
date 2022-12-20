//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import Core

/// Custom Web3 HTTP provider of Infura nodes.
public final class InfuraProvider: Web3HttpProvider {
    public init?(_ net: Networks,
                 accessToken token: String? = nil,
                 keystoreManager: KeystoreManager? = nil) async {
        let rawUrl = "https://" + net.name + Constants.infuraHttpScheme
        guard let url = URL(string: rawUrl) else { return nil }
        await super.init(url.appendingPathComponent(token ?? ""),
                         network: net,
                         keystoreManager: keystoreManager)
    }
}

/// Custom Websocket provider of Infura nodes.
public final class InfuraWebsocketProvider: Web3SocketProvider {
    public convenience init?(_ network: Networks,
                             forwarder: Web3SocketMessageForwarder? = nil,
                             token: String? = nil,
                             keystoreManager: KeystoreManager? = nil) {
        guard let url = URL(string: "wss://" + network.name + Constants.infuraWsScheme) else { return nil }
        self.init(url.appendingPathComponent(token ?? ""),
                  forwarder: forwarder,
                  keystoreManager: keystoreManager)

    }

    public convenience init?(_ endpoint: String,
                             forwarder: Web3SocketMessageForwarder? = nil,
                             keystoreManager: KeystoreManager? = nil) {
        guard let endpoint = URL(string: endpoint) else { return nil }
        self.init(endpoint,
                  forwarder: forwarder,
                  keystoreManager: keystoreManager)
    }

    public convenience init?(_ endpoint: URL,
                             forwarder: Web3SocketMessageForwarder? = nil,
                             keystoreManager: KeystoreManager? = nil) {
        guard ["wss", "ws"].contains(endpoint.scheme) else { return nil }
        self.init(DefaultWeb3SocketClient(url: endpoint),
                  forwarder: forwarder,
                  keystoreManager: keystoreManager)
    }
}


