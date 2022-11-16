//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import Metal

extension Data {
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

    public static func zero(_ data: inout Data) {
        let count = data.count
        data.withUnsafeMutableBytes { (body: UnsafeMutableRawBufferPointer) in
            body.baseAddress?.assumingMemoryBound(to: UInt8.self).initialize(repeating: 0, count: count)
        }
    }

    public static func randomBytes(length: Int) -> Data? {
        let entropy_bit_size = length//128
        //# valid_entropy_bit_sizes = [128, 160, 192, 224, 256], count: [12, 15, 18, 21, 24]
        var entropy_bytes = [UInt8](repeating: 0, count: entropy_bit_size)// / 8)
        let status = SecRandomCopyBytes(kSecRandomDefault, entropy_bytes.count, &entropy_bytes)

        if status != errSecSuccess { // Always test the status.
        } else {
            entropy_bytes = [UInt8](repeating: 0, count: entropy_bit_size)// / 8)
            arc4random_buf(&entropy_bytes, entropy_bytes.count)
        }

        let source1 = MTLCreateSystemDefaultDevice()?.makeBuffer(length: length)?.hash.description.data(using: .utf8)

        let entropyData = entropy_bytes.shuffled().map{ bit in
            return bit ^ (source1?.randomElement() ?? 0)
        }
        return Data(entropyData)
    }

    public func bitsInRange(_ startingBit: Int, _ length: Int) -> UInt64? { // return max of 8 bytes for simplicity, non-public
        if startingBit + length / 8 > self.count, length > 64, startingBit > 0, length >= 1 {return nil}
        let bytes = self[(startingBit/8) ..< (startingBit+length+7)/8]
        let padding = Data(repeating: 0, count: 8 - bytes.count)
        let padded = bytes + padding
        guard padded.count == 8 else {return nil}
        let pointee = padded.withUnsafeBytes { (body: UnsafeRawBufferPointer) in
            body.baseAddress?.assumingMemoryBound(to: UInt64.self).pointee
        }
        guard let ptee = pointee else {return nil}
        var uintRepresentation = UInt64(bigEndian: ptee)
        uintRepresentation = uintRepresentation << (startingBit % 8)
        uintRepresentation = uintRepresentation >> UInt64(64 - length)
        return uintRepresentation
    }
}
