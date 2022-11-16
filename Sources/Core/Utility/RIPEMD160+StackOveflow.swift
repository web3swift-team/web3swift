//
//  RIPEMD160_SO.swift
//
//  Created by Alexander Vlasov on 10.01.2018.
//

// From https://stackoverflow.com/questions/43091858/swift-hash-a-string-using-hash-hmac-with-ripemd160/43191938

import Foundation

public struct RIPEMD160 {

    private var MDbuf: (UInt32, UInt32, UInt32, UInt32, UInt32)
    private var buffer: Data
    private var count: Int64 // Total # of bytes processed.

    public init() {
        MDbuf = (0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476, 0xc3d2e1f0)
        buffer = Data()
        count = 0
    }

    private mutating func compress(_ X: UnsafePointer<UInt32>) {

        // *** Helper functions (originally macros in rmd160.h) ***

        /* ROL(x, n) cyclically rotates x over n bits to the left */
        /* x must be of an unsigned 32 bits type and 0 <= n < 32. */
        func ROL(_ x: UInt32, _ n: UInt32) -> UInt32 {
            return (x << n) | (x >> (32 - n))
        }

        /* the five basic functions F(), G() and H() */

        func F(_ x: UInt32, _ y: UInt32, _ z: UInt32) -> UInt32 {
            return x ^ y ^ z
        }

        func G(_ x: UInt32, _ y: UInt32, _ z: UInt32) -> UInt32 {
            return (x & y) | (~x & z)
        }

        func H(_ x: UInt32, _ y: UInt32, _ z: UInt32) -> UInt32 {
            return (x | ~y) ^ z
        }

        func I(_ x: UInt32, _ y: UInt32, _ z: UInt32) -> UInt32 {
            return (x & z) | (y & ~z)
        }

        func J(_ x: UInt32, _ y: UInt32, _ z: UInt32) -> UInt32 {
            return x ^ (y | ~z)
        }

        /* the ten basic operations FF() through III() */

        func FF(_ a: inout UInt32, _ b: UInt32, _ c: inout UInt32, _ d: UInt32, _ e: UInt32, _ x: UInt32, _ s: UInt32) {
            a = a &+ F(b, c, d) &+ x
            a = ROL(a, s) &+ e
            c = ROL(c, 10)
        }

        func GG(_ a: inout UInt32, _ b: UInt32, _ c: inout UInt32, _ d: UInt32, _ e: UInt32, _ x: UInt32, _ s: UInt32) {
            a = a &+ G(b, c, d) &+ x &+ 0x5a827999
            a = ROL(a, s) &+ e
            c = ROL(c, 10)
        }

        func HH(_ a: inout UInt32, _ b: UInt32, _ c: inout UInt32, _ d: UInt32, _ e: UInt32, _ x: UInt32, _ s: UInt32) {
            a = a &+ H(b, c, d) &+ x &+ 0x6ed9eba1
            a = ROL(a, s) &+ e
            c = ROL(c, 10)
        }

        func II(_ a: inout UInt32, _ b: UInt32, _ c: inout UInt32, _ d: UInt32, _ e: UInt32, _ x: UInt32, _ s: UInt32) {
            a = a &+ I(b, c, d) &+ x &+ 0x8f1bbcdc
            a = ROL(a, s) &+ e
            c = ROL(c, 10)
        }

        func JJ(_ a: inout UInt32, _ b: UInt32, _ c: inout UInt32, _ d: UInt32, _ e: UInt32, _ x: UInt32, _ s: UInt32) {
            a = a &+ J(b, c, d) &+ x &+ 0xa953fd4e
            a = ROL(a, s) &+ e
            c = ROL(c, 10)
        }

        func FFF(_ a: inout UInt32, _ b: UInt32, _ c: inout UInt32, _ d: UInt32, _ e: UInt32, _ x: UInt32, _ s: UInt32) {
            a = a &+ F(b, c, d) &+ x
            a = ROL(a, s) &+ e
            c = ROL(c, 10)
        }

        func GGG(_ a: inout UInt32, _ b: UInt32, _ c: inout UInt32, _ d: UInt32, _ e: UInt32, _ x: UInt32, _ s: UInt32) {
            a = a &+ G(b, c, d) &+ x &+ 0x7a6d76e9
            a = ROL(a, s) &+ e
            c = ROL(c, 10)
        }

        func HHH(_ a: inout UInt32, _ b: UInt32, _ c: inout UInt32, _ d: UInt32, _ e: UInt32, _ x: UInt32, _ s: UInt32) {
            a = a &+ H(b, c, d) &+ x &+ 0x6d703ef3
            a = ROL(a, s) &+ e
            c = ROL(c, 10)
        }

        func III(_ a: inout UInt32, _ b: UInt32, _ c: inout UInt32, _ d: UInt32, _ e: UInt32, _ x: UInt32, _ s: UInt32) {
            a = a &+ I(b, c, d) &+ x &+ 0x5c4dd124
            a = ROL(a, s) &+ e
            c = ROL(c, 10)
        }

        func JJJ(_ a: inout UInt32, _ b: UInt32, _ c: inout UInt32, _ d: UInt32, _ e: UInt32, _ x: UInt32, _ s: UInt32) {
            a = a &+ J(b, c, d) &+ x &+ 0x50a28be6
            a = ROL(a, s) &+ e
            c = ROL(c, 10)
        }

        // *** The function starts here ***

        var (aa, bb, cc, dd, ee) = MDbuf
        var (aaa, bbb, ccc, ddd, eee) = MDbuf

        /* round 1 */
        FF(&aa, bb, &cc, dd, ee, X[ 0], 11)
        FF(&ee, aa, &bb, cc, dd, X[ 1], 14)
        FF(&dd, ee, &aa, bb, cc, X[ 2], 15)
        FF(&cc, dd, &ee, aa, bb, X[ 3], 12)
        FF(&bb, cc, &dd, ee, aa, X[ 4], 5)
        FF(&aa, bb, &cc, dd, ee, X[ 5], 8)
        FF(&ee, aa, &bb, cc, dd, X[ 6], 7)
        FF(&dd, ee, &aa, bb, cc, X[ 7], 9)
        FF(&cc, dd, &ee, aa, bb, X[ 8], 11)
        FF(&bb, cc, &dd, ee, aa, X[ 9], 13)
        FF(&aa, bb, &cc, dd, ee, X[10], 14)
        FF(&ee, aa, &bb, cc, dd, X[11], 15)
        FF(&dd, ee, &aa, bb, cc, X[12], 6)
        FF(&cc, dd, &ee, aa, bb, X[13], 7)
        FF(&bb, cc, &dd, ee, aa, X[14], 9)
        FF(&aa, bb, &cc, dd, ee, X[15], 8)

        /* round 2 */
        GG(&ee, aa, &bb, cc, dd, X[ 7], 7)
        GG(&dd, ee, &aa, bb, cc, X[ 4], 6)
        GG(&cc, dd, &ee, aa, bb, X[13], 8)
        GG(&bb, cc, &dd, ee, aa, X[ 1], 13)
        GG(&aa, bb, &cc, dd, ee, X[10], 11)
        GG(&ee, aa, &bb, cc, dd, X[ 6], 9)
        GG(&dd, ee, &aa, bb, cc, X[15], 7)
        GG(&cc, dd, &ee, aa, bb, X[ 3], 15)
        GG(&bb, cc, &dd, ee, aa, X[12], 7)
        GG(&aa, bb, &cc, dd, ee, X[ 0], 12)
        GG(&ee, aa, &bb, cc, dd, X[ 9], 15)
        GG(&dd, ee, &aa, bb, cc, X[ 5], 9)
        GG(&cc, dd, &ee, aa, bb, X[ 2], 11)
        GG(&bb, cc, &dd, ee, aa, X[14], 7)
        GG(&aa, bb, &cc, dd, ee, X[11], 13)
        GG(&ee, aa, &bb, cc, dd, X[ 8], 12)

        /* round 3 */
        HH(&dd, ee, &aa, bb, cc, X[ 3], 11)
        HH(&cc, dd, &ee, aa, bb, X[10], 13)
        HH(&bb, cc, &dd, ee, aa, X[14], 6)
        HH(&aa, bb, &cc, dd, ee, X[ 4], 7)
        HH(&ee, aa, &bb, cc, dd, X[ 9], 14)
        HH(&dd, ee, &aa, bb, cc, X[15], 9)
        HH(&cc, dd, &ee, aa, bb, X[ 8], 13)
        HH(&bb, cc, &dd, ee, aa, X[ 1], 15)
        HH(&aa, bb, &cc, dd, ee, X[ 2], 14)
        HH(&ee, aa, &bb, cc, dd, X[ 7], 8)
        HH(&dd, ee, &aa, bb, cc, X[ 0], 13)
        HH(&cc, dd, &ee, aa, bb, X[ 6], 6)
        HH(&bb, cc, &dd, ee, aa, X[13], 5)
        HH(&aa, bb, &cc, dd, ee, X[11], 12)
        HH(&ee, aa, &bb, cc, dd, X[ 5], 7)
        HH(&dd, ee, &aa, bb, cc, X[12], 5)

        /* round 4 */
        II(&cc, dd, &ee, aa, bb, X[ 1], 11)
        II(&bb, cc, &dd, ee, aa, X[ 9], 12)
        II(&aa, bb, &cc, dd, ee, X[11], 14)
        II(&ee, aa, &bb, cc, dd, X[10], 15)
        II(&dd, ee, &aa, bb, cc, X[ 0], 14)
        II(&cc, dd, &ee, aa, bb, X[ 8], 15)
        II(&bb, cc, &dd, ee, aa, X[12], 9)
        II(&aa, bb, &cc, dd, ee, X[ 4], 8)
        II(&ee, aa, &bb, cc, dd, X[13], 9)
        II(&dd, ee, &aa, bb, cc, X[ 3], 14)
        II(&cc, dd, &ee, aa, bb, X[ 7], 5)
        II(&bb, cc, &dd, ee, aa, X[15], 6)
        II(&aa, bb, &cc, dd, ee, X[14], 8)
        II(&ee, aa, &bb, cc, dd, X[ 5], 6)
        II(&dd, ee, &aa, bb, cc, X[ 6], 5)
        II(&cc, dd, &ee, aa, bb, X[ 2], 12)

        /* round 5 */
        JJ(&bb, cc, &dd, ee, aa, X[ 4], 9)
        JJ(&aa, bb, &cc, dd, ee, X[ 0], 15)
        JJ(&ee, aa, &bb, cc, dd, X[ 5], 5)
        JJ(&dd, ee, &aa, bb, cc, X[ 9], 11)
        JJ(&cc, dd, &ee, aa, bb, X[ 7], 6)
        JJ(&bb, cc, &dd, ee, aa, X[12], 8)
        JJ(&aa, bb, &cc, dd, ee, X[ 2], 13)
        JJ(&ee, aa, &bb, cc, dd, X[10], 12)
        JJ(&dd, ee, &aa, bb, cc, X[14], 5)
        JJ(&cc, dd, &ee, aa, bb, X[ 1], 12)
        JJ(&bb, cc, &dd, ee, aa, X[ 3], 13)
        JJ(&aa, bb, &cc, dd, ee, X[ 8], 14)
        JJ(&ee, aa, &bb, cc, dd, X[11], 11)
        JJ(&dd, ee, &aa, bb, cc, X[ 6], 8)
        JJ(&cc, dd, &ee, aa, bb, X[15], 5)
        JJ(&bb, cc, &dd, ee, aa, X[13], 6)

        /* parallel round 1 */
        JJJ(&aaa, bbb, &ccc, ddd, eee, X[ 5], 8)
        JJJ(&eee, aaa, &bbb, ccc, ddd, X[14], 9)
        JJJ(&ddd, eee, &aaa, bbb, ccc, X[ 7], 9)
        JJJ(&ccc, ddd, &eee, aaa, bbb, X[ 0], 11)
        JJJ(&bbb, ccc, &ddd, eee, aaa, X[ 9], 13)
        JJJ(&aaa, bbb, &ccc, ddd, eee, X[ 2], 15)
        JJJ(&eee, aaa, &bbb, ccc, ddd, X[11], 15)
        JJJ(&ddd, eee, &aaa, bbb, ccc, X[ 4], 5)
        JJJ(&ccc, ddd, &eee, aaa, bbb, X[13], 7)
        JJJ(&bbb, ccc, &ddd, eee, aaa, X[ 6], 7)
        JJJ(&aaa, bbb, &ccc, ddd, eee, X[15], 8)
        JJJ(&eee, aaa, &bbb, ccc, ddd, X[ 8], 11)
        JJJ(&ddd, eee, &aaa, bbb, ccc, X[ 1], 14)
        JJJ(&ccc, ddd, &eee, aaa, bbb, X[10], 14)
        JJJ(&bbb, ccc, &ddd, eee, aaa, X[ 3], 12)
        JJJ(&aaa, bbb, &ccc, ddd, eee, X[12], 6)

        /* parallel round 2 */
        III(&eee, aaa, &bbb, ccc, ddd, X[ 6], 9)
        III(&ddd, eee, &aaa, bbb, ccc, X[11], 13)
        III(&ccc, ddd, &eee, aaa, bbb, X[ 3], 15)
        III(&bbb, ccc, &ddd, eee, aaa, X[ 7], 7)
        III(&aaa, bbb, &ccc, ddd, eee, X[ 0], 12)
        III(&eee, aaa, &bbb, ccc, ddd, X[13], 8)
        III(&ddd, eee, &aaa, bbb, ccc, X[ 5], 9)
        III(&ccc, ddd, &eee, aaa, bbb, X[10], 11)
        III(&bbb, ccc, &ddd, eee, aaa, X[14], 7)
        III(&aaa, bbb, &ccc, ddd, eee, X[15], 7)
        III(&eee, aaa, &bbb, ccc, ddd, X[ 8], 12)
        III(&ddd, eee, &aaa, bbb, ccc, X[12], 7)
        III(&ccc, ddd, &eee, aaa, bbb, X[ 4], 6)
        III(&bbb, ccc, &ddd, eee, aaa, X[ 9], 15)
        III(&aaa, bbb, &ccc, ddd, eee, X[ 1], 13)
        III(&eee, aaa, &bbb, ccc, ddd, X[ 2], 11)

        /* parallel round 3 */
        HHH(&ddd, eee, &aaa, bbb, ccc, X[15], 9)
        HHH(&ccc, ddd, &eee, aaa, bbb, X[ 5], 7)
        HHH(&bbb, ccc, &ddd, eee, aaa, X[ 1], 15)
        HHH(&aaa, bbb, &ccc, ddd, eee, X[ 3], 11)
        HHH(&eee, aaa, &bbb, ccc, ddd, X[ 7], 8)
        HHH(&ddd, eee, &aaa, bbb, ccc, X[14], 6)
        HHH(&ccc, ddd, &eee, aaa, bbb, X[ 6], 6)
        HHH(&bbb, ccc, &ddd, eee, aaa, X[ 9], 14)
        HHH(&aaa, bbb, &ccc, ddd, eee, X[11], 12)
        HHH(&eee, aaa, &bbb, ccc, ddd, X[ 8], 13)
        HHH(&ddd, eee, &aaa, bbb, ccc, X[12], 5)
        HHH(&ccc, ddd, &eee, aaa, bbb, X[ 2], 14)
        HHH(&bbb, ccc, &ddd, eee, aaa, X[10], 13)
        HHH(&aaa, bbb, &ccc, ddd, eee, X[ 0], 13)
        HHH(&eee, aaa, &bbb, ccc, ddd, X[ 4], 7)
        HHH(&ddd, eee, &aaa, bbb, ccc, X[13], 5)

        /* parallel round 4 */
        GGG(&ccc, ddd, &eee, aaa, bbb, X[ 8], 15)
        GGG(&bbb, ccc, &ddd, eee, aaa, X[ 6], 5)
        GGG(&aaa, bbb, &ccc, ddd, eee, X[ 4], 8)
        GGG(&eee, aaa, &bbb, ccc, ddd, X[ 1], 11)
        GGG(&ddd, eee, &aaa, bbb, ccc, X[ 3], 14)
        GGG(&ccc, ddd, &eee, aaa, bbb, X[11], 14)
        GGG(&bbb, ccc, &ddd, eee, aaa, X[15], 6)
        GGG(&aaa, bbb, &ccc, ddd, eee, X[ 0], 14)
        GGG(&eee, aaa, &bbb, ccc, ddd, X[ 5], 6)
        GGG(&ddd, eee, &aaa, bbb, ccc, X[12], 9)
        GGG(&ccc, ddd, &eee, aaa, bbb, X[ 2], 12)
        GGG(&bbb, ccc, &ddd, eee, aaa, X[13], 9)
        GGG(&aaa, bbb, &ccc, ddd, eee, X[ 9], 12)
        GGG(&eee, aaa, &bbb, ccc, ddd, X[ 7], 5)
        GGG(&ddd, eee, &aaa, bbb, ccc, X[10], 15)
        GGG(&ccc, ddd, &eee, aaa, bbb, X[14], 8)

        /* parallel round 5 */
        FFF(&bbb, ccc, &ddd, eee, aaa, X[12], 8)
        FFF(&aaa, bbb, &ccc, ddd, eee, X[15], 5)
        FFF(&eee, aaa, &bbb, ccc, ddd, X[10], 12)
        FFF(&ddd, eee, &aaa, bbb, ccc, X[ 4], 9)
        FFF(&ccc, ddd, &eee, aaa, bbb, X[ 1], 12)
        FFF(&bbb, ccc, &ddd, eee, aaa, X[ 5], 5)
        FFF(&aaa, bbb, &ccc, ddd, eee, X[ 8], 14)
        FFF(&eee, aaa, &bbb, ccc, ddd, X[ 7], 6)
        FFF(&ddd, eee, &aaa, bbb, ccc, X[ 6], 8)
        FFF(&ccc, ddd, &eee, aaa, bbb, X[ 2], 13)
        FFF(&bbb, ccc, &ddd, eee, aaa, X[13], 6)
        FFF(&aaa, bbb, &ccc, ddd, eee, X[14], 5)
        FFF(&eee, aaa, &bbb, ccc, ddd, X[ 0], 15)
        FFF(&ddd, eee, &aaa, bbb, ccc, X[ 3], 13)
        FFF(&ccc, ddd, &eee, aaa, bbb, X[ 9], 11)
        FFF(&bbb, ccc, &ddd, eee, aaa, X[11], 11)

        /* combine results */
        MDbuf = (MDbuf.1 &+ cc &+ ddd,
                 MDbuf.2 &+ dd &+ eee,
                 MDbuf.3 &+ ee &+ aaa,
                 MDbuf.4 &+ aa &+ bbb,
                 MDbuf.0 &+ bb &+ ccc)
    }

