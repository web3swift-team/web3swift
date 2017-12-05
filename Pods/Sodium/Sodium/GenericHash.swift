import Foundation
import libsodium

public class GenericHash {
    public let BytesMin = Int(crypto_generichash_bytes_min())
    public let BytesMax = Int(crypto_generichash_bytes_max())
    public let Bytes = Int(crypto_generichash_bytes())
    public let KeyBytesMin = Int(crypto_generichash_keybytes_min())
    public let KeyBytesMax = Int(crypto_generichash_keybytes_max())
    public let KeyBytes = Int(crypto_generichash_keybytes())
    public let Primitive = String.init(validatingUTF8: crypto_generichash_primitive())

    public typealias Key = Data

    /**
     Generates a secret key.

     - Returns: The generated key.
     */
    public func key() -> Key? {
        var k = Data(count: KeyBytes)
        k.withUnsafeMutableBytes { kPtr in
            crypto_generichash_keygen(kPtr)
        }
        return k
    }

    /**
     Computes a fixed-length fingerprint for an arbitrary long message. A key can also be specified. A message will always have the same fingerprint for a given key, but different keys used to hash the same message are very likely to produce distinct fingerprints.

     - Parameter message: The message from which to compute the fingerprint.
     - Parameter key: Optional key to use while computing the fingerprint.

     - Returns: The computed fingerprint.
     */
    public func hash(message: Data, key: Data? = nil) -> Data? {
        return hash(message: message, key: key, outputLength: Bytes)
    }

    /**
     Computes a fixed-length fingerprint for an arbitrary long message. A message will always have the same fingerprint for a given key, but different keys used to hash the same message are very likely to produce distinct fingerprints.

     - Parameter message: The message from which to compute the fingerprint.
     - Parameter key: The key to use while computing the fingerprint.
     - Parameter outputLength: Desired length of the computed fingerprint.

     - Returns: The computed fingerprint.
     */
    public func hash(message: Data, key: Data?, outputLength: Int) -> Data? {
        var output = Data(count: outputLength)
        var result: Int32 = -1

        if let key = key {
            result = output.withUnsafeMutableBytes { outputPtr in
                message.withUnsafeBytes { messagePtr in
                    key.withUnsafeBytes { keyPtr in
                        crypto_generichash(
                            outputPtr, output.count,
                            messagePtr, CUnsignedLongLong(message.count),
                            keyPtr, key.count)
                    }
                }
            }
        } else {
            result = output.withUnsafeMutableBytes { outputPtr in
                message.withUnsafeBytes { messagePtr in
                    crypto_generichash(
                        outputPtr, output.count,
                        messagePtr, CUnsignedLongLong(message.count),
                        nil, 0)
                }
            }
        }
        if result != 0 {
            return nil
        }
        return output
    }

    /**
     Computes a fixed-length fingerprint for an arbitrary long message.

     - Parameter message: The message from which to compute the fingerprint.
     - Parameter outputLength: Desired length of the computed fingerprint.

     - Returns: The computed fingerprint.
     */
    public func hash(message: Data, outputLength: Int) -> Data? {
        return hash(message: message, key: nil, outputLength: outputLength)
    }

    /**
     Initializes a `Stream` object to compute a fixed-length fingerprint for an incoming stream of data.arbitrary long message. Particular data will always have the same fingerprint for a given key, but different keys used to hash the same data are very likely to produce distinct fingerprints.

     - Parameter key: Optional key to use while computing the fingerprint.

     - Returns: The initialized `Stream`.
     */
    public func initStream(key: Data? = nil) -> Stream? {
        return Stream(key: key, outputLength: Bytes)
    }

    /**
     Initializes a `Stream` object to compute a fixed-length fingerprint for an incoming stream of data.arbitrary long message. Particular data will always have the same fingerprint for a given key, but different keys used to hash the same data are very likely to produce distinct fingerprints.

     - Parameter key: Optional key to use while computing the fingerprint.
     - Parameter outputLength: Desired length of the computed fingerprint.

     - Returns: The initialized `Stream`.
     */
    public func initStream(key: Data?, outputLength: Int) -> Stream? {
        return Stream(key: key, outputLength: outputLength)
    }

    /**
     Initializes a `Stream` object to compute a fixed-length fingerprint for an incoming stream of data.arbitrary long message.

     - Parameter: outputLength: Desired length of the computed fingerprint.

     - Returns: The initialized `Stream`.
     */
    public func initStream(outputLength: Int) -> Stream? {
        return Stream(key: nil, outputLength: outputLength)
    }

    public class Stream {
        public var outputLength: Int = 0
        private var state: UnsafeMutablePointer<crypto_generichash_state>?

        init?(key: Data?, outputLength: Int) {
            let rawState = UnsafeMutablePointer<UInt8>.allocate(capacity: crypto_generichash_statebytes())
            state = UnsafeMutableRawPointer(rawState).bindMemory(to: crypto_generichash_state.self, capacity: 1)
            guard let state = state else {
                return nil
            }
            var result: Int32 = -1
            if let key = key {
                result = key.withUnsafeBytes { keyPtr in
                    crypto_generichash_init(state, keyPtr, key.count, outputLength)
                }
            } else {
                result = crypto_generichash_init(state, nil, 0, outputLength)
            }
            if result != 0 {
                free()
                return nil
            }
            self.outputLength = outputLength
        }

        private func free() {
            guard let state = state else {
                return
            }
            let rawState = UnsafeMutableRawPointer(state).bindMemory(to: UInt8.self, capacity: crypto_generichash_statebytes())
            rawState.deallocate(capacity: 1)
            self.state = nil
        }

        deinit {
            free()
        }

        /**
         Updates the hash stream with incoming data to contribute to the computed fingerprint.

         - Parameter input: The incoming stream data.

         - Returns: `true` if the data was consumed successfully.
         */
        public func update(input: Data) -> Bool {
            return input.withUnsafeBytes { inputPtr in
                crypto_generichash_update(state!, inputPtr, CUnsignedLongLong(input.count)) == 0
            }
        }

        /**
         Signals that the incoming stream of data is complete and triggers computation of the resulting fingerprint.

         - Returns: The computed fingerprint.
         */
        public func final() -> Data? {
            var output = Data(count: outputLength)
            let result = output.withUnsafeMutableBytes { outputPtr in
                crypto_generichash_final(state!, outputPtr, output.count)
            }
            if result != 0 {
                return nil
            }
            return output
        }
    }
}
