//
//  web3utils.swift
//  web3swift
//
//  Created by Alexander Vlasov on 18.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt
import CryptoSwift

public typealias Web3Utils = Web3.Utils

extension Web3 {
    public struct Utils {
        
        typealias Iban = IBAN
    }
}

extension Web3.Utils {
    public static func calcualteContractAddress(from: EthereumAddress, nonce: BigUInt) -> EthereumAddress? {
        guard let normalizedAddress = from.addressData.setLengthLeft(32) else {return nil}
        guard let data = RLP.encode([normalizedAddress, nonce] as [Any]) else {return nil}
        guard let contractAddressData = Web3.Utils.sha3(data)?[12..<32] else {return nil}
        guard let contractAddress = EthereumAddress(Data(contractAddressData)) else {return nil}
        return contractAddress
    }
    
    public enum Units {
        case eth
        case wei
        case Kwei
        case Mwei
        case Gwei
        case Microether
        case Finney
        
        var decimals:Int {
            get {
                switch self {
                case .eth:
                    return 18
                case .wei:
                    return 0
                case .Kwei:
                    return 3
                case .Mwei:
                    return 6
                case .Gwei:
                    return 9
                case .Microether:
                    return 12
                case .Finney:
                    return 15
                }
            }
        }
    }
    
    public static var coldWalletABI = "[{\"payable\":true,\"type\":\"fallback\"}]"
    public static var erc20ABI = "[{\"constant\":true,\"inputs\":[],\"name\":\"name\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"approve\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"totalSupply\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_from\",\"type\":\"address\"},{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transferFrom\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"decimals\",\"outputs\":[{\"name\":\"\",\"type\":\"uint8\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"version\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"}],\"name\":\"balanceOf\",\"outputs\":[{\"name\":\"balance\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"symbol\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_to\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"transfer\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"_spender\",\"type\":\"address\"},{\"name\":\"_value\",\"type\":\"uint256\"},{\"name\":\"_extraData\",\"type\":\"bytes\"}],\"name\":\"approveAndCall\",\"outputs\":[{\"name\":\"success\",\"type\":\"bool\"}],\"payable\":false,\"type\":\"function\"},{\"constant\":true,\"inputs\":[{\"name\":\"_owner\",\"type\":\"address\"},{\"name\":\"_spender\",\"type\":\"address\"}],\"name\":\"allowance\",\"outputs\":[{\"name\":\"remaining\",\"type\":\"uint256\"}],\"payable\":false,\"type\":\"function\"},{\"inputs\":[{\"name\":\"_initialAmount\",\"type\":\"uint256\"},{\"name\":\"_tokenName\",\"type\":\"string\"},{\"name\":\"_decimalUnits\",\"type\":\"uint8\"},{\"name\":\"_tokenSymbol\",\"type\":\"string\"}],\"type\":\"constructor\"},{\"payable\":false,\"type\":\"fallback\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_from\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_to\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Transfer\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_owner\",\"type\":\"address\"},{\"indexed\":true,\"name\":\"_spender\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Approval\",\"type\":\"event\"},]"
}

extension Web3.Utils {
    
    public static func privateToPublic(_ privateKey: Data, compressed: Bool = false) -> Data? {
        guard let publicKey = SECP256K1.privateToPublic(privateKey:  privateKey, compressed: compressed) else {return nil}
        return publicKey
    }
    
    public static func publicToAddressData(_ publicKey: Data) -> Data? {
        if publicKey.count == 33 {
            guard let decompressedKey = SECP256K1.combineSerializedPublicKeys(keys: [publicKey], outputCompressed: false) else {return nil}
            return publicToAddressData(decompressedKey)
        }
        var stipped = publicKey
        if (stipped.count == 65) {
            if (stipped[0] != 4) {
                return nil
            }
            stipped = stipped[1...64]
        }
        if (stipped.count != 64) {
            return nil
        }
        let sha3 = stipped.sha3(.keccak256)
        let addressData = sha3[12...31]
        return addressData
    }
    
    public static func publicToAddress(_ publicKey: Data) -> EthereumAddress? {
        guard let addressData = Web3.Utils.publicToAddressData(publicKey) else {return nil}
        let address = addressData.toHexString().addHexPrefix().lowercased()
        return EthereumAddress(address)
    }
    
