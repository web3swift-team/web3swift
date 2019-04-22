//
//  Primitive Types.swift
//  SipHash
//
//  Created by Károly Lőrentey on 2016-11-14.
//  Copyright © 2016-2017 Károly Lőrentey.
//

extension SipHasher {
    //MARK: Appending buffer slices
    
    /// Add the contents of `slice` to this hash.
    ///
    /// - Requires: `finalize()` hasn't been called on this instance yet.
    public mutating func append(_ slice: RandomAccessSlice<UnsafeRawBufferPointer>) {
        self.append(UnsafeRawBufferPointer(rebasing: slice))
    }
    
    //MARK: Appending Integers

    /// Add `value` to this hash.
    ///
    /// - Requires: `finalize()` hasn't been called on this instance yet.
    public mutating func append(_ value: Bool) {
        var data = value
        append(UnsafeRawBufferPointer(start: &data, count: MemoryLayout<Bool>.size))
    }

    /// Add `value` to this hash.
    ///
    /// - Requires: `finalize()` hasn't been called on this instance yet.
    public mutating func append(_ value: Int) {
        var data = value
        append(UnsafeRawBufferPointer(start: &data, count: MemoryLayout<Int>.size))
    }

    /// Add `value` to this hash.
    ///
    /// - Requires: `finalize()` hasn't been called on this instance yet.
    public mutating func append(_ value: UInt) {
        var data = value
        append(UnsafeRawBufferPointer(start: &data, count: MemoryLayout<UInt>.size))
    }

    /// Add `value` to this hash.
    ///
    /// - Requires: `finalize()` hasn't been called on this instance yet.
    public mutating func append(_ value: Int64) {
        var data = value
        append(UnsafeRawBufferPointer(start: &data, count: MemoryLayout<Int64>.size))
    }

    /// Add `value` to this hash.
    ///
    /// - Requires: `finalize()` hasn't been called on this instance yet.
    public mutating func append(_ value: UInt64) {
        var data = value
        append(UnsafeRawBufferPointer(start: &data, count: MemoryLayout<UInt64>.size))
    }

    /// Add `value` to this hash.
    ///
    /// - Requires: `finalize()` hasn't been called on this instance yet.
    public mutating func append(_ value: Int32) {
        var data = value
        append(UnsafeRawBufferPointer(start: &data, count: MemoryLayout<Int32>.size))
    }

    /// Add `value` to this hash.
    ///
    /// - Requires: `finalize()` hasn't been called on this instance yet.
    public mutating func append(_ value: UInt32) {
        var data = value
        append(UnsafeRawBufferPointer(start: &data, count: MemoryLayout<UInt32>.size))
    }

    /// Add `value` to this hash.
    ///
    /// - Requires: `finalize()` hasn't been called on this instance yet.
    public mutating func append(_ value: Int16) {
        var data = value
        append(UnsafeRawBufferPointer(start: &data, count: MemoryLayout<Int16>.size))
    }

    /// Add `value` to this hash.
    ///
    /// - Requires: `finalize()` hasn't been called on this instance yet.
    public mutating func append(_ value: UInt16) {
        var data = value
        append(UnsafeRawBufferPointer(start: &data, count: MemoryLayout<UInt16>.size))
    }

    /// Add `value` to this hash.
    ///
    /// - Requires: `finalize()` hasn't been called on this instance yet.
    public mutating func append(_ value: Int8) {
        var data = value
        append(UnsafeRawBufferPointer(start: &data, count: MemoryLayout<Int8>.size))
    }

    /// Add `value` to this hash.
    ///
    /// - Requires: `finalize()` hasn't been called on this instance yet.
    public mutating func append(_ value: UInt8) {
        var data = value
        append(UnsafeRawBufferPointer(start: &data, count: MemoryLayout<UInt8>.size))
    }
}

extension SipHasher {
    //MARK: Appending Floating Point Types

    /// Add `value` to this hash.
    ///
    /// - Requires: `finalize()` hasn't been called on this instance yet.
    public mutating func append(_ value: Float) {
        var data = value.isZero ? 0.0 : value
        append(UnsafeRawBufferPointer(start: &data, count: MemoryLayout<Float>.size))
    }

    /// Add `value` to this hash.
    ///
    /// - Requires: `finalize()` hasn't been called on this instance yet.
    public mutating func append(_ value: Double) {
        var data = value.isZero ? 0.0 : value
        append(UnsafeRawBufferPointer(start: &data, count: MemoryLayout<Double>.size))
    }

    #if arch(i386) || arch(x86_64)
    /// Add `value` to this hash.
    ///
    /// - Requires: `finalize()` hasn't been called on this instance yet.
    public mutating func append(_ value: Float80) {
        var data = value.isZero ? 0.0 : value
        // Float80 is 16 bytes wide but the last 6 are uninitialized.
        let buffer = UnsafeRawBufferPointer(start: &data, count: 10)
        append(buffer)
    }
    #endif
}

#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
    import CoreGraphics

    extension SipHasher {
        /// Add `value` to this hash.
        ///
        /// - Requires: `finalize()` hasn't been called on this instance yet.
        public mutating func append(_ value: CGFloat) {
            var data = value.isZero ? 0.0 : value
            append(UnsafeRawBufferPointer(start: &data, count: MemoryLayout<CGFloat>.size))
        }
    }
#endif

extension SipHasher {
    //MARK: Appending Optionals

    /// Add `value` to this hash.
    ///
    /// - Requires: `finalize()` hasn't been called on this instance yet.
    public mutating func append<Value: Hashable>(_ value: Value?) {
        if let value = value {
            self.append(1 as UInt8)
            self.append(value)
        }
        else {
            self.append(0 as UInt8)
        }
    }
}
