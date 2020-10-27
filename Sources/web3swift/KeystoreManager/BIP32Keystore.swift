//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import CryptoSwift
import Foundation

//import EthereumAddress

public class BIP32Keystore: AbstractKeystore {


    // Protocol
    public var isHDKeystore: Bool = true

    public var keystoreParams: KeystoreParamsBIP32?
    public var paths: [String: EthereumAddress] = [String: EthereumAddress]()

    public var rootPrefix: String

    public var addresses: [EthereumAddress]? {
        get {
            if self.paths.count == 0 {
                return nil
            }
            var allAccounts = [EthereumAddress]()
            for (_, address) in paths {
                allAccounts.append(address)
            }
            return allAccounts
        }
    }

    public func UNSAFE_getPrivateKeyData(password: String, account: EthereumAddress) throws -> Data {
        if let key = self.paths.keyForValue(value: account) {
            guard let decryptedRootNode = try? self.getPrefixNodeData(password) else {
                throw AbstractKeystoreError.encryptionError("Failed to decrypt a keystore")
            }
            guard let rootNode = HDNode(decryptedRootNode) else {
                throw AbstractKeystoreError.encryptionError("Failed to deserialize a root node")
            }
            guard rootNode.depth == (self.rootPrefix.components(separatedBy: "/").count - 1) else {
                throw AbstractKeystoreError.encryptionError("Derivation depth mismatch")
            }
//            guard rootNode.depth == HDNode.defaultPathPrefix.components(separatedBy: "/").count - 1 else {throw AbstractKeystoreError.encryptionError("Derivation depth mismatch")}
            guard let index = UInt32(key.components(separatedBy: "/").last!) else {
                throw AbstractKeystoreError.encryptionError("Derivation depth mismatch")
            }
            guard let keyNode = rootNode.derive(index: index, derivePrivateKey: true) else {
                throw AbstractKeystoreError.encryptionError("Derivation failed")
            }
            guard let privateKey = keyNode.privateKey else {
                throw AbstractKeystoreError.invalidAccountError
            }
            return privateKey
        }
        throw AbstractKeystoreError.invalidAccountError
    }

    // --------------


    public convenience init?(_ jsonString: String) {
        let lowercaseJSON = jsonString.lowercased()
        guard let jsonData = lowercaseJSON.data(using: .utf8) else {
            return nil
        }
        self.init(jsonData)
    }

    public init?(_ jsonData: Data) {
        guard var keystorePars = try? JSONDecoder().decode(KeystoreParamsBIP32.self, from: jsonData) else {
            return nil
        }
        if (keystorePars.version != 3) {
            return nil
        }
        if (keystorePars.crypto.version != nil && keystorePars.crypto.version != "1") {
            return nil
        }
        if (!keystorePars.isHDWallet) {
            return nil
        }
        for (p, ad) in keystorePars.pathToAddress {
            paths[p] = EthereumAddress(ad)
        }
        if keystorePars.rootPath == nil {
            keystorePars.rootPath = HDNode.defaultPathPrefix
        }
        keystoreParams = keystorePars
        rootPrefix = keystoreParams!.rootPath!
    }

    public convenience init?(mnemonics: String, password: String = "web3swift", mnemonicsPassword: String = "", language: BIP39Language = BIP39Language.english, prefixPath: String = HDNode.defaultPathMetamaskPrefix, aesMode: String = "aes-128-cbc") throws {
        guard var seed = BIP39.seedFromMmemonics(mnemonics, password: mnemonicsPassword, language: language) else {
            throw AbstractKeystoreError.noEntropyError
        }
        defer{
            Data.zero(&seed)
        }
        try self.init(seed: seed, password: password, prefixPath: prefixPath, aesMode: aesMode)
    }

    public init?(seed: Data, password: String = "web3swift", prefixPath: String = HDNode.defaultPathMetamaskPrefix, aesMode: String = "aes-128-cbc") throws {
        guard let rootNode = HDNode(seed: seed)?.derive(path: prefixPath, derivePrivateKey: true) else {
            return nil
        }
        self.rootPrefix = prefixPath
        try createNewAccount(parentNode: rootNode, password: password)
        guard let serializedRootNode = rootNode.serialize(serializePublic: false) else {
            throw AbstractKeystoreError.keyDerivationError
        }
        try encryptDataToStorage(password, data: serializedRootNode, aesMode: aesMode)
    }

