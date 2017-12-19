
import Foundation
import secp256k1

func toByteArray<T>(_ value: T) -> [UInt8] {
    var value = value
    return withUnsafeBytes(of: &value) { Array($0) }
}

func fromByteArray<T>(_ value: [UInt8], _: T.Type) -> T {
    return value.withUnsafeBytes {
        $0.baseAddress!.load(as: T.self)
    }
}

struct SECP256K1 {
    struct UnmarshaledSignature{
        var v: UInt8
        var r = [UInt8](repeating: 0, count: 32)
        var s = [UInt8](repeating: 0, count: 32)
    }
}

extension SECP256K1 {
    static func signForRecovery(hash: Data, privateKey: Data) -> (compressed:Data?, uncompressed: Data?) {
        if (hash.count != 32 || privateKey.count != 32) {return (nil, nil)}
        let context = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN));
        defer {secp256k1_context_destroy(context!)}
        var uncompressed: secp256k1_ecdsa_recoverable_signature = secp256k1_ecdsa_recoverable_signature();
        let nonceFunction = secp256k1_nonce_function_rfc6979
        var result = hash.withUnsafeBytes { (hashPointer:UnsafePointer<UInt8>) -> Int32 in
            privateKey.withUnsafeBytes { (privateKeyPointer:UnsafePointer<UInt8>) -> Int32 in
                let res = secp256k1_ecdsa_sign_recoverable(context!, UnsafeMutablePointer<secp256k1_ecdsa_recoverable_signature>(&uncompressed), hashPointer, privateKeyPointer, nonceFunction!, nil)
                return res
            }
        }
        if result == 0 {
            return (nil, nil)
        }
        let uncompressedSignature = Data(toByteArray(uncompressed))
        var compressedSignature = Data(count: 64)
        var v: Int32 = 0
        result = compressedSignature.withUnsafeMutableBytes { (compressedPointer:UnsafeMutablePointer<UInt8>) -> Int32 in
            let res = secp256k1_ecdsa_recoverable_signature_serialize_compact(context!, compressedPointer, UnsafeMutablePointer<Int32>(&v), UnsafeMutablePointer<secp256k1_ecdsa_recoverable_signature>(&uncompressed))
            return res
        }
        if result == 0 {
            return (nil, nil)
        }
        let buffer = toByteArray(v)
        compressedSignature.append(buffer.last!)
        return (compressedSignature, uncompressedSignature)
    }
    
    static func privateToPublic(privateKey: Data, compressed: Bool = false) -> Data? {
        if (privateKey.count != 32) {return nil}
        let context = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN));
        var publicKey = secp256k1_pubkey()
        var result = privateKey.withUnsafeBytes { (privateKeyPointer:UnsafePointer<UInt8>) -> Int32 in
            let res = secp256k1_ec_pubkey_create(context!, UnsafeMutablePointer<secp256k1_pubkey>(&publicKey), privateKeyPointer)
            return res
        }
        if result == 0 {
            return nil
        }
        var signatureLength = compressed ? 33 : 65
        var serializedPubkey = Data(count: signatureLength)
        result = serializedPubkey.withUnsafeMutableBytes { (serializedPubkeyPointer:UnsafeMutablePointer<UInt8>) -> Int32 in
            let res = secp256k1_ec_pubkey_serialize(context!,
                                                    serializedPubkeyPointer,
                                                    UnsafeMutablePointer<Int>(&signatureLength),
                                                    UnsafeMutablePointer<secp256k1_pubkey>(&publicKey),
                                                    UInt32(compressed ? SECP256K1_EC_COMPRESSED : SECP256K1_EC_UNCOMPRESSED))
            return res
        }
        return serializedPubkey
    }
    
    static func recoverPublicKey(hash: Data, signature: Data) -> Data? {
        guard hash.count == 32, signature.count == 65 else {return nil}
        let context = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_VERIFY));
        defer {secp256k1_context_destroy(context!)}
        var uncompressed: secp256k1_ecdsa_recoverable_signature = secp256k1_ecdsa_recoverable_signature();
        let compactSignature = Data(signature[0..<64])
        let v = Int32(signature[64])
        var result = compactSignature.withUnsafeBytes { (compactPointer:UnsafePointer<UInt8>) -> Int32 in
                    let res = secp256k1_ecdsa_recoverable_signature_parse_compact( context!, UnsafeMutablePointer<secp256k1_ecdsa_recoverable_signature>(&uncompressed), compactPointer, v)
                    return res
                }
        if result == 0 {
            return nil
        }
        var pubKey: secp256k1_pubkey = secp256k1_pubkey()
        result =  hash.withUnsafeBytes { (hashPointer:UnsafePointer<UInt8>) -> Int32 in
            withUnsafePointer(to: &uncompressed) { (sigPointer:UnsafePointer<secp256k1_ecdsa_recoverable_signature>) -> Int32 in
                let res =  secp256k1_ecdsa_recover(context!, UnsafeMutablePointer<secp256k1_pubkey>(&pubKey),
                    sigPointer, hashPointer)
                return res
            }
        }
        if result == 0 {
            return nil
        }
        let buffer = toByteArray(pubKey)
        let pubKeyData = Data(buffer)
        return pubKeyData
    }
    
    static func recoverSender(hash: Data, signature: Data) -> EthereumAddress? {
        guard let pubKey = SECP256K1.recoverPublicKey(hash:hash, signature:signature) else {return nil}
        let addressString = pubKey.toHexString().addHexPrefix().lowercased()
        return EthereumAddress(addressString)
    }
    
    static func verifyPrivateKey(privateKey: Data) -> Bool {
        if (privateKey.count != 32) {return false}
        let context = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN|SECP256K1_CONTEXT_VERIFY));
        let result = privateKey.withUnsafeBytes { (privateKeyPointer:UnsafePointer<UInt8>) -> Int32 in
            let res = secp256k1_ec_seckey_verify(context!, privateKeyPointer)
            return res
        }
        return result == 1
    }
    
    static func generatePrivateKey() -> Data? {
        var keyData = Data(count: 32)
        for _ in 0...15 {
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