    public mutating func update(data: Data) throws {
        try data.withUnsafeBytes { (body: UnsafeRawBufferPointer) in
            if let bodyAddress = body.baseAddress, body.count > 0 {
                var ptr = bodyAddress.assumingMemoryBound(to: UInt8.self)
                var length = data.count
                var X = [UInt32](repeating: 0, count: 16)

                // Process remaining bytes from last call:
                if buffer.count > 0 && buffer.count + length >= 64 {
                    let amount = 64 - buffer.count
                    buffer.append(ptr, count: amount)
                    try buffer.withUnsafeBytes { (body: UnsafeRawBufferPointer) in
                        if let bodyAddress = body.baseAddress, body.count > 0 {
                            let pointer = bodyAddress.assumingMemoryBound(to: Void.self)
                            _ = memcpy(&X, pointer, 64)
                        } else {
                            throw Web3Error.dataError
                        }
                    }
                    compress(X)
                    ptr += amount
                    length -= amount
                }
                // Process 64 byte chunks:
                while length >= 64 {
                    memcpy(&X, ptr, 64)
                    compress(X)
                    ptr += 64
                    length -= 64
                }
                // Save remaining unprocessed bytes:
                buffer = Data(bytes: ptr, count: length)
            } else {
                throw Web3Error.dataError
            }
        }
        count += Int64(data.count)
    }

