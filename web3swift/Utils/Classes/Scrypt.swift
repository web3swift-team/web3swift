//
//  Scrypt.swift
//  web3swift
//
//  Created by Alexander Vlasov on 04.12.2017.
//  Copyright © 2017 Alexander Vlasov. All rights reserved.
//

import Foundation
import NAChloride

func scryptHash(password: String) -> String{
    let N = 16
    let r = 16
    let p = 16
    
    let term1 = Int(log2(Double(N))) << 16
    let term2 = r << 8
    let paramsDecimal = term1 | term2 | p
    
    let params = String(format:"%2X", paramsDecimal)
    print(params)
    
    let message = password.data(using:.utf8)!
    let salt = Data(bytes:[0x73, 0x61, 0x6c, 0x74, 0x44, 0x61, 0x74, 0x61,0x73, 0x61, 0x6c, 0x74, 0x44, 0x61, 0x74, 0x61,0x73, 0x61, 0x6c, 0x74, 0x44, 0x61, 0x74, 0x61,0x73, 0x61, 0x6c, 0x74, 0x44, 0x61, 0x74, 0x61])
    
    let saltBase64String = salt.base64EncodedString()
    print(saltBase64String)
    
    let hashData = try! NAScrypt.scrypt(message, salt: salt, n: 16, r: 16, p: 16, length: 32)
    let hashBase64String = hashData.base64EncodedString()
    print(hashBase64String)
    let result = saltBase64String+"$"+hashBase64String
    print(result)
    
    var hashString = String()
    hashString.append("$s0$")
    hashString.append(params)
    hashString.append("$")
    hashString.append(saltBase64String)
    hashString.append("$")
    hashString.append(hashBase64String)
    print(hashString)
    return hashString
}
