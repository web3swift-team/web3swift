//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//
//  Refactor to support EIP-2718 enveloping by Mark Loit 2022

import Foundation
import BigInt

/// Abstraction object for a transaction pulled from, or destined for the blockchain
/// provides all the necessary functionality to encode/decode sign/verify transactions
public struct EthereumTransaction: CustomStringConvertible {
    /// internal acccess only. The transaction envelope object itself that contains all the transaction data
    /// and type specific implementation
    internal var envelope: AbstractEnvelope

    /// storage container for additional metadata returned by the node
    /// when a transaction is decoded form a JSON stream
    public var meta: EthereumMetadata?

    // convenience accessors to the common envelope fields
    // everything else should come from getOpts/setOpts
    /// The type of the transacton being represented, see TransactionType enum
    public var type: TransactionType { return envelope.type }
    /// the unique nonce value for the transaction
    public var nonce: BigUInt {
        get { return envelope.nonce }
        set { envelope.nonce = newValue }
    }

    /// The chainId of the blockchain the transaction belongs to
    public var chainID: BigUInt? {
        get { return envelope.parameters.chainID }
        set { envelope.parameters.chainID = newValue }
    }

    /// the chain-native value of the transaction in Wei
    public var value: BigUInt {
        get { return envelope.parameters.value ?? 0 }
        set { envelope.parameters.value = newValue }
    }

    // TODO: Make me returing self public key.
    public var from: EthereumAddress {
        EthereumAddress(_address: "0x0")
    }

    /// the EthereumAddress object holding the destination address for the transaction
    public var to: EthereumAddress {
        get { return envelope.to }
        set { envelope.to = newValue }
    }

    /// the payload data for the transaction
    public var data: Data {
        get { return envelope.parameters.data ?? Data() }
        set { envelope.parameters.data = newValue }
    }

    // transaction type specific parameters should be accessed with EthereumParameters
    var parameters: CodableTransaction {
        get { return envelope.parameters }
        set { envelope.parameters = newValue }
    }

    // signature data is read-only
    /// signature v component (read only)
    public var v: BigUInt { return envelope.v }
    /// signature r component (read only)
    public var r: BigUInt { return envelope.r }
    /// signature s component (read only)
    public var s: BigUInt { return envelope.s }

    private init() { preconditionFailure("Memberwise not supported") } // disable the memberwise initializer

    /// required by CustomString convertable
    /// returns a string description for the transaction and its data
    public var description: String {
        var toReturn = ""
        toReturn += "Transaction" + "\n"
        toReturn += String(describing: self.envelope)
        toReturn += "sender: " + String(describing: self.sender?.address)  + "\n"
        toReturn += "hash: " + String(describing: self.hash?.toHexString().addHexPrefix()) + "\n"
        return toReturn
    }

    /// the address of the sender of the transaction recovered from the signature
    public var sender: EthereumAddress? {
        guard let publicKey = self.recoverPublicKey() else { return nil }
        return Utilities.publicToAddress(publicKey)
    }

    /// the transaction hash
    public var hash: Data? {
        guard let encoded: Data = self.envelope.encode(for: .transaction) else { return nil }
        let hash = encoded.sha3(.keccak256)
        return hash
    }

    /// - Returns: a hash of the transaction suitable for signing
    public func hashForSignature() -> Data? {
        guard let encoded = self.envelope.encode(for: .signature) else { return nil }
        let hash = encoded.sha3(.keccak256)
        return hash
    }

    /// - Returns: the public key decoded from the signature data
    public func recoverPublicKey() -> Data? {
        guard let sigData = envelope.getUnmarshalledSignatureData() else { return nil }
        guard let vData = BigUInt(sigData.v).serialize().setLengthLeft(1) else { return nil }
        let rData = sigData.r
        let sData = sigData.s

        guard let signatureData = SECP256K1.marshalSignature(v: vData, r: rData, s: sData) else { return nil }
        guard let hash = hashForSignature() else { return nil }

        guard let publicKey = SECP256K1.recoverPublicKey(hash: hash, signature: signatureData) else { return nil }
        return publicKey
    }

    /// Signs the transaction
    /// - Parameters:
    ///   - privateKey: the private key to use for signing
    ///   - useExtraEntropy: boolean whether to use extra entropy when signing (default false)
    public mutating func sign(privateKey: Data, useExtraEntropy: Bool = false) throws {
        for _ in 0..<1024 {
            let result = self.attemptSignature(privateKey: privateKey, useExtraEntropy: useExtraEntropy)
            if result { return }
        }
        throw AbstractKeystoreError.invalidAccountError
    }

