// Package: web3swift
// Created by Alex Vlasov.
// Copyright © 2018 Alex Vlasov. All rights reserved.
//
// Refactor to support EIP-2718 enveloping by Mark Loit 2022

import Foundation
import BigInt

public struct LegacyEnvelope: AbstractEnvelope {
    public let type: TransactionType = .legacy

    // common parameters for any transaction
    public var nonce: BigUInt = 0
    public var chainID: BigUInt? {
        get {
            if let id = explicitChainID, id != 0 { return id }
            return impliedChainID
        }
        set(newID) { explicitChainID = newID }
    }
    public var to: EthereumAddress
    public var value: BigUInt
    public var data: Data
    public var v: BigUInt
    public var r: BigUInt
    public var s: BigUInt

    // legacy specific parameters
    public var gasPrice: BigUInt = 0
    public var gasLimit: BigUInt = 0

    // legacy chainID Mechanism
    private var explicitChainID: BigUInt? // set directly or via options
    // private var impliedChainID: BigUInt? // we calculate this once, or when explicitely asked to
    private var impliedChainID: BigUInt? {
        if r == 0 && s == 0 { return v }
        if v == 27 || v == 28 || v < 35 { return nil }
        return ((v - 1) / 2) - 17
    }

    // for CustomStringConvertible
    public var description: String {
        var toReturn = ""
        toReturn += "Type: " + String(describing: self.type) + "\n"
        toReturn += "Nonce: " + String(describing: self.nonce) + "\n"
        toReturn += "Gas price: " + String(self.gasPrice) + "\n"
        toReturn += "Gas limit: " + String(describing: self.gasLimit) + "\n"
        toReturn += "To: " + self.to.address + "\n"
        toReturn += "Value: " + String(describing: self.value) + "\n"
        toReturn += "Data: " + self.data.toHexString().addHexPrefix().lowercased() + "\n"
        toReturn += "Resolved chainID: " + String(describing: self.chainID) + "\n"
        toReturn += "- Intrinsic chainID: " + String(describing: self.explicitChainID) + "\n"
        toReturn += "- Infered chainID: " + String(describing: self.impliedChainID) + "\n"
        toReturn += "v: " + String(self.v) + "\n"
        toReturn += "r: " + String(self.r) + "\n"
        toReturn += "s: " + String(self.s) + "\n"
        return toReturn
    }

    public var parameters: EthereumParameters {
        get {
            return EthereumParameters(
                type: type,
                to: to,
                nonce: nonce,
                chainID: chainID,
                value: value,
                data: data,
                gasLimit: gasLimit,
                gasPrice: gasPrice
            )
        }
        set(val) {
            nonce = val.nonce ?? nonce
            explicitChainID = val.chainID ?? explicitChainID
            to = val.to ?? to
            value = val.value ?? value
            data = val.data ?? data
            gasLimit = val.gasLimit ?? gasLimit
            gasPrice = val.gasPrice ?? gasPrice
        }
    }

}

extension LegacyEnvelope {
    private enum CodingKeys: String, CodingKey {
        case chainId
        case nonce
        case to
        case value
        case gasPrice
        case gasLimit
        case gas
        case data
        case input
        case v
        case r
        case s
    }

    public init?(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        guard container.contains(.to), container.contains(.nonce), container.contains(.value) else { return nil }
        if !container.contains(.data) && !container.contains(.input) { return nil }
        guard container.contains(.v), container.contains(.r), container.contains(.s) else { return nil }

        // everything we need is present, so we should only have to throw from here
        self.explicitChainID = try container.decodeHexIfPresent(BigUInt.self, forKey: .chainId)
        self.nonce = try container.decodeHex(BigUInt.self, forKey: .nonce)

        let toString = try? container.decode(String.self, forKey: .to)
        switch toString {
        case nil, "0x", "0x0":
            self.to = EthereumAddress.contractDeploymentAddress()
        default:
            // the forced unwrap here is safe as we trap nil in the previous case
            // swiftlint:disable force_unwrapping
            guard let ethAddr = EthereumAddress(toString!) else { throw Web3Error.dataError }
            // swiftlint:enable force_unwrapping
            self.to = ethAddr
        }
        self.value = try container.decodeHexIfPresent(BigUInt.self, forKey: .value) ?? 0
        self.gasPrice = try container.decodeHexIfPresent(BigUInt.self, forKey: .gasPrice) ?? 0
        self.gasLimit = try container.decodeHexIfPresent(BigUInt.self, forKey: .gas) ?? container.decodeHexIfPresent(BigUInt.self, forKey: .gasLimit) ?? 0

        self.data = try container.decodeHexIfPresent(Data.self, forKey: .input) ?? container.decodeHex(Data.self, forKey: .data)
        self.v = try container.decodeHex(BigUInt.self, forKey: .v)
        self.r = try container.decodeHex(BigUInt.self, forKey: .r)
        self.s = try container.decodeHex(BigUInt.self, forKey: .s)
    }

