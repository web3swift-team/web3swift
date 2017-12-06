//
//  StringExtension.swift
//  BivrostPackageDescription
//
//  Created by Luis Reisewitz on 13.10.17.
//

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
