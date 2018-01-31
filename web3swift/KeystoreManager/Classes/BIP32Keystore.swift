//
//  BIP32Keystore.swift
//  web3swift
//
//  Created by Alexander Vlasov on 11.01.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import CryptoSwift
import Foundation


public class BIP32Keystore: AbstractKeystore {
    // Protocol
    
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
    
    public var isHDKeystore: Bool = false
    
    public func signedTX(transaction: EthereumTransaction, password: String, account: EthereumAddress) throws -> EthereumTransaction? {
        if let key = self.paths.keyForValue(value: account) {
            guard let decryptedRootNode = try? self.getPrefixNodeData(password), decryptedRootNode != nil else {throw AbstractKeystoreError.encryptionError("Failed to sign transaction")}
            guard let rootNode = HDNode(decryptedRootNode!) else {throw AbstractKeystoreError.encryptionError("Failed to sign transaction")}
            guard rootNode.depth == HDNode.defaultPathPrefix.components(separatedBy: "/").count else {throw AbstractKeystoreError.encryptionError("Failed to sign transaction")}
            guard let index = UInt32(key.components(separatedBy: "/").last!) else {throw AbstractKeystoreError.encryptionError("Failed to sign transaction")}
            guard let keyNode = rootNode.derive(index: index, derivePrivateKey: true) else {throw AbstractKeystoreError.encryptionError("Failed to sign transaction")}
            return try Web3AbstractSigner.signedTX(transaction: transaction, privateKey: keyNode.privateKey!)
        }
        throw AbstractKeystoreError.invalidAccountError
    }
    
    public func signTX(transaction: inout EthereumTransaction, password: String, account: EthereumAddress) throws {
        if let key = self.paths.keyForValue(value: account) {
            guard let decryptedRootNode = try? self.getPrefixNodeData(password), decryptedRootNode != nil else {throw AbstractKeystoreError.encryptionError("Failed to sign transaction")}
            guard let rootNode = HDNode(decryptedRootNode!) else {throw AbstractKeystoreError.encryptionError("Failed to sign transaction")}
            guard rootNode.depth == HDNode.defaultPathPrefix.components(separatedBy: "/").count else {throw AbstractKeystoreError.encryptionError("Failed to sign transaction")}
            guard let index = UInt32(key.components(separatedBy: "/").last!) else {throw AbstractKeystoreError.encryptionError("Failed to sign transaction")}
            guard let keyNode = rootNode.derive(index: index, derivePrivateKey: true) else {throw AbstractKeystoreError.encryptionError("Failed to sign transaction")}
            try Web3AbstractSigner.signTX(transaction: &transaction, privateKey: keyNode.privateKey!)
            return
        }
        throw AbstractKeystoreError.invalidAccountError
    }
    
    public func signIntermediate(intermediate: TransactionIntermediate, password: String, account: EthereumAddress) throws {
        if let key = self.paths.keyForValue(value: account) {
            guard let decryptedRootNode = try? self.getPrefixNodeData(password), decryptedRootNode != nil else {throw AbstractKeystoreError.encryptionError("Failed to sign transaction")}
            guard let rootNode = HDNode(decryptedRootNode!) else {throw AbstractKeystoreError.encryptionError("Failed to sign transaction")}
            guard rootNode.depth == HDNode.defaultPathPrefix.components(separatedBy: "/").count else {throw AbstractKeystoreError.encryptionError("Failed to sign transaction")}
            guard let index = UInt32(key.components(separatedBy: "/").last!) else {throw AbstractKeystoreError.encryptionError("Failed to sign transaction")}
            guard let keyNode = rootNode.derive(index: index, derivePrivateKey: true) else {throw AbstractKeystoreError.encryptionError("Failed to sign transaction")}
            try Web3AbstractSigner.signIntermediate(intermediate: intermediate, privateKey: keyNode.privateKey!)
        }
        throw AbstractKeystoreError.invalidAccountError
    }
    
