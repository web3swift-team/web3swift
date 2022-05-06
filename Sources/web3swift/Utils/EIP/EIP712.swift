import BigInt
import CryptoSwift
import Foundation

// TODO: Refactor me

struct EIP712Domain: EIP712DomainHashable {
    let chainId:            EIP712.UInt256?
    let verifyingContract:  EIP712.Address
}

protocol EIP712DomainHashable: EIP712Hashable {}

public struct SafeTx: EIP712Hashable {
    let to:             EIP712.Address
    let value:          EIP712.UInt256
    let data:           EIP712.Bytes
    let operation:      EIP712.UInt8
    let safeTxGas:      EIP712.UInt256
    let baseGas:        EIP712.UInt256
    let gasPrice:       EIP712.UInt256
    let gasToken:       EIP712.Address
    let refundReceiver: EIP712.Address
    let nonce:          EIP712.UInt256

    public init(to: EIP712.Address, value: EIP712.UInt256, data: EIP712.Bytes, operation: EIP712.UInt8, safeTxGas: EIP712.UInt256, baseGas: EIP712.UInt256, gasPrice: EIP712.UInt256, gasToken: EIP712.Address, refundReceiver: EIP712.Address, nonce: EIP712.UInt256) {
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

public extension EIP712.Address {
    static var zero: Self {
        EthereumAddress(Data(count: 20))!
    }
}

public extension EIP712Hashable {
    private var name: String {
        let fullName = "\(Self.self)"
        let name = fullName.components(separatedBy: ".").last ?? fullName
        return name
    }

    private func dependencies() -> [EIP712Hashable] {
        let dependencies = Mirror(reflecting: self).children
            .compactMap { $0.value as? EIP712Hashable }
            .flatMap { [$0] + $0.dependencies() }
        return dependencies
    }

    private func encodePrimaryType() -> String {
        let parametrs: [String] = Mirror(reflecting: self).children.compactMap { key, value in
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
        return self.name + "(" + parametrs.joined(separator: ",") + ")"
    }

    func encodeType() -> String {
        let dependencies = self.dependencies().map { $0.encodePrimaryType() }
        let selfPrimaryType = self.encodePrimaryType()

        let result = Set(dependencies).filter { $0 != selfPrimaryType }
        return selfPrimaryType + result.sorted().joined()
    }

    // MARK: - Default implementation

    var typehash: Data {
        keccak256(encodeType())
    }

    func hash() throws -> Data {
        typealias SolidityValue = (value: Any, type: ABI.Element.ParameterType)
        var parametrs: [Data] = [self.typehash]
        for case let (_, field) in Mirror(reflecting: self).children {
            let result: Data
            switch field {
            case let string as String:
                result = keccak256(string)
            case let data as EIP712.Bytes:
                result = keccak256(data)
            case is EIP712.UInt8:
                result = ABIEncoder.encodeSingleType(type: .uint(bits: 8), value: field as AnyObject)!
            case is EIP712.UInt256:
                result = ABIEncoder.encodeSingleType(type: .uint(bits: 256), value: field as AnyObject)!
            case is EIP712.Address:
                result = ABIEncoder.encodeSingleType(type: .address, value: field as AnyObject)!
            case let hashable as EIP712Hashable:
                result = try hashable.hash()
            default:
                if (field as AnyObject) is NSNull {
                    continue
                } else {
                    preconditionFailure("Not solidity type")
                }
            }
            guard result.count == 32 else { preconditionFailure("ABI encode error") }
            parametrs.append(result)
        }
        let encoded = parametrs.flatMap { $0.bytes }
        return keccak256(encoded)
    }
}

// Encode functions
func eip712encode(domainSeparator: EIP712Hashable, message: EIP712Hashable) throws -> Data {
    let data = try Data([UInt8(0x19), UInt8(0x01)]) + domainSeparator.hash() + message.hash()
    return keccak256(data)
}

// MARK: - keccak256
private func keccak256(_ data: [UInt8]) -> Data {
    Data(SHA3(variant: .keccak256).calculate(for: data))
}

private func keccak256(_ string: String) -> Data {
    keccak256(Array(string.utf8))
}

private func keccak256(_ data: Data) -> Data {
    keccak256(data.bytes)
}
