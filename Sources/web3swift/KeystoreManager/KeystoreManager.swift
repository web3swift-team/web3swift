//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation

//import EthereumAddress

public class KeystoreManager: AbstractKeystore {
    public var isHDKeystore: Bool = false

    public var addresses: [EthereumAddress]? {
        get {
            var toReturn = [EthereumAddress]()
            for keystore in _keystores {
                guard let key = keystore.addresses?.first else {
                    continue
                }
                if key.isValid {
                    toReturn.append(key)
                }
            }
            for keystore in _bip32keystores {
                guard let allAddresses = keystore.addresses else {
                    continue
                }
                for addr in allAddresses {
                    if addr.isValid {
                        toReturn.append(addr)
                    }
                }
            }
            for keystore in _plainKeystores {
                guard let key = keystore.addresses?.first else {
                    continue
                }
                if key.isValid {
                    toReturn.append(key)
                }
            }
            return toReturn
        }
    }

    public func UNSAFE_getPrivateKeyData(password: String, account: EthereumAddress) throws -> Data {
        guard let keystore = self.walletForAddress(account) else {throw AbstractKeystoreError.invalidAccountError}
                    return try keystore.UNSAFE_getPrivateKeyData(password: password, account: account)
                }

    public static var allManagers = [KeystoreManager]()
    public static var defaultManager: KeystoreManager? {
        if KeystoreManager.allManagers.count == 0 {
            return nil
        }
        return KeystoreManager.allManagers[0]
    }

    public static func managerForPath(_ path: String, scanForHDwallets: Bool = false, suffix: String? = nil) -> KeystoreManager? {
        guard let manager = try? KeystoreManager(path, scanForHDwallets: scanForHDwallets, suffix: suffix) else {
            return nil
        }
        return manager
    }

    public var path: String

    public func walletForAddress(_ address: EthereumAddress) -> AbstractKeystore? {
        for keystore in _keystores {
            guard let key = keystore.addresses?.first else {
                continue
            }
            if key == address && key.isValid {
                return keystore as AbstractKeystore?
            }
        }
        for keystore in _bip32keystores {
            guard let allAddresses = keystore.addresses else {
                continue
            }
            for addr in allAddresses {
                if addr == address && addr.isValid {
                    return keystore as AbstractKeystore?
                }
            }
        }
        for keystore in _plainKeystores {
            guard let key = keystore.addresses?.first else {
                continue
            }
            if key == address && key.isValid {
                return keystore as AbstractKeystore?
            }
        }
        return nil
    }

    var _keystores: [EthereumKeystoreV3] = [EthereumKeystoreV3]()
    var _bip32keystores: [BIP32Keystore] = [BIP32Keystore]()
    var _plainKeystores: [PlainKeystore] = [PlainKeystore]()

    public var keystores: [EthereumKeystoreV3] {
        get {
            return self._keystores
        }
    }

    public var bip32keystores: [BIP32Keystore] {
        get {
            return self._bip32keystores
        }
    }

    public var plainKeystores: [PlainKeystore] {
        get {
            return self._plainKeystores
        }
    }

    public init(_ keystores: [EthereumKeystoreV3]) {
        self.isHDKeystore = false
        self._keystores = keystores
        self.path = ""
    }

    public init(_ keystores: [BIP32Keystore]) {
        self.isHDKeystore = true
        self._bip32keystores = keystores
        self.path = "bip32"
    }

    public init(_ keystores: [PlainKeystore]) {
        self.isHDKeystore = false
        self._plainKeystores = keystores
        self.path = "plain"
    }

    private init?(_ path: String, scanForHDwallets: Bool = false, suffix: String? = nil) throws {
        if (scanForHDwallets) {
            self.isHDKeystore = true
        }
        self.path = path
        let fileManager = FileManager.default
        var isDir: ObjCBool = false
        var exists = fileManager.fileExists(atPath: path, isDirectory: &isDir)
        if (!exists && !isDir.boolValue) {
            try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            exists = fileManager.fileExists(atPath: path, isDirectory: &isDir)
        }
        if (!isDir.boolValue) {
            return nil
        }
        let allFiles = try fileManager.contentsOfDirectory(atPath: path)
        if (suffix != nil) {
            for file in allFiles where file.hasSuffix(suffix!) {
                var filePath = path
                if (!path.hasSuffix("/")) {
                    filePath = path + "/"
                }
                filePath = filePath + file
                guard let content = fileManager.contents(atPath: filePath) else {
                    continue
                }
                if (!scanForHDwallets) {
                    guard let keystore = EthereumKeystoreV3(content) else {
                        continue
                    }
                    _keystores.append(keystore)
                } else {
                    guard let bipkeystore = BIP32Keystore(content) else {
                        continue
                    }
                    _bip32keystores.append(bipkeystore)
                }
            }
        } else {
            for file in allFiles {
                var filePath = path
                if (!path.hasSuffix("/")) {
                    filePath = path + "/"
                }
                filePath = filePath + file
                guard let content = fileManager.contents(atPath: filePath) else {
                    continue
                }
                if (!scanForHDwallets) {
                    guard let keystore = EthereumKeystoreV3(content) else {
                        continue
                    }
                    _keystores.append(keystore)
                } else {
                    guard let bipkeystore = BIP32Keystore(content) else {
                        continue
                    }
                    _bip32keystores.append(bipkeystore)
                }
            }
        }

    }
}
