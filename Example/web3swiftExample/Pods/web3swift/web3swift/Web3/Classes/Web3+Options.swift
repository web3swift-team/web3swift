//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import EthereumAddress

public protocol Web3OptionsInheritable {
    var options: Web3Options {get}
}

/// Options for sending or calling a particular Ethereum transaction
public struct Web3Options {
    /// Sets the transaction destination. It can either be a contract address or a private key controlled wallet address.
    ///
    /// Usually should never be nil.
    public var to: EthereumAddress? = nil
    /// Sets from what account a transaction should be sent. Used only internally as the sender of Ethereum transaction
    /// is determined purely from the transaction signature. Indicates to the Ethereum node or to the local keystore what private key
    /// should be used to sign a transaction.
    ///
    /// Can be nil if one reads the information from the blockchain.
    public var from: EthereumAddress? = nil
    /// Sets the gas limit for a transaction.
    ///
    /// If set to nil it's usually determined automatically.
    public var gasLimit: BigUInt? = nil
    /// Sets the gas price for a transaction.
    ///
    /// If set to nil it's usually determined automatically.
    public var gasPrice: BigUInt? = nil
    /// Sets the value (amount of Wei) sent along the transaction.
    ///
    /// If set to nil it's equal to zero
    public var value: BigUInt? = nil
    
    public init() {
    }
    
    /// Default options filler. Sets gas limit, gas price and value to zeroes.
    public static func defaultOptions() -> Web3Options{
        var options = Web3Options()
        options.gasLimit = BigUInt(0)
        options.gasPrice = BigUInt(0)
        options.value = BigUInt(0)
        return options
    }
    
    
    public static func fromJSON(_ json: [String: Any]) -> Web3Options? {
        var options = Web3Options()
        if let gas = json["gas"] as? String, let gasBiguint = BigUInt(gas.stripHexPrefix().lowercased(), radix: 16) {
            options.gasLimit = gasBiguint
        }
        if let gasPrice = json["gasPrice"] as? String, let gasPriceBiguint = BigUInt(gasPrice.stripHexPrefix().lowercased(), radix: 16) {
            options.gasPrice = gasPriceBiguint
        }
        if let value = json["value"] as? String, let valueBiguint = BigUInt(value.stripHexPrefix().lowercased(), radix: 16) {
            options.value = valueBiguint
        }
        if let fromString = json["from"] as? String {
            guard let addressFrom = EthereumAddress(fromString) else {return nil}
            options.from = addressFrom
        }
        return options
    }
    
    /// Merges two sets of topions by overriding the parameters from the first set by parameters from the second
    /// set if those are not nil.
    ///
    /// Returns default options if both parameters are nil.
    public static func merge(_ options:Web3Options?, with other:Web3Options?) -> Web3Options? {
        if (other == nil && options == nil) {
            return Web3Options.defaultOptions()
        }
        var newOptions = Web3Options.defaultOptions()
        if (other?.to != nil) {
            newOptions.to = other?.to
        } else {
            newOptions.to = options?.to
        }
        if (other?.from != nil) {
            newOptions.from = other?.from
        } else {
            newOptions.from = options?.from
        }
        if (other?.gasLimit != nil) {
            newOptions.gasLimit = other?.gasLimit
        } else {
            newOptions.gasLimit = options?.gasLimit
        }
        if (other?.gasPrice != nil) {
            newOptions.gasPrice = other?.gasPrice
        } else {
            newOptions.gasPrice = options?.gasPrice
        }
        if (other?.value != nil) {
            newOptions.value = other?.value
        } else {
            newOptions.value = options?.value
        }
        return newOptions
    }
    
    /// merges two sets of options along with a gas estimate to try to guess the final gas limit value required by user.
    ///
    /// Please refer to the source code for a logic.
    public static func smartMergeGasLimit(originalOptions: Web3Options?, extraOptions: Web3Options?, gasEstimate: BigUInt) -> BigUInt? {
        guard let mergedOptions = Web3Options.merge(originalOptions, with: extraOptions) else {return nil} //just require any non-nils
        if mergedOptions.gasLimit == nil {
            return gasEstimate // for user's convenience we just use an estimate
//            return nil // there is no opinion from user, so we can not proceed
        } else {
            if originalOptions != nil, originalOptions!.gasLimit != nil, originalOptions!.gasLimit! < gasEstimate { // original gas estimate was less than what's required, so we check extra options
                if extraOptions != nil, extraOptions!.gasLimit != nil, extraOptions!.gasLimit! >= gasEstimate {
                    return extraOptions!.gasLimit!
                } else {
                    return gasEstimate // for user's convenience we just use an estimate
//                    return nil // estimate is lower than allowed
                }
            } else {
                if extraOptions != nil, extraOptions!.gasLimit != nil, extraOptions!.gasLimit! >= gasEstimate {
                    return extraOptions!.gasLimit!
                } else {
                    return gasEstimate // for user's convenience we just use an estimate
                    //                    return nil // estimate is lower than allowed
                }
            }
        }
    }
    
