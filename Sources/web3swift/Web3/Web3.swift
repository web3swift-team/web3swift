//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import Web3Core

/// An arbitrary Web3 object. Is used only to construct provider bound fully functional object by either supplying provider URL
/// or using pre-coded Infura nodes
extension Web3 {

    /// Initialized provider-bound Web3 instance using a provider's URL. Under the hood it performs a synchronous call to get
    /// the Network ID for EIP155 purposes
    public static func new(_ providerURL: URL, network: Networks = .Mainnet) async throws -> Web3 {
        let provider = try await Web3HttpProvider(url: providerURL, network: network)
        return Web3(provider: provider)
    }

    /// Initialized Web3 instance bound to Infura's mainnet provider.
    public static func InfuraMainnetWeb3(accessToken: String? = nil) async throws -> Web3 {
        let infura = try await InfuraProvider(net: Networks.Mainnet, accessToken: accessToken)
        return Web3(provider: infura)
    }

    /// Initialized Web3 instance bound to Infura's goerli provider.
    public static func InfuraGoerliWeb3(accessToken: String? = nil) async throws -> Web3 {
        let infura = try await InfuraProvider(net: Networks.Goerli, accessToken: accessToken)
        return Web3(provider: infura)
    }

    /// Initialized Web3 instance bound to Infura's rinkeby provider.
    @available(*, deprecated, message: "This network support was deprecated by Infura")
    public static func InfuraRinkebyWeb3(accessToken: String? = nil) async throws -> Web3 {
        let infura = try await InfuraProvider(net: Networks.Rinkeby, accessToken: accessToken)
        return Web3(provider: infura)
    }

    /// Initialized Web3 instance bound to Infura's ropsten provider.
    @available(*, deprecated, message: "This network support was deprecated by Infura")
    public static func InfuraRopstenWeb3(accessToken: String? = nil) async throws -> Web3 {
        let infura = try await InfuraProvider(net: Networks.Ropsten, accessToken: accessToken)
        return Web3(provider: infura)
    }

    /// Initialized Web3 instance bound to Infura's kovan provider.
    @available(*, deprecated, message: "This network support was deprecated by Infura")
    public static func InfuraKovanWeb3(accessToken: String? = nil) async throws -> Web3 {
        let infura = try await InfuraProvider(net: Networks.Kovan, accessToken: accessToken)
        return Web3(provider: infura)
    }

}
