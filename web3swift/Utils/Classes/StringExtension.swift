import Foundation

// MARK: - Range Helpers
extension String {
    var fullRange: Range<Index> {
        return startIndex..<endIndex
    }
    
    var fullNSRange: NSRange {
        return NSRange(fullRange, in: self)
    }
}

// MARK: - Search Helpers
extension String {
    func lastIndex(of char: Character) -> Index? {
        guard let range = range(of: String(char), options: .backwards) else {
            return nil
        }
        return range.lowerBound
    }
    
    func index(of char: Character) -> Index? {
        guard let range = range(of: String(char)) else {
            return nil
        }
        return range.lowerBound
    }
}

extension String {
    func stripHexPrefix() -> String {
        if self.hasPrefix("0x") {
            let indexStart = self.index(self.startIndex, offsetBy: 2)
            return String(self[indexStart...])
        }
        return self
    }
    
    func addHexPrefix() -> String {
        if !self.hasPrefix("0x") {
            return "0x" + self
        }
        return self
    }
    
    func stripLeadingZeroes() -> String? {
        let hex = self.addHexPrefix()
        guard let matcher = try? NSRegularExpression(pattern: "^(?<prefix>0x)0*(?<end>[0-9a-fA-F]*)$", options: NSRegularExpression.Options.dotMatchesLineSeparators) else {return nil}
        let match = matcher.captureGroups(string: hex, options: NSRegularExpression.MatchingOptions.anchored)
        guard let prefix = match["prefix"] else {return nil}
        guard let end = match["end"] else {return nil}
        if (end != "") {
            return prefix + end
        }
        return "0x0"
        
    }
}
