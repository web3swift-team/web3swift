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
            /// chain id could be a hex string or an int value.
            let response: String = try await APIRequest.send(APIRequest.getNetwork.call, parameters: [], with: self).result
            let result: UInt
            if response.hasHexPrefix() {
                guard let num = BigUInt(response, radix: 16)  else {
                    throw Web3Error.processingError(desc: "Get network succeeded but can't be parsed to a valid chain id.")
                }
                result = UInt(num)
            } else {
                guard let num = UInt(response) else {
                    throw Web3Error.processingError(desc: "Get network succeeded but can't be parsed to a valid chain id.")
                }
                result = num
            }
            self.network = Networks.fromInt(result)
        }
        attachedKeystoreManager = manager
    }

    public init(url: URL, network: Networks, keystoreManager: KeystoreManager? = nil) {
        self.url = url
        self.network = network
        self.attachedKeystoreManager = keystoreManager
    }
}
