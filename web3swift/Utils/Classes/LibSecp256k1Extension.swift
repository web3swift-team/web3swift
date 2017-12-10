
import Foundation
import SECP256K1

/** Create a recoverable ECDSA signature.
 *
 *  Returns: 1: signature created
 *           0: the nonce generation function failed, or the private key was invalid.
 *  Args:    ctx:    pointer to a context object, initialized for signing (cannot be NULL)
 *  Out:     sig:    pointer to an array where the signature will be placed (cannot be NULL)
 *  In:      msg32:  the 32-byte message hash being signed (cannot be NULL)
 *           seckey: pointer to a 32-byte secret key (cannot be NULL)
 *           noncefp:pointer to a nonce generation function. If NULL, secp256k1_nonce_function_default is used
 *           ndata:  pointer to arbitrary data used by the nonce generation function (can be NULL)
 */
//SECP256K1_API int secp256k1_ecdsa_sign_recoverable(
//    const secp256k1_context* ctx,
//    secp256k1_ecdsa_recoverable_signature *sig,
//    const unsigned char *msg32,
//    const unsigned char *seckey,
//    secp256k1_nonce_function noncefp,
//    const void *ndata
//) SECP256K1_ARG_NONNULL(1) SECP256K1_ARG_NONNULL(2) SECP256K1_ARG_NONNULL(3) SECP256K1_ARG_NONNULL(4);

/** Recover an ECDSA public key from a signature.
 *
 *  Returns: 1: public key successfully recovered (which guarantees a correct signature).
 *           0: otherwise.
 *  Args:    ctx:        pointer to a context object, initialized for verification (cannot be NULL)
 *  Out:     pubkey:     pointer to the recovered public key (cannot be NULL)
 *  In:      sig:        pointer to initialized signature that supports pubkey recovery (cannot be NULL)
 *           msg32:      the 32-byte message hash assumed to be signed (cannot be NULL)
 */
//SECP256K1_API SECP256K1_WARN_UNUSED_RESULT int secp256k1_ecdsa_recover(
//    const secp256k1_context* ctx,
//    secp256k1_pubkey *pubkey,
//    const secp256k1_ecdsa_recoverable_signature *sig,
//    const unsigned char *msg32
//) SECP256K1_ARG_NONNULL(1) SECP256K1_ARG_NONNULL(2) SECP256K1_ARG_NONNULL(3) SECP256K1_ARG_NONNULL(4);


//func Sign(msg []byte, seckey []byte) ([]byte, error) {
//    if len(msg) != 32 {
//        return nil, ErrInvalidMsgLen
//    }
//    if len(seckey) != 32 {
//        return nil, ErrInvalidKey
//    }
//    seckeydata := (*C.uchar)(unsafe.Pointer(&seckey[0]))
//    if C.secp256k1_ec_seckey_verify(context, seckeydata) != 1 {
//        return nil, ErrInvalidKey
//    }
//
//    var (
//    msgdata   = (*C.uchar)(unsafe.Pointer(&msg[0]))
//    noncefunc = C.secp256k1_nonce_function_rfc6979
//    sigstruct C.secp256k1_ecdsa_recoverable_signature
//    )
//    if C.secp256k1_ecdsa_sign_recoverable(context, &sigstruct, msgdata, seckeydata, noncefunc, nil) == 0 {
//        return nil, ErrSignFailed
//    }
//
//    var (
//    sig     = make([]byte, 65)
//    sigdata = (*C.uchar)(unsafe.Pointer(&sig[0]))
//    recid   C.int
//    )
//    C.secp256k1_ecdsa_recoverable_signature_serialize_compact(context, sigdata, &recid, &sigstruct)
//    sig[64] = byte(recid) // add back recid to get 65 bytes sig
//    return sig, nil
//}


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
    static func SECP256K1signForRecovery(hash: Data, privateKey: Data) -> (compressed:Data?, uncompressed: Data?) {
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
    
    static func SECP256K1privateToPublic(privateKey: Data, compressed: Bool = false) -> Data? {
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
    
    static func unmarshalSignature(signatureData:Data) -> UnmarshaledSignature? {
        if (signatureData.count != 65) {return nil}
        let bytes = signatureData.bytes
        let r = Array(bytes[0...31])
        let s = Array(bytes[32...63])
        return UnmarshaledSignature(v: bytes[64], r: r, s: s)
    }
}