    public func createNewChildAccount(password: String = "web3swift") throws {
        guard let decryptedRootNode = try? self.getPrefixNodeData(password) else {
            throw AbstractKeystoreError.encryptionError("Failed to decrypt a keystore")
        }
        guard let rootNode = HDNode(decryptedRootNode) else {
            throw AbstractKeystoreError.encryptionError("Failed to deserialize a root node")
        }
        let prefixPath = self.rootPrefix
        guard rootNode.depth == prefixPath.components(separatedBy: "/").count - 1 else {
            throw AbstractKeystoreError.encryptionError("Derivation depth mismatch")
        }
        try createNewAccount(parentNode: rootNode, password: password)
        guard let serializedRootNode = rootNode.serialize(serializePublic: false) else {
            throw AbstractKeystoreError.keyDerivationError
        }
        try encryptDataToStorage(password, data: serializedRootNode, aesMode: self.keystoreParams!.crypto.cipher)
    }

    func createNewAccount(parentNode: HDNode, password: String = "web3swift") throws {
        var newIndex = UInt32(0)
        for (p, _) in paths {
            guard let idx = UInt32(p.components(separatedBy: "/").last!) else {
                continue
            }
            if idx >= newIndex {
                newIndex = idx + 1
            }
        }
        guard let newNode = parentNode.derive(index: newIndex, derivePrivateKey: true, hardened: false) else {
            throw AbstractKeystoreError.keyDerivationError
        }
        guard let newAddress = Web3.Utils.publicToAddress(newNode.publicKey) else {
            throw AbstractKeystoreError.keyDerivationError
        }
        let prefixPath = self.rootPrefix
        var newPath: String
        if newNode.isHardened {
            newPath = prefixPath + "/" + String(newNode.index % HDNode.hardenedIndexPrefix) + "'"
        } else {
            newPath = prefixPath + "/" + String(newNode.index)
        }
        paths[newPath] = newAddress
    }

    public func createNewCustomChildAccount(password: String = "web3swift", path: String) throws {guard let decryptedRootNode = try? self.getPrefixNodeData(password) else {
            throw AbstractKeystoreError.encryptionError("Failed to decrypt a keystore")
        }
        guard let rootNode = HDNode(decryptedRootNode) else {
            throw AbstractKeystoreError.encryptionError("Failed to deserialize a root node")
        }
        let prefixPath = self.rootPrefix
        var pathAppendix: String? = nil
        if path.hasPrefix(prefixPath) {
            let upperIndex = (path.range(of: prefixPath)?.upperBound)!
            if upperIndex < path.endIndex
            {
                pathAppendix = String(path[path.index(after: upperIndex)])
            } else
            {
                throw AbstractKeystoreError.encryptionError("out of bounds")
            }

            guard pathAppendix != nil else {
                throw AbstractKeystoreError.encryptionError("Derivation depth mismatch")
            }
            if pathAppendix!.hasPrefix("/") {
                pathAppendix = pathAppendix?.trimmingCharacters(in: CharacterSet.init(charactersIn: "/"))
            }
        } else {
            if path.hasPrefix("/") {
                pathAppendix = path.trimmingCharacters(in: CharacterSet.init(charactersIn: "/"))
            }
        }
        guard pathAppendix != nil else {
            throw AbstractKeystoreError.encryptionError("Derivation depth mismatch")
        }
        guard rootNode.depth == prefixPath.components(separatedBy: "/").count - 1 else {
            throw AbstractKeystoreError.encryptionError("Derivation depth mismatch")
        }
        guard let newNode = rootNode.derive(path: pathAppendix!, derivePrivateKey: true) else {
            throw AbstractKeystoreError.keyDerivationError
        }
        guard let newAddress = Web3.Utils.publicToAddress(newNode.publicKey) else {
            throw AbstractKeystoreError.keyDerivationError
        }
        var newPath: String
        if newNode.isHardened {
            newPath = prefixPath + "/" + pathAppendix!.trimmingCharacters(in: CharacterSet.init(charactersIn: "'")) + "'"
        } else {
            newPath = prefixPath + "/" + pathAppendix!
        }
        paths[newPath] = newAddress
        guard let serializedRootNode = rootNode.serialize(serializePublic: false) else {
            throw AbstractKeystoreError.keyDerivationError
        }
        try encryptDataToStorage(password, data: serializedRootNode, aesMode: self.keystoreParams!.crypto.cipher)
    }

