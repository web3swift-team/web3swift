//  Package: web3swift
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//
//  Refactor to support EIP-2718 enveloping by Mark Loit 2022

import Foundation
import BigInt

public struct EthereumTransaction: CustomStringConvertible {
    internal var envelope: AbstractEnvelope

    // convenience accessors to the common envelope fields
    // everything else should come from getOpts/setOpts
    public var type: TransactionType { return envelope.type }
    public var nonce: BigUInt {
        get { return envelope.nonce }
        set(nonce) { envelope.nonce = nonce }
    }

    public var chainID: BigUInt? {
        get { return envelope.chainID }
        set(newID) { envelope.chainID = newID }
    }

    public var value: BigUInt {
        get { return envelope.value }
        set(newValue) { envelope.value = newValue }
    }

    public var to: EthereumAddress {
        get { return envelope.to }
        set(newValue) { envelope.to = newValue }
    }

    public var data: Data {
        get { return envelope.data }
        set(newValue) { envelope.data = newValue }
    }

    // transaction type specific parameters should be accessed with TransactionOptions via getOptions()

    // signature data is read-only
    public var v: BigUInt { return envelope.v }
    public var r: BigUInt { return envelope.r }
    public var s: BigUInt { return envelope.s }

    private init() { preconditionFailure("Memberwise not supported") } // disable the memberwise initializer

    public var description: String {
        var toReturn = ""
        toReturn += "Transaction" + "\n"
        toReturn += String(describing: self.envelope)
        toReturn += "sender: " + String(describing: self.sender?.address)  + "\n"
        toReturn += "hash: " + String(describing: self.hash?.toHexString().addHexPrefix()) + "\n"
        return toReturn
    }

    public var sender: EthereumAddress? {
        guard let publicKey = self.recoverPublicKey() else { return nil }
        return Web3.Utils.publicToAddress(publicKey)
    }

    public var hash: Data? {
        // print("calling envelope encode")
        guard let encoded: Data = self.envelope.encodeFor(.transaction) else { return nil }
        // print("envelope encode returned")
        let hash = encoded.sha3(.keccak256)
        return hash
    }

    public func hashForSignature() -> Data? {
        guard let encoded = self.envelope.encodeFor(.signature) else { return nil }
        let hash = encoded.sha3(.keccak256)
        return hash
    }

    public func recoverPublicKey() -> Data? {
        guard let sigData = envelope.getUnmarshalledSignatureSignatureData() else { return nil }
        guard let vData = BigUInt(sigData.v).serialize().setLengthLeft(1) else { return nil }
        let rData = sigData.r
        let sData = sigData.s

        guard let signatureData = SECP256K1.marshalSignature(v: vData, r: rData, s: sData) else { return nil }
        guard let hash = hashForSignature() else { return nil }

        guard let publicKey = SECP256K1.recoverPublicKey(hash: hash, signature: signatureData) else { return nil }
        return publicKey
    }

    public mutating func sign(privateKey: Data, useExtraEntropy: Bool = false) throws {
        for _ in 0..<1024 {
            let result = self.attemptSignature(privateKey: privateKey, useExtraEntropy: useExtraEntropy)
            if result { return }
        }
        throw AbstractKeystoreError.invalidAccountError
    }

    private mutating func attemptSignature(privateKey: Data, useExtraEntropy: Bool = false) -> Bool {
        guard let hash = self.hashForSignature() else { return false }
        let signature  = SECP256K1.signForRecovery(hash: hash, privateKey: privateKey, useExtraEntropy: useExtraEntropy)
        guard let serializedSignature = signature.serializedSignature else { return false }
        guard let unmarshalledSignature = SECP256K1.unmarshalSignature(signatureData: serializedSignature) else { return false }
        guard let originalPublicKey = SECP256K1.privateToPublic(privateKey: privateKey) else { return false }
        self.envelope.setUnmarshalledSignatureSignatureData(unmarshalledSignature)
        let recoveredPublicKey = self.recoverPublicKey()
        if !(originalPublicKey.constantTimeComparisonTo(recoveredPublicKey)) { return false }
        return true
    }