    // actual signing algorithm implementation
    private mutating func attemptSignature(privateKey: Data, useExtraEntropy: Bool = false) -> Bool {
        guard let hash = self.hashForSignature() else { return false }
        let signature = SECP256K1.signForRecovery(hash: hash, privateKey: privateKey, useExtraEntropy: useExtraEntropy)
        guard let serializedSignature = signature.serializedSignature else { return false }
        guard let unmarshalledSignature = SECP256K1.unmarshalSignature(signatureData: serializedSignature) else { return false }
        guard let originalPublicKey = SECP256K1.privateToPublic(privateKey: privateKey) else { return false }
        self.envelope.setUnmarshalledSignatureData(unmarshalledSignature)
        let recoveredPublicKey = self.recoverPublicKey()
        if !(originalPublicKey.constantTimeComparisonTo(recoveredPublicKey)) { return false }
        return true
    }

    /// clears the signature data
    public mutating func unsign() {
        self.envelope.clearSignatureData()
    }

    /// Apples the provided parameters/options in to the object, if set replacing what is currently set
    /// - Parameter options: a TransactionOptions object containing parameters to be appled to the transaction
    /// if options specifies a type, and it is different from the current type the transaction will be migrated
    /// to the new type. migrating will invalidate any signature data
    public mutating func applyTransaction(_ transaction: EthereumTransaction) {
        if transaction.type != nil && self.type != transaction.type {
            // swiftlint:disable force_unwrapping
            self.migrate(to: transaction.type)
            // swiftlint:enable force_unwrapping
        }
        self.envelope.applyTransaction(transaction)
    }

    /// Descriptionconverts transaction to the new selected type
    /// - Parameter to: TransactionType to select what transaction type to convert to
    public mutating func migrate(to type: TransactionType) {
        if self.type == type { return }

        let newEnvelope = EnvelopeFactory.createEnvelope(type: type, to: self.envelope.to,
                                                         nonce: self.envelope.nonce, parameters: self.envelope.parameters)
        self.envelope = newEnvelope
    }

    /// Create a new EthereumTransaction from a raw stream of bytes from the blockchain
    public init?(rawValue: Data) {
        guard let env = EnvelopeFactory.createEnvelope(rawValue: rawValue) else { return nil }
        self.envelope = env
    }

    /// - Returns: a raw bytestream of the transaction, encoded according to the transactionType
    public func encode(for type: EncodeType = .transaction) -> Data? {
        return self.envelope.encode(for: type)
    }
}

extension EthereumTransaction {
    // the kitchen sink init: can produce a transaction of any type
    /// Universal initializer to create a new EthereumTransaction object
    /// - Parameters:
    ///   - type: TransactionType enum for selecting the type of transaction to create (default is .legacy)
    ///   - to: EthereumAddress of the destination for this transaction (required)
    ///   - nonce: nonce for this transaction (default 0)
    ///   - chainID: chainId the transaction belongs to (default: type specific)
    ///   - value: Native value for the transaction (default 0)
    ///   - data: Payload data for the transaction (required)
    ///   - v: signature v parameter (default 1) - will get set properly once signed
    ///   - r: signature r parameter (default 0) - will get set properly once signed
    ///   - s: signature s parameter (default 0) - will get set properly once signed
    ///   - parameters: EthereumParameters object containing additional parametrs for the transaction like gas
    public init(type: TransactionType? = nil, to: EthereumAddress, nonce: BigUInt = 0,
                chainID: BigUInt? = nil, value: BigUInt? = nil, data: Data,
                v: BigUInt = 1, r: BigUInt = 0, s: BigUInt = 0, parameters: CodableTransaction? = nil) {

        var params = parameters ?? CodableTransaction()

        params.chainID = chainID ?? params.chainID
        params.value = value ?? params.value
        params.data = data

        self.envelope = EnvelopeFactory.createEnvelope(type: type, to: to, nonce: nonce, v: v, r: r, s: s, parameters: params)
    }

    /// basic intializer that accepts an already created transaction envelope
    /// - Parameters:
    ///   - with: An envelope object conforming to the AbstractEnvelope protocol
    ///   - options: a TransactionOptions object containing additional options to apply to the transaction
    public init(with: AbstractEnvelope, transaction: EthereumTransaction? = nil) {
        self.envelope = with
        // swiftlint:disable force_unwrapping
        if transaction != nil { self.envelope.applyTransaction(transaction!) }
        // swiftlint:enable force_unwrapping
    }


    public static func defaultTransaction(of envelop: AbstractEnvelope) -> EthereumTransaction {
        // FIXME: Remove force unwrap
        var transaction = EthereumTransaction(to: EthereumAddress("0x0")!, data: Data())
        // FIXME: Type computed property
        transaction.envelope = envelop
        
        return transaction
    }
}


