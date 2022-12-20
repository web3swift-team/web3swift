//
//  Mocks.swift
//
//  Created by JeneaVranceanu on 07.12.2022.
//

import Foundation
@testable import web3swift
@testable import Web3Core

class Web3EthMock: IEth {
    let provider: Web3Provider

    var onCallTransaction: ((CodableTransaction) -> Data)?

    init(provider: Web3Provider) {
        self.provider = provider
    }

    func callTransaction(_ transaction: CodableTransaction) async throws -> Data {
        onCallTransaction?(transaction) ?? Data()
    }
}