    public static func smartMergeGasPrice(originalOptions: Web3Options?, extraOptions: Web3Options?, priceEstimate: BigUInt) -> BigUInt? {
        guard let mergedOptions = Web3Options.merge(originalOptions, with: extraOptions) else {return nil} //just require any non-nils
        if mergedOptions.gasPrice == nil {
            return priceEstimate
        } else if mergedOptions.gasPrice == 0 {
            return priceEstimate
        } else {
            return mergedOptions.gasPrice!
        }
    }
}

/// Options for sending or calling a particular Ethereum transaction
public struct TransactionOptions {
    /// Sets the transaction destination. It can either be a contract address or a private key controlled wallet address.
    ///
    /// Usually should never be nil.
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

//    public static func fromJSON(_ json: [String: Any]) -> Web3Options? {
//        var options = Web3Options()
//        if let gas = json["gas"] as? String, let gasBiguint = BigUInt(gas.stripHexPrefix().lowercased(), radix: 16) {
//            options.gasLimit = gasBiguint
//        }
//        if let gasPrice = json["gasPrice"] as? String, let gasPriceBiguint = BigUInt(gasPrice.stripHexPrefix().lowercased(), radix: 16) {
//            options.gasPrice = gasPriceBiguint
//        }
//        if let value = json["value"] as? String, let valueBiguint = BigUInt(value.stripHexPrefix().lowercased(), radix: 16) {
//            options.value = valueBiguint
//        }
//        if let fromString = json["from"] as? String {
//            guard let addressFrom = EthereumAddress(fromString) else {return nil}
//            options.from = addressFrom
//        }
//        return options
//    }
//
//    /// Merges two sets of topions by overriding the parameters from the first set by parameters from the second
//    /// set if those are not nil.
//    ///
//    /// Returns default options if both parameters are nil.
//    public static func merge(_ options:Web3Options?, with other:Web3Options?) -> Web3Options? {
//        if (other == nil && options == nil) {
//            return Web3Options.defaultOptions()
//        }
//        var newOptions = Web3Options.defaultOptions()
//        if (other?.to != nil) {
//            newOptions.to = other?.to
//        } else {
//            newOptions.to = options?.to
//        }
//        if (other?.from != nil) {
//            newOptions.from = other?.from
//        } else {
//            newOptions.from = options?.from
//        }
//        if (other?.gasLimit != nil) {
//            newOptions.gasLimit = other?.gasLimit
//        } else {
//            newOptions.gasLimit = options?.gasLimit
//        }
//        if (other?.gasPrice != nil) {
//            newOptions.gasPrice = other?.gasPrice
//        } else {
//            newOptions.gasPrice = options?.gasPrice
//        }
//        if (other?.value != nil) {
//            newOptions.value = other?.value
//        } else {
//            newOptions.value = options?.value
//        }
//        return newOptions
//    }
//
//    /// merges two sets of options along with a gas estimate to try to guess the final gas limit value required by user.
//    ///
//    /// Please refer to the source code for a logic.
//    public static func smartMergeGasLimit(originalOptions: Web3Options?, extraOptions: Web3Options?, gasEstimate: BigUInt) -> BigUInt? {
//        guard let mergedOptions = Web3Options.merge(originalOptions, with: extraOptions) else {return nil} //just require any non-nils
//        if mergedOptions.gasLimit == nil {
//            return gasEstimate // for user's convenience we just use an estimate
//            //            return nil // there is no opinion from user, so we can not proceed
//        } else {
//            if originalOptions != nil, originalOptions!.gasLimit != nil, originalOptions!.gasLimit! < gasEstimate { // original gas estimate was less than what's required, so we check extra options
//                if extraOptions != nil, extraOptions!.gasLimit != nil, extraOptions!.gasLimit! >= gasEstimate {
//                    return extraOptions!.gasLimit!
//                } else {
//                    return gasEstimate // for user's convenience we just use an estimate
//                    //                    return nil // estimate is lower than allowed
//                }
//            } else {
//                if extraOptions != nil, extraOptions!.gasLimit != nil, extraOptions!.gasLimit! >= gasEstimate {
//                    return extraOptions!.gasLimit!
//                } else {
//                    return gasEstimate // for user's convenience we just use an estimate
//                    //                    return nil // estimate is lower than allowed
//                }
//            }
//        }
//    }
//
//    public static func smartMergeGasPrice(originalOptions: Web3Options?, extraOptions: Web3Options?, priceEstimate: BigUInt) -> BigUInt? {
//        guard let mergedOptions = Web3Options.merge(originalOptions, with: extraOptions) else {return nil} //just require any non-nils
//        if mergedOptions.gasPrice == nil {
//            return priceEstimate
//        } else if mergedOptions.gasPrice == 0 {
//            return priceEstimate
//        } else {
//            return mergedOptions.gasPrice!
//        }
//    }
}

fileprivate func mergeIfNotNil<T>(first: T?, second: T?) -> T? {
    if second != nil {
        return second
    } else if first != nil {
        return first
    }
    return nil
}
