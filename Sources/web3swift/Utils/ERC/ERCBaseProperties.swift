//
//  ERCBaseProperties.swift
//  
//
//  Created by Jann Driessen on 21.11.22.
//

import Foundation

public protocol ERCBaseProperties: AnyObject {
    var basePropertiesProvder: ERCBasePropertiesProvider { get }
    var contract: Web3.Contract { get }
    var name: String? { get }
    var symbol: String? { get }
    var decimals: UInt8? { get }
}

public extension ERCBaseProperties {
    var name: String? {
        basePropertiesProvder.name
    }

    var symbol: String? {
        basePropertiesProvder.symbol
    }

    var decimals: UInt8? {
        basePropertiesProvder.decimals
    }

    var hasReadProperties: Bool {
        basePropertiesProvder.hasReadProperties
    }

    func readProperties() async throws {
        if basePropertiesProvder.hasReadProperties { return }
        try await basePropertiesProvder.readProperties()
    }
}