    private enum RlpKey: Int, CaseIterable {
        case nonce
        case gasPrice
        case gasLimit
        case destination
        case amount
        case data
        case sig_v
        case sig_r
        case sig_s
    }

    public init?(rawValue: Data) {
        guard let totalItem = RLP.decode(rawValue) else { return nil }
        guard let rlpItem = totalItem[0] else { return nil }
        guard RlpKey.allCases.count == rlpItem.count else { return nil }

        // we've validated the item count, so rlpItem[key] is guaranteed to return something not nil
        // swiftlint:disable force_unwrapping
        guard let nonceData = rlpItem[RlpKey.nonce.rawValue]!.data else { return nil }
        guard let gasPriceData = rlpItem[RlpKey.gasPrice.rawValue]!.data else { return nil }
        guard let gasLimitData = rlpItem[RlpKey.gasLimit.rawValue]!.data else { return nil }
        guard let valueData = rlpItem[RlpKey.amount.rawValue]!.data else { return nil }
        guard let transactionData = rlpItem[RlpKey.data.rawValue]!.data else { return nil }
        guard let vData = rlpItem[RlpKey.sig_v.rawValue]!.data else { return nil }
        guard let rData = rlpItem[RlpKey.sig_r.rawValue]!.data else { return nil }
        guard let sData = rlpItem[RlpKey.sig_s.rawValue]!.data else { return nil }

        switch rlpItem[RlpKey.destination.rawValue]!.content {
        // swiftlint:enable force_unwrapping
        case .noItem:
            self.to = EthereumAddress.contractDeploymentAddress()
        case .data(let addressData):
            if addressData.count == 0 {
                self.to = EthereumAddress.contractDeploymentAddress()
            } else if addressData.count == 20 {
                guard let addr = EthereumAddress(addressData) else { return nil }
                self.to = addr
            } else { return nil }
        case .list:
            return nil
        }

        self.nonce = BigUInt(nonceData)
        self.gasPrice = BigUInt(gasPriceData)
        self.gasLimit = BigUInt(gasLimitData)
        self.value = BigUInt(valueData)
        self.data = transactionData
        self.v = BigUInt(vData)
        self.r = BigUInt(rData)
        self.s = BigUInt(sData)
    }

    public init(to: EthereumAddress, nonce: BigUInt? = nil,
                v: BigUInt = 1, r: BigUInt = 0, s: BigUInt = 0,
                parameters: EthereumParameters? = nil) {
        self.to = to
        self.nonce = nonce ?? parameters?.nonce ?? 0
        self.explicitChainID = parameters?.chainID // Legacy can have a nil ChainID
        self.value = parameters?.value ?? 0
        self.data = parameters?.data ?? Data()
        self.v = v
        self.r = r
        self.s = s
        self.gasPrice = parameters?.gasPrice ?? 0
        self.gasLimit = parameters?.gasLimit ?? 0
    }

    // memberwise
    public init(to: EthereumAddress, nonce: BigUInt = 0,
                chainID: BigUInt? = nil, value: BigUInt = 0, data: Data,
                gasPrice: BigUInt = 0, gasLimit: BigUInt = 0,
                v: BigUInt = 1, r: BigUInt = 0, s: BigUInt = 0) {
        self.to = to
        self.nonce = nonce
        self.explicitChainID = chainID
        self.value = value
        self.data = data
        self.gasPrice = gasPrice
        self.gasLimit = gasLimit
        self.v = v
        self.r = r
        self.s = s
    }

