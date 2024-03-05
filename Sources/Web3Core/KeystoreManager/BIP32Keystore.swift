//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import CryptoSwift

public class BIP32Keystore: AbstractKeystore {

    // Protocol
    public var isHDKeystore: Bool = true

    public var keystoreParams: KeystoreParamsBIP32?

    @available(*, deprecated, message: "Please use addressStorage instead")
    public var paths: [String: EthereumAddress] {
        get {
            return self.addressStorage.toPathAddressPairs().reduce(into: [String: EthereumAddress]()) {
                $0[$1.path] = EthereumAddress($1.address)!
            }
        }
        set {
            for pair in newValue {
                self.addressStorage.add(address: pair.value, for: pair.key)
            }
        }
    }

    public var rootPrefix: String

    public var addresses: [EthereumAddress]? {
        get {
            let addresses = self.addressStorage.addresses
            if addresses.count == 0 {
                return nil
            }
            return addresses
        }
    }

    public func UNSAFE_getPrivateKeyData(password: String, account: EthereumAddress) throws -> Data {
        if let path = addressStorage.path(by: account) {
            guard let decryptedRootNode = try? self.getPrefixNodeData(password) else { throw AbstractKeystoreError.encryptionError("BIP32Keystore. Failed to decrypt a keystore") }
            guard let rootNode = HDNode(decryptedRootNode) else { throw AbstractKeystoreError.encryptionError("BIP32Keystore. Failed to deserialize a root node") }
            guard rootNode.depth == (rootPrefix.components(separatedBy: "/").count - 1) else {throw AbstractKeystoreError.encryptionError("BIP32Keystore. Derivation depth mismatch")}
            guard let index = UInt32(path.components(separatedBy: "/").last!) else {
                throw AbstractKeystoreError.encryptionError("BIP32Keystore. Derivation depth mismatch. `path` doesn't have an index (UInt32) as the last path component: \(path).")
            }
            guard let keyNode = rootNode.derive(index: index, derivePrivateKey: true) else {
                throw AbstractKeystoreError.encryptionError("BIP32Keystore. Derivation from rootNode failed. derive(index: \(index), derivePrivateKey: true)")
            }
            guard let privateKey = keyNode.privateKey else {
                throw AbstractKeystoreError.invalidAccountError("BIP32Keystore. Derived node doesn't have private key. derive(index: \(index), derivePrivateKey: true)")
            }
            return privateKey
        }
        throw AbstractKeystoreError.invalidAccountError("BIP32Keystore. Failed to find path for given address \(account.address).")
    }

    // --------------

    private static let KeystoreParamsBIP32Version = 4

    public private (set) var addressStorage: PathAddressStorage

    public convenience init?(_ jsonString: String) {
        let lowercaseJSON = jsonString.lowercased()
        guard let jsonData = lowercaseJSON.data(using: .utf8) else {
            return nil
        }
        self.init(jsonData)
    }

    public init?(_ jsonData: Data) {
        guard var keystorePars = try? JSONDecoder().decode(KeystoreParamsBIP32.self, from: jsonData) else { return nil }
        if keystorePars.version != Self.KeystoreParamsBIP32Version { return nil }
        if keystorePars.crypto.version != nil && keystorePars.crypto.version != "1" { return nil }
        if !keystorePars.isHDWallet { return nil }

        addressStorage = PathAddressStorage(pathAddressPairs: keystorePars.pathAddressPairs)

        if keystorePars.rootPath == nil {
            keystorePars.rootPath = HDNode.defaultPathPrefix
        }
        keystoreParams = keystorePars
        rootPrefix = keystoreParams!.rootPath!
    }

    public convenience init?(mnemonics: String, password: String, mnemonicsPassword: String = "", language: BIP39Language = BIP39Language.english, prefixPath: String = HDNode.defaultPathMetamaskPrefix, aesMode: String = "aes-128-cbc") throws {
        guard var seed = BIP39.seedFromMmemonics(mnemonics, password: mnemonicsPassword, language: language) else {
            throw AbstractKeystoreError.noEntropyError("BIP32Keystore. Failed to generate seed from given mnemonics, password and language.")
        }
        defer {
            Data.zero(&seed)
        }
        try self.init(seed: seed, password: password, prefixPath: prefixPath, aesMode: aesMode)
    }

    public convenience init?(mnemonicsPhrase: [String], password: String, mnemonicsPassword: String = "", language: BIP39Language = .english, prefixPath: String = HDNode.defaultPathMetamaskPrefix, aesMode: String = "aes-128-cbc") throws {
        guard var seed = BIP39.seedFromMmemonics(mnemonicsPhrase, password: mnemonicsPassword, language: language) else {
            throw AbstractKeystoreError.noEntropyError("BIP32Keystore. Failed to generate seed from given mnemonics, password and language.")
        }
        defer {
            Data.zero(&seed)
        }
        try self.init(seed: seed, password: password, prefixPath: prefixPath, aesMode: aesMode)
    }

