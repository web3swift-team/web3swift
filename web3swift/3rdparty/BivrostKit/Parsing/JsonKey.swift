//
//  JsonKey.swift
//  Bivrost
//
//  Created by Luis Reisewitz on 13.09.17.
//  Copyright © 2017 Gnosis. All rights reserved.
//
//

enum JsonKey: String {
    case type
    case name
    case inputs
    case outputs
    case constant
    case payable
    case anonymous
    case indexed
    case abi
    case contractName = "contract_name"
}

extension Dictionary where Key == String {
    subscript(key: JsonKey) -> Value? {
        get {
            return self[key.rawValue]
        }
        set {
            self[key.rawValue] = newValue
        }
    }
}
