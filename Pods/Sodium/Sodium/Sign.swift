import Foundation
import libsodium

public class Sign {
    public let SeedBytes = Int(crypto_sign_seedbytes())
    public let PublicKeyBytes = Int(crypto_sign_publickeybytes())
    public let SecretKeyBytes = Int(crypto_sign_secretkeybytes())
    public let Bytes = Int(crypto_sign_bytes())
    public let Primitive = String(validatingUTF8: crypto_sign_primitive())

    public typealias PublicKey = Data
    public typealias SecretKey = Data

    public struct KeyPair {
        public let publicKey: PublicKey
        public let secretKey: SecretKey

        public init(publicKey: PublicKey, secretKey: SecretKey) {
            self.publicKey = publicKey
            self.secretKey = secretKey
        }
    }

    /**
     Generates a signing secret key and a corresponding public key.

     - Returns: A key pair containing the secret key and public key.
     */
    public func keyPair() -> KeyPair? {
        var pk = Data(count: PublicKeyBytes)
        var sk = Data(count: SecretKeyBytes)

        let result = pk.withUnsafeMutableBytes { pkPtr in
            sk.withUnsafeMutableBytes { skPtr in
                crypto_sign_keypair(pkPtr, skPtr)
            }
        }
        if result != 0 {
            return nil
        }
        return KeyPair(publicKey: pk, secretKey: sk)
    }

    /**
     Generates a signing secret key and a corresponding public key derived from a seed.

     - Parameter seed: The value from which to derive the secret and public key.

     - Returns: A key pair containing the secret key and public key.
     */
    public func keyPair(seed: Data) -> KeyPair? {
        if seed.count != SeedBytes {
            return nil
        }
        var pk = Data(count: PublicKeyBytes)
        var sk = Data(count: SecretKeyBytes)

        let result = pk.withUnsafeMutableBytes { pkPtr in
            sk.withUnsafeMutableBytes { skPtr in
                seed.withUnsafeBytes { seedPtr in
                    crypto_sign_seed_keypair(pkPtr, skPtr, seedPtr)
                }
            }
        }
        if result != 0 {
            return nil
        }
        return KeyPair(publicKey: pk, secretKey: sk)
    }

    /**
     Signs a message with the sender's secret key

     - Parameter message: The message to encrypt.
     - Parameter secretKey: The sender's secret key.

     - Returns: The signed message.
     */
    public func sign(message: Data, secretKey: SecretKey) -> Data? {
        if secretKey.count != SecretKeyBytes {
            return nil
        }
        var signedMessage = Data(count: message.count + Bytes)

        let result = signedMessage.withUnsafeMutableBytes { signedMessagePtr in
            message.withUnsafeBytes { messagePtr in
                secretKey.withUnsafeBytes { secretKeyPtr in
                    crypto_sign(
                        signedMessagePtr, nil,
                        messagePtr, CUnsignedLongLong(message.count),
                        secretKeyPtr)
                }
            }
        }
        if result != 0 {
            return nil
        }
        return signedMessage
    }

    /**
     Computes a detached signature for a message with the sender's secret key.

     - Parameter message: The message to encrypt.
     - Parameter secretKey: The sender's secret key.

     - Returns: The computed signature.
     */
    public func signature(message: Data, secretKey: SecretKey) -> Data? {
        if secretKey.count != SecretKeyBytes {
            return nil
        }
        var signature = Data(count: Bytes)

        let result = signature.withUnsafeMutableBytes { signaturePtr in
            message.withUnsafeBytes { messagePtr in
                secretKey.withUnsafeBytes { secretKeyPtr in
                    crypto_sign_detached(
                        signaturePtr, nil,
                        messagePtr, CUnsignedLongLong(message.count),
                        secretKeyPtr)
                }
            }
        }

        if result != 0 {
            return nil
        }

        return signature
    }

    /**
     Verifies a signed message with the sender's public key.

     - Parameter signedMessage: The signed message to verify.
     - Parameter publicKey: The sender's public key.

     - Returns: `true` if verification is successful.
     */
    public func verify(signedMessage: Data, publicKey: PublicKey) -> Bool {
        let signature = signedMessage.subdata(in: 0..<Bytes) as Data
        let message = signedMessage.subdata(in: Bytes..<signedMessage.count) as Data

        return verify(message: message, publicKey: publicKey, signature: signature)
    }

    /**
     Verifies the detached signature of a message with the sender's public key.

     - Parameter message: The message to verify.
     - Parameter publicKey: The sender's public key.
     - Parameter signature: The detached signature to verify.

     - Returns: `true` if verification is successful.
     */
    public func verify(message: Data, publicKey: PublicKey, signature: Data) -> Bool {
        if publicKey.count != PublicKeyBytes {
            return false
        }

        return signature.withUnsafeBytes { signaturePtr in
            message.withUnsafeBytes { messagePtr in
                publicKey.withUnsafeBytes { publicKeyPtr in
                    crypto_sign_verify_detached(
                        signaturePtr,
                        messagePtr, CUnsignedLongLong(message.count), publicKeyPtr) == 0
                }
            }
        }
    }

    /**
     Extracts and returns the message data of a signed message if the signature is verified with the sender's secret key.

     - Parameter signedMessage: The signed message to open.
     - Parameter publicKey: The sender's public key.

     - Returns: The message data if verification is successful.
     */
    public func open(signedMessage: Data, publicKey: PublicKey) -> Data? {
        if publicKey.count != PublicKeyBytes || signedMessage.count < Bytes {
            return nil
        }
        var message = Data(count: signedMessage.count - Bytes)
        var mlen: CUnsignedLongLong = 0

        let result = message.withUnsafeMutableBytes { messagePtr in
            signedMessage.withUnsafeBytes { signedMessagePtr in
                publicKey.withUnsafeBytes { publicKeyPtr in
                    crypto_sign_open(
                        messagePtr, &mlen,
                        signedMessagePtr, CUnsignedLongLong(signedMessage.count),
                        publicKeyPtr)
                }
            }
        }
        if result != 0 {
            return nil
        }
        return message
    }
}
