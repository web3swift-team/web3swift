//
//  KeystoreManager.swift
//  web3swift
//
//  Created by Alexander Vlasov on 04.12.2017.
//  Copyright © 2017 Alexander Vlasov. All rights reserved.
//

import Foundation

public class KeystoreManager: AbstractKeystore {
    public var isHDKeystore: Bool = false
    
    public var addresses: [EthereumAddress]? {
        get {
            var toReturn = [EthereumAddress]()
            for keystore in _keystores {
                guard let key = keystore.addresses?.first else {continue}
                if key.isValid {
                    toReturn.append(key)
                }
            }
            return toReturn
        }
    }
    
    public func signedTX(transaction: EthereumTransaction, password: String, account: EthereumAddress) throws -> EthereumTransaction? {
        guard let keystore = self.walletForAddress(account) else {throw AbstractKeystoreError.encryptionError("Failed to sign transaction")}
        return try keystore.signedTX(transaction:transaction, password:password, account:account)
    }
    
    public func signTX(transaction: inout EthereumTransaction, password: String, account: EthereumAddress) throws {
        guard let keystore = self.walletForAddress(account) else {throw AbstractKeystoreError.encryptionError("Failed to sign transaction")}
        try keystore.signTX(transaction: &transaction, password: password, account: account)
    }
    
    public func signIntermediate(intermediate: TransactionIntermediate, password: String, account: EthereumAddress) throws {
        guard let keystore = self.walletForAddress(account) else {throw AbstractKeystoreError.encryptionError("Failed to sign transaction")}
        try keystore.signIntermediate(intermediate:intermediate, password:password, account:account)
    }
    
    public func signPersonalMessage(_ personalMessage: Data, password: String, account: EthereumAddress) throws -> Data? {
        guard let keystore = self.walletForAddress(account) else {throw AbstractKeystoreError.encryptionError("Failed to sign transaction")}
        return try keystore.signPersonalMessage(personalMessage, password:password, account:account)
    }
    
    
    public static var allManagers = [KeystoreManager]()
    public static var defaultManager : KeystoreManager? {
        if KeystoreManager.allManagers.count == 0 {
            return nil
        }
        return KeystoreManager.allManagers[0]
    }
    
    public static func managerForPath(_ path: String, suffix: String? = nil) -> KeystoreManager? {
        if KeystoreManager.allManagers.count == 0 {
            guard let newManager = try? KeystoreManager(path, suffix: suffix), let manager = newManager  else {return nil}
            KeystoreManager.allManagers.append(manager)
            return manager
        } else {
            let foundManager = KeystoreManager.allManagers.filter({ (manager:KeystoreManager) -> Bool in
                return manager.path == path
            })
            if foundManager.count == 0 {
                guard let newManager = try? KeystoreManager(path, suffix: suffix), let manager = newManager  else {return nil}
                KeystoreManager.allManagers.append(manager)
                return manager
            } else if (foundManager.count == 1) {
                return foundManager[0]
            }
        }
        return nil
    }
    
//    public var defaultAddress: EthereumAddress?
    
    public var path: String
//    public var wallets:[String:EthereumKeystoreV3] {
//        get {
//            var toReturn = [String:EthereumKeystoreV3]()
//            for keystore in _keystores {
//                let key = keystore.addresses?.first?.address
//                if key != nil {
//                    toReturn[key!] = keystore
//                }
//            }
//            return toReturn
//        }
//    }
    
//    public var addresses: [EthereumAddress]? {
//        get {
//            var toReturn = [EthereumAddress]()
//            for keystore in _keystores {
//                guard let key = keystore.addresses?.first else {continue}
//                if key == defaultAddress && key.isValid {
//                    toReturn.append(key)
//                }
//            }
//            for keystore in _keystores {
//                guard let key = keystore.addresses?.first else {continue}
//                if key != defaultAddress && key.isValid {
//                    toReturn.append(key)
//                }
//            }
//            return toReturn
//        }
//    }
//    public var knownAddresses:[String] {
//        get {
//            var toReturn = [String]()
//            for keystore in _keystores {
//                guard let key = keystore.addresses?.first?.address else {continue}
//                if key.lowercased() == defaultAddress?.address.lowercased() {
//                    toReturn.append(key)
//                }
//            }
//            for keystore in _keystores {
//                guard let key = keystore.addresses?.first?.address else {continue}
//                if key.lowercased() != defaultAddress?.address.lowercased() {
//                    toReturn.append(key)
//                }
//            }
//            return toReturn
//        }
//    }
    
//    public func walletForAddress(_ address: String) -> EthereumKeystoreV3? {
//        for keystore in _keystores {
//            guard let key = keystore.addresses?.first?.address else {continue}
//            if key.lowercased() == address.lowercased().addHexPrefix() {
//                return keystore
//            }
//        }
//        return nil
//    }
    
    public func walletForAddress(_ address: EthereumAddress) -> AbstractKeystore? {
        for keystore in _keystores {
            guard let key = keystore.addresses?.first else {continue}
            if key == address && key.isValid {
                return keystore as AbstractKeystore?
            }
        }
        return nil
    }
    
    var _keystores:[EthereumKeystoreV3] = [EthereumKeystoreV3]()
    
    public var keystores:[AbstractKeystore] {
        get {
            return self._keystores as [AbstractKeystore]
        }
    }
    
    
    private init?(_ path: String, suffix: String? = nil) throws {
        self.path = path
        let fileManager = FileManager.default
        var isDir : ObjCBool = false
        var exists = fileManager.fileExists(atPath: path, isDirectory: &isDir)
        if (!exists && !isDir.boolValue){
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
                if (!path.hasSuffix("/")){
                    filePath = path + "/"
                }
                filePath = filePath + file
                guard let content = fileManager.contents(atPath: filePath) else {continue}
                guard let keystore = EthereumKeystoreV3(content) else {continue}
//                guard let string = String(data: content, encoding: .utf8) else {continue}
//                guard let keystore = EthereumKeystoreV3(string) else {continue}
                _keystores.append(keystore)
            }
        } else {
            for file in allFiles {
                var filePath = path
                if (!path.hasSuffix("/")){
                    filePath = path + "/"
                }
                filePath = filePath + file
                guard let content = fileManager.contents(atPath: filePath) else {continue}
                guard let keystore = EthereumKeystoreV3(content) else {continue}
//                guard let string = String(data: content, encoding: .utf8) else {continue}
//                guard let keystore = EthereumKeystoreV3(string) else {continue}
                _keystores.append(keystore)
            }
        }

    }
}




