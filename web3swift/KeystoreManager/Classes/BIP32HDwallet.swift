//
//  BIP32HDwallet.swift
//  web3swift
//
//  Created by Alexander Vlasov on 09.01.2018.
//

import Foundation
import BigInt
import CryptoSwift

extension UInt32 {
    public func serialize32() -> Data {
        let uint32 = UInt32(self)
        var bigEndian = uint32.bigEndian
        let count = MemoryLayout<UInt32>.size
        let bytePtr = withUnsafePointer(to: &bigEndian) {
            $0.withMemoryRebound(to: UInt8.self, capacity: count) {
                UnsafeBufferPointer(start: $0, count: count)
            }
        }
        let byteArray = Array(bytePtr)
        return Data(byteArray)
    }
}



public struct HDNode {
    public struct HDversion{
        public var privatePrefix: Data = Data.fromHex("0x0488ADE4")!
        public var publicPrefix: Data = Data.fromHex("0x0488B21E")!
    }
    
    public var privateKey: Data? = nil
    public var publicKey: Data
    public var chaincode: Data
    public var depth: UInt8
    public var parentFingerprint: Data = Data(repeating: 0, count: 4)
    public var childNumber: UInt32 = UInt32(0)
    public var version: HDversion = HDversion()
    public var isHardened:Bool {
        get {
            return self.childNumber >= (UInt32(1) << 31)
        }
    }
    public var index: UInt32 {
        get {
            if self.isHardened {
                return self.childNumber - (UInt32(1) << 31)
            } else {
                return self.childNumber
            }
        }
    }
    public var hasPrivate:Bool {
        get {
            return privateKey != nil
        }
    }
    
    private init() {
        publicKey = Data()
        chaincode = Data()
        depth = UInt8(0)
    }
    
    public init?(serializedString: String) {
        return nil
    }
    
    public init?(seed: Data) {
        guard seed.count >= 16 else {return nil}
        let hmacKey = "Bitcoin seed".data(using: .ascii)!
        let hmac:Authenticator = HMAC(key: hmacKey.bytes, variant: HMAC.Variant.sha512)
        guard let entropy = try? hmac.authenticate(seed.bytes) else {return nil}
        guard entropy.count == 64 else { return nil}
        let I_L = entropy[0..<32]
        let I_R = entropy[32..<64]
        chaincode = Data(I_R)
        let privKeyCandidate = Data(I_L)
        guard SECP256K1.verifyPrivateKey(privateKey: privKeyCandidate) else {return nil}
        guard let pubKeyCandidate = SECP256K1.privateToPublic(privateKey: privKeyCandidate, compressed: true) else {return nil}
        guard pubKeyCandidate.bytes[0] == 0x02 || pubKeyCandidate.bytes[0] == 0x03 else {return nil}
        publicKey = pubKeyCandidate
        privateKey = privKeyCandidate
        depth = 0x00
        childNumber = UInt32(0)
    }
    
    static var defaultPath: String = "m/44'/60'/0'/0"
    private static var curveOrder = BigUInt("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141", radix: 16)!
}

