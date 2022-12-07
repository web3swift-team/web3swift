//
//  Mocks.swift
//
//  Created by JeneaVranceanu on 07.12.2022.
//

import Foundation
@testable import web3swift
@testable import Core

class Web3EthMock: Web3.Eth {
    var onCallTransaction: ((CodableTransaction) -> Data)?

    override func callTransaction(_ transaction: CodableTransaction) async throws -> Data {
        onCallTransaction?(transaction) ?? Data()
    }
}
