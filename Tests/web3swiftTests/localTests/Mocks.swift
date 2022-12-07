//
//  Mocks.swift
//
//  Created by JeneaVranceanu on 07.12.2022.
//

import Foundation
@testable import web3swift
@testable import Core

class Web3EthMock: IEth {
    var onCallTransaction: ((CodableTransaction) -> Data)?

    func callTransaction(_ transaction: CodableTransaction) async throws -> Data {
        onCallTransaction?(transaction) ?? Data()
    }
}
