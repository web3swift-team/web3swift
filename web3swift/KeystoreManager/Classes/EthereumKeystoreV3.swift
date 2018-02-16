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



public class EthereumKeystoreV3: AbstractKeystore {
    // Protocol
    
    public var addresses: [EthereumAddress]? {
        get {
            if self.address != nil {
                return [self.address!]
            }
            return nil
        }
    }
    public var isHDKeystore: Bool = false
    
    public func signedTX(transaction: EthereumTransaction, password: String, account: EthereumAddress) throws -> EthereumTransaction? {
        if self.addresses?.count == 1 && account == self.addresses?.last {
            guard let pk = try? self.getKeyData(password) else {throw AbstractKeystoreError.encryptionError("Failed to sign transaction")}
            guard var privateKey = pk else {throw AbstractKeystoreError.encryptionError("Failed to sign transaction")}
            defer {Data.zero(&privateKey)}
            let signedTX = try Web3AbstractSigner.signedTX(transaction: transaction, privateKey: privateKey)
            return signedTX
        }
        else {
            throw AbstractKeystoreError.invalidAccountError
        }
    }

    public func signTX(transaction: inout EthereumTransaction, password: String, account: EthereumAddress) throws {
        if self.address == account {
            guard let pk = try? self.getKeyData(password) else {throw AbstractKeystoreError.encryptionError("Failed to sign transaction")}
            guard var privateKey = pk else {throw AbstractKeystoreError.encryptionError("Failed to sign transaction")}
            defer {Data.zero(&privateKey)}
            try Web3AbstractSigner.signTX(transaction: &transaction, privateKey: privateKey)
        }
        else {
            throw AbstractKeystoreError.invalidAccountError
        }
    }

    public func signIntermediate(intermediate: TransactionIntermediate, password: String, account: EthereumAddress) throws {
        if self.address == account {
            guard let pk = try? self.getKeyData(password) else {throw AbstractKeystoreError.encryptionError("Failed to sign transaction")}
            guard var privateKey = pk else {throw AbstractKeystoreError.encryptionError("Failed to sign transaction")}
            defer {Data.zero(&privateKey)}
            try Web3AbstractSigner.signIntermediate(intermediate: intermediate, privateKey: privateKey)
        }
        else {
            throw AbstractKeystoreError.invalidAccountError
        }
    }

    public func signPersonalMessage(_ personalMessage: Data, password: String, account: EthereumAddress) throws -> Data? {
        if self.address == account {
            guard let pk = try? self.getKeyData(password) else {throw AbstractKeystoreError.encryptionError("Failed to sign transaction")}
            guard var privateKey = pk else {throw AbstractKeystoreError.encryptionError("Failed to sign transaction")}
            defer {Data.zero(&privateKey)}
            let signature = try Web3AbstractSigner.signPersonalMessage(personalMessage, privateKey: privateKey)
            return signature
        }
        else {
            throw AbstractKeystoreError.invalidAccountError
        }
    }

    // --------------
    private var address: EthereumAddress?
    public var keystoreParams: KeystoreParamsV3?
    
    public convenience init?(_ jsonString: String) {
        let lowercaseJSON = jsonString.lowercased()
        guard let jsonData = lowercaseJSON.data(using: .utf8) else {return nil}
        self.init(jsonData)
    }
    
    public init?(_ jsonData: Data) {
        guard let keystoreParams = try? JSONDecoder().decode(KeystoreParamsV3.self, from: jsonData) else {return nil}
        if (keystoreParams.version != 3) {return nil}
        if (keystoreParams.crypto.version != nil && keystoreParams.crypto.version != "1") {return nil}
        self.keystoreParams = keystoreParams
        if keystoreParams.address != nil {
            self.address = EthereumAddress(keystoreParams.address!)
        } else {
            return nil
        }
    }
    
    public init? (password: String = "BANKEXFOUNDATION") throws {
        guard var newPrivateKey = SECP256K1.generatePrivateKey() else {return nil}
        defer {Data.zero(&newPrivateKey)}
        try encryptDataToStorage(password, keyData: newPrivateKey)
    }
    
    public init? (privateKey: Data, password: String = "BANKEXFOUNDATION") throws {
        guard privateKey.count == 32 else {return nil}
        guard SECP256K1.verifyPrivateKey(privateKey: privateKey) else {return nil}
        try encryptDataToStorage(password, keyData: privateKey)
    }
    
