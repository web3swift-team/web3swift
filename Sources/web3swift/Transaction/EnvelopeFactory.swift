// Package: web3swift
// Created by Alex Vlasov.
// Copyright © 2018 Alex Vlasov. All rights reserved.
//
// Support for EIP-2718 by Mark Loit March 2022

import Foundation
import BigInt

public struct EnvelopeFactory {
    private init?() { return nil }

    // Transaction factory function to create a new transaction with the correct internal envelope
    // from a raw transaction stream of bytes
    static func createEnvelope(rawValue: Data) -> AbstractEnvelope? {
        // RLP encoding of anything larger than one byte will never have a value below 0x80 as the first byte
        // no valid transaction will be only 1 byte
        let typeUInt: UInt = UInt(rawValue[0])
        let envelopeType: TransactionType

        if typeUInt < 0x80 {
            if typeUInt < TransactionType.unknown.rawValue {
                guard let rawType = TransactionType(rawValue: typeUInt) else { return nil }
                envelopeType = rawType
            } else { return nil }
        } else { envelopeType = .legacy } // legacy streams do not have type set

        if typeUInt == 0xff { return nil } // reserved value per EIP-2718

        switch envelopeType {
        case .legacy: return LegacyEnvelope(rawValue: rawValue)
        case .eip2930: return EIP2930Envelope(rawValue: rawValue)
        case .eip1559: return EIP1559Envelope(rawValue: rawValue)
        default: return nil
        }
    }

    enum CodingKeys: String, CodingKey {
        case type
    }

    // consider that this can throw as it is part of Decodable
    static func createEnvelope(from decoder: Decoder) throws -> AbstractEnvelope? {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let envelopeType: TransactionType
        if container.contains(.type) {
            let typeUInt = try container.decodeHex(to: UInt.self, key: .type)
            if typeUInt < TransactionType.unknown.rawValue {
                guard let type = TransactionType(rawValue: typeUInt) else { throw Web3Error.dataError } // conversion error
                envelopeType = type
            } else { throw Web3Error.dataError } // illegal value
        } else { envelopeType = .legacy } // legacy streams may not have type set

        switch envelopeType {
        case .legacy: return try LegacyEnvelope(from: decoder)
        case .eip2930: return try EIP2930Envelope(from: decoder)
        case .eip1559: return try EIP1559Envelope(from: decoder)
        default: return nil
        }
    }

    static func createEnvelope(type: TransactionType? = nil, to: EthereumAddress, nonce: BigUInt = 0,
                               chainID: BigUInt? = nil, value: BigUInt? = nil, data: Data,
                               v: BigUInt = 1, r: BigUInt = 0, s: BigUInt = 0, options: TransactionOptions? = nil) -> AbstractEnvelope {
        let envelopeType: TransactionType = type ?? options?.type ?? .legacy

        switch envelopeType {
        case .eip2930: return EIP2930Envelope(to: to, nonce: nonce,
                                              chainID: chainID, value: value, data: data,
                                              v: v, r: r, s: s, options: options)
        case .eip1559: return EIP1559Envelope(to: to, nonce: nonce,
                                              chainID: chainID, value: value, data: data,
                                              v: v, r: r, s: s, options: options)
        default: return LegacyEnvelope(to: to, nonce: nonce,
                                       chainID: chainID, value: value, data: data,
                                       v: v, r: r, s: s, options: options)
        }
    }
}