    fileprivate func encryptDataToStorage(_ password: String, data: Data?, dkLen: Int = 32, N: Int = 4096, R: Int = 6, P: Int = 1, aesMode: String = "aes-128-cbc") throws {
        if (data == nil) {
            throw AbstractKeystoreError.encryptionError("Encryption without key data")
        }
        if (data!.count != 82) {
            throw AbstractKeystoreError.encryptionError("Invalid expected data length")
        }
        let saltLen = 32;
        guard let saltData = Data.randomBytes(length: saltLen) else {
            throw AbstractKeystoreError.noEntropyError
        }
        guard let derivedKey = scrypt(password: password, salt: saltData, length: dkLen, N: N, R: R, P: P) else {
            throw AbstractKeystoreError.keyDerivationError
        }
        let last16bytes = derivedKey[(derivedKey.count - 16)...(derivedKey.count - 1)]
        let encryptionKey = derivedKey[0...15]
        guard let IV = Data.randomBytes(length: 16) else {
            throw AbstractKeystoreError.noEntropyError
        }
        var aesCipher: AES?
        switch aesMode {
        case "aes-128-cbc":
            aesCipher = try? AES(key: encryptionKey.bytes, blockMode: CBC(iv: IV.bytes), padding: .pkcs7)
        case "aes-128-ctr":
            aesCipher = try? AES(key: encryptionKey.bytes, blockMode: CTR(iv: IV.bytes), padding: .pkcs7)
        default:
            aesCipher = nil
        }
        if aesCipher == nil {
            throw AbstractKeystoreError.aesError
        }
        guard let encryptedKey = try aesCipher?.encrypt(data!.bytes) else {
            throw AbstractKeystoreError.aesError
        }
//        let encryptedKeyData = Data(bytes:encryptedKey) Data(encryptedKey)
        let encryptedKeyData = Data(encryptedKey)
        var dataForMAC = Data()
        dataForMAC.append(last16bytes)
        dataForMAC.append(encryptedKeyData)
        let mac = dataForMAC.sha3(.keccak256)
        let kdfparams = KdfParamsV3(salt: saltData.toHexString(), dklen: dkLen, n: N, p: P, r: R, c: nil, prf: nil)
        let cipherparams = CipherParamsV3(iv: IV.toHexString())
        let crypto = CryptoParamsV3(ciphertext: encryptedKeyData.toHexString(), cipher: aesMode, cipherparams: cipherparams, kdf: "scrypt", kdfparams: kdfparams, mac: mac.toHexString(), version: nil)
        var pathToAddress = [String: String]()
        for (path, address) in paths {
            pathToAddress[path] = address.address
        }
        var keystorePars = KeystoreParamsBIP32(crypto: crypto, id: UUID().uuidString.lowercased(), version: 3)
        keystorePars.pathToAddress = pathToAddress
        keystorePars.rootPath = self.rootPrefix
        keystoreParams = keystorePars
    }

    public func regenerate(oldPassword: String, newPassword: String, dkLen: Int = 32, N: Int = 4096, R: Int = 6, P: Int = 1) throws {
        var keyData = try self.getPrefixNodeData(oldPassword)
        if keyData == nil {
            throw AbstractKeystoreError.encryptionError("Failed to decrypt a keystore")
        }
        defer {
            Data.zero(&keyData!)
        }
        try self.encryptDataToStorage(newPassword, data: keyData!, aesMode: self.keystoreParams!.crypto.cipher)
    }

