//
// Created by Alex Vlasov.
// Copyright © 2018 Alex Vlasov. All rights reserved.
//
// Support for EIP-2718 by Mark Loit March 2022

import Foundation
import BigInt

/// Utility class for creating transaction envelopes. Generally not used directly, but are used by CodableTransaction
public struct EnvelopeFactory {
    // Transaction factory function to create a new transaction with the correct internal envelope
    // from a raw transaction stream of bytes
    /// create a transaction envelope from a raw bytestream
    /// - Parameter rawValue: raw bytestream of the transaction
    /// - Returns: a transaction envelope according to the type dictated by the input data
    static func createEnvelope(rawValue: Data) -> AbstractEnvelope? {
        // RLP encoding of anything larger than one byte will never have a value below 0x80 as the first byte
        // no valid transaction will be only 1 byte
        let typeUInt: UInt = UInt(rawValue[0])
        let envelopeType: TransactionType

        if typeUInt < 0x80 {
            if typeUInt < TransactionType.allCases.count {
                guard let rawType = TransactionType(rawValue: typeUInt) else { return nil }
                envelopeType = rawType
            } else { return nil }
        } else { envelopeType = .legacy } // legacy streams do not have type set

        if typeUInt == 0xff { return nil } // reserved value per EIP-2718

        switch envelopeType {
        case .legacy: return LegacyEnvelope(rawValue: rawValue)
        case .eip2930: return EIP2930Envelope(rawValue: rawValue)
        case .eip1559: return EIP1559Envelope(rawValue: rawValue)
        }
    }

    enum CodingKeys: String, CodingKey {
        case type
    }

    // consider that this can throw as it is part of Decodable
    // from a raw transaction stream of bytes
    /// create a transaction envelope from a decoder stream (Decodable protocol)
    /// - Parameter from: the Decoder object/stream containing the input parameters
    /// - Returns: a transaction envelope according to the type dictated by the input data
    static func createEnvelope(from decoder: Decoder) throws -> AbstractEnvelope? {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let envelopeType: TransactionType
        if container.contains(.type) {
            let typeUInt = try container.decodeHex(UInt.self, forKey: .type)
            guard let type = TransactionType(rawValue: typeUInt) else {
                throw Web3Error.dataError(desc: "Given TransactionType raw value is not supported. Value given is \(typeUInt).")
            }
            envelopeType = type
        } else { envelopeType = .legacy } // legacy streams may not have type set

        switch envelopeType {
        case .legacy: return try LegacyEnvelope(from: decoder)
        case .eip2930: return try EIP2930Envelope(from: decoder)
        case .eip1559: return try EIP1559Envelope(from: decoder)
        }
    }

    // MARK: Delete all default values in initializer, because of this is a internal factory, so it shouldn't be convenient,
    // rather then is should have no magic in itself.
    /// Description Create a new transaction envelope of the type dictated by the type parameter
    /// - Parameters:
    ///   - type: TransactionType enum, dictates what kind of envelope to create defaults to .legacy if nil
    ///   - to: EthereumAddress of the destination for this transaction (required)
    ///   - nonce: nonce for this transaction (default 0)
    ///   - v: signature v parameter (default 1) - will get set properly once signed
    ///   - r: signature r parameter (default 0) - will get set properly once signed
    ///   - s: signature s parameter (default 0) - will get set properly once signed
    ///   - options: TransactionParameters containing additional parameters for the transaction like gas
    /// - Returns: a new envelope of type dictated by 'type'
    static func createEnvelope(type: TransactionType? = nil, to: EthereumAddress, nonce: BigUInt,
                               chainID: BigUInt, value: BigUInt, data: Data,
                               gasLimit: BigUInt, maxFeePerGas: BigUInt?, maxPriorityFeePerGas: BigUInt?, gasPrice: BigUInt?,
                               accessList: [AccessListEntry]?, v: BigUInt, r: BigUInt, s: BigUInt) -> AbstractEnvelope {
        let envelopeType: TransactionType = type ?? .legacy

        switch envelopeType {
        case .eip2930: return EIP2930Envelope(to: to, nonce: nonce, chainID: chainID, value: value, data: data, gasPrice: gasPrice ?? 0, gasLimit: gasLimit, accessList: accessList, v: v, r: r, s: s)
        case .eip1559: return EIP1559Envelope(to: to, nonce: nonce, chainID: chainID, value: value, data: data, maxPriorityFeePerGas: maxPriorityFeePerGas ?? 0, maxFeePerGas: maxFeePerGas ?? 0, gasLimit: gasLimit, accessList: accessList, v: v, r: r, s: s)
        default: return LegacyEnvelope(to: to, nonce: nonce, chainID: chainID, value: value, data: data, gasPrice: gasPrice ?? 0, gasLimit: gasLimit, v: v, r: r, s: s)
        }
    }
}
