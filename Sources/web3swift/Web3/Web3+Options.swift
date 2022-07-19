//  Package: web3swift
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//
// Additions to support new transaction types by Mark Loit March 2022

import Foundation
import BigInt

public protocol TransactionOptionsInheritable {
    var transactionOptions: TransactionOptions { get }
}

/// Options for sending or calling a particular Ethereum transaction
public struct TransactionOptions {
    // Sets the transaction envelope type.
    // default here is legacy, so it will work on all chains
    // but the provider should perhaps set better defaults based on what chain is connected
    // id for Ethereum, default to EIP-1559
    public var type: TransactionType?

    /// Sets the transaction destination. It can either be a contract address or a private key controlled wallet address.
    ///
    /// Usually should never be nil, left undefined for a contract-creation transaction.
    public var to: EthereumAddress?
    /// Sets from what account a transaction should be sent. Used only internally as the sender of Ethereum transaction
    /// is determined purely from the transaction signature. Indicates to the Ethereum node or to the local keystore what private key
    /// should be used to sign a transaction.
    ///
    /// Can be nil if one reads the information from the blockchain.
    public var from: EthereumAddress?

    public var chainID: BigUInt?

    public enum GasLimitPolicy {
        case automatic
        case manual(BigUInt)
        case limited(BigUInt)
        case withMargin(Double)
    }
    public var gasLimit: GasLimitPolicy?

    public enum GasPricePolicy {
        case automatic
        case manual(BigUInt)
        case withMargin(Double)
    }

    public var gasPrice: GasPricePolicy?

    // new gas parameters for EIP-1559 support
    public enum FeePerGasPolicy {
        case automatic
        case manual(BigUInt)
    }
    public var maxFeePerGas: FeePerGasPolicy?
    public var maxPriorityFeePerGas: FeePerGasPolicy?

    /// The value transferred for the transaction in wei, also the endowment if it’s a contract-creation transaction.
    public var value: BigUInt?

    public enum NoncePolicy {
        case pending
        case latest
        case manual(BigUInt)
    }

    public var nonce: NoncePolicy?

    public enum CallingBlockPolicy {
        case pending
        case latest
        case exactBlockNumber(BigUInt)

        var stringValue: String {
            switch self {
            case .pending:
                return "pending"
            case .latest:
                return "latest"
            case .exactBlockNumber(let number):
                return String(number, radix: 16).addHexPrefix()
            }
        }
    }

    public var callOnBlock: CallingBlockPolicy?

    public var accessList: [AccessListEntry]?

    public init(type: TransactionType? = nil,
                to: EthereumAddress? = nil,
                from: EthereumAddress? = nil,
                chainID: BigUInt? = nil,
                gasLimit: TransactionOptions.GasLimitPolicy? = nil,
                gasPrice: TransactionOptions.GasPricePolicy? = nil,
                maxFeePerGas: TransactionOptions.FeePerGasPolicy? = nil,
                maxPriorityFeePerGas: TransactionOptions.FeePerGasPolicy? = nil,
                value: BigUInt? = nil,
                nonce: TransactionOptions.NoncePolicy? = nil,
                callOnBlock: TransactionOptions.CallingBlockPolicy? = nil,
                accessList: [AccessListEntry]? = nil) {
        self.type = type
        self.to = to
        self.from = from
        self.chainID = chainID
        self.gasLimit = gasLimit
        self.gasPrice = gasPrice
        self.maxFeePerGas = maxFeePerGas
        self.maxPriorityFeePerGas = maxPriorityFeePerGas
        self.value = value
        self.nonce = nonce
        self.callOnBlock = callOnBlock
        self.accessList = accessList
    }

    public static var defaultOptions: TransactionOptions {
        var opts = TransactionOptions()
        opts.type = .legacy
        opts.gasLimit = .automatic
        opts.gasPrice = .automatic
        opts.maxFeePerGas = .automatic
        opts.maxPriorityFeePerGas = .automatic
        opts.nonce = .pending
        opts.callOnBlock = .pending
        return opts
    }

    public func resolveNonce(_ suggestedByNode: BigUInt) -> BigUInt {
        guard let noncePolicy = self.nonce else { return suggestedByNode }
        switch noncePolicy {
        case .pending, .latest:
            return suggestedByNode
        case .manual(let value):
            return value
        }
    }

    public func resolveGasPrice(_ suggestedByNode: BigUInt) -> BigUInt {
        guard let gasPricePolicy = self.gasPrice else { return suggestedByNode }
        switch gasPricePolicy {
        case .automatic, .withMargin:
            return suggestedByNode
        case .manual(let value):
            return value
        }
    }

    public func resolveGasLimit(_ suggestedByNode: BigUInt) -> BigUInt {
        guard let gasLimitPolicy = self.gasLimit else { return suggestedByNode }
        switch gasLimitPolicy {
        case .automatic, .withMargin:
            return suggestedByNode
        case .manual(let value):
            return value
        case .limited(let limit):
            if limit <= suggestedByNode {
                return suggestedByNode
            } else {
                return limit
            }
        }
    }

    public func resolveMaxFeePerGas(_ suggestedByNode: BigUInt) -> BigUInt {
        guard let maxFeePerGasPolicy = self.maxFeePerGas else { return suggestedByNode }
        switch maxFeePerGasPolicy {
        case .automatic:
            return suggestedByNode
        case .manual(let value):
            return value
        }
    }

