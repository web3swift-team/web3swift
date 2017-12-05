import Foundation
import libsodium

public class Stream {
    public let KeyBytes = Int(crypto_secretbox_keybytes())
    public let NonceBytes = Int(crypto_secretbox_noncebytes())
    public let Primitive = String.init(validatingUTF8: crypto_stream_primitive())

    public typealias Key = Data
    public typealias Nonce = Data

    /**
     Generates a secret key.

     - Returns: The generated key.
     */
    public func key() -> Key? {
        var k = Data(count: KeyBytes)
        k.withUnsafeMutableBytes { kPtr in
            crypto_stream_keygen(kPtr)
        }
        return k
    }

    /**
     Generates a random nonce.

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
     XOR the input with a key stream derived from a secret key and a nonce.
     Applying the same operation twice outputs the original input.
     No authentication tag is added to the output. The data can be tampered with; an adversary can flip arbitrary bits.
     In order to encrypt data using a secret key, the SecretBox class is likely to be what you are looking for.
     In order to generate a deterministic stream out of a seed, the RandomBytes.deterministic_rand() function is likely to be what you need.

     - Parameter input: Input data
     - Parameter nonce: Nonce
     - Parameter secretKey: The secret key

     -  Returns: input XOR keystream(secretKey, nonce)
     */
    public func xor(input: Data, nonce: Nonce, secretKey: Key) -> Data? {
        if secretKey.count != KeyBytes || nonce.count != NonceBytes {
            return nil
        }
        var output = Data(count: input.count)
        let result = output.withUnsafeMutableBytes { outputPtr in
            input.withUnsafeBytes { inputPtr in
                nonce.withUnsafeBytes { noncePtr in
                    secretKey.withUnsafeBytes { secretKeyPtr in
                        crypto_stream_xor(outputPtr, inputPtr, UInt64(input.count), noncePtr, secretKeyPtr)
                    }
                }
            }
        }
        if result != 0 {
            return nil
        }
        return output
    }

    /**
     XOR the input with a key stream derived from a secret key and a random nonce.
     Applying the same operation twice outputs the original input.
     No authentication tag is added to the output. The data can be tampered with; an adversary can flip arbitrary bits.
     In order to encrypt data using a secret key, the SecretBox class is likely to be what you are looking for.
     In order to generate a deterministic stream out of a seed, the RandomBytes.deterministic_rand() function is likely to be what you need.

     - Parameter input: Input data
     - Parameter nonce: Nonce
     - Parameter secretKey: The secret key

     -  Returns: (input XOR keystream(secretKey, nonce), nonce)
     */
    public func xor(input: Data, secretKey: Key) -> (output:Data, nonce: Nonce)? {
        let nonce = self.nonce()
        guard let output: Data = xor(input: input, nonce: nonce, secretKey: secretKey) else {
            return nil
        }
        return (output: output, nonce: nonce)
    }
}