    public func signPersonalMessage(_ personalMessage: Data, password: String, account: EthereumAddress) throws -> Data? {
        if let key = self.paths.keyForValue(value: account) {
            guard let decryptedRootNode = try? self.getPrefixNodeData(password), decryptedRootNode != nil else {throw AbstractKeystoreError.encryptionError("Failed to sign transaction")}
            guard let rootNode = HDNode(decryptedRootNode!) else {throw AbstractKeystoreError.encryptionError("Failed to sign transaction")}
            guard rootNode.depth == HDNode.defaultPathPrefix.components(separatedBy: "/").count else {throw AbstractKeystoreError.encryptionError("Failed to sign transaction")}
            guard let index = UInt32(key.components(separatedBy: "/").last!) else {throw AbstractKeystoreError.encryptionError("Failed to sign transaction")}
            guard let keyNode = rootNode.derive(index: index, derivePrivateKey: true) else {throw AbstractKeystoreError.encryptionError("Failed to sign transaction")}
            return try Web3AbstractSigner.signPersonalMessage(personalMessage, privateKey: keyNode.privateKey!)
        }
        throw AbstractKeystoreError.invalidAccountError
    }
    
    // --------------
    
    public var keystoreParams: KeystoreParamsBIP32?
    public var mnemonics: String?
    public var paths: [String:EthereumAddress] = [String:EthereumAddress]()
    
    public convenience init?(_ jsonString: String) {
        let lowercaseJSON = jsonString.lowercased()
        guard let jsonData = lowercaseJSON.data(using: .utf8) else {return nil}
        self.init(jsonData)
    }
    
    public init?(_ jsonData: Data) {
        guard let keystorePars = try? JSONDecoder().decode(KeystoreParamsBIP32.self, from: jsonData) else {return nil}
        if (keystorePars.version != 3) {return nil}
        if (keystorePars.crypto.version != nil && keystorePars.crypto.version != "1") {return nil}
        if (!keystorePars.isHDWallet) {return nil}
        for (p, ad) in keystorePars.pathToAddress {
            paths[p] = EthereumAddress(ad)
        }
        keystoreParams = keystorePars
    }
    
    public init? (mnemonics: String, password: String = "BANKEXFOUNDATION", mnemonicsPassword: String = "BANKEXFOUNDATION", language: BIP39Language = BIP39Language.english) throws {
        guard var seed = BIP39.seedFromMmemonics(mnemonics, password: mnemonicsPassword, language: language) else {throw AbstractKeystoreError.noEntropyError}
        guard let prefixNode = HDNode(seed: seed)?.derive(path: HDNode.defaultPathPrefix, derivePrivateKey: true) else {return nil}
        defer{ Data.zero(&seed) }
        self.mnemonics = mnemonics
        try createNewAccount(parentNode: prefixNode, password: password)
    }
    
    public func createNewAccount(parentNode: HDNode, password: String = "BANKEXFOUNDATION") throws {
        var newIndex = UInt32(0)
        for (p, _) in paths {
            guard let idx = UInt32(p.components(separatedBy: "/").last!) else {continue}
            if idx > newIndex {
                newIndex = idx + 1
            }
        }
        guard let newNode = parentNode.derive(index: newIndex, derivePrivateKey: true, hardened: false) else {throw AbstractKeystoreError.keyDerivationError}
        guard let newAddress = Web3.Utils.publicToAddress(newNode.publicKey)  else {throw AbstractKeystoreError.keyDerivationError}
        var newPath:String
        if newNode.isHardened {
            newPath = HDNode.defaultPathPrefix + "/" + String(newNode.index % HDNode.hardenedIndexPrefix) + "'"
        } else {
            newPath = HDNode.defaultPathPrefix + "/" + String(newNode.index)
        }
        paths[newPath] = newAddress
        guard let serializedRootNode = parentNode.serialize() else {throw AbstractKeystoreError.keyDerivationError}
        try encryptDataToStorage(password, data: serializedRootNode.data(using: .ascii))
    }
    
