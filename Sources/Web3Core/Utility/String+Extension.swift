//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation

extension String {
    var fullRange: Range<Index> {
        return startIndex..<endIndex
    }

    public var fullNSRange: NSRange {
        return NSRange(fullRange, in: self)
    }

    func index(of char: Character) -> Index? {
        guard let range = range(of: String(char)) else {
            return nil
        }
        return range.lowerBound
    }

    func split(intoChunksOf chunkSize: Int) -> [String] {
        var output = [String]()
        let splittedString = self
            .map { $0 }
            .split(intoChunksOf: chunkSize)
        splittedString.forEach {
            output.append($0.map { String($0) }.joined(separator: ""))
        }
        return output
    }

    public subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(self.startIndex, offsetBy: bounds.lowerBound)
        let end = index(self.startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }

    public subscript (bounds: CountableRange<Int>) -> String {
        let start = index(self.startIndex, offsetBy: bounds.lowerBound)
        let end = index(self.startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }

    public subscript (bounds: CountablePartialRangeFrom<Int>) -> String {
        let start = index(self.startIndex, offsetBy: bounds.lowerBound)
        let end = self.endIndex
        return String(self[start..<end])
    }

    func leftPadding(toLength: Int, withPad character: Character) -> String {
        let stringLength = self.count
        if stringLength < toLength {
            return String(repeatElement(character, count: toLength - stringLength)) + self
        } else {
            return String(self.suffix(toLength))
        }
    }

    func interpretAsBinaryData() -> Data? {
        let padded = self.padding(toLength: ((self.count + 7) / 8) * 8, withPad: "0", startingAt: 0)
        let byteArray = padded.split(intoChunksOf: 8).map { UInt8(strtoul($0, nil, 2)) }
        return Data(byteArray)
    }

    public func hasHexPrefix() -> Bool {
        return self.hasPrefix("0x")
    }

    public func stripHexPrefix() -> String {
        if self.hasPrefix("0x") {
            let indexStart = self.index(self.startIndex, offsetBy: 2)
            return String(self[indexStart...])
        }
        return self
    }

    public func addHexPrefix() -> String {
        if !self.hasPrefix("0x") {
            return "0x" + self
        }
        return self
    }

    /// Strips leading zeroes from a HEX string.
    /// ONLY HEX string format is supported.
    /// - Returns: string with stripped leading zeroes (and 0x prefix) or unchanged string.
    func stripLeadingZeroes() -> String {
        let hex = addHexPrefix()
        guard let matcher = try? NSRegularExpression(pattern: "^(?<prefix>0x)(?<leadingZeroes>0+)(?<end>[0-9a-fA-F]*)$",
                                                     options: .dotMatchesLineSeparators)
        else {
            NSLog("stripLeadingZeroes(): failed to parse regex pattern.")
            return self
        }
        let match = matcher.captureGroups(string: hex, options: .anchored)
        guard match["leadingZeroes"] != nil,
              let prefix = match["prefix"],
              let end = match["end"] else { return self }
        return end != "" ? prefix + end : "0x0"
    }

    func matchingStrings(regex: String) -> [[String]] {
        guard let regex = try? NSRegularExpression(pattern: regex, options: []) else { return [] }
        let nsString = self as NSString
        let results  = regex.matches(in: self, options: [], range: NSRange(location: 0, length: nsString.length))
        return results.map { result in
            (0..<result.numberOfRanges).map { result.range(at: $0).location != NSNotFound
                ? nsString.substring(with: result.range(at: $0))
                : ""
            }
        }
    }

    func range(from nsRange: NSRange) -> Range<String.Index>? {
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location + nsRange.length, limitedBy: utf16.endIndex),
            let from = from16.samePosition(in: self),
            let to = to16.samePosition(in: self)
            else { return nil }
        return from ..< to
    }

    var asciiValue: Int {
        get {
            let s = self.unicodeScalars
            return Int(s[s.startIndex].value)
        }
    }

    /// Strips whitespaces and newlines on both ends.
    func trim() -> String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

extension Character {
    var asciiValue: Int {
        get {
            let s = String(self).unicodeScalars
            return Int(s[s.startIndex].value)
        }
    }
}
