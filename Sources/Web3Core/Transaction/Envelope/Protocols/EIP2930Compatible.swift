//
//  EIP2930Compatible.swift
//
//  Created by JeneaVranceanu on 10.11.2022.
//

import Foundation

/// Protocol to support `EIP-2930` properties access
public protocol EIP2930Compatible {
    var accessList: [AccessListEntry] { get set }
}
