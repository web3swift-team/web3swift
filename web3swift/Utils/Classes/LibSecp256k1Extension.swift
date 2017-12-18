
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
}






