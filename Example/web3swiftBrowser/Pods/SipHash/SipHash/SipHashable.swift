//
//  SipHashable.swift
//  SipHash
//
//  Created by Károly Lőrentey on 2016-11-14.
//  Copyright © 2016-2017 Károly Lőrentey.
//

/// A variant of `Hashable` that makes it simpler to generate good hash values.
///
/// Instead of `hashValue`, you need to implement `addHashes`, adding
/// data that should contribute to the hash to the supplied hasher.
/// The hasher takes care of blending the supplied data together.
///
/// Example implementation:
///
/// ```
/// struct Book: SipHashable {
///     var title: String
///     var pageCount: Int
///
///     func appendHashes(to hasher: inout SipHasher) {
///         hasher.append(title)
///         hasher.append(pageCount)
///     }
///
///     static func ==(left: Book, right: Book) -> Bool {
///         return left.title == right.title && left.pageCount == right.pageCount
///     }
/// }
/// ```
public protocol SipHashable: Hashable {
    /// Add components of `self` that should contribute to hashing to `hash`.
    func appendHashes(to hasher: inout SipHasher)
}

extension SipHashable {
    /// The hash value, calculated using `addHashes`.
    ///
    /// Hash values are not guaranteed to be equal across different executions of your program.
    /// Do not save hash values to use during a future execution.
    public var hashValue: Int {
        var hasher = SipHasher()
        appendHashes(to: &hasher)
        return hasher.finalize()
    }
}

extension SipHasher {
    //MARK: Appending Hashable Values
    
    /// Add hashing components in `value` to this hash. This method simply calls `value.addHashes`.
    ///
    /// - Requires: `finalize()` hasn't been called on this instance yet.
    public mutating func append<H: SipHashable>(_ value: H) {
        value.appendHashes(to: &self)
    }

    /// Add the hash value of `value` to this hash.
    ///
    /// - Requires: `finalize()` hasn't been called on this instance yet.
    public mutating func append<H: Hashable>(_ value: H) {
        append(value.hashValue)
    }
}
