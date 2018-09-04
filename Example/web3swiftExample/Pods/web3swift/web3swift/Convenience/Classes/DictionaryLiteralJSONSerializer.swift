//
//  DictionaryLiteralJSONSERIALIZER.swift
//  web3swift
//
//  Created by Alexander Vlasov on 05.12.2017.
//  Copyright © 2017 Alexander Vlasov. All rights reserved.
//

import Foundation

extension DictionaryLiteral {
    
    public func toJSONString () throws  -> String {
        var jsonString = "{"
        for (idx, _) in self.enumerated() {
            let v = self[idx]
            let key = v.key
            let val = v.value
            switch val {
            case is Int :
                    jsonString.append("\"\(key)\":\(val)")
                    jsonString.append(",")
            case is String :
                    jsonString.append("\"\(key)\":\"\(val)\"")
                    jsonString.append(",")
            case is DictionaryLiteral<String, Any> :
                    let casted = val as! DictionaryLiteral<String, Any>
                    let nestedString = try casted.toJSONString()
                    jsonString.append("\"\(key)\":\(nestedString),")
            default:
                break
            }
        }
        jsonString.removeLast(1)
        jsonString.append("}")
        return jsonString
    }
}
