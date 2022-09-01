//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//
//  Additions for new transaction types by Mark Loit 2022

import Foundation
import BigInt

///  Structure capable of carying the parameters for any transaction type.
///  while all fields in this struct are optional, they are not necessarily
///  optional for the type of transaction they apply to.
public struct EncodableTransaction {
    /// signifies the transaction type that this payload is for
    /// indicates what fields should be populated. 
    /// this should always be set to give an idea of what other fields to expect
    public var type: TransactionType?

    // FIXME: Should be from: EthereumAddress property

    /// the destination, or contract, address for the transaction
    public var to: EthereumAddress?

    /// the nonce for the transaction
    public var nonce: BigUInt?

    /// the chainId that transaction is targeted for
    /// should be set for all types, except some Legacy transactions (Pre EIP-155)
    /// will not have this set
    public var chainID: BigUInt?

    /// the native value of the transaction
    public var value: BigUInt?

    /// any additional data for the transaction
    public var data: Data?

    /// the max number of gas units allowed to process this transaction
    public var gasLimit: BigUInt?

    /// the price per gas unit for the tranaction (Legacy and EIP-2930 only)
    public var gasPrice: BigUInt?

    /// the max base fee per gas unit (EIP-1559 only)
    /// this value must be >= baseFee + maxPriorityFeePerGas
    public var maxFeePerGas: BigUInt?

    /// the maximum tip to pay the miner (EIP-1559 only)
    public var maxPriorityFeePerGas: BigUInt?

    /// access list for contract execution (EIP-2930 and EIP-1559 only)
    public var accessList: [AccessListEntry]?
    
    public init(type: TransactionType? = nil, to: EthereumAddress? = nil, nonce: BigUInt? = nil, chainID: BigUInt? = nil, value: BigUInt? = nil, data: Data? = nil, gasLimit: BigUInt? = nil, gasPrice: BigUInt? = nil, maxFeePerGas: BigUInt? = nil, maxPriorityFeePerGas: BigUInt? = nil, accessList: [AccessListEntry]? = nil) {
        self.type = type
        self.to = to
        self.nonce = nonce
        self.chainID = chainID
        self.value = value
        self.data = data
        self.gasLimit = gasLimit
        self.gasPrice = gasPrice
        self.maxFeePerGas = maxFeePerGas
        self.maxPriorityFeePerGas = maxPriorityFeePerGas
        self.accessList = accessList
    }
}

extension EncodableTransaction: Encodable {
    enum CodingKeys: String, CodingKey {
        case type
        case to
        case nonce
        case chainID
        case value
        case data
        case gasLimit
        case gasPrice
        case maxFeePerGas
        case maxPriorityFeePerGas
        case accessList
    }

    public func encode(to encoder: Encoder) throws {
        var containier = encoder.container(keyedBy: CodingKeys.self)
        try containier.encode(type?.rawValue.hexString, forKey: .type)
        try containier.encode(to, forKey: .to)
        try containier.encode(nonce?.hexString, forKey: .nonce)
        try containier.encode(chainID?.hexString, forKey: .chainID)
        try containier.encode(value?.hexString, forKey: .value)
        try containier.encode(data?.toHexString().addHexPrefix(), forKey: .data)
        try containier.encode(gasLimit?.hexString, forKey: .gasLimit)
        try containier.encode(gasPrice?.hexString, forKey: .gasPrice)
        try containier.encode(maxFeePerGas?.hexString, forKey: .maxFeePerGas)
        try containier.encode(maxPriorityFeePerGas?.hexString, forKey: .maxPriorityFeePerGas)
        try containier.encode(accessList, forKey: .accessList)
    }
}

extension EncodableTransaction: APIRequestParameterType { }