    public mutating func finalize() throws -> Data {
        var X = [UInt32](repeating: 0, count: 16)
        /* append the bit m_n == 1 */
        buffer.append(0x80)
        try buffer.withUnsafeBytes { (body: UnsafeRawBufferPointer) in
            if let bodyAddress = body.baseAddress, body.count > 0 {
                let pointer = bodyAddress.assumingMemoryBound(to: Void.self)
                _ = memcpy(&X, pointer, buffer.count)
            } else {
                throw Web3Error.dataError
            }
        }

        if (count & 63) > 55 {
            /* length goes to next block */
            compress(X)
            X = [UInt32](repeating: 0, count: 16)
        }

        /* append length in bits */
        let lswlen = UInt32(truncatingIfNeeded: count)
        let mswlen = UInt32(UInt64(count) >> 32)
        X[14] = lswlen << 3
        X[15] = (lswlen >> 29) | (mswlen << 3)
        compress(X)

        var data = Data(count: 20)
        try data.withUnsafeMutableBytes { (body: UnsafeMutableRawBufferPointer) in
            if let bodyAddress = body.baseAddress, body.count > 0 {
                let pointer = bodyAddress.assumingMemoryBound(to: UInt32.self)
                pointer[0] = MDbuf.0
                pointer[1] = MDbuf.1
                pointer[2] = MDbuf.2
                pointer[3] = MDbuf.3
                pointer[4] = MDbuf.4
            } else {
                throw Web3Error.dataError
            }
        }

        buffer = Data()

        return data
    }
}