    fileprivate func encryptDataToStorage(_ password: String, data: Data?, dkLen: Int=32, N: Int = 4096, R: Int = 6, P: Int = 1) throws {
        if (data == nil) {
            throw AbstractKeystoreError.encryptionError("Encryption without key data")
        }
        let saltLen = 32;
        guard let saltData = Data.randomBytes(length: saltLen) else {throw AbstractKeystoreError.noEntropyError}
        guard let derivedKey = scrypt(password: password, salt: saltData, length: dkLen, N: N, R: R, P: P) else {throw AbstractKeystoreError.keyDerivationError}
        let last16bytes = derivedKey[(derivedKey.count - 16)...(derivedKey.count-1)]
        let encryptionKey = derivedKey[0...15]
        guard let IV = Data.randomBytes(length: 16) else {throw AbstractKeystoreError.noEntropyError}
        let aecCipher = try? AES(key: encryptionKey.bytes, blockMode: .CBC(iv: IV.bytes), padding: .pkcs7)
        guard let encryptedKey = try aecCipher?.encrypt(data!.bytes) else {throw AbstractKeystoreError.aesError}
        let encryptedKeyData = Data(bytes:encryptedKey)
        var dataForMAC = Data()
        dataForMAC.append(last16bytes)
        dataForMAC.append(encryptedKeyData)
        let mac = dataForMAC.sha3(.keccak256)
        let kdfparams = KdfParamsV3(salt: saltData.toHexString(), dklen: dkLen, n: N, p: P, r: R, c: nil, prf: nil)
        let cipherparams = CipherParamsV3(iv: IV.toHexString())
        let crypto = CryptoParamsV3(ciphertext: encryptedKeyData.toHexString(), cipher: "aes-128-cbc", cipherparams: cipherparams, kdf: "scrypt", kdfparams: kdfparams, mac: mac.toHexString(), version: nil)
        var pathToAddress = [String:String]()
        for (path, address) in paths {
            pathToAddress[path] = address.address
        }
        var keystorePars = KeystoreParamsBIP32(crypto: crypto, id: UUID().uuidString.lowercased(), version: 3)
        keystorePars.pathToAddress = pathToAddress
        keystoreParams = keystorePars
    }
    
    public func regenerate(oldPassword: String, newPassword: String, dkLen: Int=32, N: Int = 262144, R: Int = 8, P: Int = 1) throws {
        var keyData = try self.getPrefixNodeData(oldPassword)
        defer {Data.zero(&keyData!)}
        try self.encryptDataToStorage(newPassword, data: keyData!)
    }
    
    fileprivate func getPrefixNodeData(_ password: String) throws -> Data? {
        guard let keystorePars = keystoreParams else {return nil}
        guard let saltData = Data.fromHex(keystorePars.crypto.kdfparams.salt) else {return nil}
        let derivedLen = keystorePars.crypto.kdfparams.dklen
        var passwordDerivedKey:Data?
        switch keystorePars.crypto.kdf {
        case "scrypt":
            guard let N = keystorePars.crypto.kdfparams.n else {return nil}
            guard let P = keystorePars.crypto.kdfparams.p else {return nil}
            guard let R = keystorePars.crypto.kdfparams.r else {return nil}
            passwordDerivedKey = scrypt(password: password, salt: saltData, length: derivedLen, N: N, R: R, P: P)
        case "pbkdf2":
            guard let algo = keystorePars.crypto.kdfparams.prf else {return nil}
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
            guard let c = keystorePars.crypto.kdfparams.c else {return nil}
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
        guard let cipherText = Data.fromHex(keystorePars.crypto.ciphertext) else {return nil}
        if (cipherText.count != 32) {return nil}
        dataForMAC.append(cipherText)
        let mac = dataForMAC.sha3(.keccak256)
        guard let calculatedMac = Data.fromHex(keystorePars.crypto.mac), mac.constantTimeComparisonTo(calculatedMac) else {return nil}
        let cipher = keystorePars.crypto.cipher
        let decryptionKey = derivedKey[0...15]
        guard let IV = Data.fromHex(keystorePars.crypto.cipherparams.iv) else {return nil}
        var decryptedPK:Array<UInt8>?
        switch cipher {
        case "aes-128-ctr":
            guard let aesCipher = try? AES(key: decryptionKey.bytes, blockMode: .CTR(iv: IV.bytes), padding: .pkcs7) else {return nil}
            decryptedPK = try aesCipher.decrypt(cipherText.bytes)
        case "aes-128-cbc":
            guard let aesCipher = try? AES(key: decryptionKey.bytes, blockMode: .CBC(iv: IV.bytes), padding: .pkcs7) else {return nil}
            decryptedPK = try? aesCipher.decrypt(cipherText.bytes)
        default:
            return nil
        }
        guard decryptedPK != nil else {return nil}
        return Data(bytes:decryptedPK!)
    }
}
