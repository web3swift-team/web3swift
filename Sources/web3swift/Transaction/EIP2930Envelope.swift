//  Package: web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//
//  Support for EIP-2930 transaction type by Mark Loit 2022

import Foundation
import BigInt

public struct EIP2930Envelope: EIP2718Envelope {
    public let type: TransactionType = .eip2930

    // common parameters for any transaction
    public var nonce: BigUInt = 0
    public var chainID: BigUInt? {
        get { return internalChainID }
        // swiftlint:disable force_unwrapping
        set(newID) { if newID != nil { internalChainID = newID! } }
        // swiftlint:enable force_unwrapping
    }
    public var to: EthereumAddress
    public var value: BigUInt
    public var data: Data
    public var v: BigUInt
    public var r: BigUInt
    public var s: BigUInt

    // EIP-2930 specific parameters
    public var gasPrice: BigUInt = 0
    public var gasLimit: BigUInt = 0
    public var accessList: [AccessListEntry] = []

    private var internalChainID: BigUInt

    // for CustomStringConvertible
    public var description: String {
        var toReturn = ""
        toReturn += "Type: " + String(describing: self.type) + "\n"
        toReturn += "chainID: " + String(describing: self.chainID) + "\n"
        toReturn += "Nonce: " + String(describing: self.nonce) + "\n"
        toReturn += "Gas price: " + String(self.gasPrice) + "\n"
        toReturn += "Gas limit: " + String(describing: self.gasLimit) + "\n"
        toReturn += "To: " + self.to.address + "\n"
        toReturn += "Value: " + String(describing: self.value) + "\n"
        toReturn += "Data: " + self.data.toHexString().addHexPrefix().lowercased() + "\n"
        toReturn += "Access List: " + String(describing: accessList) + "\n"
        toReturn += "v: " + String(self.v) + "\n"
        toReturn += "r: " + String(self.r) + "\n"
        toReturn += "s: " + String(self.s) + "\n"
        return toReturn
    }
}