extension RIPEMD160 {

    public static func hash(message: Data) throws -> Data {
        var md = RIPEMD160()
        try md.update(data: message)
        return try md.finalize()
        //        return try md.finalize()
    }

    static func hash(message: String) throws -> Data {
        return try RIPEMD160.hash(message: message.data(using: .utf8)!)
        //        return try RIPEMD160.hash(message: message.data(using: .utf8)!)
    }
}

extension RIPEMD160 {

    static func hmac(key: Data, message: Data) throws -> Data {

        var key = key
        key.count = 64 // Truncate to 64 bytes or fill-up with zeros.

        //        let outerKeyPad = Data(bytes: key.map { $0 ^ 0x5c })
        //        let innerKeyPad = Data(bytes: key.map { $0 ^ 0x36 })
        let outerKeyPad = Data(key.map { $0 ^ 0x5c })
        let innerKeyPad = Data(key.map { $0 ^ 0x36 })

        var innerMd = RIPEMD160()
        try innerMd.update(data: innerKeyPad)
        try innerMd.update(data: message)
        //        try innerMd.update(data: innerKeyPad)
        //        try innerMd.update(data: message)

        var outerMd = RIPEMD160()
        try outerMd.update(data: outerKeyPad)
        try outerMd.update(data: innerMd.finalize())
        //        try outerMd.update(data: outerKeyPad)
        //        try outerMd.update(data: innerMd.finalize())

        return try outerMd.finalize()
        //        return try outerMd.finalize()
    }

    static func hmac(key: Data, message: String) throws -> Data {
        return try RIPEMD160.hmac(key: key, message: message.data(using: .utf8)!)
        //        return try RIPEMD160.hmac(key: key, message: message.data(using: .utf8)!)
    }

    static func hmac(key: String, message: String) throws -> Data {
        return try RIPEMD160.hmac(key: key.data(using: .utf8)!, message: message)
        //        return try RIPEMD160.hmac(key: key.data(using: .utf8)!, message: message)
    }
}
