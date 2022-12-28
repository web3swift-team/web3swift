//
//  EtherscanTransactionCheckerTests.swift
//  Created by albertopeam on 28/12/22.
//

import XCTest
@testable import Web3Core

final class EtherscanTransactionCheckerTests: XCTestCase {
    private var testApiKey: String!
    private var vitaliksAddress: String!
    private var emptyAddress: String!

    override func setUpWithError() throws {
        try super.setUpWithError()
        testApiKey = "4HVPVMV1PN6NGZDFXZIYKEZRP53IA41KVC"
        vitaliksAddress = "0xAb5801a7D398351b8bE11C439e05C5B3259aeC9B"
        emptyAddress = "0x1BeY3KhtHpfATH5Yqxz9d8Z1XbqZFSXtK7"
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        testApiKey = nil
        vitaliksAddress = nil
        emptyAddress = nil
    }

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

final class URLSessionMock: URLSessionProxy {
    var response: (Data, HTTPURLResponse) = (Data(), HTTPURLResponse())

    func data(request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        return response
    }
}
