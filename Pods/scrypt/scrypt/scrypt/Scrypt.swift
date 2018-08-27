//
//  Scrypt.swift
//  scrypt-cryptoswift
//
//  Created by Alexander Vlasov on 08.08.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

//  https://www.ietf.org/rfc/rfc7914.txt
//
import CryptoSwift


/// A key derivation function.
///
/// Scrypt - Password-Based Key Derivation Function. Key stretching technique.
//    Passphrase:                Bytes    string of characters to be hashed
//    Salt:                      Bytes    random salt
//    CostFactor (N):            Integer  CPU/memory cost parameter
//    BlockSizeFactor (r):       Integer  blocksize parameter (8 is commonly used)
//    ParallelizationFactor (p): Integer  Parallelization parameter. (1..232-1 * hLen/MFlen)
//    DesiredKeyLen:

public struct Scrypt {
    public enum Error: Swift.Error {
        case invalidInput
        case derivedKeyTooLong
        case pValueTooLarge
        case nValueNotPowerOf2
    }
    
    private let salt: Array<UInt8> // S
    private let password: Array<UInt8>
    fileprivate let blocksize: Int // 128 * r
    private let dkLen: Int
    private let N: Int
    private let r: Int
    private let p: Int

    public init(password: Array<UInt8>, salt: Array<UInt8>, dkLen: Int, N: Int, r: Int, p: Int) throws {
        precondition(dkLen > 0)
        precondition(N > 0)
        precondition(r > 0)
        precondition(p > 0)
        
        let MFLen = Double(r)*128
        let hLen = Double(32)
        
        if N & (N-1) != 0 {
            throw Error.nValueNotPowerOf2
        }
        
        if Double(p) > (pow(2, 32) - 1) * hLen / MFLen {
            throw Error.pValueTooLarge
        }
        
        if Double(dkLen) > (pow(2, 32) - 1) * hLen {
            throw Error.derivedKeyTooLong
        }
        
        self.blocksize = 128 * r
        self.N = N
        self.r = r
        self.p = p
        self.password = password
        self.salt = salt
        self.dkLen = dkLen
    }
    
    public func calculate() throws -> Array<UInt8> {
        var kdf = try CryptoSwift.PKCS5.PBKDF2(password: password, salt: salt, iterations: 1, keyLength: blocksize*p, variant: .sha256)
        var B = try kdf.calculate()
        let v = BufferStorage<UInt32>(repeating: 0, count: 32*N*r)
        let xy = BufferStorage<UInt32>(repeating: 0, count: 64*r) // 128*2*r bytes
        // no parallelization here for now
        for i in 0 ..< p {
            Scrypt.smix(b: &B[(i*128*r)...], N: N, r: r, v: v, xy: xy)
        }
        kdf = try CryptoSwift.PKCS5.PBKDF2(password: self.password, salt: B, iterations: 1, keyLength: dkLen, variant: .sha256)
        let ret = try kdf.calculate()
        return Array(ret)
    }
}

extension Scrypt {
    static func blockCopy(destination: BufferStorage<UInt32>, source: BufferStorage<UInt32>, n: Int) {
        destination.replaceSubrange(0 ..< n, with: source)
    }
    
    static func blockXOR(destination: BufferStorage<UInt32>, source: BufferStorage<UInt32>, n: Int) {
        for i in 0 ..< n {
            destination[i] ^= source[i]
        }
    }
    
    static func blockMix(tmp: BufferStorage<UInt32>, source: BufferStorage<UInt32>, destination: BufferStorage<UInt32>, r: Int) {
        blockCopy(destination: tmp, source: source[((2*r-1)*16)...], n: 16)
        for i in stride(from: 0, to: 2*r, by: 2) {
            salsaXOR(tmp: tmp, source: source[(i*16)...], destination: destination[(i*8)...])
            salsaXOR(tmp: tmp, source: source[(i*16 + 16)...], destination: destination[(i*8 + r*16)...])
        }
    }
    
    static func salsaXOR(tmp: BufferStorage<UInt32>, source: BufferStorage<UInt32>, destination: BufferStorage<UInt32>) {
        blockXOR(destination: tmp, source: source, n: 16)
        // reuse destination as a temporary memory
        Salsa.salsa20(tmp, rounds: 8, tmp: destination)
        blockCopy(destination: destination, source: tmp, n: 16)
    }
    
    static func integerify(b : BufferStorage<UInt32>, r: Int) -> UInt64 {
        let j = (2*r - 1) * 16
        return UInt64(b[j]) | (UInt64(b[j+1]) << 32) // LE
    }
    
    static func smix(b: inout ArraySlice<UInt8>, N: Int, r: Int, v: BufferStorage<UInt32>, xy: BufferStorage<UInt32>) {
        let tmp = BufferStorage<UInt32>(repeating: 0, count: 16)
        let x = xy
        let y = xy[(32*r)...]
        
        var j = b.startIndex
        for i in 0 ..< 32*r {
            x[i] = UInt32(b[j]) | UInt32(b[j+1])<<8 | UInt32(b[j+2])<<16 | UInt32(b[j+3])<<24 // decode as LE Uint32
            j += 4
        }
        for i in stride(from: 0, to: N, by: 2) {
            Scrypt.blockCopy(destination: v[(i*(32*r))...], source: x, n: 32*r)
            // blockMix starts with copy, so tmp can be garbage
            Scrypt.blockMix(tmp: tmp, source: x, destination: y, r: r)
            
            Scrypt.blockCopy(destination: v[((i+1)*(32*r))...], source: y, n: 32*r)
            // blockMix starts with copy, so tmp can be garbage
            Scrypt.blockMix(tmp: tmp, source: y, destination: x, r: r)
        }
        
        for _ in stride(from: 0, to: N, by: 2) {
            var j = Int(Scrypt.integerify(b: x, r: r) & UInt64(N-1) )
            Scrypt.blockXOR(destination: x, source: v[(j*(32*r))...], n: 32*r)
            // blockMix starts with copy, so tmp can be garbage
            Scrypt.blockMix(tmp: tmp, source: x, destination: y, r: r)
            
            j = Int(Scrypt.integerify(b: y, r: r) & UInt64(N-1) )
            Scrypt.blockXOR(destination: y, source: v[(j*(32*r))...], n: 32*r)
            // blockMix starts with copy, so tmp can be garbage
            Scrypt.blockMix(tmp: tmp, source: y, destination: x, r: r)
        }
        j = b.startIndex
        for i in 0 ..< 32*r {
            let v = x[i]
            b[j+0] = UInt8(v >> 0 & 0xff)
            b[j+1] = UInt8(v >> 8 & 0xff)
            b[j+2] = UInt8(v >> 16 & 0xff)
            b[j+3] = UInt8(v >> 24 & 0xff)
            j += 4
        }
    }
    
    static func integerify(_ X: Array<UInt8>) -> UInt64 {
        precondition(X.count >= 8)
        let count = X.count
        var result = UInt64(0)
        var shift = 56
        for i in (count-8 ..< count).reversed() {
            result |= UInt64(X[i]) << shift
            shift -= 8
        }
        return result
    }
}
