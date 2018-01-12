//
//  KeystoreManager.swift
//  web3swift
//
//  Created by Alexander Vlasov on 04.12.2017.
//  Copyright © 2017 Alexander Vlasov. All rights reserved.
//

import Foundation

public class KeystoreManager{
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
    
    public var defaultAddress: String?
    
    public var path: String
    public var wallets:[String:EthereumKeystoreV3] {
        get {
            var toReturn = [String:EthereumKeystoreV3]()
            for keystore in _keystores {
                let key = keystore.addresses?.first?.address
                if key != nil {
                    toReturn[key!] = keystore
                }
            }
            return toReturn
        }
    }
    public var knownAddresses:[String] {
        get {
            var toReturn = [String]()
            for keystore in _keystores {
                guard let key = keystore.addresses?.first?.address else {continue}
                if key.lowercased() == defaultAddress?.lowercased() {
                    toReturn.append(key)
                }
            }
            for keystore in _keystores {
                guard let key = keystore.addresses?.first?.address else {continue}
                if key.lowercased() != defaultAddress?.lowercased() {
                    toReturn.append(key)
                }
            }
            return toReturn
        }
    }
    
    public func walletForAddress(_ address: String) -> EthereumKeystoreV3? {
        for keystore in _keystores {
            guard let key = keystore.addresses?.first?.address else {continue}
            if key.lowercased() == address.lowercased().addHexPrefix() {
                return keystore
            }
        }
        return nil
    }
    
    public func walletForAddress(_ address: EthereumAddress) -> EthereumKeystoreV3? {
        for keystore in _keystores {
            guard let key = keystore.addresses?.first?.address else {continue}
            if key == address.address {
                return keystore
            }
        }
        return nil
    }
    
    var _keystores:[EthereumKeystoreV3] = [EthereumKeystoreV3]()
    
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
                guard let string = String(data: content, encoding: .utf8) else {continue}
                guard let keystore = EthereumKeystoreV3(string) else {continue}
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
                guard let string = String(data: content, encoding: .utf8) else {continue}
                guard let keystore = EthereumKeystoreV3(string) else {continue}
                _keystores.append(keystore)
            }
        }

    }
}




