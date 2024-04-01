//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation

public extension Data {

    init<T>(fromArray values: [T]) {
        let values = values
        let ptrUB = values.withUnsafeBufferPointer { (ptr: UnsafeBufferPointer) in return ptr }
        self.init(buffer: ptrUB)
    }

    func toArray<T>(type: T.Type) throws -> [T] {
        return try self.withUnsafeBytes { (body: UnsafeRawBufferPointer) in
            if let bodyAddress = body.baseAddress, body.count > 0 {
                let pointer = bodyAddress.assumingMemoryBound(to: T.self)
                return [T](UnsafeBufferPointer(start: pointer, count: self.count/MemoryLayout<T>.stride))
            } else {
                throw Web3Error.dataError
            }
        }
    }

    func constantTimeComparisonTo(_ other: Data?) -> Bool {
        guard let rhs = other else {return false}
        guard self.count == rhs.count else {return false}
        var difference = UInt8(0x00)
        for i in 0..<self.count { // compare full length
            difference |= self[i] ^ rhs[i] // constant time
        }
        return difference == UInt8(0x00)
    }

    static func zero(_ data: inout Data) {
        let count = data.count
        data.withUnsafeMutableBytes { (body: UnsafeMutableRawBufferPointer) in
            body.baseAddress?.assumingMemoryBound(to: UInt8.self).initialize(repeating: 0, count: count)
        }
    }

    /**
     Generates an array of random bytes of the specified length.
     This function uses `SecRandomCopyBytes` to generate random bytes returning it as a `Data` object.
     If an error occurs during random bytes generation, the function returns `nil`.
     Error occurs only if `SecRandomCopyBytes` returns status that is not `errSecSuccess`.
     See [all status codes](https://developer.apple.com/documentation/security/1542001-security_framework_result_codes) for possible error reasons.
     Note: in v4 of web3swift this function will be deprecated and a new implementation will be provided that will throw occurred error.
     - Parameter length: The number of random bytes to generate.

     - Returns: optional `Data` object containing the generated random bytes, or `nil` if an error occurred during generation.
     */
    static func randomBytes(length: Int) -> Data? {
        var entropyBytes = [UInt8](repeating: 0, count: length)
        let status = SecRandomCopyBytes(kSecRandomDefault, entropyBytes.count, &entropyBytes)
        guard status == errSecSuccess else {
            return nil
        }
        return Data(entropyBytes)
    }

    func bitsInRange(_ startingBit: Int, _ length: Int) -> UInt64? { // return max of 8 bytes for simplicity, non-public
        if startingBit + length / 8 > self.count, length > 64, startingBit > 0, length >= 1 { return nil }
        let bytes = self[(startingBit/8) ..< (startingBit+length+7)/8]
        let padding = Data(repeating: 0, count: 8 - bytes.count)
        let padded = bytes + padding
        guard padded.count == 8 else { return nil }
        let pointee = padded.withUnsafeBytes { (body: UnsafeRawBufferPointer) in
            body.baseAddress?.assumingMemoryBound(to: UInt64.self).pointee
        }
        guard let ptee = pointee else { return nil }
        var uintRepresentation = UInt64(bigEndian: ptee)
        uintRepresentation = uintRepresentation << (startingBit % 8)
        uintRepresentation = uintRepresentation >> UInt64(64 - length)
        return uintRepresentation
    }
}
