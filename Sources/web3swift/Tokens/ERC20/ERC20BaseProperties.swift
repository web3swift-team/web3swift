//
//  ERC20BaseProperties.swift
//
//
//  Created by Jann Driessen on 21.11.22.
//

import Foundation

/// Declares common properties of an [ERC-20](https://eips.ethereum.org/EIPS/eip-20) compliant smart contract.
/// Default implementation of access to these properties is declared in the extension of this protocol.
public protocol ERC20BaseProperties: AnyObject {
    var basePropertiesProvider: ERC20BasePropertiesProvider { get }
    var contract: Web3.Contract { get }
    var name: String? { get }
    var symbol: String? { get }
    var decimals: UInt8? { get }
}

public extension ERC20BaseProperties {
    var name: String? {
        basePropertiesProvider.name
    }

    var symbol: String? {
        basePropertiesProvider.symbol
    }

    var decimals: UInt8? {
        basePropertiesProvider.decimals
    }

    var hasReadProperties: Bool {
        basePropertiesProvider.hasReadProperties
    }

    func readProperties() async throws {
        if basePropertiesProvider.hasReadProperties { return }
        try await basePropertiesProvider.readProperties()
    }
}
