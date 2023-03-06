//
//  BIP44Tests.swift
//  Created by Alberto Penas Amor on 15/12/22.
//

import XCTest
import Web3Core
@testable import web3swift

final class BIP44Tests: XCTestCase {
    private var accountZeroScannedAddresses: [String] {
        [
            "0x31a4aD7593D06D049b3Cc07aB5430264Bf7e069f",
            "0x2b4fb04d485446ade5889e77b0cbC2c71075209c",
            "0x93DDC6583D4BF6e9b309cfBdC681A78F8B5f37Ff",
            "0xab2bBC1392f957F7A5DDCE89b64f30064D39C08b",
            "0x5Ae1794fFD14bebF34e0BA65815dF9DCB0FD11a8",
            "0x4894C017C7fEfB53A9dc3Cf707d098EBCFD8BdF1",
            "0x29cC28Cd30e21e73B51389792453818DaCe33f65",
            "0x6B3cB8CFBC89ab7A1D9Ccb53537020c53dD4f6E0",
            "0xD5FD55fcB93a47Ef176062ac8265E28A5f09887D",
            "0xa8A99549A522aF52a2050e081100ef3D42228B55",
            "0x2007f83D32cd82b013b9d0d33Ac9e5Ae725367C5",
            "0x80a9A6Dd42D67Dd2EEC5c3D6568Fd16e7c964948",
            "0xC7781cd86F6336CfE56Fc243f1a9544595dC984E",
            "0x7E3eDEB0201D5A5cAF2b50749a7C7843374c312F",
            "0x800853194B31Bf5D621Be0b402E8c2b3b402a2Ed",
            "0x73BE98d0a3702E8279ca087B2564b6977389C242",
            "0x3eFC4765C5BaB65947864fDf4669b7fb8073d89B",
            "0xd521A57ea2bAA6396AE916aD2bC4972a9b3635EB",
            "0x561192570145C499f0951dEc0a4Df80D0D0A96bb",
            "0x4DdBe17BB1b0056941A1425739978e44D462D7DD"]
    }
    private var accountZeroAndOneScannedAddresses: [String] {
        [
            "0x31a4aD7593D06D049b3Cc07aB5430264Bf7e069f",
            "0x3C7b0FadC415d0be5EBa971DC7Dcc39DdDcd4AF7",
            "0x73C13e421eF367c4F55BBC02a8e2a2b12e82f717",
            "0xE9D8f89452CF0a0d501B9C798cE696C3a1BAE535",
            "0x662e78FD3C77A9B8e693f5DC75398C9c0E7233a6",
            "0xBEDF61A3466b40f2591702c91cF888843C81e576",
            "0xb406aD2666D36716a847c27BAA6d742ECdA85F23",
            "0x069c7bF73d17aeb7b8Ff490177A6eefB7aCcb4a8",
            "0xa9dbD111007cAfF0804b98195F7f9231bcBEdf86",
            "0x2DDDf0447Eb85ae4B16815B010a7007cd30f0A64",
            "0x35ff1f3dcb02B6F137A654a419bFb66FE74dFDFE",
            "0xd3A77dE492A58386129546469D0E3D3C67Dd520E",
            "0x1c011fEfb24210EB1415DD87C161591f5040d71A",
            "0x6C289DCE390863ed58bBd56948950f4D96c7Ab8f",
            "0xbB13176bf7571D15E1600077F4da6eD22075676b",
            "0x618c1ddD96a3Dc2Bd1E90F7053bCc48986A412f7",
            "0x5220836980697693fE2137b64e545f926856feAe",
            "0xC49D7d886CA02C438c413ceabE6C1f8138ED6ef8",
            "0x049e9466CD2417A615e98DD7233eeec4Fcf5632D",
            "0x111FbB56b0B5c97F2896Ee722A917b261bCC77fC",
            "0xF3F66e5C119620eBDbD7Fb48B4b5d365De5c9750"]
    }
    private var mockTransactionChecker: MockTransactionChecker = .init()

    func testDeriveWithoutThrowOnWarning() async throws {
        let rootNode = try rootNode()

        let childNode = try await rootNode.derive(path: "m/44'/60'/8096'/0/1", throwOnWarning: false, transactionChecker: mockTransactionChecker)

        XCTAssertEqual(try XCTUnwrap(childNode).publicKey.toHexString(), "035785d4918449c87892371c0f9ccf6e4eda40a7fb0f773f1254c064d3bba64026")
        XCTAssertEqual(mockTransactionChecker.addresses.count, 0)
    }

    func testDeriveInvalidPath() async throws {
        let rootNode = try rootNode()

        let childNode = try? await rootNode.derive(path: "", throwOnWarning: true, transactionChecker: mockTransactionChecker)

        XCTAssertNil(childNode)
        XCTAssertEqual(mockTransactionChecker.addresses.count, 0)
    }