extension EIP2930Envelope {
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
        case accessList
        case v
        case r
        case s
    }

    public init?(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if !container.contains(.to) || !container.contains(.nonce) || !container.contains(.value) || !container.contains(.chainId) { return nil }
        if !container.contains(.data) && !container.contains(.input) { return nil }
        if !container.contains(.v) || !container.contains(.r) || !container.contains(.s) { return nil }

        // everything we need is present, so we should only have to throw from here
        self.internalChainID = try container.decodeHexIfPresent(to: BigUInt.self, key: .chainId) ?? 0
        self.nonce = try container.decodeHex(to: BigUInt.self, key: .nonce)

        let list = try? container.decode([AccessListEntry].self, forKey: .accessList)
        self.accessList = list ?? []

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
        self.value = try container.decodeHexIfPresent(to: BigUInt.self, key: .value) ?? 0
        self.gasPrice = try container.decodeHexIfPresent(to: BigUInt.self, key: .gasPrice) ?? 0
        self.gasLimit = try container.decodeHexIfPresent(to: BigUInt.self, key: .gas) ?? container.decodeHexIfPresent(to: BigUInt.self, key: .gasLimit) ?? 0

        self.data = try container.decodeHexIfPresent(to: Data.self, key: .input) ?? container.decodeHex(to: Data.self, key: .data)
        self.v = try container.decodeHex(to: BigUInt.self, key: .v)
        self.r = try container.decodeHex(to: BigUInt.self, key: .r)
        self.s = try container.decodeHex(to: BigUInt.self, key: .s)
    }

    // RLP encoding positions
    fileprivate enum RlpKey: Int {
        case chainId
        case nonce
        case gasPrice
        case gasLimit
        case destination
        case amount
        case data
        case accessList
        case sig_v
        case sig_r
        case sig_s
        case total // not a real entry, used to auto-size based on number of keys
    }

    public init?(rawValue: Data) {
        // pop the first byte from the stream [EIP-2718]
        let typeByte: UInt8 = rawValue.first ?? 0 // can't decode if we're the wrong type
        if typeByte != self.type.rawValue { return nil }

        guard let totalItem = RLP.decode(rawValue.dropFirst(1)) else { return nil }
        guard let rlpItem = totalItem[0] else { return nil }
        if rlpItem.count != RlpKey.total.rawValue { return nil }

        // we've validated the item count, so rlpItem[keyIndex] is guaranteed to return something not nil
        // swiftlint:disable force_unwrapping
        guard let chainData = rlpItem[RlpKey.chainId.rawValue]!.data else { return nil }
        guard let nonceData = rlpItem[RlpKey.nonce.rawValue]!.data else { return nil }
        guard let gasPriceData = rlpItem[RlpKey.gasPrice.rawValue]!.data else { return nil }
        guard let gasLimitData = rlpItem[RlpKey.gasLimit.rawValue]!.data else { return nil }
        guard let valueData = rlpItem[RlpKey.amount.rawValue]!.data else { return nil }
        guard let transactionData = rlpItem[RlpKey.data.rawValue]!.data else { return nil }
        guard let vData = rlpItem[RlpKey.sig_v.rawValue]!.data else { return nil }
        guard let rData = rlpItem[RlpKey.sig_r.rawValue]!.data else { return nil }
        guard let sData = rlpItem[RlpKey.sig_s.rawValue]!.data else { return nil }
        // swiftlint:enable force_unwrapping

        self.internalChainID = BigUInt(chainData)
        self.nonce = BigUInt(nonceData)
        self.gasPrice = BigUInt(gasPriceData)
        self.gasLimit = BigUInt(gasLimitData)
        self.value = BigUInt(valueData)
        self.data = transactionData
        self.v = BigUInt(vData)
        self.r = BigUInt(rData)
        self.s = BigUInt(sData)

        // swiftlint:disable force_unwrapping
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

        // swiftlint:disable force_unwrapping
        switch rlpItem[RlpKey.accessList.rawValue]!.content {
            // swiftlint:enable force_unwrapping
        case .noItem:
            self.accessList = []
        case .data:
            return nil
        case .list:
            // decode the list here
            // swiftlint:disable force_unwrapping
            let accessData = rlpItem[RlpKey.accessList.rawValue]!
            // swiftlint:enable force_unwrapping
            let itemCount = accessData.count ?? 0
            var newList: [AccessListEntry] = []
            for index in 0...(itemCount - 1) {
                guard let itemData = accessData[index] else { return nil }
                guard let newItem = AccessListEntry(rlpItem: itemData)  else { return nil }
                newList.append(newItem)
            }
            self.accessList = newList
        }
    }

    public init(to: EthereumAddress, nonce: BigUInt? = nil,
                chainID: BigUInt? = nil, value: BigUInt? = nil, data: Data,
                v: BigUInt = 1, r: BigUInt = 0, s: BigUInt = 0,
                options: TransactionOptions? = nil) {
        self.to = to
        self.nonce = nonce ?? options?.resolveNonce(0) ?? 0
        self.internalChainID = chainID ?? 0
        self.value = value ?? options?.value ?? 0
        self.data = data
        self.v = v
        self.r = r
        self.s = s
        // decode gas options, if present
        self.gasPrice = options?.resolveGasPrice(0) ?? 0
        self.gasLimit = options?.resolveGasLimit(0) ?? 0
        self.accessList = options?.accessList ?? []
    }

    // memberwise
    public init(to: EthereumAddress, nonce: BigUInt = 0,
                chainID: BigUInt = 0, value: BigUInt = 0, data: Data,
                gasPrice: BigUInt = 0, gasLimit: BigUInt = 0, accessList: [AccessListEntry]? = nil,
                v: BigUInt = 1, r: BigUInt = 0, s: BigUInt = 0) {
        self.to = to
        self.nonce = nonce
        self.internalChainID = chainID
        self.value = value
        self.data = data
        self.gasPrice = gasPrice
        self.gasLimit = gasLimit
        self.accessList = accessList ?? []
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
        if options.accessList != nil { self.accessList = options.accessList! }
        // swiftlint:enable force_unwrapping
    }

    public func getOptions() -> TransactionOptions {
        var options = TransactionOptions()
        options.nonce = .manual(self.nonce)
        options.gasPrice = .manual(self.gasPrice)
        options.gasLimit = .manual(self.gasLimit)
        options.value = self.nonce
        options.to = self.to
        options.accessList = self.accessList
        return options
    }

    public func encodeFor(_ type: EncodeType = .transaction) -> Data? {
        let fields: [AnyObject]
        var list: [AnyObject] = []

        for listEntry in self.accessList {
            let encoded = listEntry.encodeAsList()
            list.append(encoded as AnyObject)
        }

        switch type {
        case .transaction: fields = [internalChainID, nonce, gasPrice, gasLimit, to.addressData, value, data, list, v, r, s] as [AnyObject]
        case .signature: fields = [internalChainID, nonce, gasPrice, gasLimit, to.addressData, value, data, list] as [AnyObject]
        }
        guard var result = RLP.encode(fields) else { return nil }
        result.insert(UInt8(self.type.rawValue), at: 0)
        return result
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
        let typeEncoding = String(UInt8(self.type.rawValue), radix: 16).addHexPrefix()
        params.type = typeEncoding
        let chainEncoding = self.internalChainID.abiEncode(bits: 256)
        params.chainID = chainEncoding?.toHexString().addHexPrefix().stripLeadingZeroes()
        var accessEncoding: [TransactionParameters.AccessListEntry] = []
        for listEntry in self.accessList {
            guard let encoded = listEntry.encodeAsDictionary() else { return nil }
            accessEncoding.append(encoded)
        }
        params.accessList = accessEncoding
        let gasEncoding = self.gasLimit.abiEncode(bits: 256)
        params.gas = gasEncoding?.toHexString().addHexPrefix().stripLeadingZeroes()
        let gasPriceEncoding = self.gasPrice.abiEncode(bits: 256)
        params.gasPrice = gasPriceEncoding?.toHexString().addHexPrefix().stripLeadingZeroes()
        let valueEncoding = self.value.abiEncode(bits: 256)
        params.value = valueEncoding?.toHexString().addHexPrefix().stripLeadingZeroes()
        if self.data != Data() {
            params.data = self.data.toHexString().addHexPrefix()
        } else {
            params.data = "0x"
        }
        return params
    }
}

