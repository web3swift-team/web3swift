//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//
//  Support for EIP-1559 Transaction type by Mark Loit March 2022

import Foundation
import BigInt

public struct EIP1559Envelope: EIP2718Envelope, EIP2930Compatible {
    public let type: TransactionType = .eip1559

    // common parameters for any transaction
    public var nonce: BigUInt = 0
    public var chainID: BigUInt?

    public var from: EthereumAddress? {
        guard let publicKey = publicKey else { return nil }
        return Utilities.publicToAddress(publicKey)
    }

    public var to: EthereumAddress
    public var value: BigUInt
    public var data: Data
    public var v: BigUInt
    public var r: BigUInt
    public var s: BigUInt

    // EIP-1559 specific parameters
    public var gasLimit: BigUInt

    var gasPrice: BigUInt?

    /// Value of the tip to the miner for transaction processing.
    ///
    /// Full amount of this variable goes to a miner.
    public var maxPriorityFeePerGas: BigUInt?
    /// Value of the fee for one gas unit
    ///
    /// This value should be greater than sum of:
    /// - `Block.nextBlockBaseFeePerGas` - baseFee which will be burnt during the transaction processing
    /// - `self.maxPriorityFeePerGas` - explicit amount of a tip to the miner of the given block which will include this transaction
    ///
    /// If amount of this will be **greater** than sum of `Block.baseFeePerGas` and `maxPriorityFeePerGas`
    /// all exceed funds will be returned to the sender.
    ///
    /// If amount of this will be **lower** than sum of `Block.baseFeePerGas` and `maxPriorityFeePerGas`
    /// miner will receive amount calculated by the following equation: `maxFeePerGas - Block.baseFeePerGas`
    /// where 'Block' is the block that the transaction will be included.
    public var maxFeePerGas: BigUInt?
    public var accessList: [AccessListEntry] // from EIP-2930