    // MARK: - address

    func testZeroAccountNeverThrow() async throws {
        let rootNode = try rootNode()

        let childNode = try await rootNode.derive(path: "m/44'/60'/0'/0/255", throwOnWarning: true, transactionChecker: mockTransactionChecker)

        XCTAssertEqual(try XCTUnwrap(childNode).publicKey.toHexString(), "0262fba1af8f149258123265318114066decf50d16c1222a9d657b7de2296c2734")
        XCTAssertEqual(mockTransactionChecker.addresses.count, 0)
    }

    func testFirstAccountWithNoPreviousTransactionHistory() async throws {
        do {
            let rootNode = try rootNode()
            let path = "m/44'/60'/1'/0/0"
            var results = false.times(n: 20)
            results.append(true)
            mockTransactionChecker.results = results

            _ = try await rootNode.derive(path: path, throwOnWarning: true, transactionChecker: mockTransactionChecker)

            XCTFail("Child must not be created using throwOnWarning true for the path: \(path)")
        } catch BIP44Error.warning {
            XCTAssertEqual(mockTransactionChecker.addresses, accountZeroScannedAddresses)
        }
    }

    func testFirstAccountWithPreviousTransactionHistory() async throws {
        do {
            let rootNode = try rootNode()
            let path = "m/44'/60'/1'/0/0"
            var results = false.times(n: 19)
            results.append(true)
            mockTransactionChecker.results = results

            let childNode = try await rootNode.derive(path: path, throwOnWarning: true, transactionChecker: mockTransactionChecker)

            XCTAssertEqual(try XCTUnwrap(childNode).publicKey.toHexString(), "036cd8f1bad46fa7caf7a80d48528b90db2a3b7a5c9a18d74d61b286e03850abf4")
            XCTAssertEqual(mockTransactionChecker.addresses, accountZeroScannedAddresses)
        } catch BIP44Error.warning {
            XCTFail("BIP44Error.warning must not be thrown")
        }
    }

    func testSecondAccountWithNoPreviousTransactionHistory() async throws {
        do {
            let rootNode = try rootNode()
            let path = "m/44'/60'/2'/0/0"
            var results: [Bool] = .init()
            results.append(true)
            results.append(contentsOf: false.times(n: 20))
            mockTransactionChecker.results = results

            _ = try await rootNode.derive(path: path, throwOnWarning: true, transactionChecker: mockTransactionChecker)

            XCTFail("Child must not be created using throwOnWarning true for the path: \(path)")
        } catch BIP44Error.warning {
            XCTAssertEqual(mockTransactionChecker.addresses, accountZeroAndOneScannedAddresses)
            XCTAssertEqual(mockTransactionChecker.addresses.count, 21)
        }
    }

    // MARK: - change + addressIndex

    func testNotZeroChangeAndAddressIndexWithPreviousTransactionHistory() async throws {
        do {
            let rootNode = try rootNode()
            let path = "m/44'/60'/1'/1/128"
            var results = false.times(n: 19)
            results.append(true)
            mockTransactionChecker.results = results

            let childNode = try await rootNode.derive(path: path, throwOnWarning: true, transactionChecker: mockTransactionChecker)

            XCTAssertEqual(try XCTUnwrap(childNode).publicKey.toHexString(), "0282134e44d4c040a4b4c1a780d8302955096cf1d5e738b161c83f0ce1b863c14e")
            XCTAssertEqual(mockTransactionChecker.addresses, accountZeroScannedAddresses)
        } catch BIP44Error.warning {
            XCTFail("BIP44Error.warning must not be thrown")
        }
    }

    // MARK: - private

    private func rootNode() throws -> HDNode {
        let mnemonic = "fruit wave dwarf banana earth journey tattoo true farm silk olive fence"
        let seed = try XCTUnwrap(BIP39.seedFromMmemonics(mnemonic, password: ""))
        return try XCTUnwrap(HDNode(seed: seed))
    }
}

// MARK: - BIP44ErrorTests

final class BIP44ErrorTests: XCTestCase {
    func testLocalizedDescription() {
        let error = BIP44Error.warning
        XCTAssertEqual(error.localizedDescription, "Couldn't derive key as it doesn't have a previous account with at least one transaction")
    }
}

// MARK: - helper

private extension Bool {
    func times(n: Int) -> [Bool] {
        var array: [Bool] = .init()
        (0..<n).forEach { _ in
            array.append(self)
        }
        return array
    }
}

// MARK: - test double

private final class MockTransactionChecker: TransactionChecker {
    var addresses: [String] = .init()
    var results: [Bool] = .init()

    func hasTransactions(ethereumAddress: EthereumAddress) async throws -> Bool {
        addresses.append(ethereumAddress.address)
        return results.removeFirst()
    }
}
