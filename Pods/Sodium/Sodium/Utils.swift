import Foundation
import libsodium

public class Utils {
    /**
     Tries to effectively zero bytes in `data`, even if optimizations are being applied to the code.

     - Parameter data: The `Data` object to zero.
     */
    public func zero(_ data: inout Data)  {
        let count = data.count
        data.withUnsafeMutableBytes { (dataPtr: UnsafeMutablePointer<UInt8>) in
            let rawPtr = UnsafeMutableRawPointer(dataPtr)
            sodium_memzero(rawPtr, count)
        }
    }

    /**
     Checks that two `Data` objects have the same content, without leaking information
     about the actual content of these objects.

     - Parameter b1: first object
     - Parameter b2: second object

     - Returns: `true` if the bytes in `b1` match the bytes in `b2`. Otherwise, it returns false.
     */
    public func equals(_ b1: Data, _ b2: Data) -> Bool {
        if b1.count != b2.count {
            return false
        }
        return b1.withUnsafeBytes { b1Ptr in
            b2.withUnsafeBytes { b2Ptr in
                Int(sodium_memcmp(
                    UnsafeRawPointer(b1Ptr), UnsafeRawPointer(b2Ptr), b1.count)) == 0
            }
        }
    }

    /**
     Compares two `Data` objects without leaking information about the content of these objects.

     - Returns: `0` if the bytes in `b1` match the bytes in `b2`.
     `-1` if `b2` is less than `b1` (considered as little-endian values) and
     `1`  if `b1` is less than `b2` (considered as little-endian values)
     */
    public func compare(_ b1: Data, _ b2: Data) -> Int? {
        if b1.count != b2.count {
            return nil
        }
        return b1.withUnsafeBytes { b1Ptr in
            b2.withUnsafeBytes { b2Ptr in
                Int(sodium_compare(
                    b1Ptr, b2Ptr, b1.count))
            }
        }
    }

    /**
     Converts bytes stored in `bin` into a hexadecimal string.

     - Parameter bin: The data to encode as hexdecimal.

     - Returns: The encoded hexdecimal string.
     */
    public func bin2hex(_ bin: Data) -> String? {
        var hexData = Data(count: bin.count * 2 + 1)

        return hexData.withUnsafeMutableBytes { (hexPtr: UnsafeMutablePointer<Int8>) -> String? in
            bin.withUnsafeBytes { (binPtr: UnsafePointer<UInt8>) -> String? in
                if sodium_bin2hex(hexPtr, hexData.count, binPtr, bin.count) == nil {
                    return nil
                }
                return String.init(validatingUTF8: hexPtr)
            }
        }
    }

    /**
     Decodes a hexdecimal string, ignoring characters included for readability.

     - Parameter hex: The hexdecimal string to decode.
     - Parameter ignore: Optional string containing readability characters to ignore during decoding.

     - Returns: The decoded data.
     */
    public func hex2bin(_ hex: String, ignore: String? = nil) -> Data? {
        guard let hexData = hex.data(using: .utf8, allowLossyConversion: false) else {
            return nil
        }
        let hexDataLen = hexData.count
        let binDataCapacity = hexDataLen / 2
        var binData = Data(count: binDataCapacity)
        var binDataLen: size_t = 0
        let ignore_cstr = ignore != nil ? (ignore! as NSString).utf8String : nil

        let result = binData.withUnsafeMutableBytes { binPtr in
            hexData.withUnsafeBytes { hexPtr in
                sodium_hex2bin(binPtr, binDataCapacity,
                               hexPtr, hexDataLen,
                               ignore_cstr, &binDataLen, nil)
            }
        }
        if result != 0 {
            return nil
        }
        binData.count = Int(binDataLen)

        return binData
    }

    public enum Base64Variant: CInt {
        case ORIGINAL            = 1
        case ORIGINAL_NO_PADDING = 3
        case URLSAFE             = 5
        case URLSAFE_NO_PADDING  = 7
    }

    /**
     Converts bytes stored in `bin` into a Base64 representation.

     - Parameter bin: The data to encode as Base64.
     - Parameter variant: the Base64 variant to use. By default: URLSAFE.

     - Returns: The encoded base64 string.
     */
    public func bin2base64(_ bin: Data, variant: Base64Variant = .URLSAFE) -> String? {
        var b64Data = Data(count: sodium_base64_encoded_len(bin.count, variant.rawValue))

        return b64Data.withUnsafeMutableBytes { (b64Ptr: UnsafeMutablePointer<Int8>) -> String? in
            bin.withUnsafeBytes { (binPtr: UnsafePointer<UInt8>) -> String? in
                if sodium_bin2base64(b64Ptr, b64Data.count, binPtr, bin.count, variant.rawValue) == nil {
                    return nil
                }
                return String.init(validatingUTF8: b64Ptr)
            }
        }
    }

    /*
     Decodes a Base64 string, ignoring characters included for readability.

     - Parameter b64: The Base64 string to decode.
     - Parameter ignore: Optional string containing readability characters to ignore during decoding.

     - Returns: The decoded data.
     */
    public func base642bin(_ b64: String, variant: Base64Variant = .URLSAFE, ignore: String? = nil) -> Data? {
        guard let b64Data = b64.data(using: .utf8, allowLossyConversion: false) else {
            return nil
        }
        let b64DataLen = b64Data.count
        let binDataCapacity = b64DataLen * 3 / 4
        var binData = Data(count: binDataCapacity)
        var binDataLen: size_t = 0
        let ignore_cstr = ignore != nil ? (ignore! as NSString).utf8String : nil

        let result = binData.withUnsafeMutableBytes { binPtr in
            b64Data.withUnsafeBytes { b64Ptr in
                sodium_base642bin(binPtr, binDataCapacity,
                                  b64Ptr, b64DataLen,
                                  ignore_cstr, &binDataLen, nil, variant.rawValue)
            }
        }
        if  result != 0 {
            return nil
        }
        binData.count = Int(binDataLen)

        return binData
    }

    /*
     Adds padding to `data` so that its length becomes a multiple of `blockSize`

     - Parameter data: input/output buffer, will be modified in-place
     - Parameter blocksize: the block size
     */
    public func pad(data: inout Data, blockSize: Int) -> ()? {
        let dataCount = data.count
        data.reserveCapacity(dataCount + blockSize)
        data.count = dataCount + blockSize
        var paddedLen: size_t = 0
        let result = data.withUnsafeMutableBytes { dataPtr in
            sodium_pad(&paddedLen, dataPtr, dataCount, blockSize, dataCount + blockSize)
        }
        if result != 0 {
            return nil
        }
        data.count = Int(paddedLen)

        return ()
    }

    /*
     Removes padding from `data` to restore its original size

     - Parameter data: input/output buffer, will be modified in-place
     - Parameter blocksize: the block size
     */
    public func unpad(data: inout Data, blockSize: Int) -> ()? {
        var unpaddedLen: size_t = 0
        let result = data.withUnsafeMutableBytes { dataPtr in
            sodium_unpad(&unpaddedLen, dataPtr, data.count, blockSize)
        }
        if result != 0 {
            return nil
        }
        data.count = Int(unpaddedLen)

        return ()
    }
}
