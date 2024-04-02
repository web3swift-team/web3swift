//
//  String+Extension.swift
//
//
//  Created by JeneaVranceanu on 17.10.2023.
//

import Foundation

extension String {

    func asJsonDictionary() throws -> [String: AnyObject]? {
        guard let data = data(using: .utf8) else { return nil }
        return try data.asJsonDictionary()
    }
}
