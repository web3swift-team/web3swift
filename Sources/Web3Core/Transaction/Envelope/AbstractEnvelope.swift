//
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
    will get generated when `CodableTransaction` is being created with data for the new type
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

extension TransactionType: Codable { }

/// Encoding selector for transaction transmission/hashing or signing
public enum EncodeType {

    /// Encode the transaction for transmission or hashing
    case transaction

    /// Encode the transaction for signing
    case signature
}

/// Protocol definition for all transaction envelope types
/// All envelopes must conform to this protocol to work with `CodableTransaction`
/// each implementation holds all the type specific data
/// and implements the type specific encoding/decoding
protocol AbstractEnvelope: CustomStringConvertible { // possibly add Codable?

    /// The type of transaction this envelope represents
    var type: TransactionType { get }

    // MARK: common parameters for any transaction
    /// the nonce value for the transaction
    var nonce: BigUInt { get set }

    var sender: EthereumAddress? { get }

    var chainID: BigUInt? { get set }

    /// On chain address that this transaction is being sent to
    var to: EthereumAddress { get set }

    /// The native value of the transaction in Wei
    var value: BigUInt { get set }

    var gasLimit: BigUInt { get set }

    var gasPrice: BigUInt? { get set }

    /// the max base fee per gas unit (EIP-1559 only)
    /// this value must be >= baseFee + maxPriorityFeePerGas
    var maxFeePerGas: BigUInt? { get set }

    /// the maximum tip to pay the miner (EIP-1559 only)
    var maxPriorityFeePerGas: BigUInt? { get set }

    /// Any encoded data accompanying the transaction
    var data: Data { get set }

    // Signature data should not be set directly
    /// signature V compoonent
    var v: BigUInt { get set }

    /// signature R compoonent
    var r: BigUInt { get set }

    /// signature S compoonent
    var s: BigUInt { get set }

    /// - Returns: the public key decoded from the signature data
    var publicKey: Data? { get }

    /// - Returns: a hash of the transaction suitable for signing
    var signatureHash: Data? { get }

    // required initializers
    // for Decodable support
    /// initializer for creating an `CodableTransaction` with the Decodable protocol
    /// will return an new `CodableTransaction` object on success
    /// throws a `Web3.dataError` if an error occurs while trying to decode a value
    /// returns nil if a required field is not found in the decoder stream
    init?(from decoder: Decoder) throws // Decodable Protocol

    // initializes from a raw stream of bytes
    // can fail if input stream is not of the right size/cannot be decoded
    /// initializer for creating an `CodableTransaction` with raw bytestream data
    /// will return an new `CodableTransaction` object on success
    /// returns nil if a required field is not found in the decoder stream, or can't be decoded
    init?(rawValue: Data) // Decode from Ethereum Data

    /// Transaction encoder for transmission or signing
    ///  - Parameters:
    ///    - {default}: EncodeType enum
    ///     - when type is .signature the transaction is encoded for signing
    ///     - when type is .transaction the thransaction is encoded for hashing or transmission to the blockchain
    /// - Returns: a raw encoding stream representing the transaction, encoded according to it's type
    func encode(for type: EncodeType) -> Data?

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

extension AbstractEnvelope {

    var sender: EthereumAddress? {
        guard let publicKey = publicKey else { return nil }
        return Utilities.publicToAddress(publicKey)
    }

    mutating func clearSignatureData() {
        self.v = 1
        self.r = 0
        self.s = 0
    }

    /// - Returns: a hash of the transaction suitable for signing
    var signatureHash: Data? {
        guard let encoded = self.encode(for: .signature) else { return nil }
        let hash = encoded.sha3(.keccak256)
        return hash
    }

    /// - Returns: the public key decoded from the signature data
    var publicKey: Data? {
        guard let sigData = self.getUnmarshalledSignatureData() else { return nil }
        guard let vData = BigUInt(sigData.v).serialize().setLengthLeft(1) else { return nil }
        let rData = sigData.r
        let sData = sigData.s

        guard let signatureData = SECP256K1.marshalSignature(v: vData, r: rData, s: sData) else { return nil }
        guard let hash = signatureHash else { return nil }

        guard let publicKey = SECP256K1.recoverPublicKey(hash: hash, signature: signatureData) else { return nil }
        return publicKey
    }
}
