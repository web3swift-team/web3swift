import Foundation
import libsodium

public class KeyDerivation {
    public let BytesMin = Int(crypto_kdf_bytes_min())
    public let BytesMax = Int(crypto_kdf_bytes_max())
    public let KeyBytes = Int(crypto_kdf_keybytes())
    public let ContextBytes = Int(crypto_kdf_contextbytes())

    public typealias Key = Data
    public typealias SubKey = Data

    /**
     Generates a secret key.

     - Returns: The generated key.
     */
    public func key() -> Key? {
        var k = Data(count: KeyBytes)
        k.withUnsafeMutableBytes { kPtr in
            crypto_kdf_keygen(kPtr)
        }
        return k
    }

    /**
     Derives a subkey from the specified input key. Each index (from 0 to (2^64) - 1) yields a unique deterministic subkey.
     The sequence of subkeys is likely unique for a given context.

     - Parameter secretKey: the master key from which to derive the subkey (must be KeyBytes bytes)
     - Parameter index: the index of the subkey to generate (allowed range: 0 to (2^64) - 1)
     - Parameter length: the desired length of the subkey in bytes (allowed range: BytesMin to BytesMax)
     - Parameter context: a String that identifies the context; use a different value for different types of keys (should be exactly 8 characters long but must be no longer than 8 characters)

     - Returns: the derived key or nil on error.

     - Note: Output keys must have a length between BytesMin and BytesMax bytes (inclusive), otherwise an error is returned. Context must be at most 8 characters long. If the specified context is shorter than 8 characters, it will be padded to 8 characters. The master key is KeyBytes long.
     */
    public func derive(secretKey: Data, index: UInt64, length: Int, context: String) -> Data? {
        if length < BytesMin || length > BytesMax {
            return nil
        }
        if secretKey.count != KeyBytes {
            return nil
        }
        var contextBin = context.data(using: String.Encoding.utf8)!
        if contextBin.count > ContextBytes {
            return nil
        }
        while contextBin.count < ContextBytes {
            contextBin += [0]
        }

        var output = Data(count: length)

        let result = output.withUnsafeMutableBytes { outputPtr in
            secretKey.withUnsafeBytes { secretKeyPtr in
                contextBin.withUnsafeBytes { contextBinPtr in
                    crypto_kdf_derive_from_key(outputPtr, length, index, contextBinPtr, secretKeyPtr)
                }
            }
        }
        if result != 0 {
            return nil
        }
        return output
    }
}
