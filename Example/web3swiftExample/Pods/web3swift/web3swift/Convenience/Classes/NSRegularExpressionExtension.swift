//
//  NSRegularExpressionExtension.swift
//  web3swift
//
//  Created by Alexander Vlasov on 06.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//


import Foundation


extension NSRegularExpression {
    typealias GroupNamesSearchResult = (NSTextCheckingResult, NSTextCheckingResult, Int)
    
    private func textCheckingResultsOfNamedCaptureGroups() -> [String:GroupNamesSearchResult] {
        var groupnames = [String:GroupNamesSearchResult]()
        
        guard let greg = try? NSRegularExpression(pattern: "^\\(\\?<([\\w\\a_-]*)>$", options: NSRegularExpression.Options.dotMatchesLineSeparators) else {
            // This never happens but the alternative is to make this method throwing
            return groupnames
        }
        guard let reg = try? NSRegularExpression(pattern: "\\(.*?>", options: NSRegularExpression.Options.dotMatchesLineSeparators) else {
            // This never happens but the alternative is to make this method throwing
            return groupnames
        }
        let m = reg.matches(in: self.pattern, options: NSRegularExpression.MatchingOptions.withTransparentBounds, range: NSRange(location: 0, length: self.pattern.utf16.count))
        for (n,g) in m.enumerated() {
            let r = self.pattern.range(from: g.range(at: 0))
            let gstring = String(self.pattern[r!])
            let gmatch = greg.matches(in: gstring, options: NSRegularExpression.MatchingOptions.anchored, range: NSRange(location: 0, length: gstring.utf16.count))
            if gmatch.count > 0{
                let r2 = gstring.range(from: gmatch[0].range(at: 1))!
                groupnames[String(gstring[r2])] = (g, gmatch[0],n)
            }
            
        }
        return groupnames
    }
    
    func indexOfNamedCaptureGroups() throws -> [String:Int] {
        var groupnames = [String:Int]()
        for (name,(_,_,n)) in self.textCheckingResultsOfNamedCaptureGroups() {
            groupnames[name] = n + 1
        }
        return groupnames
    }
    
    func rangesOfNamedCaptureGroups(match:NSTextCheckingResult) throws -> [String:Range<Int>] {
        var ranges = [String:Range<Int>]()
        for (name,(_,_,n)) in self.textCheckingResultsOfNamedCaptureGroups() {
            ranges[name] = Range(match.range(at: n+1))
        }
        return ranges
    }
    
    private func nameForIndex(_ index: Int, from: [String:GroupNamesSearchResult]) -> String? {
        for (name,(_,_,n)) in from {
            if (n + 1) == index {
                return name
            }
        }
        return nil
    }
    
    func captureGroups(string: String, options: NSRegularExpression.MatchingOptions = []) -> [String:String] {
        return captureGroups(string: string, options: options, range: NSRange(location: 0, length: string.utf16.count))
    }
    
    func captureGroups(string: String, options: NSRegularExpression.MatchingOptions = [], range: NSRange) -> [String:String] {
        var dict = [String:String]()
        let matchResult = matches(in: string, options: options, range: range)
        let names = self.textCheckingResultsOfNamedCaptureGroups()
        for (_,m) in matchResult.enumerated() {
            for i in (0..<m.numberOfRanges) {
                guard let r2 = string.range(from: m.range(at: i)) else {continue}
                let g = String(string[r2])
                if let name = nameForIndex(i, from: names) {
                    dict[name] = g
                }
            }
        }
        return dict
    }
}