    public mutating func applyOptions(_ options: TransactionOptions) {
        // type cannot be changed here, and is ignored
        self.nonce = options.resolveNonce(self.nonce)
        self.gasPrice = options.resolveGasPrice(self.gasPrice)
        self.gasLimit = options.resolveGasLimit(self.gasLimit)
        // swiftlint:disable force_unwrapping
        if options.value != nil { self.value = options.value! }
        if options.to != nil { self.to = options.to! }
        // swiftlint:enable force_unwrapping
    }

    public func encode(for type: EncodeType = .transaction) -> Data? {
        let fields: [AnyObject]
        switch type {
        case .transaction: fields = [self.nonce, self.gasPrice, self.gasLimit, self.to.addressData, self.value, self.data, v, r, s] as [AnyObject]
        case .signature:
            if let chainID = self.chainID, chainID != 0 {
                fields = [self.nonce, self.gasPrice, self.gasLimit, self.to.addressData, self.value, self.data, chainID, BigUInt(0), BigUInt(0)] as [AnyObject]
            } else {
                fields = [self.nonce, self.gasPrice, self.gasLimit, self.to.addressData, self.value, self.data] as [AnyObject]
            }
        }
        return RLP.encode(fields)
    }

    public func encodeAsDictionary(from: EthereumAddress? = nil) -> TransactionParameters? {
        var toString: String?
        switch self.to.type {
        case .normal:
            toString = self.to.address.lowercased()
        case .contractDeployment:
            break
        }
        var params = TransactionParameters(from: from?.address.lowercased(), to: toString)
        let gasEncoding = self.gasLimit.abiEncode(bits: 256)
        params.gas = gasEncoding?.toHexString().addHexPrefix().stripLeadingZeroes()
        let gasPriceEncoding = self.gasPrice.abiEncode(bits: 256)
        params.gasPrice = gasPriceEncoding?.toHexString().addHexPrefix().stripLeadingZeroes()
        let valueEncoding = self.value.abiEncode(bits: 256)
        params.value = valueEncoding?.toHexString().addHexPrefix().stripLeadingZeroes()
        params.data = self.data.toHexString().addHexPrefix()
        return params
    }

    public func getUnmarshalledSignatureData() -> SECP256K1.UnmarshaledSignature? {
        if self.r == 0 && self.s == 0 { return nil }
        var normalizedV: BigUInt = 27
        let chainID: BigUInt? = self.chainID
        var d: BigUInt = 0

        if self.v >= 35 && self.v <= 38 {
            d = 35
        } else if self.v >= 31 && self.v <= 34 {
            d = 31
        } else if self.v >= 27 && self.v <= 30 {
            d = 27
        }

        if let id = chainID, id != 0 && self.v >= (d + id + id) {
            normalizedV = self.v - d - id - id
        } else {
            if d > v { d = 0 }
            normalizedV = self.v - d
        }

        guard let rData = self.r.serialize().setLengthLeft(32) else { return nil }
        guard let sData = self.s.serialize().setLengthLeft(32) else { return nil }

        return SECP256K1.UnmarshaledSignature(v: UInt8(normalizedV), r: rData, s: sData)
    }

    public mutating func setUnmarshalledSignatureData(_ unmarshalledSignature: SECP256K1.UnmarshaledSignature) {
        if let chainID = self.explicitChainID {
            var d: BigUInt = 0
            if unmarshalledSignature.v >= 0 && unmarshalledSignature.v <= 3 {
                d = 35
            } else if unmarshalledSignature.v >= 27 && unmarshalledSignature.v <= 30 {
                d = 8
            } else if unmarshalledSignature.v >= 31 && unmarshalledSignature.v <= 34 {
                d = 4
            }
            self.v = BigUInt(unmarshalledSignature.v) + d + chainID + chainID
            self.r = BigUInt(unmarshalledSignature.r)
            self.s = BigUInt(unmarshalledSignature.s)
        } else {
            var d: BigUInt = 0
            var a: BigUInt = 0
            if unmarshalledSignature.v >= 0 && unmarshalledSignature.v <= 3 {
                d = 27
            } else if unmarshalledSignature.v >= 31 && unmarshalledSignature.v <= 34 {
                a = 4
            } else if unmarshalledSignature.v >= 35 && unmarshalledSignature.v <= 38 {
                a = 8
            }
            self.v = BigUInt(unmarshalledSignature.v) + d - a
            self.r = BigUInt(unmarshalledSignature.r)
            self.s = BigUInt(unmarshalledSignature.s)
        }
    }
}
