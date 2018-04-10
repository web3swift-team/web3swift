//
//  ABIv2.swift
//  web3swift
//
//  Created by Alexander Vlasov on 02.04.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation

protocol ABIv2ElementPropertiesProtocol {
    var isStatic: Bool {get}
    var isArray: Bool {get}
    var isTuple: Bool {get}
    var arraySize: ABIv2.Element.ArraySize {get}
    var subtype: ABIv2.Element.ParameterType? {get}
    var memoryUsage: UInt64 {get}
    var emptyValue: Any {get}
}

protocol ABIv2Encoding {
    var abiRepresentation: String {get}
}

protocol ABIv2Validation {
    var isValid: Bool {get}
}

public struct ABIv2 {
    
}
