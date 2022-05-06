//
// Created by Petr Korolev on 26.10.2020.
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

public protocol AbstractKeystoreParams: Codable {
    var crypto: CryptoParamsV3 { get }
    var id: String? { get }
    var version: Int { get }
    var isHDWallet: Bool { get }

}

public struct PathAddressPair: Codable {
    let path: String
    let address: String
}

public struct KeystoreParamsBIP32: AbstractKeystoreParams {
    public var crypto: CryptoParamsV3
    public var id: String?
    public var version: Int
    public var isHDWallet: Bool

    @available(*, deprecated, message: "Please use pathAddressPairs instead")
    var pathToAddress: [String: String] {
        get {
            return self.pathAddressPairs.reduce(into: [String: String]()) {
                $0[$1.path] = $1.address
            }
        }
        set {
            for pair in newValue {
                self.pathAddressPairs.append(PathAddressPair(path: pair.0, address: pair.1))
            }
        }
    }

    var pathAddressPairs: [PathAddressPair]
    var rootPath: String?

    public init(crypto cr: CryptoParamsV3, id i: String, version ver: Int = 32, rootPath: String? = nil) {
        self.crypto = cr
        self.id = i
        self.version = ver
        pathAddressPairs = [PathAddressPair]()
        self.rootPath = rootPath
        self.isHDWallet = true
    }

}

public struct KeystoreParamsV3: AbstractKeystoreParams {
    public var crypto: CryptoParamsV3
    public var id: String?
    public var version: Int
    public var isHDWallet: Bool

    var address: String?

    public init(address ad: String?, crypto cr: CryptoParamsV3, id i: String, version ver: Int) {
        address = ad
        self.crypto = cr
        self.id = i
        self.version = ver
        self.isHDWallet = false
    }

}
