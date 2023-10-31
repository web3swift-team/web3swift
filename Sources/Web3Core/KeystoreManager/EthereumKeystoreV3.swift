//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import CryptoSwift

// swiftlint:disable cyclomatic_complexity
public class EthereumKeystoreV3: AbstractKeystore {
    // Protocol
    public var isHDKeystore: Bool = false
    private var address: EthereumAddress?
    public var keystoreParams: KeystoreParamsV3?

    public var addresses: [EthereumAddress]? {
        get {
            if self.address != nil {
                return [self.address!]
            }
            return nil
        }
    }

    public func UNSAFE_getPrivateKeyData(password: String, account: EthereumAddress) throws -> Data {
        if account == addresses?.last {
            guard let privateKey = try? getKeyData(password) else {
                throw AbstractKeystoreError.invalidPasswordError
            }
            return privateKey
        }
        throw AbstractKeystoreError.invalidAccountError("EthereumKeystoreV3. Cannot get private key: keystore doesn't contain information about given address \(account.address).")
    }

    // Class

    public func getAddress() -> EthereumAddress? {
        return self.address
    }

    // --------------

    public convenience init?(_ jsonString: String) {
        let lowercaseJSON = jsonString.lowercased()
        guard let jsonData = lowercaseJSON.data(using: .utf8) else {
            return nil
        }
        self.init(jsonData)
    }

    public convenience init?(_ jsonData: Data) {
        guard let keystoreParams = try? JSONDecoder().decode(KeystoreParamsV3.self, from: jsonData) else {
            return nil
        }
        self.init(keystoreParams)
    }

    public init?(_ keystoreParams: KeystoreParamsV3) {
        if keystoreParams.version != 3 {
            return nil
        }
        if keystoreParams.crypto.version != nil && keystoreParams.crypto.version != "1" {
            return nil
        }
        self.keystoreParams = keystoreParams
        if keystoreParams.address != nil {
            self.address = EthereumAddress(keystoreParams.address!.addHexPrefix())
        } else {
            return nil
        }
    }

    public init?(password: String, aesMode: String = "aes-128-cbc") throws {
        guard var newPrivateKey = SECP256K1.generatePrivateKey() else {
            return nil
        }
        defer {
            Data.zero(&newPrivateKey)
        }
        try encryptDataToStorage(password, privateKey: newPrivateKey, aesMode: aesMode)
    }

    public init?(privateKey: Data, password: String, aesMode: String = "aes-128-cbc") throws {
        guard privateKey.count == 32 else {
            return nil
        }
        guard SECP256K1.verifyPrivateKey(privateKey: privateKey) else {
            return nil
        }
        try encryptDataToStorage(password, privateKey: privateKey, aesMode: aesMode)
    }

    fileprivate func encryptDataToStorage(_ password: String, privateKey: Data, dkLen: Int = 32, N: Int = 4096, R: Int = 6, P: Int = 1, aesMode: String = "aes-128-cbc") throws {
        if privateKey.count != 32 {
            throw AbstractKeystoreError.encryptionError("EthereumKeystoreV3. Attempted encryption with private key of length != 32. Given private key length is \(privateKey.count).")
        }
        let saltLen = 32
        guard let saltData = Data.randomBytes(length: saltLen) else {
            throw AbstractKeystoreError.noEntropyError("EthereumKeystoreV3. Failed to generate random bytes: `Data.randomBytes(length: \(saltLen))`.")
        }
        guard let derivedKey = scrypt(password: password, salt: saltData, length: dkLen, N: N, R: R, P: P) else {
            throw AbstractKeystoreError.keyDerivationError("EthereumKeystoreV3. Scrypt function failed.")
        }
        let last16bytes = Data(derivedKey[(derivedKey.count - 16)...(derivedKey.count - 1)])
        let encryptionKey = Data(derivedKey[0...15])
        guard let IV = Data.randomBytes(length: 16) else {
            throw AbstractKeystoreError.noEntropyError("EthereumKeystoreV3. Failed to generate random bytes: `Data.randomBytes(length: 16)`.")
        }
        var aesCipher: AES
        switch aesMode.lowercased() {
        case "aes-128-cbc":
            aesCipher = try AES(key: encryptionKey.bytes, blockMode: CBC(iv: IV.bytes), padding: .noPadding)
        case "aes-128-ctr":
            aesCipher = try AES(key: encryptionKey.bytes, blockMode: CTR(iv: IV.bytes), padding: .noPadding)
        default:
            throw AbstractKeystoreError.aesError("EthereumKeystoreV3. AES error: given AES mode can be one of 'aes-128-cbc' or 'aes-128-ctr'. Instead '\(aesMode)' was given.")
        }

        let encryptedKeyData = Data(try aesCipher.encrypt(privateKey.bytes))
        let dataForMAC = last16bytes + encryptedKeyData
        let mac = dataForMAC.sha3(.keccak256)
        let kdfparams = KdfParamsV3(salt: saltData.toHexString(), dklen: dkLen, n: N, p: P, r: R, c: nil, prf: nil)
        let cipherparams = CipherParamsV3(iv: IV.toHexString())
        let crypto = CryptoParamsV3(ciphertext: encryptedKeyData.toHexString(), cipher: aesMode, cipherparams: cipherparams, kdf: "scrypt", kdfparams: kdfparams, mac: mac.toHexString(), version: nil)
        guard let publicKey = Utilities.privateToPublic(privateKey) else {
            throw AbstractKeystoreError.keyDerivationError("EthereumKeystoreV3. Failed to derive public key from given private key. `Utilities.privateToPublic(privateKey)` returned `nil`.")
        }
        guard let addr = Utilities.publicToAddress(publicKey) else {
            throw AbstractKeystoreError.keyDerivationError("EthereumKeystoreV3. Failed to derive address from derived public key. `Utilities.publicToAddress(publicKey)` returned `nil`.")
        }
        self.address = addr
        let keystoreparams = KeystoreParamsV3(address: addr.address.lowercased(), crypto: crypto, id: UUID().uuidString.lowercased(), version: 3)
        self.keystoreParams = keystoreparams
    }