    // for CustomStringConvertible
    public var description: String {
        var toReturn = ""
        toReturn += "Type: " + String(describing: self.type) + "\n"
        toReturn += "chainID: " + String(describing: self.chainID) + "\n"
        toReturn += "Nonce: " + String(describing: self.nonce) + "\n"
        toReturn += "Gas limit: " + String(describing: self.gasLimit) + "\n"
        toReturn += "Max priority fee per gas: " + String(describing: self.maxPriorityFeePerGas) + "\n"
        toReturn += "Max fee per gas: " + String(describing: maxFeePerGas) + "\n"
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

extension EIP1559Envelope {
    private enum CodingKeys: String, CodingKey {
        case chainId
        case nonce
        case to
        case value
        case maxPriorityFeePerGas
        case maxFeePerGas
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

        guard container.contains(.to), container.contains(.nonce), container.contains(.value), container.contains(.chainId) else { return nil }
        if !container.contains(.data) && !container.contains(.input) { return nil }
        guard container.contains(.v), container.contains(.r), container.contains(.s) else { return nil }

        // everything we need is present, so we should only have to throw from here
        self.chainID = try container.decodeHexIfPresent(BigUInt.self, forKey: .chainId) ?? 0
        self.nonce = try container.decodeHex(BigUInt.self, forKey: .nonce)

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

        self.value = try container.decodeHexIfPresent(BigUInt.self, forKey: .value) ?? 0
        self.maxPriorityFeePerGas = try container.decodeHexIfPresent(BigUInt.self, forKey: .maxPriorityFeePerGas) ?? 0
        self.maxFeePerGas = try container.decodeHexIfPresent(BigUInt.self, forKey: .maxFeePerGas) ?? 0
        self.gasLimit = try container.decodeHexIfPresent(BigUInt.self, forKey: .gas) ?? container.decodeHexIfPresent(BigUInt.self, forKey: .gasLimit) ?? 0

        self.data = try container.decodeHexIfPresent(Data.self, forKey: .input) ?? container.decodeHex(Data.self, forKey: .data)
        self.v = try container.decodeHex(BigUInt.self, forKey: .v)
        self.r = try container.decodeHex(BigUInt.self, forKey: .r)
        self.s = try container.decodeHex(BigUInt.self, forKey: .s)
    }

    private enum RlpKey: Int, CaseIterable {
        case chainId
        case nonce
        case maxPriorityFeePerGas
        case maxFeePerGas
        case gasLimit
        case destination
        case amount
        case data
        case accessList
        case sig_v
        case sig_r
        case sig_s
    }

    public init?(rawValue: Data) {
        // pop the first byte from the stream [EIP-2718]
        let typeByte: UInt8 = rawValue.first ?? 0 // can't decode if we're the wrong type
        guard self.type.rawValue == typeByte else { return nil }

        guard let totalItem = RLP.decode(rawValue.dropFirst(1)) else { return nil }
        guard let rlpItem = totalItem[0] else { return nil }
        guard RlpKey.allCases.count == rlpItem.count else { return nil }

        // we've validated the item count, so rlpItem[keyName] is guaranteed to return something not nil
        // swiftlint:disable force_unwrapping
        guard let chainData = rlpItem[RlpKey.chainId.rawValue]!.data else { return nil }
        guard let nonceData = rlpItem[RlpKey.nonce.rawValue]!.data else { return nil }
        guard let maxPriorityData = rlpItem[RlpKey.maxPriorityFeePerGas.rawValue]!.data else { return nil }
        guard let maxFeeData = rlpItem[RlpKey.maxFeePerGas.rawValue]!.data else { return nil }
        guard let gasLimitData = rlpItem[RlpKey.gasLimit.rawValue]!.data else { return nil }
        guard let valueData = rlpItem[RlpKey.amount.rawValue]!.data else { return nil }
        guard let transactionData = rlpItem[RlpKey.data.rawValue]!.data else { return nil }
        guard let vData = rlpItem[RlpKey.sig_v.rawValue]!.data else { return nil }
        guard let rData = rlpItem[RlpKey.sig_r.rawValue]!.data else { return nil }
        guard let sData = rlpItem[RlpKey.sig_s.rawValue]!.data else { return nil }
        // swiftlint:enable force_unwrapping

        self.chainID = BigUInt(chainData)
        self.nonce = BigUInt(nonceData)
        self.maxPriorityFeePerGas = BigUInt(maxPriorityData)
        self.maxFeePerGas = BigUInt(maxFeeData)
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

    // memberwise
    public init(to: EthereumAddress, nonce: BigUInt = 0,
                chainID: BigUInt = 0, value: BigUInt = 0, data: Data,
                maxPriorityFeePerGas: BigUInt = 0, maxFeePerGas: BigUInt = 0, gasLimit: BigUInt = 0,
                accessList: [AccessListEntry]? = nil,
                v: BigUInt = 1, r: BigUInt = 0, s: BigUInt = 0) {
        self.to = to
        self.nonce = nonce
        self.chainID = chainID
        self.value = value
        self.data = data
        self.maxPriorityFeePerGas = maxPriorityFeePerGas
        self.maxFeePerGas = maxFeePerGas
        self.gasLimit = gasLimit
        self.accessList = accessList ?? []
        self.v = v
        self.r = r
        self.s = s
    }

//    public mutating func applyTransaction(_ transaction: CodableTransaction) {
//        // type cannot be changed here, and is ignored
//        self.nonce = transaction.resolveNonce(self.nonce)
//        self.maxPriorityFeePerGas = transaction.resolveMaxPriorityFeePerGas(self.maxPriorityFeePerGas)
//        self.maxFeePerGas = transaction.resolveMaxFeePerGas(self.maxFeePerGas)
//        self.gasLimitPolicy = transaction.resolveGasLimit(self.gasLimit)
//        self.value = transaction.value ?? self.value
//        self.to = transaction.to ?? self.to
//        self.accessList = transaction.accessList ?? self.accessList
//    }

    public func encode(for type: EncodeType = .transaction) -> Data? {
        let fields: [Any?]
        let list = accessList.map { $0.encodeAsList() }
        switch type {
        case .transaction:
            fields = [chainID, nonce, maxPriorityFeePerGas, maxFeePerGas, gasLimit, to.addressData, value, data, list, v, r, s]
        case .signature:
            fields = [chainID, nonce, maxPriorityFeePerGas, maxFeePerGas, gasLimit, to.addressData, value, data, list]
        }
        guard var result = RLP.encode(fields) else { return nil }
        result.insert(UInt8(self.type.rawValue), at: 0)
        return result
    }
}