    public init?(seed: Data, password: String, prefixPath: String = HDNode.defaultPathMetamaskPrefix, aesMode: String = "aes-128-cbc") throws {
        addressStorage = PathAddressStorage()
        guard let rootNode = HDNode(seed: seed)?.derive(path: prefixPath, derivePrivateKey: true) else { return nil }
        self.rootPrefix = prefixPath
        try createNewAccount(parentNode: rootNode)
        guard let serializedRootNode = rootNode.serialize(serializePublic: false) else {
            throw AbstractKeystoreError.keyDerivationError("BIP32Keystore. Failed to serialize root node.")
        }
        try encryptDataToStorage(password, serializedNodeData: serializedRootNode, aesMode: aesMode)
    }

    public func createNewChildAccount(password: String) throws {
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
        try createNewAccount(parentNode: rootNode)
        guard let serializedRootNode = rootNode.serialize(serializePublic: false) else {
            throw AbstractKeystoreError.keyDerivationError("BIP32Keystore. Failed to serialize root node.")
        }
        try encryptDataToStorage(password, serializedNodeData: serializedRootNode, aesMode: self.keystoreParams!.crypto.cipher)
    }

    func createNewAccount(parentNode: HDNode) throws {
        let maxIndex = addressStorage.paths
            .compactMap { $0.components(separatedBy: "/").last }
            .compactMap { UInt32($0) }
            .max()

        let newIndex: UInt32

        if let idx = maxIndex {
            newIndex = idx + 1
        } else {
            newIndex = UInt32.zero
        }

        guard let newNode = parentNode.derive(index: newIndex, derivePrivateKey: true, hardened: false) else {
            throw AbstractKeystoreError.keyDerivationError("BIP32Keystore. Failed to derive a new node. Check given parent node.")
        }
        guard let newAddress = Utilities.publicToAddress(newNode.publicKey) else {
            throw AbstractKeystoreError.keyDerivationError("BIP32Keystore. Failed to derive a public address from the new derived node.")
        }
        let newPath = rootPrefix + "/" + String(newNode.index)
        addressStorage.add(address: newAddress, for: newPath)
    }

    public func createNewCustomChildAccount(password: String, path: String) throws {
        guard let decryptedRootNode = try getPrefixNodeData(password),
              let keystoreParams else {
            throw AbstractKeystoreError.encryptionError("BIP32Keystore. Failed to decrypt the keystore. Check given password.")
        }
        guard let rootNode = HDNode(decryptedRootNode) else {
            throw AbstractKeystoreError.encryptionError("BIP32Keystore. Failed to deserialize the root node.")
        }

        let prefixPath = rootPrefix
        var pathAppendix = path

        if path.hasPrefix(prefixPath) {
            if let upperIndex = (path.range(of: prefixPath)?.upperBound), upperIndex < path.endIndex {
                pathAppendix = String(path[path.index(after: upperIndex)..<path.endIndex])
            } else {
                throw AbstractKeystoreError.encryptionError("BIP32Keystore. Given derivation path has no extra sections after the rootPrefix. Root prefix: '\(rootPrefix)'; given derivation path: '\(path)'. Expected to be true: `path.range(of: rootPrefix).upperBound < path.endIndex`.")
            }
        }
        if pathAppendix.hasPrefix("/") {
            pathAppendix = pathAppendix.trimmingCharacters(in: .init(charactersIn: "/"))
        }
        guard rootNode.depth == prefixPath.components(separatedBy: "/").count - 1 else {
            throw AbstractKeystoreError.encryptionError("BIP32Keystore. Derivation depth mismatch.")
        }
        guard let newNode = rootNode.derive(path: pathAppendix, derivePrivateKey: true) else {
            throw AbstractKeystoreError.keyDerivationError("BIP32Keystore. Failed to derive a new node. Check given parent node and path.")
        }
        guard let newAddress = Utilities.publicToAddress(newNode.publicKey) else {
            throw AbstractKeystoreError.keyDerivationError("BIP32Keystore. Failed to derive a public address from the new derived node.")
        }

        let newPath = prefixPath + "/" + pathAppendix

        addressStorage.add(address: newAddress, for: newPath)
        guard let serializedRootNode = rootNode.serialize(serializePublic: false) else {
            throw AbstractKeystoreError.keyDerivationError("BIP32Keystore. Failed to serialize the root node.")
        }
        try encryptDataToStorage(password, serializedNodeData: serializedRootNode, aesMode: keystoreParams.crypto.cipher)
    }

