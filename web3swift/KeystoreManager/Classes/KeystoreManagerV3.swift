//
//  KeystoreManager.swift
//  web3swift
//
//  Created by Alexander Vlasov on 04.12.2017.
//  Copyright © 2017 Alexander Vlasov. All rights reserved.
//

import Foundation


public struct KeystoreManagerV3{
    var wallets:[String:EthereumKeystoreV3] {
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
    var _keystores:[EthereumKeystoreV3] = [EthereumKeystoreV3]()
    
    init?(_ path: URL, suffix: String?) {
        let fileManager = FileManager.default
        var isDir : ObjCBool = true
        let err = fileManager.fileExists(atPath: path.absoluteString, isDirectory: &isDir)
        if (err || !isDir.boolValue) {
            return nil
        }
        guard let allFiles = try? fileManager.contentsOfDirectory(atPath: path.path) else {return nil}
        if (suffix != nil) {
            for file in allFiles where file.hasSuffix(suffix!) {
                let filePath = path.appendingPathComponent(file)
                guard let content = fileManager.contents(atPath: filePath.path) else {continue}
                guard let string = String(data: content, encoding: .utf8) else {continue}
                guard let ks = try? EthereumKeystoreV3(string) else {continue}
                guard let keystore = ks else {return nil}
                _keystores.append(keystore)
            }
        } else {
            for file in allFiles {
                let filePath = path.appendingPathComponent(file)
                guard let content = fileManager.contents(atPath: filePath.path) else {continue}
                guard let string = String(data: content, encoding: .utf8) else {continue}
                guard let ks = try? EthereumKeystoreV3(string) else {continue}
                guard let keystore = ks else {return nil}
                _keystores.append(keystore)
            }
        }

    }
}