public struct AccessListEntry: CustomStringConvertible, Decodable {
    var address: EthereumAddress
    var storageKeys: [BigUInt]

    // for CustomStringConvertible
    public var description: String {
        var toReturn = ""
        toReturn += "Address: " + self.address.address + "\n"
        toReturn += "Storage keys: " + String(describing: storageKeys) + "\n"
        return toReturn
    }

    private enum CodingKeys: String, CodingKey {
        case address
        case storageKeys
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let addrString = try? container.decode(String.self, forKey: .address)
        switch addrString {
        case nil, "0x", "0x0":
            self.address = EthereumAddress.contractDeploymentAddress()
        default:
            // the forced unwrap here is safe as we trap nil in the previous case
            // swiftlint:disable force_unwrapping
            guard let ethAddr = EthereumAddress(addrString!) else { throw Web3Error.dataError }
            // swiftlint:enable force_unwrapping
            self.address = ethAddr
        }
        self.storageKeys = []
        if let keyStrings = try? container.decode([String].self, forKey: .storageKeys) {
            for keyString in keyStrings {
                guard let number = BigUInt(from: keyString) else { throw Web3Error.dataError }
                self.storageKeys.append(number)
            }
        }
    }

    // RLP encoding positions
    fileprivate enum RlpKey: Int {
        case address
        case storageKeys
        case total // not a real entry, used to auto-size based on number of keys
    }

    public init?(rlpItem: RLP.RLPItem) {
        if rlpItem.count != RlpKey.total.rawValue { return nil }

        // swiftlint:disable force_unwrapping
        switch rlpItem[RlpKey.address.rawValue]!.content {
            // swiftlint:enable force_unwrapping
        case .noItem, .list:
            return nil
        case .data(let addressData):
            if addressData.count == 0 {
                return nil
            } else if addressData.count == 20 {
                guard let addr = EthereumAddress(addressData) else { return nil }
                self.address = addr
            } else { return nil }
        }

        // swiftlint:disable force_unwrapping
        switch rlpItem[RlpKey.storageKeys.rawValue]!.content {
            // swiftlint:enable force_unwrapping
        case .noItem:
            self.storageKeys = []
        case .data:
            return nil
        case .list:
            // decode the list here
            // swiftlint:disable force_unwrapping
            let keyData = rlpItem[RlpKey.storageKeys.rawValue]!
            // swiftlint:enable force_unwrapping
            let itemCount = keyData.count ?? 0
            var newList: [BigUInt] = []
            for index in 0...(itemCount - 1) {
                guard let keyItem = keyData[index] else { return nil }
                guard let itemData = keyItem.data else { return nil }
                if itemData.count != 32 { return nil }
                let newItem = BigUInt(itemData)
                newList.append(newItem)
            }
            self.storageKeys = newList
        }
    }

    public func encodeAsList() -> [AnyObject]? {
        var storage: [Data] = []

        for key in storageKeys {
            guard let keyData = key.abiEncode(bits: 256) else { return nil }
            storage.append(keyData)
        }

        return [address.address as AnyObject, storage as AnyObject]
    }

    public func encodeAsDictionary() -> TransactionParameters.AccessListEntry? {
        var addrString: String
        switch self.address.type {
        case .normal:
            addrString = self.address.address.lowercased()
        case .contractDeployment:
            return nil
        }

        var keyStrings: [String] = []
        for key in storageKeys {
            guard let keyString = key.abiEncode(bits: 256) else { return nil }
            keyStrings.append(keyString.toHexString().addHexPrefix())
        }
        return TransactionParameters.AccessListEntry(address: addrString, storageKeys: keyStrings)
    }
}