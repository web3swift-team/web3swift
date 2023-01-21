//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation

public extension NSRegularExpression {
    typealias GroupNamesSearchResult = (NSTextCheckingResult, NSTextCheckingResult, Int)

    private func getNamedCaptureGroups() -> [String: GroupNamesSearchResult] {
        var groupnames = [String: GroupNamesSearchResult]()

        guard let greg = try? NSRegularExpression(pattern: "\\(\\?<([\\w\\a_-]*)>$",
                                                  options: .dotMatchesLineSeparators),
              let reg = try? NSRegularExpression(pattern: "\\(.*?>",
                                                 options: .dotMatchesLineSeparators) else {
            // This never happens but the alternative is to make this method throwing
            return groupnames
        }

        let m = reg.matches(in: pattern, options: .withTransparentBounds, range: pattern.fullNSRange)
        for (nameIndex, g) in m.enumerated() {
            let r = pattern.range(from: g.range(at: 0))
            let gstring = String(pattern[r!])
            let gmatch = greg.matches(in: gstring, options: [], range: gstring.fullNSRange)
            if gmatch.count > 0 {
                let r2 = gstring.range(from: gmatch[0].range(at: 1))!
                groupnames[String(gstring[r2])] = (g, gmatch[0], nameIndex)
            }

        }
        return groupnames
    }

    func captureGroups(string: String, options: NSRegularExpression.MatchingOptions = []) -> [String: String] {
        captureGroups(string: string, options: options, range: string.fullNSRange)
    }

    func captureGroups(string: String, options: NSRegularExpression.MatchingOptions = [], range: NSRange) -> [String: String] {
        var dict = [String: String]()
        let matchResult = matches(in: string, options: options, range: range)
        guard let match = matchResult.first else {
            return dict
        }
        for name in getNamedCaptureGroups().keys {
            guard let stringRange = string.range(from: match.range(withName: name)) else {continue}
            dict[name] = String(string[stringRange])
        }
        return dict
    }
}
