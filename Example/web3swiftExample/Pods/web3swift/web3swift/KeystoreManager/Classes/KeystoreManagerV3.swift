//
//  KeystoreManager.swift
//  web3swift
//
//  Created by Alexander Vlasov on 04.12.2017.
//  Copyright © 2017 Alexander Vlasov. All rights reserved.
//

import Foundation

public struct KeystoreManagerV3{
    public var wallets:[String:EthereumKeystoreV3] {
        get {
            var toReturn = [String:EthereumKeystoreV3]()
            for keystore in _keystores {
                let key = keystore.address?.address
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
                guard let key = keystore.address?.address else {continue}
                toReturn.append(key)
            }
            return toReturn
        }
    }
    var _keystores:[EthereumKeystoreV3] = [EthereumKeystoreV3]()
    
    public init?(_ path: String, suffix: String? = nil) throws {
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
                guard let ks = try? EthereumKeystoreV3(string) else {continue}
                guard let keystore = ks else {return nil}
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
                guard let ks = try? EthereumKeystoreV3(string) else {continue}
                guard let keystore = ks else {return nil}
                _keystores.append(keystore)
            }
        }

    }
}




