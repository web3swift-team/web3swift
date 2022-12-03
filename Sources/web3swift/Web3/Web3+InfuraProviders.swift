//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//
import Foundation
import BigInt
import Web3Core

/// Custom Web3 HTTP provider of Infura nodes.
public final class InfuraProvider: Web3HttpProvider {
    public init?(_ net: Networks, accessToken token: String? = nil, keystoreManager manager: KeystoreManager? = nil) async {
        var requestURLstring = "https://" + net.name + Constants.infuraHttpScheme
        requestURLstring += token ?? Constants.infuraToken
        let providerURL = URL(string: requestURLstring)
        await super.init(providerURL!, network: net, keystoreManager: manager)
    }
}
