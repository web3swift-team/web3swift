import Foundation
import libsodium

public class SecretBox {
    public let KeyBytes = Int(crypto_secretbox_keybytes())
    public let NonceBytes = Int(crypto_secretbox_noncebytes())
    public let MacBytes = Int(crypto_secretbox_macbytes())

    public typealias Key = Data
    public typealias Nonce = Data
    public typealias MAC = Data

    /**
     Generates a shared secret key.

     - Returns: The generated key.
     */
    public func key() -> Key? {
        var k = Data(count: KeyBytes)
        k.withUnsafeMutableBytes { kPtr in
            crypto_secretbox_keygen(kPtr)
        }
        return k
    }

    /**
     Generates an encryption nonce.

     - Returns: The generated nonce.
     */
    public func nonce() -> Nonce {
        var nonce = Data(count: NonceBytes)
        nonce.withUnsafeMutableBytes { noncePtr in
            randombytes_buf(noncePtr, nonce.count)
        }
        return nonce
    }

    /**
     Encrypts a message with a shared secret key.

     - Parameter message: The message to encrypt.
     - Parameter secretKey: The shared secret key.

     - Returns: A `Data` object containing the nonce and authenticated ciphertext.
     */
    public func seal(message: Data, secretKey: Key) -> Data? {
        guard let (authenticatedCipherText, nonce): (Data, Nonce) = seal(message: message, secretKey: secretKey) else {
            return nil
        }
        var nonceAndAuthenticatedCipherText = nonce
        nonceAndAuthenticatedCipherText.append(authenticatedCipherText)

        return nonceAndAuthenticatedCipherText
    }

    /**
     Encrypts a message with a shared secret key.

     - Parameter message: The message to encrypt.
     - Parameter secretKey: The shared secret key.

     - Returns: The authenticated ciphertext and encryption nonce.
     */
    public func seal(message: Data, secretKey: Key) -> (authenticatedCipherText: Data, nonce: Nonce)? {
        if secretKey.count != KeyBytes {
            return nil
        }
        var authenticatedCipherText = Data(count: message.count + MacBytes)
        let nonce = self.nonce()

        let result = authenticatedCipherText.withUnsafeMutableBytes { authenticatedCipherTextPtr in
            message.withUnsafeBytes { messagePtr in
                nonce.withUnsafeBytes { noncePtr in
                    secretKey.withUnsafeBytes { secretKeyPtr in
                        crypto_secretbox_easy(
                            authenticatedCipherTextPtr,
                            messagePtr, UInt64(message.count),
                            noncePtr, secretKeyPtr)
                    }
                }
            }
        }
        if result != 0 {
            return nil
        }
        return (authenticatedCipherText: authenticatedCipherText, nonce: nonce)
    }

    /**
     Encrypts a message with a shared secret key (detached mode).

     - Parameter message: The message to encrypt.
     - Parameter secretKey: The shared secret key.

     - Returns: The encrypted ciphertext, encryption nonce, and authentication tag.
     */
    public func seal(message: Data, secretKey: Key) -> (cipherText: Data, nonce: Nonce, mac: MAC)? {
        if secretKey.count != KeyBytes {
            return nil
        }
        var cipherText = Data(count: message.count)
        var mac = Data(count: MacBytes)
        let nonce = self.nonce()

        let result = cipherText.withUnsafeMutableBytes { cipherTextPtr in
            mac.withUnsafeMutableBytes { macPtr in
                message.withUnsafeBytes { messagePtr in
                    nonce.withUnsafeBytes { noncePtr in
                        secretKey.withUnsafeBytes { secretKeyPtr in
                            crypto_secretbox_detached(
                                cipherTextPtr, macPtr,
                                messagePtr, UInt64(message.count),
                                noncePtr, secretKeyPtr)
                        }
                    }
                }
            }
        }
        if result != 0 {
            return nil
        }
        return (cipherText: cipherText, nonce: nonce, mac: mac)
    }

    /**
     Decrypts a message with a shared secret key.

     - Parameter nonceAndAuthenticatedCipherText: A `Data` object containing the nonce and authenticated ciphertext.
     - Parameter secretKey: The shared secret key.

     - Returns: The decrypted message.
     */
    public func open(nonceAndAuthenticatedCipherText: Data, secretKey: Key) -> Data? {
        if nonceAndAuthenticatedCipherText.count < MacBytes + NonceBytes {
            return nil
        }
        let nonce = nonceAndAuthenticatedCipherText.subdata(in: 0..<NonceBytes) as Nonce
        let authenticatedCipherText = nonceAndAuthenticatedCipherText.subdata(in: NonceBytes..<nonceAndAuthenticatedCipherText.count)

        return open(authenticatedCipherText: authenticatedCipherText, secretKey: secretKey, nonce: nonce)
    }

    /**
     Decrypts a message with a shared secret key and encryption nonce.

     - Parameter authenticatedCipherText: The authenticated ciphertext.
     - Parameter secretKey: The shared secret key.
     - Parameter nonce: The encryption nonce.

     - Returns: The decrypted message.
     */
    public func open(authenticatedCipherText: Data, secretKey: Key, nonce: Nonce) -> Data? {
        if authenticatedCipherText.count < MacBytes {
            return nil
        }
        var message = Data(count: authenticatedCipherText.count - MacBytes)

        let result = message.withUnsafeMutableBytes { messagePtr in
            authenticatedCipherText.withUnsafeBytes { authenticatedCipherTextPtr in
                nonce.withUnsafeBytes { noncePtr in
                    secretKey.withUnsafeBytes { secretKeyPtr in
                        crypto_secretbox_open_easy(
                            messagePtr,
                            authenticatedCipherTextPtr, UInt64(authenticatedCipherText.count),
                            noncePtr, secretKeyPtr)
                    }
                }
            }
        }
        if result != 0 {
            return nil
        }
        return message
    }

    /**
     Decrypts a message with a shared secret key, encryption nonce, and authentication tag.

     - Parameter cipherText: The encrypted ciphertext.
     - Parameter secretKey: The shared secret key.
     - Parameter nonce: The encryption nonce.

     - Returns: The decrypted message.
     */
    public func open(cipherText: Data, secretKey: Key, nonce: Nonce, mac: MAC) -> Data? {
        if nonce.count != NonceBytes || mac.count != MacBytes {
            return nil
        }
        if secretKey.count != KeyBytes {
            return nil
        }
        var message = Data(count: cipherText.count)

        let result = message.withUnsafeMutableBytes { messagePtr in
            cipherText.withUnsafeBytes { cipherTextPtr in
                mac.withUnsafeBytes { macPtr in
                    nonce.withUnsafeBytes { noncePtr in
                        secretKey.withUnsafeBytes { secretKeyPtr in
                            crypto_secretbox_open_detached(
                                messagePtr,
                                cipherTextPtr, macPtr, UInt64(cipherText.count),
                                noncePtr, secretKeyPtr)
                        }
                    }
                }
            }
        }
        if result != 0 {
            return nil
        }
        return message
    }
}
