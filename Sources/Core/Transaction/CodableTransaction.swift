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
public struct CodableTransaction {
    public typealias NoncePolicy = BlockNumber
    /// internal acccess only. The transaction envelope object itself that contains all the transaction data
    /// and type specific implementation
    internal var envelope: AbstractEnvelope

    /// storage container for additional metadata returned by the node
    /// when a transaction is decoded form a JSON stream
    public var meta: TransactionMetadata?

    // MARK: - Properties that always sends to a Node

    /// the address of the sender of the transaction recovered from the signature
    public var sender: EthereumAddress? {
        guard let publicKey = self.recoverPublicKey() else { return nil }
        return Utilities.publicToAddress(publicKey)
    }

    public var from: EthereumAddress?

    /// the destination, or contract, address for the transaction
    public var to: EthereumAddress {
        get { return envelope.to }
        set { envelope.to = newValue }
    }

    /// signifies the transaction type that this payload is for
    /// indicates what fields should be populated.
    /// this should always be set to give an idea of what other fields to expect
    public var type: TransactionType { return envelope.type }

    /// the chainId that transaction is targeted for
    /// should be set for all types, except some Legacy transactions (Pre EIP-155)
    /// will not have this set
    public var chainID: BigUInt? {
        get { return envelope.chainID }
        set { envelope.chainID = newValue }
    }

    /// the native value of the transaction
    public var value: BigUInt {
        get { return envelope.value }
        set { envelope.value = newValue }
    }

    // MARK: - Ruins signing and decoding tests if tied to envelop
    /// any additional data for the transaction
    public var data: Data

    // MARK: - Properties transaction type related either sends to a node if exist

    /// the nonce for the transaction
    internal var nonce: BigUInt {
        get { return envelope.nonce }
        set { envelope.nonce = newValue }
    }

    /// the max number of gas units allowed to process this transaction
    internal var gasLimit: BigUInt {
        get { return envelope.gasLimit }
        set { return envelope.gasLimit = newValue }
    }

    /// the price per gas unit for the tranaction (Legacy and EIP-2930 only)
    internal var gasPrice: BigUInt? {
        get { return envelope.gasPrice }
        set { return envelope.gasPrice = newValue }
    }

    /// the max base fee per gas unit (EIP-1559 only)
    /// this value must be >= baseFee + maxPriorityFeePerGas
    internal var maxFeePerGas: BigUInt? {
        get { return envelope.maxFeePerGas }
        set { return envelope.maxFeePerGas = newValue }
    }

    /// the maximum tip to pay the miner (EIP-1559 only)
    internal var maxPriorityFeePerGas: BigUInt? {
        get { return envelope.maxPriorityFeePerGas }
        set { return envelope.maxPriorityFeePerGas = newValue }
    }

    public var callOnBlock: BlockNumber?

    /// access list for contract execution (EIP-2930 and EIP-1559 only)
    public var accessList: [AccessListEntry]?

    // MARK: - Properties to contract encode/sign data only

    // signature data is read-only
    /// signature v component (read only)
    public var v: BigUInt { return envelope.v }
    /// signature r component (read only)
    public var r: BigUInt { return envelope.r }
    /// signature s component (read only)
    public var s: BigUInt { return envelope.s }

    /// the transaction hash
    public var hash: Data? {
        guard let encoded: Data = self.envelope.encode(for: .transaction) else { return nil }
        let hash = encoded.sha3(.keccak256)
        return hash
    }

    private init() { preconditionFailure("Memberwise not supported") } // disable the memberwise initializer

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
    ///
    /// This method signs transaction iteself and not related to contract call data signing.
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

    /// Create a new CodableTransaction from a raw stream of bytes from the blockchain
    public init?(rawValue: Data) {
        guard let env = EnvelopeFactory.createEnvelope(rawValue: rawValue) else { return nil }
        self.envelope = env
        // FIXME: This is duplication and should be fixed.
        data = Data()
        noncePolicy = .latest
        gasLimitPolicy = .automatic
        gasPricePolicy = .automatic
        maxFeePerGasPolicy = .automatic
        maxPriorityFeePerGasPolicy = .automatic
    }

