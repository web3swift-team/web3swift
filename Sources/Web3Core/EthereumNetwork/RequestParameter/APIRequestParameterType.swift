//
//  APIRequestParameter.swift
//
//
//  Created by Yaroslav on 24.05.2022.
//

import Foundation

/// Protocol to restrict supported types which can be passed into `RequestParameter` to a node.
///
/// Due to internal logic and swift itself restrictions, there's lack of encoding generic types
/// so current implementation of `RequestParameter`s belongs on hardcoded supported types.
///
/// Please see `RequestParameter` documentation for more details.
protocol APIRequestParameterType: Encodable { }

extension Int: APIRequestParameterType { }

extension UInt: APIRequestParameterType { }

extension Double: APIRequestParameterType { }

extension String: APIRequestParameterType { }

extension Bool: APIRequestParameterType { }

extension Array: APIRequestParameterType where Element: APIRequestParameterType { }