    fileprivate func encryptDataToStorage(_ password: String, keyData: Data?, dkLen: Int=32, N: Int = 4096, R: Int = 6, P: Int = 1) throws {
        if (keyData == nil) {
            throw AbstractKeystoreError.encryptionError("Encryption without key data")
        }
        let saltLen = 32;
        guard let saltData = Data.randomBytes(length: saltLen) else {throw AbstractKeystoreError.noEntropyError}
        guard let derivedKey = scrypt(password: password, salt: saltData, length: dkLen, N: N, R: R, P: P) else {throw AbstractKeystoreError.keyDerivationError}
        let last16bytes = derivedKey[(derivedKey.count - 16)...(derivedKey.count-1)]
        let encryptionKey = derivedKey[0...15]
        guard let IV = Data.randomBytes(length: 16) else {throw AbstractKeystoreError.noEntropyError}
        let aecCipher = try? AES(key: encryptionKey.bytes, blockMode: .CBC(iv: IV.bytes), padding: .noPadding)
        guard let encryptedKey = try aecCipher?.encrypt(keyData!.bytes) else {throw AbstractKeystoreError.aesError}
        let encryptedKeyData = Data(bytes:encryptedKey)
        var dataForMAC = Data()
        dataForMAC.append(last16bytes)
        dataForMAC.append(encryptedKeyData)
        let mac = dataForMAC.sha3(.keccak256)
        let kdfparams = KdfParamsV3(salt: saltData.toHexString(), dklen: dkLen, n: N, p: P, r: R, c: nil, prf: nil)
        let cipherparams = CipherParamsV3(iv: IV.toHexString())
        let crypto = CryptoParamsV3(ciphertext: encryptedKeyData.toHexString(), cipher: "aes-128-cbc", cipherparams: cipherparams, kdf: "scrypt", kdfparams: kdfparams, mac: mac.toHexString(), version: nil)
        guard let pubKey = Web3.Utils.privateToPublic(keyData!) else {throw AbstractKeystoreError.keyDerivationError}
        guard let addr = Web3.Utils.publicToAddress(pubKey) else {throw AbstractKeystoreError.keyDerivationError}
        self.address = addr
        let keystoreparams = KeystoreParamsV3(address: addr.address.lowercased(), crypto: crypto, id: UUID().uuidString.lowercased(), version: 3)
        self.keystoreParams = keystoreparams
    }
    
    public func regenerate(oldPassword: String, newPassword: String, dkLen: Int=32, N: Int = 262144, R: Int = 8, P: Int = 1) throws {
        var keyData = try self.getKeyData(oldPassword)
        defer {Data.zero(&keyData!)}
        try self.encryptDataToStorage(newPassword, keyData: keyData!)
    }
    
    fileprivate func getKeyData(_ password: String) throws -> Data? {
        guard let keystoreParams = self.keystoreParams else {return nil}
        guard let saltData = Data.fromHex(keystoreParams.crypto.kdfparams.salt) else {return nil}
        let derivedLen = keystoreParams.crypto.kdfparams.dklen
        var passwordDerivedKey:Data?
        switch keystoreParams.crypto.kdf {
        case "scrypt":
            guard let N = keystoreParams.crypto.kdfparams.n else {return nil}
            guard let P = keystoreParams.crypto.kdfparams.p else {return nil}
            guard let R = keystoreParams.crypto.kdfparams.r else {return nil}
            passwordDerivedKey = scrypt(password: password, salt: saltData, length: derivedLen, N: N, R: R, P: P)
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
            guard let passData = password.data(using: .utf8) else {return nil}
            guard let derivedArray = try? PKCS5.PBKDF2(password: passData.bytes, salt: saltData.bytes, iterations: c, keyLength: derivedLen, variant: hashVariant!).calculate() else {return nil}
            passwordDerivedKey = Data(bytes:derivedArray)
        default:
            return nil
        }
        guard let derivedKey = passwordDerivedKey else {return nil}
        var dataForMAC = Data()
        let derivedKeyLast16bytes = derivedKey[(derivedKey.count - 16)...(derivedKey.count - 1)]
        dataForMAC.append(derivedKeyLast16bytes)
        guard let cipherText = Data.fromHex(keystoreParams.crypto.ciphertext) else {return nil}
        if (cipherText.count != 32) {return nil}
        dataForMAC.append(cipherText)
        let mac = dataForMAC.sha3(.keccak256)
        guard let calculatedMac = Data.fromHex(keystoreParams.crypto.mac), mac.constantTimeComparisonTo(calculatedMac) else {return nil}
        let cipher = keystoreParams.crypto.cipher
        let decryptionKey = derivedKey[0...15]
        guard let IV = Data.fromHex(keystoreParams.crypto.cipherparams.iv) else {return nil}
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