    /// - Returns: a raw bytestream of the transaction, encoded according to the transactionType
    public func encode(for type: EncodeType = .transaction) -> Data? {
        return self.envelope.encode(for: type)
    }

    public mutating func resolve(provider: Web3Provider) async {
        // FIXME: Delete force try
        self.gasLimit = try! await self.gasLimitPolicy.resolve(provider: provider, transaction: self)

        if from != nil || sender != nil {
            self.nonce = try! await self.resolveNonce(provider: provider)
        }
        if case .eip1559 = type {
            self.maxFeePerGas = try! await self.maxFeePerGasPolicy.resolve(provider: provider)
            self.maxPriorityFeePerGas = try! await self.maxPriorityFeePerGasPolicy.resolve(provider: provider)
        } else {
            self.gasPrice = try! await self.gasPricePolicy.resolve(provider: provider)
        }
    }

    public var noncePolicy: NoncePolicy
    public var maxFeePerGasPolicy: FeePerGasPolicy
    public var maxPriorityFeePerGasPolicy: PriorityFeePerGasPolicy
    public var gasPricePolicy: GasPricePolicy
    public var gasLimitPolicy: GasLimitPolicy

    public static var emptyTransaction = CodableTransaction(to: EthereumAddress.contractDeploymentAddress())
}

extension CodableTransaction: Codable {
    enum CodingKeys: String, CodingKey {
        case type
        case from
        case to
        case nonce
        case chainID
        case value
        case data
        case gasLimit = "gas"
        case gasPrice
        case maxFeePerGas
        case maxPriorityFeePerGas
        case accessList
    }

    /// initializer required to support the Decodable protocol
    /// - Parameter decoder: the decoder stream for the input data
    public init(from decoder: Decoder) throws {
        guard let env = try EnvelopeFactory.createEnvelope(from: decoder) else { throw Web3Error.dataError }
        self.envelope = env
        // FIXME: This is duplication and should be fixed.
        data = Data()

        noncePolicy = .latest
        gasLimitPolicy = .automatic
        gasPricePolicy = .automatic
        maxFeePerGasPolicy = .automatic
        maxPriorityFeePerGasPolicy = .automatic

        // capture any metadata that might be present
        self.meta = try TransactionMetadata(from: decoder)
    }

    public func encode(to encoder: Encoder) throws {
        // FIXME: There's a huge mess here, please take a look here at code review if any.
        var containier = encoder.container(keyedBy: CodingKeys.self)
        try containier.encode(nonce.hexString, forKey: .nonce)
        try containier.encode(data.toHexString().addHexPrefix(), forKey: .data)
        try containier.encode(value.hexString, forKey: .value)

        // Encoding only fields with value.
        // TODO: Rewrite me somehow better.
        if type != .legacy {
            try containier.encode(type.rawValue.hexString, forKey: .type)
            if let chainID = chainID, !chainID.isZero {
                try containier.encode(chainID.hexString, forKey: .chainID)
            }
        }
        if let accessList = accessList, !accessList.isEmpty {
            try containier.encode(accessList, forKey: .accessList)
        }

        if !gasLimit.isZero {
            try containier.encode(gasLimit.hexString, forKey: .gasLimit)
        }

        if let gasPrice = gasPrice, !gasPrice.isZero {
            try containier.encode(gasPrice.hexString, forKey: .gasPrice)
        }

        if let maxFeePerGas = maxFeePerGas, !maxFeePerGas.isZero {
            try containier.encode(maxFeePerGas.hexString, forKey: .maxFeePerGas)
        }

        if let maxPriorityFeePerGas = maxPriorityFeePerGas, !maxPriorityFeePerGas.isZero {
            try containier.encode(maxPriorityFeePerGas.hexString, forKey: .maxPriorityFeePerGas)
        }

        // Don't encode empty address
        if !to.address.elementsEqual("0x") {
            try containier.encode(to, forKey: .to)
        }

        if let from = from {
            try containier.encode(from, forKey: .from)
        }
    }

}

public protocol Policyable {
    func resolve(provider: Web3Provider, transaction: CodableTransaction?) async throws -> BigUInt
}

extension CodableTransaction {
    public enum GasLimitPolicy {
        case automatic
        case manual(BigUInt)
        case limited(BigUInt)
        case withMargin(Double)