    public func resolveMaxPriorityFeePerGas(_ suggestedByNode: BigUInt) -> BigUInt {
        guard let maxPriorityFeePerGasPolicy = self.maxPriorityFeePerGas else { return suggestedByNode }
        switch maxPriorityFeePerGasPolicy {
        case .automatic:
            return suggestedByNode
        case .manual(let value):
            return value
        }
    }

    public func merge(_ otherOptions: TransactionOptions?) -> TransactionOptions {
        guard let other = otherOptions else { return self }
        var opts = TransactionOptions()
        opts.type = mergeIfNotNil(first: self.type, second: other.type)
        opts.to = mergeIfNotNil(first: self.to, second: other.to)
        opts.from = mergeIfNotNil(first: self.from, second: other.from)
        opts.chainID = mergeIfNotNil(first: self.chainID, second: other.chainID)
        opts.gasLimit = mergeIfNotNil(first: self.gasLimit, second: other.gasLimit)
        opts.gasPrice = mergeIfNotNil(first: self.gasPrice, second: other.gasPrice)
        opts.maxFeePerGas = mergeIfNotNil(first: self.maxFeePerGas, second: other.maxFeePerGas)
        opts.maxPriorityFeePerGas = mergeIfNotNil(first: self.maxPriorityFeePerGas, second: other.maxPriorityFeePerGas)
        opts.value = mergeIfNotNil(first: self.value, second: other.value)
        opts.nonce = mergeIfNotNil(first: self.nonce, second: other.nonce)
        opts.callOnBlock = mergeIfNotNil(first: self.callOnBlock, second: other.callOnBlock)
        return opts
    }

    /// Merges two sets of options by overriding the parameters from the first set by parameters from the second
    /// set if those are not nil.
    ///
    /// Returns default options if both parameters are nil.
    public static func merge(_ options: TransactionOptions?, with other: TransactionOptions?) -> TransactionOptions? {
        var newOptions = TransactionOptions.defaultOptions // default has lowest priority
        newOptions = newOptions.merge(options)
        newOptions = newOptions.merge(other) // other has highest priority
        return newOptions
    }
}

private func mergeIfNotNil<T>(first: T?, second: T?) -> T? {
    if second != nil {
        return second
    } else if first != nil {
        return first
    }
    return nil
}

extension TransactionOptions: Decodable {
    enum CodingKeys: String, CodingKey {
        case type
        case to
        case from
        case chainId
        case gasPrice
        case gas
        case maxFeePerGas
        case maxPriorityFeePerGas
        case value
        case nonce
        case callOnBlock
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let defaultOptions = TransactionOptions.defaultOptions

        // type is guaranteed to be set after this
        if let typeUInt = try? container.decodeHex(UInt.self, forKey: .type) {
            if typeUInt < TransactionType.allCases.count {
                guard let type = TransactionType(rawValue: typeUInt) else { throw Web3Error.dataError }
                self.type = type
            } else { throw Web3Error.dataError }
        } else { self.type = .legacy } // legacy streams may not have type set

        self.chainID = try container.decodeHexIfPresent(BigUInt.self, forKey: .chainId)

        let toString = try? container.decode(String.self, forKey: .to)
        switch toString {
        case nil, "0x", "0x0":
            self.to = EthereumAddress.contractDeploymentAddress()
        default:
            // the forced unwrap here is safe as we trap nil in the previous case
            // swiftlint:disable force_unwrapping
            guard let ethAddr = EthereumAddress(toString!) else { throw Web3Error.dataError }
            // swiftlint:enable force_unwrapping
            self.to = ethAddr
        }

        self.from = try container.decodeIfPresent(EthereumAddress.self, forKey: .from)

        if let gasPrice = try? container.decodeHex(BigUInt.self, forKey: .gasPrice) {
            self.gasPrice = .manual(gasPrice)
        } else {
            self.gasPrice = defaultOptions.gasPrice
        }

        if let gasLimit = try? container.decodeHex(BigUInt.self, forKey: .gas) {
            self.gasLimit = .manual(gasLimit)
        } else {
            self.gasLimit = defaultOptions.gasLimit
        }

        if let maxFeePerGas = try? container.decodeHex(BigUInt.self, forKey: .maxFeePerGas) {
            self.maxFeePerGas = .manual(maxFeePerGas)
        } else {
            self.maxFeePerGas = defaultOptions.maxFeePerGas
        }

        if let maxPriorityFeePerGas = try? container.decodeHex(BigUInt.self, forKey: .maxPriorityFeePerGas) {
            self.maxPriorityFeePerGas = .manual(maxPriorityFeePerGas)
        } else {
            self.maxPriorityFeePerGas = defaultOptions.maxPriorityFeePerGas
        }

        if let value = try? container.decodeHex(BigUInt.self, forKey: .value) {
            self.value = value
        } else {
            self.value = defaultOptions.value
        }

        if let nonce = try? container.decodeHex(BigUInt.self, forKey: .nonce) {
            self.nonce = .manual(nonce)
        } else {
            self.nonce = defaultOptions.nonce
        }

        if let callOnBlock = try? container.decodeHex(BigUInt.self, forKey: .callOnBlock) {
            self.callOnBlock = .exactBlockNumber(callOnBlock)
        } else {
            self.callOnBlock = defaultOptions.callOnBlock
        }
    }
}

extension TransactionOptions {
    @available(*, deprecated, message: "use Decodable instead")
    public static func fromJSON(_ json: [String: Any]) -> TransactionOptions? {
        do {
            let jsonData: Data = try JSONSerialization.data(withJSONObject: json, options: [])
            return try JSONDecoder().decode(TransactionOptions.self, from: jsonData)
        } catch {
            return nil
        }
    }

}
