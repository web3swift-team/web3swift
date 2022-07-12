//
//  APIRequestParameterElementType.swift
//
//
//  Created by Yaroslav Yashin on 12.07.2022.
//

import Foundation

protocol APIRequestParameterElementType: Encodable { }

extension Int: APIRequestParameterElementType { }

extension UInt: APIRequestParameterElementType { }

extension Double: APIRequestParameterElementType { }

extension String: APIRequestParameterElementType { }

extension Bool: APIRequestParameterElementType { }