extension HDNode {
    public func derive (index: UInt32, derivePrivateKey:Bool, hardened: Bool = false) -> HDNode? {
        if derivePrivateKey {
            if self.hasPrivate { // derive private key when is itself extended private key
                var entropy:Array<UInt8>
                var trueIndex: UInt32
                if index >= (UInt32(1) << 31) || hardened {
                    trueIndex = index;
                    if trueIndex < (UInt32(1) << 31) {
                        trueIndex = trueIndex + (UInt32(1) << 31)
                    }
                    let hmac:Authenticator = HMAC(key: self.chaincode.bytes, variant: .sha512)
                    var inputForHMAC = Data()
                    inputForHMAC.append(Data([UInt8(0x00)]))
                    inputForHMAC.append(self.privateKey!)
                    inputForHMAC.append(trueIndex.serialize32())
                    guard let ent = try? hmac.authenticate(inputForHMAC.bytes) else {return nil }
                    guard ent.count == 64 else { return nil }
                    entropy = ent
                } else {
                    trueIndex = index
                    let hmac:Authenticator = HMAC(key: self.chaincode.bytes, variant: .sha512)
                    var inputForHMAC = Data()
                    inputForHMAC.append(self.publicKey)
                    inputForHMAC.append(trueIndex.serialize32())
                    guard let ent = try? hmac.authenticate(inputForHMAC.bytes) else {return nil }
                    guard ent.count == 64 else { return nil }
                    entropy = ent
                }
                let I_L = entropy[0..<32]
                let I_R = entropy[32..<64]
                let cc = Data(I_R)
                let bn = BigUInt(Data(I_L))
                if bn > HDNode.curveOrder {
                    if trueIndex < UInt32.max {
                        return self.derive(index:index+1, derivePrivateKey: derivePrivateKey, hardened:hardened)
                    }
                    return nil
                }
                let newPK = (bn + BigUInt(self.privateKey!)) % HDNode.curveOrder
                if newPK == BigUInt(0) {
                    if trueIndex < UInt32.max {
                        return self.derive(index:index+1, derivePrivateKey: derivePrivateKey, hardened:hardened)
                    }
                    return nil
                }
                guard let privKeyCandidate = newPK.serialize().setLengthLeft(32) else {return nil}
                guard SECP256K1.verifyPrivateKey(privateKey: privKeyCandidate) else {return nil }
                guard let pubKeyCandidate = SECP256K1.privateToPublic(privateKey: privKeyCandidate, compressed: true) else {return nil}
                guard pubKeyCandidate.bytes[0] == 0x02 || pubKeyCandidate.bytes[0] == 0x03 else {return nil}
                guard self.depth < UInt8.max else {return nil}
                var newNode = HDNode()
                newNode.chaincode = cc
                newNode.depth = self.depth + 1
                newNode.publicKey = pubKeyCandidate
                newNode.privateKey = privKeyCandidate
                newNode.childNumber = trueIndex
                let fprint = RIPEMD160.hash(message: self.publicKey.sha256())[0..<4]
                newNode.parentFingerprint = fprint
                return newNode
            } else {
                return nil // derive private key when is itself extended public key (impossible)
            }
        }
        else { // deriving only the public key
            var entropy:Array<UInt8> // derive public key when is itself public key
            if index >= (UInt32(1) << 31) || hardened {
                return nil // no derivation of hardened public key from extended public key
            } else {
                let hmac:Authenticator = HMAC(key: self.chaincode.bytes, variant: .sha512)
                var inputForHMAC = Data()
                inputForHMAC.append(self.publicKey)
                inputForHMAC.append(index.serialize32())
                guard let ent = try? hmac.authenticate(inputForHMAC.bytes) else {return nil }
                guard ent.count == 64 else { return nil }
                entropy = ent
            }
            let I_L = entropy[0..<32]
            let I_R = entropy[32..<64]
            let cc = Data(I_R)
            let bn = BigUInt(Data(I_L))
            if bn > HDNode.curveOrder {
                if index < UInt32.max {
                    return self.derive(index:index+1, derivePrivateKey: derivePrivateKey, hardened:hardened)
                }
                return nil
            }
            guard let tempKey = bn.serialize().setLengthLeft(32) else {return nil}
            guard SECP256K1.verifyPrivateKey(privateKey: tempKey) else {return nil }
            guard let pubKeyCandidate = SECP256K1.privateToPublic(privateKey: tempKey, compressed: true) else {return nil}
            guard pubKeyCandidate.bytes[0] == 0x02 || pubKeyCandidate.bytes[0] == 0x03 else {return nil}
            guard let newPublicKey = SECP256K1.combineSerializedPublicKeys(keys: [self.publicKey, pubKeyCandidate], outputCompressed: true) else {return nil}
            guard newPublicKey.bytes[0] == 0x02 || newPublicKey.bytes[0] == 0x03 else {return nil}
            guard self.depth < UInt8.max else {return nil}
            var newNode = HDNode()
            newNode.chaincode = cc
            newNode.depth = self.depth + 1
            newNode.publicKey = pubKeyCandidate
            newNode.childNumber = index
            let fprint = RIPEMD160.hash(message: self.publicKey.sha256())[0..<4]
            newNode.parentFingerprint = fprint
            return newNode
        }
    }
    
    public func derive (path: String) -> HDNode? {
        return nil
    }
    
    public func serialize(serializePublic: Bool = true) -> String? {
        var data = Data()
        if (!serializePublic && !self.hasPrivate) {return nil}
        if serializePublic {
            data.append(self.version.publicPrefix)
        } else {
            data.append(self.version.privatePrefix)
        }
        data.append(contentsOf: [self.depth])
        data.append(self.parentFingerprint)
        data.append(self.childNumber.serialize32())
        data.append(self.chaincode)
        if serializePublic {
            data.append(self.publicKey)
        } else {
            data.append(contentsOf: [0x00])
            data.append(self.privateKey!)
        }
        let hashedData = data.sha256().sha256()
        let checksum = hashedData[0..<4]
        data.append(checksum)
        let encoded = Base58.base58FromBytes(data.bytes)
        return encoded
    }
    
}