    public mutating func applyOptions(_ options: TransactionOptions) {
        self.envelope.applyOptions(options)
    }

    public func getOptions() -> TransactionOptions {
        return self.envelope.getOptions()
    }

    public init?(rawValue: Data) {
        guard let env = EnvelopeFactory.createEnvelope(rawValue: rawValue) else { return nil }
        self.envelope = env
    }

    public func encodeAsDictionary(from: EthereumAddress? = nil) -> TransactionParameters? { self.envelope.encodeAsDictionary(from: from) }

    static func createRequest(method: JSONRPCmethod, transaction: EthereumTransaction, transactionOptions: TransactionOptions?) -> JSONRPCrequest? {
        let onBlock = transactionOptions?.callOnBlock?.stringValue
        var request = JSONRPCrequest()

        request.method = method
        let from = transactionOptions?.from
        guard var txParams = transaction.encodeAsDictionary(from: from) else { return nil }
        if method == .estimateGas || transactionOptions?.gasLimit == nil {
            txParams.gas = nil
        }
        var params = [txParams] as [Encodable]
        if method.requiredNumOfParameters == 2 && onBlock != nil {
            params.append(onBlock as Encodable)
        }
        let pars = JSONRPCparams(params: params)
        request.params = pars
        if !request.isValid { return nil }
        return request
    }

    func encode() -> Data? {
        return self.envelope.encodeFor(.transaction)
    }

    static func createRawTransaction(transaction: EthereumTransaction) -> JSONRPCrequest? {
        guard transaction.sender != nil else { return nil }
        guard let encodedData = transaction.encode() else { return nil }
        let hex = encodedData.toHexString().addHexPrefix().lowercased()
        var request = JSONRPCrequest()
        request.method = JSONRPCmethod.sendRawTransaction
        let params = [hex] as [Encodable]
        let pars = JSONRPCparams(params: params)
        request.params = pars
        if !request.isValid { return nil }
        return request
    }
}

extension EthereumTransaction {
    // the kitchen sink init: can produce a transaction of any type
    public init(type: TransactionType? = nil, to: EthereumAddress, nonce: BigUInt = 0,
                chainID: BigUInt? = nil, value: BigUInt? = nil, data: Data,
                v: BigUInt = 1, r: BigUInt = 0, s: BigUInt = 0, options: TransactionOptions? = nil) {
        self.envelope = EnvelopeFactory.createEnvelope(type: type, to: to, nonce: nonce,
                                                       chainID: chainID, value: value, data: data,
                                                       v: v, r: r, s: s, options: options)
    }

    public init(with: AbstractEnvelope, options: TransactionOptions? = nil) {
        self.envelope = with
        // swiftlint:disable force_unwrapping
        if options != nil { self.envelope.applyOptions(options!) }
        // swiftlint:enable force_unwrapping
    }
}

// Deprecated calls
extension EthereumTransaction {
    @available(*, deprecated, message: "Please use init(type:to:nonce:chainID:value:data:v:r:s:options:) instead")
    public init(nonce: BigUInt = 0, gasPrice: BigUInt, gasLimit: BigUInt,
                to: EthereumAddress, value: BigUInt = 0, data: Data, chainID: BigUInt? = nil,
                v: BigUInt = 1, r: BigUInt = 0, s: BigUInt = 0) {

        self.envelope = LegacyEnvelope( to: to, nonce: nonce,
                                        chainID: chainID, value: value, data: data,
                                        gasPrice: gasPrice, gasLimit: gasLimit,
                                        v: v, r: r, s: s)
    }
    @available(*, deprecated, message: "Please use hashForSignature() instead")
    public func hashForSignature(chainID: BigUInt? = nil) -> Data? {
        guard let encoded = self.envelope.encodeFor(.signature) else { return nil }
        let hash = encoded.sha3(.keccak256)
        return hash
    }
}
