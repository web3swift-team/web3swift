//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import Web3Core

/// The default http provider.
public class Web3HttpProvider: Web3Provider {
    public var url: URL
    public var network: Networks?
    public var policies: Policies = .auto
    public var attachedKeystoreManager: KeystoreManager?
    public var session: URLSession = {() -> URLSession in
        let config = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: config)
        return urlSession
    }()

    @available(*, deprecated, message: "Will be removed in Web3Swift v4. Please use `init(url: URL, network: Networks?, keystoreManager: KeystoreManager?)` instead as it will throw an error instead of returning `nil` value.")
    public convenience init?(_ httpProviderURL: URL, network net: Networks?, keystoreManager manager: KeystoreManager? = nil) async {
        try? await self.init(url: httpProviderURL, network: net, keystoreManager: manager)
    }

    public init(url: URL, network net: Networks?, keystoreManager manager: KeystoreManager? = nil) async throws {
        guard url.scheme == "http" || url.scheme == "https" else {
            throw Web3Error.inputError(desc: "Web3HttpProvider endpoint must have scheme http or https. Given scheme \(url.scheme ?? "none"). \(url.absoluteString)")
        }

        self.url = url
        if let net = net {
            network = net
        } else {
            var urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData)
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
            urlRequest.httpMethod = APIRequest.getNetwork.call
            urlRequest.httpBody = APIRequest.getNetwork.encodedBody
            let response: APIResponse<UInt> = try await APIRequest.send(uRLRequest: urlRequest, with: session)
            self.network = Networks.fromInt(response.result)
        }
        attachedKeystoreManager = manager
    }

    public init(url: URL, network: Networks, keystoreManager: KeystoreManager? = nil) {
        self.url = url
        self.network = network
        self.attachedKeystoreManager = keystoreManager
    }
}
