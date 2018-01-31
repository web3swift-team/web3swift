
import Foundation
import secp256k1_ios
import BigInt



struct SECP256K1 {
    struct UnmarshaledSignature{
        var v: UInt8
        var r = [UInt8](repeating: 0, count: 32)
        var s = [UInt8](repeating: 0, count: 32)
    }
    
    static var secp256k1_N  = BigUInt("fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141", radix: 16)!
    static var secp256k1_halfN = secp256k1_N >> 2
}

extension SECP256K1 {
    static var context = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN|SECP256K1_CONTEXT_VERIFY))
    
    static func signForRecovery(hash: Data, privateKey: Data) -> (compressed:Data?, uncompressed: Data?) {
        if (hash.count != 32 || privateKey.count != 32) {return (nil, nil)}
        if !SECP256K1.verifyPrivateKey(privateKey: privateKey) {
            return (nil, nil)
        }
        for rounds in 0...1024 {
            var extraEntropy = Data(count: 32)
            for _ in 0...1024 {
                let result = extraEntropy.withUnsafeMutableBytes {
                    SecRandomCopyBytes(kSecRandomDefault, extraEntropy.count, $0)
                }
                if result == errSecSuccess {
                    break
                }
            }
            var uncompressed: secp256k1_ecdsa_recoverable_signature = secp256k1_ecdsa_recoverable_signature();
            var result = hash.withUnsafeBytes { (hashPointer:UnsafePointer<UInt8>) -> Int32 in
                privateKey.withUnsafeBytes { (privateKeyPointer:UnsafePointer<UInt8>) -> Int32 in
                    extraEntropy.withUnsafeBytes { (extraEntropyPointer:UnsafePointer<UInt8>) -> Int32 in
                        let res = secp256k1_ecdsa_sign_recoverable(context!, UnsafeMutablePointer<secp256k1_ecdsa_recoverable_signature>(&uncompressed), hashPointer, privateKeyPointer, secp256k1_nonce_function_rfc6979, extraEntropyPointer)
                        return res
                    }
                }
            }
            if result == 0 {
                continue
//                return (nil, nil)
            }
            let uncompressedSignature = Data(toByteArray(uncompressed))
            var compressedSignature = Data(count: 64)
            var v: Int32 = 0
            result = compressedSignature.withUnsafeMutableBytes { (compressedPointer:UnsafeMutablePointer<UInt8>) -> Int32 in
                let res = secp256k1_ecdsa_recoverable_signature_serialize_compact(context!, compressedPointer, UnsafeMutablePointer<Int32>(&v), UnsafeMutablePointer<secp256k1_ecdsa_recoverable_signature>(&uncompressed))
                return res
            }
            if result == 0 {
                continue
//                return (nil, nil)
            }
            let buffer = toByteArray(v)
            compressedSignature.append(buffer.last!)
            
//            let S = BigUInt(compressedSignature[32..<65])
//            if S > secp256k1_halfN {
//                continue
//            }

            guard let recoveredPubKey = SECP256K1.recoverPublicKey(hash: hash, signature: compressedSignature) else {continue}
            guard let truePubKey = SECP256K1.privateToPublic(privateKey: privateKey) else {continue}
            if recoveredPubKey != truePubKey {continue}
            print("Signature required \(rounds) rounds")
            return (compressedSignature, uncompressedSignature)
        }
        return (nil, nil)
    }
    
    static func privateToPublic(privateKey: Data, compressed: Bool = false) -> Data? {
        if (privateKey.count != 32) {return nil}
        var publicKey = secp256k1_pubkey()
        var result = privateKey.withUnsafeBytes { (privateKeyPointer:UnsafePointer<UInt8>) -> Int32 in
            let res = secp256k1_ec_pubkey_create(context!, UnsafeMutablePointer<secp256k1_pubkey>(&publicKey), privateKeyPointer)
            return res
        }
        if result == 0 {
            return nil
        }
        var keyLength = compressed ? 33 : 65
        var serializedPubkey = Data(count: keyLength)
        result = serializedPubkey.withUnsafeMutableBytes { (serializedPubkeyPointer:UnsafeMutablePointer<UInt8>) -> Int32 in
            let res = secp256k1_ec_pubkey_serialize(context!,
                                                    serializedPubkeyPointer,
                                                    UnsafeMutablePointer<Int>(&keyLength),
                                                    UnsafeMutablePointer<secp256k1_pubkey>(&publicKey),
                                                    UInt32(compressed ? SECP256K1_EC_COMPRESSED : SECP256K1_EC_UNCOMPRESSED))
            return res
        }
        return serializedPubkey
    }
    
    static func combineSerializedPublicKeys(keys: [Data], outputCompressed: Bool = false) -> Data? {
        let numToCombine = keys.count
        guard numToCombine >= 1 else { return nil}
        var publicKeys = [UnsafePointer<secp256k1_pubkey>?]()
        var result:Int32
        for i in 0..<numToCombine {
            var publicKey = secp256k1_pubkey()
            let key = keys[i]
            let keyLen = key.count
            result = key.withUnsafeBytes { (publicKeyPointer:UnsafePointer<UInt8>) -> Int32 in
                let res = secp256k1_ec_pubkey_parse(context!, UnsafeMutablePointer<secp256k1_pubkey>(&publicKey), publicKeyPointer, keyLen)
                return res
            }
            if result == 0 {
                return nil
            }
            let pointer = UnsafePointer<secp256k1_pubkey>(UnsafeMutablePointer<secp256k1_pubkey>(&publicKey))
            publicKeys.append(pointer)
        }
    

        
        var publicKey: secp256k1_pubkey = secp256k1_pubkey()
        let arrayPointer = UnsafePointer(publicKeys)
        result = secp256k1_ec_pubkey_combine(context!, UnsafeMutablePointer<secp256k1_pubkey>(&publicKey), arrayPointer, numToCombine)
        
        if result == 0 {
            return nil
        }
        
        var keyLength = outputCompressed ? 33 : 65
        var serializedPubkey = Data(count: keyLength)
        
        result = serializedPubkey.withUnsafeMutableBytes { (serializedPubkeyPointer:UnsafeMutablePointer<UInt8>) -> Int32 in
            let res = secp256k1_ec_pubkey_serialize(context!,
                                                    serializedPubkeyPointer,
                                                    UnsafeMutablePointer<Int>(&keyLength),
                                                    UnsafeMutablePointer<secp256k1_pubkey>(&publicKey),
                                                    UInt32(outputCompressed ? SECP256K1_EC_COMPRESSED : SECP256K1_EC_UNCOMPRESSED))
            return res
        }
        
        return serializedPubkey
    }
    
    static func recoverPublicKey(hash: Data, signature: Data, compressed: Bool = false) -> Data? {
        guard hash.count == 32, signature.count == 65 else {return nil}
        var uncompressed: secp256k1_ecdsa_recoverable_signature = secp256k1_ecdsa_recoverable_signature();
        let compressedSignature = Data(signature[0..<64])
        let v = Int32(signature[64])
        var result = compressedSignature.withUnsafeBytes{ (compressedSignaturePointer: UnsafePointer<UInt8>) -> Int32 in
                    let res = secp256k1_ecdsa_recoverable_signature_parse_compact(context!, UnsafeMutablePointer<secp256k1_ecdsa_recoverable_signature>(&uncompressed), compressedSignaturePointer, v)
                    return res
                }
        if result == 0 {
            return nil
        }
        var publicKey: secp256k1_pubkey = secp256k1_pubkey()
        result = hash.withUnsafeBytes { (hashPointer:UnsafePointer<UInt8>) -> Int32 in
            withUnsafePointer(to: &uncompressed) { (signaturePointer:UnsafePointer<secp256k1_ecdsa_recoverable_signature>) -> Int32 in
                let res = secp256k1_ecdsa_recover(context!, UnsafeMutablePointer<secp256k1_pubkey>(&publicKey),
                    signaturePointer, hashPointer)
                return res
            }
        }
        if result == 0 {
            return nil
        }
        var keyLength = compressed ? 33 : 65
        var serializedPubkey = Data(count: keyLength)
        result = serializedPubkey.withUnsafeMutableBytes { (serializedPubkeyPointer:UnsafeMutablePointer<UInt8>) -> Int32 in
            let res = secp256k1_ec_pubkey_serialize(context!,
                                                    serializedPubkeyPointer,
                                                    UnsafeMutablePointer<Int>(&keyLength),
                                                    UnsafeMutablePointer<secp256k1_pubkey>(&publicKey),
                                                    UInt32(compressed ? SECP256K1_EC_COMPRESSED : SECP256K1_EC_UNCOMPRESSED))
            return res
        }
        
        if result == 0 {
            return nil
        }
        
        return serializedPubkey
    }
    
    static func recoverSender(hash: Data, signature: Data) -> EthereumAddress? {
        guard let pubKey = SECP256K1.recoverPublicKey(hash:hash, signature:signature, compressed: false) else {return nil}
        let addressString = pubKey.toHexString().addHexPrefix().lowercased()
        return EthereumAddress(addressString)
    }
    
    static func verifyPrivateKey(privateKey: Data) -> Bool {
        if (privateKey.count != 32) {return false}
        let result = privateKey.withUnsafeBytes { (privateKeyPointer:UnsafePointer<UInt8>) -> Int32 in
            let res = secp256k1_ec_seckey_verify(context!, privateKeyPointer)
            return res
        }
        return result == 1
    }
    
    static func generatePrivateKey() -> Data? {
        var keyData = Data(count: 32)
        for _ in 0...1024 {
            let result = keyData.withUnsafeMutableBytes {
                SecRandomCopyBytes(kSecRandomDefault, keyData.count, $0)
            }
            if result == errSecSuccess {
                if (verifyPrivateKey(privateKey: keyData)) {
                    return keyData
                }
            }
        }
        return nil
    }
    
    static func unmarshalSignature(signatureData:Data) -> UnmarshaledSignature? {
        if (signatureData.count != 65) {return nil}
        let bytes = signatureData.bytes
        let r = Array(bytes[0...31])
        let s = Array(bytes[32...63])
//        let S = BigUInt(Data(bytes: s))
//        if S > secp256k1_halfN {
//            return nil
//        }
        return UnmarshaledSignature(v: bytes[64], r: r, s: s)
    }
    
    static func marshalSignature(v: UInt8, r: [UInt8] = [UInt8](repeating: 0, count: 32), s: [UInt8] = [UInt8](repeating: 0, count: 32)) -> Data? {
        guard r.count == 32, s.count == 32 else {return nil}
        var completeSignature = Data(bytes: r)
        completeSignature.append(Data(bytes: s))
        completeSignature.append(Data(bytes: [v]))
        return completeSignature
    }
    
    static func marshalSignature(v: Data, r: Data, s: Data) -> Data? {
        guard r.count == 32, s.count == 32 else {return nil}
        var completeSignature = Data(r)
        completeSignature.append(s)
        completeSignature.append(v)
        return completeSignature
    }
}