    public func regenerate(oldPassword: String, newPassword: String, dkLen: Int = 32, N: Int = 4096, R: Int = 6, P: Int = 1) throws {
        guard var privateKey = try getKeyData(oldPassword) else {
            throw AbstractKeystoreError.encryptionError("EthereumKeystoreV3. Failed to decrypt a keystore")
        }
        defer {
            Data.zero(&privateKey)
        }
        try self.encryptDataToStorage(newPassword, privateKey: privateKey, aesMode: self.keystoreParams!.crypto.cipher)
    }

    fileprivate func getKeyData(_ password: String) throws -> Data? {
        guard let keystoreParams = self.keystoreParams else {
            return nil
        }
        guard let saltData = Data.fromHex(keystoreParams.crypto.kdfparams.salt) else {
            return nil
        }
        let derivedLen = keystoreParams.crypto.kdfparams.dklen
        var passwordDerivedKey: Data?
        switch keystoreParams.crypto.kdf {
        case "scrypt":
            guard let N = keystoreParams.crypto.kdfparams.n else {
                return nil
            }
            guard let P = keystoreParams.crypto.kdfparams.p else {
                return nil
            }
            guard let R = keystoreParams.crypto.kdfparams.r else {
                return nil
            }
            passwordDerivedKey = scrypt(password: password, salt: saltData, length: derivedLen, N: N, R: R, P: P)
        case "pbkdf2":
            guard let algo = keystoreParams.crypto.kdfparams.prf else {
                return nil
            }
            var hashVariant: HMAC.Variant?
            switch algo {
            case "hmac-sha256":
                hashVariant = HMAC.Variant.sha2(.sha256)
            case "hmac-sha384":
                hashVariant = HMAC.Variant.sha2(.sha384)
            case "hmac-sha512":
                hashVariant = HMAC.Variant.sha2(.sha512)
            default:
                hashVariant = nil
            }
            guard hashVariant != nil else {
                return nil
            }
            guard let c = keystoreParams.crypto.kdfparams.c else {
                return nil
            }
            guard let passData = password.data(using: .utf8) else {
                return nil
            }
            guard let derivedArray = try? PKCS5.PBKDF2(password: passData.bytes, salt: saltData.bytes, iterations: c, keyLength: derivedLen, variant: hashVariant!).calculate() else {
                return nil
            }
            passwordDerivedKey = Data(derivedArray)
        default:
            return nil
        }
        guard let derivedKey = passwordDerivedKey else {
            return nil
        }
        var dataForMAC = Data()
        let derivedKeyLast16bytes = Data(derivedKey[(derivedKey.count - 16)...(derivedKey.count - 1)])
        dataForMAC.append(derivedKeyLast16bytes)
        guard let cipherText = Data.fromHex(keystoreParams.crypto.ciphertext) else {
            return nil
        }
        if cipherText.count != 32 {
            return nil
        }
        dataForMAC.append(cipherText)
        let mac = dataForMAC.sha3(.keccak256)
        guard let calculatedMac = Data.fromHex(keystoreParams.crypto.mac), mac.constantTimeComparisonTo(calculatedMac) else {
            return nil
        }
        let cipher = keystoreParams.crypto.cipher
        let decryptionKey = derivedKey[0...15]
        guard let IV = Data.fromHex(keystoreParams.crypto.cipherparams.iv) else {
            return nil
        }
        var decryptedPK: [UInt8]?
        switch cipher {
        case "aes-128-ctr":
            guard let aesCipher = try? AES(key: decryptionKey.bytes, blockMode: CTR(iv: IV.bytes), padding: .noPadding) else {
                return nil
            }
            decryptedPK = try aesCipher.decrypt(cipherText.bytes)
        case "aes-128-cbc":
            guard let aesCipher = try? AES(key: decryptionKey.bytes, blockMode: CBC(iv: IV.bytes), padding: .noPadding) else {
                return nil
            }
            decryptedPK = try? aesCipher.decrypt(cipherText.bytes)
        default:
            return nil
        }
        guard decryptedPK != nil else {
            return nil
        }
        return Data(decryptedPK!)
    }

    public func serialize() throws -> Data? {
        guard let params = self.keystoreParams else {
            return nil
        }
        let data = try JSONEncoder().encode(params)
        return data
    }
}
