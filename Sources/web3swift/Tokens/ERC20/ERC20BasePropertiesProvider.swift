//
//  ERC20BasePropertiesProvider.swift
//
//
//  Created by Jann Driessen on 21.11.22.
//

import BigInt
import Foundation

/// The default implementation of access of common [ERC-20](https://eips.ethereum.org/EIPS/eip-20#methods) properties `name`, `symbol` and `decimals`.
public final class ERC20BasePropertiesProvider {
    var name: String?
    var symbol: String?
    var decimals: UInt8?

    private let contract: Web3.Contract
    private (set) var hasReadProperties: Bool = false
    init(contract: Web3.Contract) {
        self.contract = contract
    }

    public func readProperties() async throws {
        guard !hasReadProperties && contract.contract.address != nil else { return }
        name = try await contract
            .createReadOperation("name")?
            .callContractMethod()["0"] as? String

        symbol = try await contract
            .createReadOperation("symbol")?
            .callContractMethod()["0"] as? String

        let decimals = try await contract
            .createReadOperation("decimals")?
            .callContractMethod()["0"] as? BigUInt
        self.decimals = decimals != nil ? UInt8(decimals!) : nil
        hasReadProperties = true
    }
}
