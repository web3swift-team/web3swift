// Package: web3swift
// Created by Alex Vlasov.
// Copyright © 2018 Alex Vlasov. All rights reserved.
//
// Support for EIP-2718 by Mark Loit 2022

import Foundation
import BigInt

/*
    AbstractEnvelope is the main protocol definition to enable support for different transaction types.
    it defines the basic parameters and methods required by all transaction types.
    Other than `Legacy` (untyped transaction) and `EIP2718Envelope`, no other transaction type should inherit directly
    from AbstractEnvelope. All typed transactions should inherit from `EIP2718Envelope` instead, as it provides default
    implementations for some required methods.

    Adding a new transaction type in the future should be as straight forward as adding to the TransactionType enum here
    then creating a new struct that implements to `EIP2718Envelope`, and implementing the required elements for the type
    Finally adding the type specific inits to the factory routines in `EnvelopeFactory` so that objectts of the new type 
    will get generated when `EthereumTransaction` is being created with data for the new type
*/

/// Enumeration for supported transaction types
public enum TransactionType: UInt, CustomStringConvertible, CaseIterable {

    /// For untyped and type 0 transactions EIP155 and older
    case legacy

    /// For type 1 transactions conforming to EIP2930
    case eip2930

    /// For type 2 transactions conforming to EIP1559
    case eip1559

    /// range-checking value, not a valid type, will never be returned as a type
    // case total // always keep immediately after last valid type
    // should there be a need to handle an unknown type, place it after total

    public var description: String {
        switch self {
        case .legacy: return "Legacy"   // legacy is a pseudo-type, no EIP-2718 transaction will ever be encoded with type = 0
        //                                 though nodes do appear to return a type of 0 for legacy transactions in their JSON
        case .eip2930: return "EIP-2930"
        case .eip1559: return "EIP-1559"
        }
    }
}

/// Encoding selector for transaction transmission/hashing or signing
public enum EncodeType {

    /// Encode the transaction for transmission or hashing
    case transaction

    /// Encode the transaction for signing
    case signature
}

/// Protocol definition for all transaction envelope types
/// All envelopes must conform to this protocol to work with `EthereumTransaction`
/// each implememtation holds all the type specific data
/// and implments the type specific encoding/decoding
public protocol AbstractEnvelope: CustomStringConvertible { // possibly add Codable?

    /// The type of transaction this envelope represents
    var type: TransactionType { get }

    // MARK: common parameters for any transaction
    /// the nonce value for the transaction
    var nonce: BigUInt { get set }

    /// On chain address that this transaction is being sent to
    var to: EthereumAddress { get set }

    // /// The native value of the transaction in Wei
    // var value: BigUInt { get set }

    // /// Any encoded data accompanying the transaction
    // var data: Data { get set }

    // Signature data should not be set directly
    /// signature V compoonent
    var v: BigUInt { get set }

    /// signature R compoonent
    var r: BigUInt { get set }

    /// signature S compoonent
    var s: BigUInt { get set }

    /// Transaction Parameters object
    /// used to provide external access to the otherwise
    /// protected parameters of the object
    var parameters: EthereumParameters { get set }

    // required initializers
    // for Decodable support
    /// initializer for creating an `EthereumTransaction` with the Decodable protocol
    /// will return an new `EthereumTransaction` object on success
    /// thows a `Web3.dataError` if an error occurs while trying to decode a value
    /// returns nil if a required field is not found in the decoder stream
    init?(from decoder: Decoder) throws // Decodable Protocol

    // initializes from a raw stream of bytes
    // can fail if input stream is not of the right size/cannot be decoded
    /// initializer for creating an `EthereumTransaction` with raw bytestream data
    /// will return an new `EthereumTransaction` object on success
    /// returns nil if a required field is not found in the decoder stream, or can't be decoded
    init?(rawValue: Data) // Decode from Ethereum Data

    // pseudo memberwise initializer
    // accepts all common parameters (full description with default implementation below)
    // Note the `nil` parameters, even though non-optional in the struct, are there to allow
    // fallback to pulling the value from `options`. If options also does not have a value, a suitable default is used
    // precedence is as follows: direct parameter > options value > default value
    /// Default memberwse initializer that all envelopes must support
    /// - Parameters:
    ///   - to: EthereumAddress of destination
    ///   - nonce: nonce for the transaction
    ///   - v: Signature V component
    ///   - r: Signature R component
    ///   - s: Signature S component
    ///   - parameters: EthereumParameters struct containing any other required parameters
    init(to: EthereumAddress, nonce: BigUInt?, v: BigUInt, r: BigUInt, s: BigUInt, parameters: EthereumParameters?)

    /// Applies the passed options to the transaction envelope
    ///   - Parameters:
    ///     - {default}: TransactionOptions struct
    mutating func applyOptions(_ options: TransactionOptions)

    /// Transaction encoder for transmission or signing
    ///  - Parameters:
    ///    - {default}: EncodeType enum
    ///     - when type is .signature the transaction is encoded for signing
    ///     - when type is .transaction the thransaction is encoded for hashing or transmission to the blockchain
    /// - Returns: a raw encoding stream representing the transaction, encoded according to it's type
    func encode(for type: EncodeType) -> Data?

    /// Encodes the transaction as a set of strings for JSON transmission
    /// - Returns: A TransactionParameters object containg all the parameters for the transaction
    func encodeAsDictionary(from: EthereumAddress?) -> TransactionParameters?

    /// used by the signing algorithm to set the v, r, s parameters
    /// - Parameters:
    ///   - {default}: UnmarshalledSignature struct containing the v, r, s parameters
    mutating func setUnmarshalledSignatureData(_ unmarshalledSignature: SECP256K1.UnmarshaledSignature)

    /// used by the public-key recovery algorithm for determining the signer of the transaction
    /// - Returns: returns the 'unmarshalled' v,r,s psignatrure parameters
    func getUnmarshalledSignatureData() -> SECP256K1.UnmarshaledSignature?

    /// used by Transaction.unsign() to reset/clear the signature
    mutating func clearSignatureData()
}

public extension AbstractEnvelope {

    mutating func clearSignatureData() {
        self.v = 1
        self.r = 0
        self.s = 0
    }
}
