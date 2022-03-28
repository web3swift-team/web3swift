//
//  soliditySha3.swift
//  Tests
//
//  Created by JeneaVranceanu on 28/03/2022.
//  Copyright © 2022 web3swift. All rights reserved.
//

import Foundation
import XCTest
@testable import web3swift

class SoliditySha3Test: XCTestCase {

    func test_soliditySha3() throws {
        var hex = soliditySha3(true).toHexString().addHexPrefix()
        assert(hex == "0x5fe7f977e71dba2ea1a68e21057beebb9be2ac30c6410aa38d4f3fbe41dcffd2")
        hex = soliditySha3(-10).toHexString().addHexPrefix()
        assert(hex == "0xd6fb717f7e270a360f5093ce6a7a3752183e89c9a9afe5c0cb54b458a304d3d5")
        hex = soliditySha3(Data.fromHex("0xfff23243")!).toHexString().addHexPrefix()
        assert(hex == "0x0ee4597224d3499c72aa0c309b0d0cb80ff3c2439a548c53edb479abfd6927ba")
        hex = soliditySha3(UInt(234564535)).toHexString().addHexPrefix()
        assert(hex == "0xb2daf574dc6ceac97e984c8a3ffce3c1ec19e81cc6b18aeea67b3ac2666f4e97")

        hex = soliditySha3([UInt(234564535), Data.fromHex("0xfff23243")!, true, -10]).toHexString().addHexPrefix()
        assert(hex == "0x3e27a893dc40ef8a7f0841d96639de2f58a132be5ae466d40087a2cfa83b7179")

        hex = soliditySha3("Hello!%").toHexString().addHexPrefix()
        assert(hex == "0x661136a4267dba9ccdf6bfddb7c00e714de936674c4bdb065a531cf1cb15c7fc")

        // This is not JS. '234' (with single or double qoutes) will be a String, not any kind of number.
        // From Web3JS docs:> web3.utils.soliditySha3('234'); // auto detects: uint256

        hex = soliditySha3(0xea).toHexString().addHexPrefix()
        assert(hex == "0x61c831beab28d67d1bb40b5ae1a11e2757fa842f031a2d0bc94a7867bc5d26c2")

        hex = soliditySha3(234).toHexString().addHexPrefix()
        assert(hex == "0x61c831beab28d67d1bb40b5ae1a11e2757fa842f031a2d0bc94a7867bc5d26c2")

        hex = soliditySha3(UInt64(234)).toHexString().addHexPrefix()
        assert(hex == "0x6e48b7f8b342032bfa46a07cf85358feee0efe560d6caa87d342f24cdcd07b0c")

        hex = soliditySha3(UInt(234)).toHexString().addHexPrefix()
        assert(hex == "0x61c831beab28d67d1bb40b5ae1a11e2757fa842f031a2d0bc94a7867bc5d26c2")

        hex = soliditySha3("0x407D73d8a49eeb85D32Cf465507dd71d507100c1").toHexString().addHexPrefix()
        assert(hex == "0x4e8ebbefa452077428f93c9520d3edd60594ff452a29ac7d2ccc11d47f3ab95b")

        hex = soliditySha3(Data.fromHex("0x407D73d8a49eeb85D32Cf465507dd71d507100c1")!).toHexString().addHexPrefix()
        assert(hex == "0x4e8ebbefa452077428f93c9520d3edd60594ff452a29ac7d2ccc11d47f3ab95b")

        hex = soliditySha3(EthereumAddress("0x407D73d8a49eeb85D32Cf465507dd71d507100c1")!).toHexString().addHexPrefix()
        assert(hex == "0x4e8ebbefa452077428f93c9520d3edd60594ff452a29ac7d2ccc11d47f3ab95b")


        hex = soliditySha3("Hello!%").toHexString().addHexPrefix()
        assert(hex == "0x661136a4267dba9ccdf6bfddb7c00e714de936674c4bdb065a531cf1cb15c7fc")

        hex = soliditySha3(Int8(-23)).toHexString().addHexPrefix()
        assert(hex == "0xdc046d75852af4aea44a770057190294068a953828daaaab83800e2d0a8f1f35")

        hex = soliditySha3(EthereumAddress("0x85F43D8a49eeB85d32Cf465507DD71d507100C1d")!).toHexString().addHexPrefix()
        assert(hex == "0xe88edd4848fdce08c45ecfafd2fbfdefc020a7eafb8178e94c5feaeec7ac0bb4")

        hex = soliditySha3(["Hello!%", Int8(-23), EthereumAddress("0x85F43D8a49eeB85d32Cf465507DD71d507100C1d")!]).toHexString().addHexPrefix()
        assert(hex == "0xa13b31627c1ed7aaded5aecec71baf02fe123797fffd45e662eac8e06fbe4955")
    }

    /// `[AnyObject]` is not allowed to be used directly as input for `solidtySha3`.
    /// `AnyObject` erases type data making it impossible to encode some types correctly,
    /// e.g.: Bool can be treated as Int (8/16/32/64) and 0/1 numbers can be treated as Bool.
    func test_soliditySha3Fail_1() throws {
        var didFail = false
        do {
            let _ = try soliditySha3([""] as [AnyObject])
        } catch {
            didFail = true
        }
        XCTAssertTrue(didFail)
    }

    /// `AnyObject` is not allowed to be used directly as input for `solidtySha3`.
    /// `AnyObject` erases type data making it impossible to encode some types correctly,
    /// e.g.: Bool can be treated as Int (8/16/32/64) and 0/1 numbers can be treated as Bool.
    func test_soliditySha3Fail_2() throws {
        var didFail = false
        do {
            let _ = try soliditySha3("" as AnyObject)
        } catch {
            didFail = true
        }
        XCTAssertTrue(didFail)
    }
}
