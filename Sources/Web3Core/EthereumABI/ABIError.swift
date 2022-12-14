//
//  ABIError.swift
//  web3swift
//
//  Created by JeneaVranceanu on 12/07/2022.
//

import Foundation

public enum ABIError: Error {
    case invalidFunctionOverloading(_ errorMessage: String? = nil)
}