    public static func publicToAddressString(_ publicKey: Data) -> String? {
        guard let addressData = Web3.Utils.publicToAddressData(publicKey) else {return nil}
        let address = addressData.toHexString().addHexPrefix().lowercased()
        return address
    }
    
    public static func addressDataToString(_ addressData: Data) -> String {
        return addressData.toHexString().addHexPrefix().lowercased()
    }
    
    public static func hashPersonalMessage(_ personalMessage: Data) -> Data? {
        var prefix = "\u{19}Ethereum Signed Message:\n"
        prefix += String(personalMessage.count)
        guard let prefixData = prefix.data(using: .ascii) else {return nil}
        var data = Data()
        if personalMessage.count >= prefixData.count && prefixData == personalMessage[0 ..< prefixData.count] {
            data.append(personalMessage)
        } else {
            data.append(prefixData)
            data.append(personalMessage)
        }
        let hash = data.sha3(.keccak256)
        return hash
    }
    
    public static func parseToBigUInt(_ amount: String, units: Web3.Utils.Units = .eth) -> BigUInt? {
        let unitDecimals = units.decimals
        return parseToBigUInt(amount, decimals: unitDecimals)
    }
    
    public static func parseToBigUInt(_ amount: String, decimals: Int = 18) -> BigUInt? {
        let separators = CharacterSet(charactersIn: ".,")
        let components = amount.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: separators)
        guard components.count == 1 || components.count == 2 else {return nil}
        let unitDecimals = decimals
        guard let beforeDecPoint = BigUInt(components[0], radix: 10) else {return nil}
        var mainPart = beforeDecPoint*BigUInt(10).power(unitDecimals)
        if (components.count == 2) {
            let numDigits = components[1].count
            guard numDigits <= unitDecimals else {return nil}
            guard let afterDecPoint = BigUInt(components[1], radix: 10) else {return nil}
            let extraPart = afterDecPoint*BigUInt(10).power(unitDecimals-numDigits)
            mainPart = mainPart + extraPart
        }
        return mainPart
    }
    
    public static func formatToEthereumUnits(_ bigNumber: BigInt, toUnits: Web3.Utils.Units = .eth, decimals: Int = 4, decimalSeparator: String = ".") -> String? {
        let magnitude = bigNumber.magnitude
        guard let formatted = formatToEthereumUnits(magnitude, toUnits: toUnits, decimals: decimals, decimalSeparator: decimalSeparator) else {return nil}
        switch bigNumber.sign {
        case .plus:
            return formatted
        case .minus:
            return "-" + formatted
        }
    }
    
    public static func formatToPrecision(_ bigNumber: BigInt, numberDecimals: Int = 18, formattingDecimals: Int = 4, decimalSeparator: String = ".", fallbackToScientific: Bool = false) -> String? {
        let magnitude = bigNumber.magnitude
        guard let formatted = formatToPrecision(magnitude, numberDecimals: numberDecimals, formattingDecimals: formattingDecimals, decimalSeparator: decimalSeparator, fallbackToScientific: fallbackToScientific) else {return nil}
        switch bigNumber.sign {
        case .plus:
            return formatted
        case .minus:
            return "-" + formatted
        }
    }
    
    public static func formatToEthereumUnits(_ bigNumber: BigUInt, toUnits: Web3.Utils.Units = .eth, decimals: Int = 4, decimalSeparator: String = ".", fallbackToScientific: Bool = false) -> String? {
        return formatToPrecision(bigNumber, numberDecimals: toUnits.decimals, formattingDecimals: decimals, decimalSeparator: decimalSeparator, fallbackToScientific: fallbackToScientific);
    }
    
    public static func formatToPrecision(_ bigNumber: BigUInt, numberDecimals: Int = 18, formattingDecimals: Int = 4, decimalSeparator: String = ".", fallbackToScientific: Bool = false) -> String? {
        if bigNumber == 0 {
            return "0"
        }
        let unitDecimals = numberDecimals
        var toDecimals = formattingDecimals
        if unitDecimals < toDecimals {
            toDecimals = unitDecimals
        }
        let divisor = BigUInt(10).power(unitDecimals)
        let (quotient, remainder) = bigNumber.quotientAndRemainder(dividingBy: divisor)
        let fullRemainder = String(remainder);
        let fullPaddedRemainder = fullRemainder.leftPadding(toLength: unitDecimals, withPad: "0")
        let remainderPadded = fullPaddedRemainder[0..<toDecimals]
        if remainderPadded == String(repeating: "0", count: toDecimals) {
            if quotient != 0 {
                return String(quotient)
            } else if fallbackToScientific {
                var firstDigit = 0
                for char in fullPaddedRemainder {
                    if (char == "0") {
                        firstDigit = firstDigit + 1;
                    } else {
                        firstDigit = firstDigit + 1;
                        break
                    }
                }
                return fullRemainder + "e-" + String(firstDigit)
            }
        }
        if (toDecimals == 0) {
            return String(quotient)
        }
        return String(quotient) + decimalSeparator + remainderPadded
    }
    
    static public func personalECRecover(_ personalMessage: String, signature: String) -> EthereumAddress? {
        guard let data = Data.fromHex(personalMessage) else {return nil}
        guard let sig = Data.fromHex(signature) else {return nil}
        return Web3.Utils.personalECRecover(data, signature:sig)
    }
    
    static public func personalECRecover(_ personalMessage: Data, signature: Data) -> EthereumAddress? {
        if signature.count != 65 { return nil}
        let rData = signature[0..<32].bytes
        let sData = signature[32..<64].bytes
        let vData = signature[64]
        guard let signatureData = SECP256K1.marshalSignature(v: vData, r: rData, s: sData) else {return nil}
        guard let hash = Web3.Utils.hashPersonalMessage(personalMessage) else {return nil}
        guard let publicKey = SECP256K1.recoverPublicKey(hash: hash, signature: signatureData) else {return nil}
        return Web3.Utils.publicToAddress(publicKey)
    }
    
    static public func hashECRecover(hash: Data, signature: Data) -> EthereumAddress? {
        if signature.count != 65 { return nil}
        let rData = signature[0..<32].bytes
        let sData = signature[32..<64].bytes
        let vData = signature[64]
        guard let signatureData = SECP256K1.marshalSignature(v: vData, r: rData, s: sData) else {return nil}
        guard let publicKey = SECP256K1.recoverPublicKey(hash: hash, signature: signatureData) else {return nil}
        return Web3.Utils.publicToAddress(publicKey)
    }
    
    /// returns Ethereum variant of sha3 (keccak256) of data. Returns nil is data is empty
    static public func keccak256(_ data: Data) -> Data? {
        if data.count == 0 {return nil}
        return data.sha3(.keccak256)
    }
    
    /// returns Ethereum variant of sha3 (keccak256) of data. Returns nil is data is empty
    static public func sha3(_ data: Data) -> Data? {
        if data.count == 0 {return nil}
        return data.sha3(.keccak256)
    }
    
    /// returns sha256 of data. Returns nil is data is empty
    static public func sha256(_ data: Data) -> Data? {
        if data.count == 0 {return nil}
        return data.sha256()
    }
    
    static func unmarshalSignature(signatureData:Data) -> SECP256K1.UnmarshaledSignature? {
        if (signatureData.count != 65) {return nil}
        let bytes = signatureData.bytes
        let r = Array(bytes[0..<32])
        let s = Array(bytes[32..<64])
        return SECP256K1.UnmarshaledSignature(v: bytes[64], r: r, s: s)
    }
    
    static func marshalSignature(v: UInt8, r: [UInt8], s: [UInt8]) -> Data? {
        guard r.count == 32, s.count == 32 else {return nil}
        var completeSignature = Data(bytes: r)
        completeSignature.append(Data(bytes: s))
        completeSignature.append(Data(bytes: [v]))
        return completeSignature
    }
    
    static func marshalSignature(unmarshalledSignature: SECP256K1.UnmarshaledSignature) -> Data? {
        var completeSignature = Data(bytes: unmarshalledSignature.r)
        completeSignature.append(Data(bytes: unmarshalledSignature.s))
        completeSignature.append(Data(bytes: [unmarshalledSignature.v]))
        return completeSignature
    }
}
