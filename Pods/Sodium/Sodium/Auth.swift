import Foundation
import libsodium

public class Auth {
    public let KeyBytes = Int(crypto_auth_keybytes())
    public let Bytes = Int(crypto_auth_bytes())

    public typealias SecretKey = Data

    /**
     Generates a key to compute authentication tags.

     - Returns: The generated key.
     */
    public func key() -> SecretKey? {
        var secretKey = Data(count: KeyBytes)
        secretKey.withUnsafeMutableBytes { secretKeyPtr in
            crypto_auth_keygen(secretKeyPtr)
        }
        return secretKey
    }

    /**
     Computes an authentication tag for a message using a key

     - Parameter message: The message to authenticate.
     - Parameter secretKey: The key required to create and verify messages.

     - Returns: The computed authentication tag.
     */
    public func tag(message: Data, secretKey: SecretKey) -> Data? {
        if secretKey.count != KeyBytes {
            return nil
        }

        var tag = Data(count: Bytes)
        let result = tag.withUnsafeMutableBytes { tagPtr in
            message.withUnsafeBytes { messagePtr in
                secretKey.withUnsafeBytes { secretKeyPtr in
                    crypto_auth( tagPtr,
                                 messagePtr, CUnsignedLongLong(message.count),
                                 secretKeyPtr)
                }
            }
        }
        if result != 0 {
            return nil
        }
        return tag
    }

    /**
     Verifies that an authentication tag is valid for a message and a key

     - Parameter message: The message to verify.
     - Parameter secretKey: The key required to create and verify messages.
     - Parameter tag: The authentication tag.

     - Returns: `true` if the verification is successful.
     */
    public func verify(message: Data, secretKey: SecretKey, tag: Data) -> Bool {
        if secretKey.count != KeyBytes {
            return false
        }
        return tag.withUnsafeBytes { tagPtr in
            message.withUnsafeBytes { messagePtr in
                secretKey.withUnsafeBytes { secretKeyPtr in
                    crypto_auth_verify(
                        tagPtr,
                        messagePtr, CUnsignedLongLong(message.count), secretKeyPtr) == 0
                }
            }
        }
    }
}
