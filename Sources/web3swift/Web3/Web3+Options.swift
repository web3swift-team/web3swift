//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
//import EthereumAddress

public protocol TransactionOptionsInheritable {
    var transactionOptions: TransactionOptions {get}
}

/// Options for sending or calling a particular Ethereum transaction
public struct TransactionOptions {
    /// Sets the transaction destination. It can either be a contract address or a private key controlled wallet address.
    ///
    /// Usually should never be nil, left undefined for a contract-creation transaction.
    public var to: EthereumAddress? = nil
    /// Sets from what account a transaction should be sent. Used only internally as the sender of Ethereum transaction
    /// is determined purely from the transaction signature. Indicates to the Ethereum node or to the local keystore what private key
    /// should be used to sign a transaction.
    ///
    /// Can be nil if one reads the information from the blockchain.
    public var from: EthereumAddress? = nil
    
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

    /// The value transferred for the transaction in wei, also the endowment if it’s a contract-creation transaction.
    public var value: BigUInt? = nil
    
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
    
    public init() {
    }
    
    public static var defaultOptions: TransactionOptions {
        var opts = TransactionOptions()
        opts.callOnBlock = .pending
        opts.nonce = .pending
        opts.gasLimit = .automatic
        opts.gasPrice = .automatic
        return opts
    }
    
    public func resolveGasPrice(_ suggestedByNode: BigUInt) -> BigUInt? {
        guard let gasPricePolicy = self.gasPrice else {return nil}
        switch gasPricePolicy {
        case .automatic:
            return suggestedByNode
        case .manual(let value):
            return value
        case .withMargin(_):
            return suggestedByNode
        }
    }
    
    public func resolveGasLimit(_ suggestedByNode: BigUInt) -> BigUInt? {
        guard let gasLimitPolicy = self.gasLimit else {return nil}
        switch gasLimitPolicy {
        case .automatic:
            return suggestedByNode
        case .manual(let value):
            return value
        case .withMargin(_):
            return suggestedByNode
        case .limited(let limit):
            if limit <= suggestedByNode {
                return suggestedByNode
            }
            return nil
        }
    }
    
    public func merge(_ otherOptions: TransactionOptions?) -> TransactionOptions {
        guard let other = otherOptions else {return self}
        var opts = TransactionOptions()
        opts.from = mergeIfNotNil(first: self.from, second: other.from)
        opts.to = mergeIfNotNil(first: self.to, second: other.to)
        opts.gasLimit = mergeIfNotNil(first: self.gasLimit, second: other.gasLimit)
        opts.gasPrice = mergeIfNotNil(first: self.gasPrice, second: other.gasPrice)
        opts.value = mergeIfNotNil(first: self.value, second: other.value)
        opts.nonce = mergeIfNotNil(first: self.nonce, second: other.nonce)
        opts.callOnBlock = mergeIfNotNil(first: self.callOnBlock, second: other.callOnBlock)
        return opts
    }
    
    public static func fromJSON(_ json: [String: Any]) -> TransactionOptions? {
        var options = TransactionOptions()
        if let gas = json["gas"] as? String, let gasBiguint = BigUInt(gas.stripHexPrefix().lowercased(), radix: 16) {
            options.gasLimit = .manual(gasBiguint)
        } else if let gasLimit = json["gasLimit"] as? String, let gasgasLimitBiguint = BigUInt(gasLimit.stripHexPrefix().lowercased(), radix: 16) {
            options.gasLimit = .limited(gasgasLimitBiguint)
        } else {
            options.gasLimit = .automatic
        }
        if let gasPrice = json["gasPrice"] as? String, let gasPriceBiguint = BigUInt(gasPrice.stripHexPrefix().lowercased(), radix: 16) {
            options.gasPrice = .manual(gasPriceBiguint)
        } else {
            options.gasPrice = .automatic
        }
        if let value = json["value"] as? String, let valueBiguint = BigUInt(value.stripHexPrefix().lowercased(), radix: 16) {
            options.value = valueBiguint
        }
        if let toString = json["to"] as? String {
            guard let addressTo = EthereumAddress(toString) else {return nil}
            options.to = addressTo
        }
        if let fromString = json["from"] as? String {
            guard let addressFrom = EthereumAddress(fromString) else {return nil}
            options.from = addressFrom
        }
        if let nonceString = json["nonce"] as? String, let nonce = BigUInt(nonceString.stripHexPrefix(), radix: 16) {
            options.nonce = .manual(nonce)
        } else {
            options.nonce = .pending
        }
        if let callOnBlockString = json["callOnBlock"] as? String, let callOnBlock = BigUInt(callOnBlockString.stripHexPrefix(), radix: 16) {
            options.callOnBlock = .exactBlockNumber(callOnBlock)
        } else {
            options.callOnBlock = .pending
        }
        return options
    }
    
    /// Merges two sets of topions by overriding the parameters from the first set by parameters from the second
    /// set if those are not nil.
    ///
    /// Returns default options if both parameters are nil.
    public static func merge(_ options:TransactionOptions?, with other:TransactionOptions?) -> TransactionOptions? {
        if (other == nil && options == nil) {
            return TransactionOptions.defaultOptions
        }
        var newOptions = TransactionOptions.defaultOptions

        newOptions.to = other?.to ?? options?.to
        newOptions.from = other?.from ?? options?.from
        newOptions.gasLimit = other?.gasLimit ?? options?.gasLimit
        newOptions.gasPrice = other?.gasPrice ?? options?.gasPrice
        newOptions.value = other?.value ?? options?.value

        return newOptions
    }
}

fileprivate func mergeIfNotNil<T>(first: T?, second: T?) -> T? {
    if second != nil {
        return second
    } else if first != nil {
        return first
    }
    return nil
}
