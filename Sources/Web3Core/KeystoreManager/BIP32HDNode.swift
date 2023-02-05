//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import CryptoSwift

extension UInt32 {
    public func serialize32() -> Data {
        var bigEndian = self.bigEndian
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

public class HDNode {
    public struct HDversion {
        // swiftlint:disable force_unwrapping
        public var privatePrefix: Data = Data.fromHex("0x0488ADE4")!
        public var publicPrefix: Data = Data.fromHex("0x0488B21E")!
        // swiftlint:enable force_unwrapping
        public init() {}
    }
    public var path: String? = "m"
    public var privateKey: Data?
    public var publicKey: Data
    public var chaincode: Data
    public var depth: UInt8
    public var parentFingerprint: Data = Data(repeating: 0, count: 4)
    public var childNumber: UInt32 = UInt32(0)
    public var isHardened: Bool {
        childNumber >= (UInt32(1) << 31)
    }
    public var index: UInt32 {
            if self.isHardened {
                return childNumber - (UInt32(1) << 31)
            } else {
                return childNumber
            }
    }
    public var hasPrivate: Bool {
        privateKey != nil
    }

    init() {
        publicKey = Data()
        chaincode = Data()
        depth = UInt8(0)
    }

    public convenience init?(_ serializedString: String) {
        let data = Data(Base58.bytesFromBase58(serializedString))
        self.init(data)
    }

    public init?(_ data: Data) {
        guard data.count == 82 else { return nil }
        let header = data[0..<4]
        var serializePrivate = false
        if header == HDNode.HDversion().privatePrefix {
            serializePrivate = true
        }
        depth = data[4..<5].bytes[0]
        parentFingerprint = data[5..<9]
        childNumber = data[9..<13].bytes.withUnsafeBytes { $0.load(as: UInt32.self) }
        chaincode = data[13..<45]
        if serializePrivate {
            privateKey = data[46..<78]
            guard
                let privateKey = privateKey,
                let pubKey = Utilities.privateToPublic(privateKey, compressed: true),
                (pubKey[0] == 0x02 || pubKey[0] == 0x03)
            else { return nil }
            publicKey = pubKey
        } else {
            publicKey = data[45..<78]
        }
        let hashedData = data[0..<78].sha256().sha256()
        let checksum = hashedData[0..<4]
        if checksum != data[78..<82] { return nil }
    }

    public init?(seed: Data) {
        guard seed.count >= 16 else { return nil }
        // swiftlint:disable force_unwrapping
        let hmacKey = "Bitcoin seed".data(using: .ascii)!
        let hmac = HMAC(key: hmacKey.bytes, variant: HMAC.Variant.sha2(.sha512))
        guard let entropy = try? hmac.authenticate(seed.bytes), entropy.count == 64 else { return nil }
        let I_L = entropy[0..<32]
        let I_R = entropy[32..<64]
        chaincode = Data(I_R)
        let privKeyCandidate = Data(I_L)
        guard SECP256K1.verifyPrivateKey(privateKey: privKeyCandidate) else { return nil }
        guard let pubKeyCandidate = SECP256K1.privateToPublic(privateKey: privKeyCandidate, compressed: true) else { return nil }
        guard pubKeyCandidate.bytes[0] == 0x02 || pubKeyCandidate.bytes[0] == 0x03 else { return nil }
        publicKey = pubKeyCandidate
        privateKey = privKeyCandidate
        depth = 0x00
        childNumber = UInt32(0)
    }

    private static var curveOrder = BigUInt("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141", radix: 16)!
    // swiftlint:enable force_unwrapping
    public static var defaultPath: String = "m/44'/60'/0'/0"
    public static var defaultPathPrefix: String = "m/44'/60'/0'"
    public static var defaultPathMetamask: String = "m/44'/60'/0'/0/0"
    public static var defaultPathMetamaskPrefix: String = "m/44'/60'/0'/0"
    public static var hardenedIndexPrefix: UInt32 = (UInt32(1) << 31)
}

extension HDNode {
    public func derive(index: UInt32, derivePrivateKey: Bool, hardened: Bool = false) -> HDNode? {
        if derivePrivateKey {
            return self.derivePrivateKey(index: index, hardened: hardened)
        } else {
            return derivePublicKey(index: index, hardened: hardened)
        }
    }

    public func derive(path: String, derivePrivateKey: Bool = true) -> HDNode? {
        let components = path.components(separatedBy: "/")
        var currentNode: HDNode = self
        var firstComponent = 0
        if path.hasPrefix("m") {
            firstComponent = 1
        }
        for component in components[firstComponent ..< components.count] {
            var hardened = false
            if component.hasSuffix("'") {
                hardened = true
            }
            guard let index = UInt32(component.trimmingCharacters(in: CharacterSet(charactersIn: "'"))) else { return nil }
            guard let newNode = currentNode.derive(index: index, derivePrivateKey: derivePrivateKey, hardened: hardened) else { return nil }
            currentNode = newNode
        }
        return currentNode
    }

    /// Derive public key when is itself private key.
    /// Derivation of private key when is itself extended public key is impossible and will return `nil`.
    private func derivePrivateKey(index: UInt32, hardened: Bool) -> HDNode? {
        guard let privateKey = privateKey else {
            // derive private key when is itself extended public key (impossible)
            return nil
        }

        var trueIndex = index
        if trueIndex < (UInt32(1) << 31) && hardened {
            trueIndex += (UInt32(1) << 31)
        }

        guard let entropy = calculateEntropy(index: trueIndex, privateKey: privateKey, hardened: hardened) else { return nil }

        let I_L = entropy[0..<32]
        let I_R = entropy[32..<64]
        let chainCode = Data(I_R)
        let bn = BigUInt(Data(I_L))
        if bn > HDNode.curveOrder {
            if trueIndex < UInt32.max {
                return self.derive(index: index + 1, derivePrivateKey: true, hardened: hardened)
            }
            return nil
        }
        let newPK = (bn + BigUInt(privateKey)) % HDNode.curveOrder
        if newPK == BigUInt(0) {
            if trueIndex < UInt32.max {
                return self.derive(index: index + 1, derivePrivateKey: true, hardened: hardened)
            }
            return nil
        }

        guard
            let newPrivateKey = newPK.serialize().setLengthLeft(32),
            SECP256K1.verifyPrivateKey(privateKey: newPrivateKey),
            let newPublicKey = SECP256K1.privateToPublic(privateKey: newPrivateKey, compressed: true),
            (newPublicKey.bytes[0] == 0x02 || newPublicKey.bytes[0] == 0x03),
            self.depth < UInt8.max
        else { return nil }
        return createNode(chainCode: chainCode, depth: depth + 1, publicKey: newPublicKey, privateKey: newPrivateKey, childNumber: trueIndex)
    }

    /// Derive public key when is itself public key.
    /// No derivation of hardened public key from extended public key is allowed.
    private func derivePublicKey(index: UInt32, hardened: Bool) -> HDNode? {
        if index >= (UInt32(1) << 31) || hardened {
            // no derivation of hardened public key from extended public key
            return nil
        }

        guard let entropy = calculateEntropy(index: index, hardened: hardened) else { return nil }

        let I_L = entropy[0..<32]
        let I_R = entropy[32..<64]
        let chainCode = Data(I_R)
        let bn = BigUInt(Data(I_L))
        if bn > HDNode.curveOrder {
            if index < UInt32.max {
                return self.derive(index: index+1, derivePrivateKey: false, hardened: hardened)
            }
            return nil
        }

        guard
            let tempKey = bn.serialize().setLengthLeft(32),
            SECP256K1.verifyPrivateKey(privateKey: tempKey),
            let pubKeyCandidate = SECP256K1.privateToPublic(privateKey: tempKey, compressed: true),
            (pubKeyCandidate.bytes[0] == 0x02 || pubKeyCandidate.bytes[0] == 0x03),
            let newPublicKey = SECP256K1.combineSerializedPublicKeys(keys: [self.publicKey, pubKeyCandidate], outputCompressed: true),
            (newPublicKey.bytes[0] == 0x02 || newPublicKey.bytes[0] == 0x03),
            self.depth < UInt8.max
        else { return nil }

        return createNode(chainCode: chainCode, depth: depth + 1, publicKey: newPublicKey, childNumber: index)
    }

    private func createNode(chainCode: Data, depth: UInt8, publicKey: Data, privateKey: Data? = nil, childNumber: UInt32) -> HDNode? {
        let newNode = HDNode()
        newNode.chaincode = chainCode
        newNode.depth = depth
        newNode.publicKey = publicKey
        newNode.privateKey = privateKey
        newNode.childNumber = childNumber
        guard
            let fprint = try? RIPEMD160.hash(message: self.publicKey.sha256())[0..<4],
            let path = path
        else { return nil }
        newNode.parentFingerprint = fprint
        var newPath = String()
        if newNode.isHardened {
            newPath = path + "/"
            newPath += String(newNode.index % HDNode.hardenedIndexPrefix) + "'"
        } else {
            newPath = path + "/" + String(newNode.index)
        }
        newNode.path = newPath
        return newNode
    }

    private func calculateHMACInput(_ index: UInt32, privateKey: Data? = nil, hardened: Bool) -> Data {
        var inputForHMAC = Data()

        if let privateKey = privateKey, (index >= (UInt32(1) << 31) || hardened) {
            inputForHMAC.append(Data([UInt8(0x00)]))
            inputForHMAC.append(privateKey)
        } else {
            inputForHMAC.append(self.publicKey)
        }

        inputForHMAC.append(index.serialize32())
        return inputForHMAC
    }

    /// Calculates entropy used for private or public key derivation.
    /// - Parameters:
    ///   - index: index
    ///   - privateKey: private key data or `nil` if entropy is calculated for a public key;
    ///   - hardened: is hardened key
    /// - Returns: 64 bytes entropy or `nil`.
    private func calculateEntropy(index: UInt32, privateKey: Data? = nil, hardened: Bool) -> [UInt8]? {
        let inputForHMAC = calculateHMACInput(index, privateKey: privateKey, hardened: hardened)
        let hmac = HMAC(key: self.chaincode.bytes, variant: .sha2(.sha512))
        guard let entropy = try? hmac.authenticate(inputForHMAC.bytes), entropy.count == 64 else { return nil }
        return entropy
    }

    public func serializeToString(serializePublic: Bool = true, version: HDversion = HDversion()) -> String? {
        guard let data = self.serialize(serializePublic: serializePublic, version: version) else { return nil }
        return Base58.base58FromBytes(data.bytes)
    }

    public func serialize(serializePublic: Bool = true, version: HDversion = HDversion()) -> Data? {
        var data = Data()
        /// Public or private key
        let keyData: Data
        if serializePublic {
            keyData = publicKey
            data.append(version.publicPrefix)
        } else {
            guard let privateKey = privateKey else { return nil }
            keyData = privateKey
            data.append(version.privatePrefix)
        }
        data.append(contentsOf: [depth])
        data.append(parentFingerprint)
        data.append(childNumber.serialize32())
        data.append(chaincode)
        if !serializePublic {
            data.append(contentsOf: [0x00])
        }
        data.append(keyData)
        let hashedData = data.sha256().sha256()
        let checksum = hashedData[0..<4]
        data.append(checksum)
        return data
    }

}
