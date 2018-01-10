//
//  EthereumKeystoreV3.swift
//  web3swift
//
//  Created by Alexander Vlasov on 18.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import Foundation
import CryptoSwift
import Foundation

public typealias TransactionIntermediate = web3.web3contract.transactionIntermediate

public struct KdfParamsV3: Decodable, Encodable {
    var salt: String
    var dklen: Int
    var n: Int?
    var p: Int?
    var r: Int?
    var c: Int?
    var prf: String?
}

public struct CipherParamsV3: Decodable, Encodable {
    var iv: String
}

public struct CryptoParamsV3: Decodable, Encodable {
    var ciphertext: String
    var cipher: String
    var cipherparams: CipherParamsV3
    var kdf: String
    var kdfparams: KdfParamsV3
    var mac: String
    var version: String?
}

public struct KeystoreParamsV3: Decodable, Encodable {
    var address: String?
    var crypto: CryptoParamsV3
    var id: String?
    var version: Int
}

enum EthereumKeystoreV3Error: Error {
    case noEntropyError
    case keyDerivationError
    case aesError
    case encryptionError(String)
}

public class EthereumKeystoreV3 {
    public var keystoreParams: KeystoreParamsV3?
    public var address: EthereumAddress?
    
    public init?(_ jsonString: String) throws {
        let lowercaseJSON = jsonString.lowercased()
        guard let jsonData = lowercaseJSON.data(using: .utf8) else {return nil}
        guard let keystoreParams = try? JSONDecoder().decode(KeystoreParamsV3.self, from: jsonData) else {return nil}
        if (keystoreParams.version != 3) {return nil}
        if (keystoreParams.crypto.version != nil && keystoreParams.crypto.version != "1") {return nil}
        self.keystoreParams = keystoreParams
        if keystoreParams.address != nil {
            self.address = EthereumAddress(keystoreParams.address!)
        }
    }
    
    public init?(_ jsonData: Data) throws {
        guard let keystoreParams = try? JSONDecoder().decode(KeystoreParamsV3.self, from: jsonData) else {return nil}
        if (keystoreParams.version != 3) {return nil}
        if (keystoreParams.crypto.version != nil && keystoreParams.crypto.version != "1") {return nil}
        self.keystoreParams = keystoreParams
        if keystoreParams.address != nil {
            self.address = EthereumAddress(keystoreParams.address!)
        }
    }
    
    public init? (password: String = "BANKEXFOUNDATION") throws {
        guard let newPrivateKey = SECP256K1.generatePrivateKey() else {return nil}
        try encryptDataToStorage(password, keyData: newPrivateKey)
    }
    
    public init? (privateKey: Data, password: String = "BANKEXFOUNDATION") throws {
        guard privateKey.count == 32 else {return nil}
        try encryptDataToStorage(password, keyData: privateKey)
    }
    
    public func signedTX(transaction:EthereumTransaction, password: String) throws -> EthereumTransaction? {
        guard var privateKey = try self.getKeyData(password) else {return nil}
        defer {Data.zero(&privateKey)}
        var tx = transaction
        guard tx.sign(privateKey: privateKey) else {return nil}
        return tx
    }
    
    public func signTX( transaction:inout EthereumTransaction, password: String) throws{
        guard var privateKey = try self.getKeyData(password) else {throw EthereumKeystoreV3Error.keyDerivationError}
        defer {Data.zero(&privateKey)}
        guard transaction.sign(privateKey: privateKey) else {throw EthereumKeystoreV3Error.encryptionError("Failed to sign transaction")}
    }
    
    public func signIntermediate(intermediate: TransactionIntermediate, password: String, network: Networks? = nil) throws {
        var privateKey = try self.getKeyData(password)
        defer {Data.zero(&privateKey!)}
        try intermediate.sign(privateKey!, network: network)
    }
    
    public func signHashWithPrivateKey(hash: Data, password: String) throws -> Data? {
        guard let pk = try? self.getKeyData(password) else {return nil}
        guard var privateKey = pk else {return nil}
        defer {Data.zero(&privateKey)}
        let (compressedSignature, _) = SECP256K1.signForRecovery(hash: hash, privateKey: privateKey)
        return compressedSignature
    }
    
    public func signPersonalMessage(_ personalMessage: Data, password: String) throws -> Data? {
        var hash: Data
        if personalMessage.count == 32 {
            print("Most likely it's hash already, allow for now")
            hash = personalMessage
        } else {
            guard let h = Web3.Utils.hashPersonalMessage(personalMessage) else {return nil}
            hash = h
        }
        guard let pk = try? self.getKeyData(password) else {return nil}
        guard var privateKey = pk else {return nil}
        defer {Data.zero(&privateKey)}
        let (compressedSignature, _) = SECP256K1.signForRecovery(hash: hash, privateKey: privateKey)
        return compressedSignature
    }
    
