// Package: web3swift
// Created by Alex Vlasov.
// Copyright © 2018 Alex Vlasov. All rights reserved.
//
// Support for EIP-2718 by Mark Loit 2022

import Foundation
import BigInt

public enum TransactionType: UInt, CustomStringConvertible {
    case legacy
    case eip2930
    case eip1559

    case unknown // catch-all type, always place as last position, also used for range checking
    // only used in parsing, no TransactionObject will ever return this

    public var description: String {
        switch self {
        case .legacy: return "Legacy"
        case .eip2930: return "EIP-2930"
        case .eip1559: return "EIP-1559"
        case .unknown: return "Unknown EIP-2718 Type"
        }
    }
}

public enum EncodeType {
    case transaction
    case signature
}

public struct SignatureData {
    var v: BigUInt
    var r: BigUInt
    var s: BigUInt
}

public protocol AbstractEnvelope: CustomStringConvertible { // possibly add Codable?
    var type: TransactionType { get }

    // common parameters for any transaction
    var nonce: BigUInt { get set }
    var chainID: BigUInt? { get set } // this unfortunately needs to remain optional due to legacy transaction type
    var to: EthereumAddress { get set }
    var value: BigUInt { get set }
    var data: Data { get set }
    // Signatre data is read-only, must be set via setUnmarshalledSignatureSignatureData()
    var v: BigUInt { get set }
    var r: BigUInt { get set }
    var s: BigUInt { get set }

    // required initializers
    // for Decodable support
    // can fail if specific fields are missing [basically if anything except gasXXX is missing]
    // will throw on data decoding issues only
    init?(from decoder: Decoder) throws // Decodable Protocol

    // initializes from a raw stream of bytes
    // can fail if input stream is not of the right size/cannot be decoded
    init?(rawValue: Data) // Decode from Ethereum Data

    // pseudo memberwise initializer
    // accepts all common parameters
    init(to: EthereumAddress, nonce: BigUInt?, chainID: BigUInt?, value: BigUInt?,
         data: Data, v: BigUInt, r: BigUInt, s: BigUInt, options: TransactionOptions?)

    mutating func applyOptions(_ options: TransactionOptions)
    func getOptions() -> TransactionOptions

    func encodeFor(_ type: EncodeType) -> Data?
    func encodeAsDictionary(from: EthereumAddress?) -> TransactionParameters?
    mutating func setUnmarshalledSignatureSignatureData(_ unmarshalledSignature: SECP256K1.UnmarshaledSignature)
    func getUnmarshalledSignatureSignatureData() -> SECP256K1.UnmarshaledSignature?
}

public extension AbstractEnvelope {
    // default implementation, should be overridden by each Envelope implementation
    init(to: EthereumAddress, nonce: BigUInt? = nil,
         chainID: BigUInt? = nil, value: BigUInt? = nil, data: Data,
         v: BigUInt = 1, r: BigUInt = 0, s: BigUInt = 0,
         options: TransactionOptions? = nil) {
        self.init(to: to, nonce: nonce, chainID: chainID, value: value,
                  data: data, v: v, r: r, s: s, options: options)
    }
}
