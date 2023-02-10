//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//
import Foundation
import BigInt
import Web3Core

/// Custom Web3 HTTP provider of Infura nodes.
public final class InfuraProvider: Web3HttpProvider {

    @available(*, deprecated, message: "Will be removed in Web3Swift v4. Please use `init(net: Networks, accessToken: String?, keystoreManager: KeystoreManager?)` instead as it will throw an error instead of returning `nil`.")
    public convenience init?(_ net: Networks, accessToken token: String? = nil, keystoreManager manager: KeystoreManager? = nil) async {
        try? await self.init(net: net, accessToken: token, keystoreManager: manager)
    }

    public init(net: Networks, accessToken token: String? = nil, keystoreManager manager: KeystoreManager? = nil) async throws {
        var requestURLstring = "https://" + net.name + Constants.infuraHttpScheme
        requestURLstring += token ?? Constants.infuraToken
        guard let providerURL = URL(string: requestURLstring) else {
            throw Web3Error.inputError(desc: "URL created with token \(token ?? "Default token - \(Constants.infuraToken)") is not a valid URL: \(requestURLstring)")
        }
        try await super.init(url: providerURL, network: net, keystoreManager: manager)
    }
}
