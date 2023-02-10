import CryptoSwift
import Foundation
import BigInt
import Web3Core

/// Protocol defines EIP712 struct encoding
public protocol EIP712Hashable {
    var typehash: Data { get }
    func hash() throws -> Data
}

public class EIP712 {
    public typealias Address = EthereumAddress
    public typealias UInt256 = BigUInt
    public typealias UInt8 = Swift.UInt8
    public typealias Bytes = Data
}

public struct EIP712Domain: EIP712Hashable {
    public let chainId: EIP712.UInt256?
    public let verifyingContract: EIP712.Address
    public init(chainId: EIP712.UInt256?, verifyingContract: EIP712.Address) {
        self.chainId = chainId
        self.verifyingContract = verifyingContract
    }
}

public extension EIP712.Address {
    static var zero: Self {
        // swiftlint:disable force_unwrapping
        EthereumAddress(Data(count: 20))!
        // swiftlint:enable force_unwrapping
    }
}

// MARK: - Default implementation for EIP712Hashable
public extension EIP712Hashable {
    var typehash: Data {
        Data(encodeType().bytes).sha3(.keccak256)
    }

    func hash() throws -> Data {
        var parameters: [Data] = [typehash]
        for case let (_, field) in Mirror(reflecting: self).children {
            let result: Data
            switch field {
            case let string as String:
                result = Data(string.bytes).sha3(.keccak256)
            case let data as EIP712.Bytes:
                result = data.sha3(.keccak256)
            case is EIP712.UInt8:
                result = ABIEncoder.encodeSingleType(type: .uint(bits: 8), value: field)!
            case is EIP712.UInt256:
                result = ABIEncoder.encodeSingleType(type: .uint(bits: 256), value: field)!
            case is EIP712.Address:
                result = ABIEncoder.encodeSingleType(type: .address, value: field)!
            case let hashable as EIP712Hashable:
                result = try hashable.hash()
            default:
                /// Cast to `AnyObject` is required. Otherwise, `nil` value will fail this condition.
                if (field as AnyObject) is NSNull {
                    continue
                } else {
                    preconditionFailure("Not solidity type")
                }
            }
            guard result.count == 32 else { preconditionFailure("ABI encode error") }
            parameters.append(result)
        }
        return Data(parameters.flatMap { $0.bytes }).sha3(.keccak256)
    }
}

public func eip712encode(domainSeparator: EIP712Hashable, message: EIP712Hashable) throws -> Data {
    let data = try Data([UInt8(0x19), UInt8(0x01)]) + domainSeparator.hash() + message.hash()
    return data.sha3(.keccak256)
}

// MARK: - Additional private and public extensions with support members

public extension EIP712Hashable {
    func encodeType() -> String {
        let dependencies = dependencies().map { $0.encodePrimaryType() }
        let selfPrimaryType = encodePrimaryType()

        let result = Set(dependencies).filter { $0 != selfPrimaryType }
        return selfPrimaryType + result.sorted().joined()
    }
}

fileprivate extension EIP712Hashable {
    var name: String {
        let fullName = "\(Self.self)"
        let name = fullName.components(separatedBy: ".").last ?? fullName
        return name
    }

    func dependencies() -> [EIP712Hashable] {
        Mirror(reflecting: self).children
            .compactMap { $0.value as? EIP712Hashable }
            .flatMap { [$0] + $0.dependencies() }
    }

    func encodePrimaryType() -> String {
        let parameters: [String] = Mirror(reflecting: self).children.compactMap { key, value in
            guard let key = key else { return nil }

            func checkIfValueIsNil(value: Any) -> Bool {
                let mirror = Mirror(reflecting: value)
                if mirror.displayStyle == .optional {
                    if mirror.children.count == 0 {
                        return true
                    }
                }

                return false
            }

            guard !checkIfValueIsNil(value: value) else { return nil }

            let typeName: String
            switch value {
            case is EIP712.UInt8: typeName = "uint8"
            case is EIP712.UInt256: typeName = "uint256"
            case is EIP712.Address: typeName = "address"
            case is EIP712.Bytes: typeName = "bytes"
            case let hashable as EIP712Hashable: typeName = hashable.name
            default: typeName = "\(type(of: value))".lowercased()
            }
            return typeName + " " + key
        }
        return name + "(" + parameters.joined(separator: ",") + ")"
    }
}

// MARK: - Gnosis Safe Transaction model

/// Gnosis Safe Transaction.
/// https://docs.gnosis-safe.io/tutorials/tutorial_tx_service_initiate_sign
///
/// Note for web3swift developers: **DO NOT CHANGE THE ORDER OF VARIABLES**.
///
/// Changing the order will result in a different hash.
/// Order must match the implementation of hash calculation in
/// [`GnosisSafe.sol`](https://github.com/safe-global/safe-contracts/blob/main/contracts/GnosisSafe.sol#L126).
public struct GnosisSafeTx: EIP712Hashable {
    /// Checksummed address
    let to: EIP712.Address
    /// Value in wei
    let value: EIP712.UInt256
    /// 0x prefixed hex string
    let data: EIP712.Bytes
    /// `0` CALL, `1` DELEGATE_CALL
    let operation: EIP712.UInt8
    /// Max gas to use in the transaction
    let safeTxGas: EIP712.UInt256
    /// Gast costs not related to the transaction execution (signature check, refund payment...)
    let baseGas: EIP712.UInt256
    /// Gas price used for the refund calculation
    let gasPrice: EIP712.UInt256
    /// Token address, **must be checksummed**, (held by the Safe) to be used as a refund to the sender, if `null` is Ether
    let gasToken: EIP712.Address
    /// Checksummed address of receiver of gas payment (or `null` if tx.origin)
    let refundReceiver: EIP712.Address
    /// Nonce of the Safe, transaction cannot be executed until Safe's nonce is not equal to this nonce
    let nonce: EIP712.UInt256

    public init(to: EIP712.Address,
                value: EIP712.UInt256,
                data: EIP712.Bytes,
                operation: EIP712.UInt8,
                safeTxGas: EIP712.UInt256,
                baseGas: EIP712.UInt256,
                gasPrice: EIP712.UInt256,
                gasToken: EIP712.Address,
                refundReceiver: EIP712.Address,
                nonce: EIP712.UInt256) {
        self.to = to
        self.value = value
        self.data = data
        self.operation = operation
        self.safeTxGas = safeTxGas
        self.baseGas = baseGas
        self.gasPrice = gasPrice
        self.gasToken = gasToken
        self.refundReceiver = refundReceiver
        self.nonce = nonce
    }

}