    /// Fast generation addresses for current account
    /// used to show which addresses the user can get for indices from `0` to `number-1`
    /// - Parameters:
    ///   - password: password of seed storage
    ///   - number: number of wallets addresses needed to generate from  `0` to `number-1`
    /// - Returns: Array of addresses generated from `0` to number bound
    public func getAddressForAccount(password: String, number: UInt) throws -> [EthereumAddress] {
        guard let decryptedRootNode = try getPrefixNodeData(password),
              let rootNode = HDNode(decryptedRootNode) else {
            throw AbstractKeystoreError.encryptionError("BIP32Keystore. Failed to decrypt a keystore. Check given password.")
        }
        return try [UInt](0..<number).compactMap { number in
            guard rootNode.depth == rootPrefix.components(separatedBy: "/").count - 1,
                  let newNode = rootNode.derive(path: "\(number)", derivePrivateKey: true) else {
                throw AbstractKeystoreError.keyDerivationError("BIP32Keystore. Failed to derive a new child node with private key at index \(number). Is there's a root node depth mismatch: \(rootNode.depth == rootPrefix.components(separatedBy: "/").count - 1).")
            }
            return Utilities.publicToAddress(newNode.publicKey)
        }
    }

    fileprivate func encryptDataToStorage(_ password: String,
                                          serializedNodeData nodeData: Data,
                                          dkLen: Int = 32,
                                          N: Int = 4096,
                                          R: Int = 6,
                                          P: Int = 1,
                                          aesMode: String = "aes-128-cbc") throws {
        guard nodeData.count == 82 else {
            throw AbstractKeystoreError.encryptionError("BIP32Keystore. Invalid expected serialized node data length. Expected 82 bytes but given \(nodeData.count).")
        }
        guard let saltData = Data.randomBytes(length: 32) else {
            throw AbstractKeystoreError.noEntropyError("BIP32Keystore. Failed to generate random bytes: `Data.randomBytes(length: 32)`.")
        }
        guard let derivedKey = scrypt(password: password, salt: saltData, length: dkLen, N: N, R: R, P: P) else {
            throw AbstractKeystoreError.keyDerivationError("BIP32Keystore. Scrypt function failed.")
        }
        let last16bytes = derivedKey[(derivedKey.count - 16)...(derivedKey.count - 1)]
        let encryptionKey = derivedKey[0...15]
        guard let IV = Data.randomBytes(length: 16) else {
            throw AbstractKeystoreError.noEntropyError("BIP32Keystore. Failed to generate random bytes: `Data.randomBytes(length: 16)`.")
        }
        var aesCipher: AES
        switch aesMode {
        case "aes-128-cbc":
            aesCipher = try AES(key: encryptionKey.bytes, blockMode: CBC(iv: IV.bytes), padding: .pkcs7)
        case "aes-128-ctr":
            aesCipher = try AES(key: encryptionKey.bytes, blockMode: CTR(iv: IV.bytes), padding: .pkcs7)
        default:
            throw AbstractKeystoreError.aesError("BIP32Keystore. AES error: given AES mode can be one of 'aes-128-cbc' or 'aes-128-ctr'. Instead '\(aesMode)' was given.")
        }
        let encryptedKeyData = Data(try aesCipher.encrypt(nodeData.bytes))
        let dataForMAC = last16bytes + encryptedKeyData
        let mac = dataForMAC.sha3(.keccak256)
        let kdfparams = KdfParamsV3(salt: saltData.toHexString(), dklen: dkLen, n: N, p: P, r: R, c: nil, prf: nil)
        let cipherparams = CipherParamsV3(iv: IV.toHexString())
        let crypto = CryptoParamsV3(ciphertext: encryptedKeyData.toHexString(), cipher: aesMode, cipherparams: cipherparams, kdf: "scrypt", kdfparams: kdfparams, mac: mac.toHexString(), version: nil)

        var keystorePars = KeystoreParamsBIP32(crypto: crypto, id: UUID().uuidString.lowercased(), version: Self.KeystoreParamsBIP32Version)
        keystorePars.pathAddressPairs = addressStorage.toPathAddressPairs()
        keystorePars.rootPath = rootPrefix
        keystoreParams = keystorePars
    }

    public func regenerate(oldPassword: String, newPassword: String) throws {
        guard var nodeData = try getPrefixNodeData(oldPassword) else {
            throw AbstractKeystoreError.encryptionError("BIP32Keystore. Failed to decrypt a keystore. Check given password.")
        }
        defer {
            Data.zero(&nodeData)
        }
        try encryptDataToStorage(newPassword, serializedNodeData: nodeData, aesMode: keystoreParams!.crypto.cipher)
    }

    // FIXME: it doesn't look like it derives a private key.
    // FIXME: update the function name and variables' names as right now they are misleading. Or write the docs.
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
            guard let c = keystorePars.crypto.kdfparams.c else {
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
        let derivedKeyLast16bytes = derivedKey[(derivedKey.count - 16)...(derivedKey.count - 1)]
        dataForMAC.append(derivedKeyLast16bytes)
        guard let cipherText = Data.fromHex(keystorePars.crypto.ciphertext) else {
            return nil
        }
        guard cipherText.count.isMultiple(of: 32) else {
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
        var decryptedPK: [UInt8]?
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
        return Data(decryptedPK!)
    }

    public func serialize() throws -> Data? {
        guard let params = self.keystoreParams else {
            return nil
        }
        let data = try JSONEncoder().encode(params)
        return data
    }

    public func serializeRootNodeToString(password: String ) throws -> String {
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
