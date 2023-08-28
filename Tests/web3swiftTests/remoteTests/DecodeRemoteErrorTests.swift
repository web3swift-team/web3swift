//
//  DecodeRemoteErrorTests.swift
//
//  Created by liugang zhang on 2023/8/25.
//

import XCTest
import Web3Core

@testable import web3swift

final class DecodeRemoteErrorTests: XCTestCase {

    let entryPoint = EthereumAddress("0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789")!
    let factory = EthereumAddress("0x9406Cc6185a346906296840746125a0E44976454")!
    let address = EthereumAddress("0x581074D2d9e50913eB37665b07CAFa9bFFdd1640")!

    func testDecodeRemoteFunc() async throws {
        let web3 = try await Web3.InfuraMainnetWeb3(accessToken: Constants.infuraToken)

        let entryABI = try EthereumContract(abi: [
            .error(.init(name: "SenderAddressResult",
                         inputs: [.init(name: "sender", type: .address)])),
            .function(.init(name: "getSenderAddress",
                            inputs: [.init(name: "initCode", type: .dynamicBytes)],
                            outputs: [],
                            constant: false,
                            payable: false))
        ], at: entryPoint)

        let factoryABI = try EthereumContract(abi: [
            .function(.init(name: "createAccount",
                            inputs: [
                                .init(name: "owner", type: .address),
                                .init(name: "salt", type: .uint(bits: 256))
                            ],
                            outputs: [],
                            constant: false,
                            payable: false))
        ])

        let initCode = factory.addressData + factoryABI.method("createAccount", parameters: [address, 0], extraData: nil)!

        do {
            try await entryABI.callStatic("getSenderAddress", parameters: [initCode], provider: web3.provider)
            XCTFail()
        } catch Web3Error.revertCustom(let signature, let args) {
            XCTAssertEqual(signature, "SenderAddressResult(address)")
            XCTAssertEqual((args["sender"] as? EthereumAddress)?.address, "0x9CF91286f22a1b799770fB5De0E66f3C4cc165d1")
            XCTAssertEqual((args["0"] as? EthereumAddress)?.address, "0x9CF91286f22a1b799770fB5De0E66f3C4cc165d1")
        }
    }
}
