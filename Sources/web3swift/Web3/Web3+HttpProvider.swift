//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Foundation
import BigInt
import Core

/// The default http provider.
public class Web3HttpProvider: Web3Provider {
    public var url: URL
    public var network: Networks?
    public var attachedKeystoreManager: KeystoreManager? = nil
    public var session: URLSession = {() -> URLSession in
        let config = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: config)
        return urlSession
    }()
    public init?(_ httpProviderURL: URL, network net: Networks?, keystoreManager manager: KeystoreManager? = nil) async {
        guard httpProviderURL.scheme == "http" || httpProviderURL.scheme == "https" else { return nil }
        url = httpProviderURL
        if let net = net {
            network = net
        } else {
            var urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData)
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
            urlRequest.httpMethod = APIRequest.getNetwork.call
            urlRequest.httpBody = APIRequest.getNetwork.encodedBody
            do {
                let response: APIResponse<UInt> = try await APIRequest.send(uRLRequest: urlRequest, with: session)
                let network = Networks.fromInt(response.result)
                self.network = network
            } catch {
                return nil
            }
        }
        attachedKeystoreManager = manager
    }
}