        func resolve(provider: Web3Provider, transaction: CodableTransaction?) async throws -> BigUInt {
            guard let transaction = transaction else { throw Web3Error.valueError }
            let request: APIRequest = .estimateGas(transaction, transaction.callOnBlock ?? .latest)
            let response: APIResponse<BigUInt> = try await APIRequest.sendRequest(with: provider, for: request)
            switch self {
            case .automatic, .withMargin:
                return response.result
            case .manual(let value):
                return value
            case .limited(let limit):
                if limit <= response.result {
                    return response.result
                } else {
                    return limit
                }
            }
        }
    }

    public enum GasPricePolicy {
        case automatic
        case manual(BigUInt)
        case withMargin(Double)

        func resolve(provider: Web3Provider, transaction: CodableTransaction? = nil) async throws -> BigUInt {
            let oracle = Oracle(provider)
            switch self {
            case .automatic, .withMargin:
                return await oracle.gasPriceLegacyPercentiles().max() ?? 0
            case .manual(let value):
                return value
            }
        }
    }

    public enum PriorityFeePerGasPolicy: Policyable {
        case automatic
        case manual(BigUInt)

        public func resolve(provider: Web3Provider, transaction: CodableTransaction? = nil) async throws -> BigUInt {
            let oracle = Oracle(provider)
            switch self {
            case .automatic:
                return await oracle.tipFeePercentiles().max() ?? 0
            case .manual(let value):
                return value
            }
        }
    }

    public enum FeePerGasPolicy: Policyable {
        case automatic
        case manual(BigUInt)

        public func resolve(provider: Web3Provider, transaction: CodableTransaction? = nil) async throws -> BigUInt {
            let oracle = Oracle(provider)
            switch self {
            case .automatic:
                return await oracle.baseFeePercentiles().max() ?? 0
            case .manual(let value):
                return value
            }
        }
    }

    func resolveNonce(provider: Web3Provider) async throws -> BigUInt {
        switch noncePolicy {
        case .pending, .latest, .earliest:
            guard let address = from ?? sender else { throw Web3Error.valueError }
            let request: APIRequest = .getTransactionCount(address.address, callOnBlock ?? .latest)
            let response: APIResponse<BigUInt> = try await APIRequest.sendRequest(with: provider, for: request)
            return response.result
        case .exact(let value):
            return value
        }
    }

}

extension CodableTransaction: CustomStringConvertible {
    /// required by CustomString convertable
    /// returns a string description for the transaction and its data
    public var description: String {
        var toReturn = ""
        toReturn += "Transaction" + "\n"
        toReturn += String(describing: self.envelope)
        toReturn += "from: " + String(describing: self.sender?.address)  + "\n"
        toReturn += "hash: " + String(describing: self.hash?.toHexString().addHexPrefix()) + "\n"
        return toReturn
    }
}

extension CodableTransaction {
    // the kitchen sink init: can produce a transaction of any type
    /// Universal initializer to create a new CodableTransaction object
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
                chainID: BigUInt = 0, value: BigUInt = 0, data: Data = Data(),
                gasLimit: BigUInt = 0, maxFeePerGas: BigUInt? = nil, maxPriorityFeePerGas: BigUInt? = nil, gasPrice: BigUInt? = nil,
                accessList: [AccessListEntry]? = nil, v: BigUInt = 1, r: BigUInt = 0, s: BigUInt = 0) {
        // FIXME: This is duplication and should be fixed.
        self.data = data
        self.accessList = accessList
        self.gasLimitPolicy = .automatic
        self.noncePolicy = .pending
        self.gasPricePolicy = .automatic
        self.maxFeePerGasPolicy = .automatic
        self.maxPriorityFeePerGasPolicy = .automatic
        self.callOnBlock = .latest

        self.envelope = EnvelopeFactory.createEnvelope(type: type, to: to, nonce: nonce, chainID: chainID, value: value, data: data, gasLimit: gasLimit, maxFeePerGas: maxFeePerGas, maxPriorityFeePerGas: maxPriorityFeePerGas, gasPrice: gasPrice, accessList: accessList, v: v, r: r, s: s)
    }
}

extension CodableTransaction: APIRequestParameterType { }