    public func encryptDataToStorage(_ password: String, keyData: Data?, dkLen: Int=32, N: Int = 4096, R: Int = 6, P: Int = 1) throws {
        if (keyData == nil) {
            throw EthereumKeystoreV3Error.encryptionError("Encryption without key data")
        }
        let saltLen = 32;
        guard let saltData = Data.randomBytes(length: saltLen) else {throw EthereumKeystoreV3Error.noEntropyError}
        guard let derivedKey = scrypt(password: password, salt: saltData, length: dkLen, N: N, R: R, P: P) else {throw EthereumKeystoreV3Error.keyDerivationError}
        let last16bytes = derivedKey[(derivedKey.count - 16)...(derivedKey.count-1)]
        let encryptionKey = derivedKey[0...15]
        guard let IV = Data.randomBytes(length: 16) else {throw EthereumKeystoreV3Error.noEntropyError}
        let aecCipher = try? AES(key: encryptionKey.bytes, blockMode: .CBC(iv: IV.bytes), padding: .noPadding)
        guard let encryptedKey = try aecCipher?.encrypt(keyData!.bytes) else {throw EthereumKeystoreV3Error.aesError}
        let encryptedKeyData = Data(bytes:encryptedKey)
        var dataForMAC = Data()
        dataForMAC.append(last16bytes)
        dataForMAC.append(encryptedKeyData)
        let mac = dataForMAC.sha3(.keccak256)
        let kdfparams = KdfParamsV3(salt: saltData.toHexString(), dklen: dkLen, n: N, p: P, r: R, c: nil, prf: nil)
        let cipherparams = CipherParamsV3(iv: IV.toHexString())
        let crypto = CryptoParamsV3(ciphertext: encryptedKeyData.toHexString(), cipher: "aes-128-cbc", cipherparams: cipherparams, kdf: "scrypt", kdfparams: kdfparams, mac: mac.toHexString(), version: nil)
        let pubKey = Web3.Utils.privateToPublic(keyData!)
        let address = Web3.Utils.publicToAddress(pubKey!)?.address.lowercased()
        let keystoreparams = KeystoreParamsV3(address: address, crypto: crypto, id: UUID().uuidString.lowercased(), version: 3)
        self.keystoreParams = keystoreparams
    }
    
    public func regenerate(oldPassword: String, newPassword: String, dkLen: Int=32, N: Int = 262144, R: Int = 8, P: Int = 1) throws {
        var keyData = try self.getKeyData(oldPassword)
        defer {Data.zero(&keyData!)}
        try self.encryptDataToStorage(newPassword, keyData: keyData!)
    }
    
    fileprivate func getKeyData(_ password: String? = nil) throws -> Data? {
        if (password == nil) {
            return nil
        }
        guard let keystoreParams = self.keystoreParams else {return nil}
        guard let saltData = hex2bin(keystoreParams.crypto.kdfparams.salt) else {return nil}
        let derivedLen = keystoreParams.crypto.kdfparams.dklen
        var passwordDerivedKey:Data?
        switch keystoreParams.crypto.kdf {
        case "scrypt":
            guard let N = keystoreParams.crypto.kdfparams.n else {return nil}
            guard let P = keystoreParams.crypto.kdfparams.p else {return nil}
            guard let R = keystoreParams.crypto.kdfparams.r else {return nil}
            passwordDerivedKey = scrypt(password: password!, salt: saltData, length: derivedLen, N: N, R: R, P: P)
        case "pbkdf2":
            guard let algo = keystoreParams.crypto.kdfparams.prf else {return nil}
            var hashVariant:HMAC.Variant?;
            switch algo {
            case "hmac-sha256" :
                hashVariant = HMAC.Variant.sha256
            case "hmac-sha384" :
                hashVariant = HMAC.Variant.sha384
            case "hmac-sha512" :
                hashVariant = HMAC.Variant.sha512
            default:
                hashVariant = nil
            }
            guard (hashVariant != nil) else {return nil}
            guard let c = keystoreParams.crypto.kdfparams.c else {return nil}
            guard let passData = password!.data(using: .utf8) else {return nil}
            guard let derivedArray = try? PKCS5.PBKDF2(password: passData.bytes, salt: saltData.bytes, iterations: c, keyLength: derivedLen, variant: hashVariant!).calculate() else {return nil}
            passwordDerivedKey = Data(bytes:derivedArray)
        default:
            return nil
        }
        guard let derivedKey = passwordDerivedKey else {return nil}
        var dataForMAC = Data()
        let derivedKeyLast16bytes = passwordDerivedKey![(derivedKey.count - 16)...(derivedKey.count - 1)]
        dataForMAC.append(derivedKeyLast16bytes)
        guard let cipherText = hex2bin(keystoreParams.crypto.ciphertext) else {return nil}
        if (cipherText.count != 32) {return nil}
        dataForMAC.append(cipherText)
        let mac = dataForMAC.sha3(.keccak256)
        if (mac != hex2bin(keystoreParams.crypto.mac)!) {return nil}
        let cipher = keystoreParams.crypto.cipher
        let decryptionKey = derivedKey[0...15]
        guard let IV = hex2bin(keystoreParams.crypto.cipherparams.iv) else {return nil}
        var decryptedPK:Array<UInt8>?
        switch cipher {
        case "aes-128-ctr":
            guard let aesCipher = try? AES(key: decryptionKey.bytes, blockMode: .CTR(iv: IV.bytes), padding: .noPadding) else {return nil}
            decryptedPK = try aesCipher.decrypt(cipherText.bytes)
        case "aes-128-cbc":
            guard let aesCipher = try? AES(key: decryptionKey.bytes, blockMode: .CBC(iv: IV.bytes), padding: .noPadding) else {return nil}
            decryptedPK = try? aesCipher.decrypt(cipherText.bytes)
        default:
            return nil
        }
        guard decryptedPK != nil else {return nil}
        return Data(bytes:decryptedPK!)
    }
}
