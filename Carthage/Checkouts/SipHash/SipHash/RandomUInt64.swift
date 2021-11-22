//
//  RandomUInt64.swift
//  SipHash
//
//  Created by Károly Lőrentey on 2016-11-14.
//  Copyright © 2016-2017 Károly Lőrentey.
//

#if os(iOS) || os(macOS) || os(watchOS) || os(tvOS)
    import Darwin

    func randomUInt64() -> UInt64 {
        return UInt64(arc4random()) << 32 | UInt64(arc4random())
    }
#elseif os(Linux) || os(FreeBSD)
    import Glibc

    func randomUInt64() -> UInt64 {
        var randomArray = [UInt8](repeating: 0, count: 8)

        let fd = open("/dev/urandom", O_RDONLY)
        defer {
            close(fd)
        }

        let _ = read(fd, &randomArray, MemoryLayout<UInt8>.size * 8)

        var randomInt: UInt64 = 0
        for i in 0..<randomArray.count {
            randomInt = randomInt | (UInt64(randomArray[i]) << (i * 8))
        }

        return randomInt
    }
#else
    func randomUInt64() -> UInt64 {
        fatalError("Unsupported platform")
    }
#endif
