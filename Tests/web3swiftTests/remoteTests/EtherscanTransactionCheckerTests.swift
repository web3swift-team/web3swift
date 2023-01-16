//
//  EtherscanTransactionCheckerTests.swift
//  Created by albertopeam on 28/12/22.
//

import XCTest
@testable import Web3Core

final class EtherscanTransactionCheckerTests: XCTestCase {
    private var testApiKey: String { "4HVPVMV1PN6NGZDFXZIYKEZRP53IA41KVC" }
    private var vitaliksAddress: String { "0xAb5801a7D398351b8bE11C439e05C5B3259aeC9B" }
    private var emptyAddress: String { "0x1BeY3KhtHpfATH5Yqxz9d8Z1XbqZFSXtK7" }

    func testHasTransactions() async throws {
        let sut = EtherscanTransactionChecker(urlSession: URLSession.shared, apiKey: testApiKey)

        let result = try await sut.hasTransactions(address: vitaliksAddress)

        XCTAssertTrue(result)
    }

    func testHasNotTransactions() async throws {
        let sut = EtherscanTransactionChecker(urlSession: URLSession.shared, apiKey: testApiKey)

        let result = try await sut.hasTransactions(address: emptyAddress)

        XCTAssertFalse(result)
    }

    func testNetworkError() async throws {
        do {
            let urlSessionMock = URLSessionMock()
            urlSessionMock.response = (Data(), try XCTUnwrap(HTTPURLResponse(url: try XCTUnwrap(URL(string: "https://")), statusCode: 500, httpVersion: nil, headerFields: nil)))
            let sut = EtherscanTransactionChecker(urlSession: urlSessionMock, apiKey: testApiKey)

            _ = try await sut.hasTransactions(address: vitaliksAddress)

            XCTFail("Network must throw an error")
        } catch {
            XCTAssertTrue(true)
        }
    }

    func testInitURLError() async throws {
        do {
            let sut = EtherscanTransactionChecker(urlSession: URLSessionMock(), apiKey: testApiKey)

            _ = try await sut.hasTransactions(address: " ")

            XCTFail("URL init must throw an error")
        } catch {
            XCTAssertTrue(error is EtherscanTransactionCheckerError)
        }
    }

    func testWrongApiKey() async throws {
        do {
            let sut = EtherscanTransactionChecker(urlSession: URLSession.shared, apiKey: "")

            _ = try await sut.hasTransactions(address: "")

            XCTFail("API not returns a valid response")
        } catch DecodingError.typeMismatch {
            XCTAssertTrue(true)
        }
    }
}

// MARK: - EtherscanTransactionCheckerErrorTests

final class EtherscanTransactionCheckerErrorTests: XCTestCase {
    func testLocalizedDescription() {
        let error = EtherscanTransactionCheckerError.invalidUrl(url: "mock url")
        XCTAssertEqual(error.localizedDescription, "Couldn't create URL(string: mock url)")
    }
}

// MARK: - test double

final private class URLSessionMock: URLSessionProxy {
    var response: (Data, URLResponse) = (Data(), URLResponse())

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        return response
    }
}
