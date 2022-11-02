//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import Core

/// An arbitary Web3 object. Is used only to construct provider bound fully functional object by either supplying provider URL
/// or using pre-coded Infura nodes
extension Web3 {

    /// Initialized provider-bound Web3 instance using a provider's URL. Under the hood it performs a synchronous call to get
    /// the Network ID for EIP155 purposes
    public static func new(_ providerURL: URL) async throws -> Web3 {
        // FIXME: Change this hardcoded value to dynamicly fethed from a Node
        guard let provider = await Web3HttpProvider(providerURL, network: .Mainnet) else {
            throw Web3Error.inputError(desc: "Wrong provider - should be Web3HttpProvider with endpoint scheme http or https")
        }
        return Web3(provider: provider)
    }

    /// Initialized Web3 instance bound to Infura's mainnet provider.
    public static func InfuraMainnetWeb3(accessToken: String? = nil) async -> Web3 {
        let infura = await InfuraProvider(Networks.Mainnet, accessToken: accessToken)!
        return Web3(provider: infura)
    }

    /// Initialized Web3 instance bound to Infura's goerli provider.
    public static func InfuraGoerliWeb3(accessToken: String? = nil) async -> Web3 {
        let infura = await InfuraProvider(Networks.Goerli, accessToken: accessToken)!
        return Web3(provider: infura)
    }

    /// Initialized Web3 instance bound to Infura's rinkeby provider.
    @available(*, deprecated, message: "This network support was deprecated by Infura")
    public static func InfuraRinkebyWeb3(accessToken: String? = nil) async -> Web3 {
        let infura = await InfuraProvider(Networks.Rinkeby, accessToken: accessToken)!
        return Web3(provider: infura)
    }

    /// Initialized Web3 instance bound to Infura's ropsten provider.
    @available(*, deprecated, message: "This network support was deprecated by Infura")
    public static func InfuraRopstenWeb3(accessToken: String? = nil) async -> Web3 {
        let infura = await InfuraProvider(Networks.Ropsten, accessToken: accessToken)!
        return Web3(provider: infura)
    }

    /// Initialized Web3 instance bound to Infura's kovan provider.
    @available(*, deprecated, message: "This network support was deprecated by Infura")
    public static func InfuraKovanWeb3(accessToken: String? = nil) async -> Web3 {
        let infura = await InfuraProvider(Networks.Kovan, accessToken: accessToken)!
        return Web3(provider: infura)
    }

}