    fileprivate func getPrefixNodeData(_ password: String) throws -> Data? {
        guard let keystorePars = keystoreParams else {
            return nil
        }
        guard let saltData = Data.fromHex(keystorePars.crypto.kdfparams.salt) else {
            return nil
        }
        let derivedLen = keystorePars.crypto.kdfparams.dklen
        var passwordDerivedKey: Data?
        switch keystorePars.crypto.kdf {
        case "scrypt":
            guard let N = keystorePars.crypto.kdfparams.n else {
                return nil
            }
            guard let P = keystorePars.crypto.kdfparams.p else {
                return nil
            }
            guard let R = keystorePars.crypto.kdfparams.r else {
                return nil
            }
            passwordDerivedKey = scrypt(password: password, salt: saltData, length: derivedLen, N: N, R: R, P: P)
        case "pbkdf2":
            guard let algo = keystorePars.crypto.kdfparams.prf else {
                return nil
            }
            var hashVariant: HMAC.Variant?;
            switch algo {
            case "hmac-sha256":
                hashVariant = HMAC.Variant.sha256
            case "hmac-sha384":
                hashVariant = HMAC.Variant.sha384
            case "hmac-sha512":
                hashVariant = HMAC.Variant.sha512
            default:
                hashVariant = nil
            }
            guard (hashVariant != nil) else {
                return nil
            }
            guard let c = keystorePars.crypto.kdfparams.c else {
                return nil
            }
            guard let passData = password.data(using: .utf8) else {
                return nil
            }
            guard let derivedArray = try? PKCS5.PBKDF2(password: passData.bytes, salt: saltData.bytes, iterations: c, keyLength: derivedLen, variant: hashVariant!).calculate() else {
                return nil
            }
//            passwordDerivedKey = Data(bytes:derivedArray)
            passwordDerivedKey = Data(derivedArray)
        default:
            return nil
        }
        guard let derivedKey = passwordDerivedKey else {
            return nil
        }
        var dataForMAC = Data()
        let derivedKeyLast16bytes = derivedKey[(derivedKey.count - 16)...(derivedKey.count - 1)]
        dataForMAC.append(derivedKeyLast16bytes)
        guard let cipherText = Data.fromHex(keystorePars.crypto.ciphertext) else {
            return nil
        }
        guard (cipherText.count.isMultiple(of: 32)) else {
            return nil
        }
        dataForMAC.append(cipherText)
        let mac = dataForMAC.sha3(.keccak256)
        guard let calculatedMac = Data.fromHex(keystorePars.crypto.mac), mac.constantTimeComparisonTo(calculatedMac) else {
            return nil
        }
        let cipher = keystorePars.crypto.cipher
        let decryptionKey = derivedKey[0...15]
        guard let IV = Data.fromHex(keystorePars.crypto.cipherparams.iv) else {
            return nil
        }
        var decryptedPK: Array<UInt8>?
        switch cipher {
        case "aes-128-ctr":
            guard let aesCipher = try? AES(key: decryptionKey.bytes, blockMode: CTR(iv: IV.bytes), padding: .pkcs7) else {
                return nil
            }
            decryptedPK = try aesCipher.decrypt(cipherText.bytes)
        case "aes-128-cbc":
            guard let aesCipher = try? AES(key: decryptionKey.bytes, blockMode: CBC(iv: IV.bytes), padding: .pkcs7) else {
                return nil
            }
            decryptedPK = try? aesCipher.decrypt(cipherText.bytes)
        default:
            return nil
        }
        guard decryptedPK != nil else {
            return nil
        }
        guard decryptedPK?.count == 82 else {
            return nil
        }
//        return Data(bytes:decryptedPK!)
        return Data(decryptedPK!)
    }

    public func serialize() throws -> Data? {
        guard let params = self.keystoreParams else {
            return nil
        }
        let data = try JSONEncoder().encode(params)
        return data
    }

    public func serializeRootNodeToString(password: String = "web3swift") throws -> String {
        guard let decryptedRootNode = try? self.getPrefixNodeData(password) else {
            throw AbstractKeystoreError.encryptionError("Failed to decrypt a keystore")
        }
        guard let rootNode = HDNode(decryptedRootNode) else {
            throw AbstractKeystoreError.encryptionError("Failed to deserialize a root node")
        }
        guard let string = rootNode.serializeToString(serializePublic: false) else {
            throw AbstractKeystoreError.encryptionError("Failed to deserialize a root node")
        }
        return string
    }
}
