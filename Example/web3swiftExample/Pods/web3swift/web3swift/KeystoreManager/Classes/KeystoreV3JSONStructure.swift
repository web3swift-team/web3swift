//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation

public struct KdfParamsV3: Decodable, Encodable {
    var salt: String
    var dklen: Int
    var n: Int?
    var p: Int?
    var r: Int?
    var c: Int?
    var prf: String?
}

public struct CipherParamsV3: Decodable, Encodable {
    var iv: String
}

public struct CryptoParamsV3: Decodable, Encodable {
    var ciphertext: String
    var cipher: String
    var cipherparams: CipherParamsV3
    var kdf: String
    var kdfparams: KdfParamsV3
    var mac: String
    var version: String?
}

public struct KeystoreParamsV3: Decodable, Encodable {
    var address: String?
    var crypto: CryptoParamsV3
    var id: String?
    var version: Int
    
    public init(address ad: String?, crypto cr: CryptoParamsV3, id i: String, version ver: Int) {
        address = ad
        crypto = cr
        id = i
        version = ver
    }
    
}
