//
//  web3swift_ST20_Tests.swift
//  web3swift-iOS_Tests
//
//  Created by Anton on 15/03/2019.
//  Copyright © 2019 The Matter Inc. All rights reserved.
//
import XCTest
import BigInt
import web3swift
import Core

@testable import web3swift

class ST20AndSecurityTokenTests: XCTestCase {

    var web3: Web3!
    var ethMock: Web3EthMock!
    var st20token: ST20!
    var securityToken: SecurityToken!

    override func setUp() async throws {
        web3 = await Web3.InfuraGoerliWeb3(accessToken: Constants.infuraToken)
        ethMock = Web3EthMock(provider: web3.provider, web3: web3)
        web3.ethInstance = ethMock
        st20token = ST20.init(web3: web3, provider: web3.provider, address: .contractDeploymentAddress())
        securityToken = SecurityToken.init(web3: web3, provider: web3.provider, address: .contractDeploymentAddress())
    }

    func testST20TokenPropertiesBasedOnERC20() async throws {
        let expectedSymbol = "RandomTokenSymbol953"
        let expectedName = "WhatA NAME - l953. Never seen again!"
        let expectedDecimals = UInt8.random(in: 0...255)

        ethMock.onCallTransaction = { transaction in
            guard let function = self.st20token.contract.contract.getFunctionCalled(transaction.data) else {
                XCTFail("Failed to decode function call to determine what shall be returned")
                return Data()
            }
            switch function.name {
            case "symbol":
                return ABIEncoder.encode(types: [.string], values: [expectedSymbol] as [AnyObject])!
            case "name":
                return ABIEncoder.encode(types: [.string], values: [expectedName] as [AnyObject])!
            case "decimals":
                return ABIEncoder.encode(types: [.uint(bits: 8)], values: [expectedDecimals] as [AnyObject])!
            default:
                // Unexpected function called
                XCTFail("Called function '\(String(describing: function.name))' which wasn't supposed to be called.")
                return Data()
            }
        }

        try await st20token.readProperties()
        XCTAssertEqual(st20token.symbol, expectedSymbol)
        XCTAssertEqual(st20token.name, expectedName)
        XCTAssertEqual(st20token.decimals, expectedDecimals)
    }

    func testST20TokenBalanceAndAllowance() async throws {
        let expectedAllowance = BigUInt.randomInteger(lessThan: BigUInt(10000000000))
        let expectedBalance = BigUInt.randomInteger(lessThan: BigUInt(10000000000))

        let userAddress = EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901")!
        let delegate = EthereumAddress("0x2dD33957C90880bE4Ee9fd5F703110BDA2E579EC")!

        ethMock.onCallTransaction = { transaction in
            guard let function = self.st20token.contract.contract.getFunctionCalled(transaction.data) else {
                XCTFail("Failed to decode function call to determine what shall be returned")
                return Data()
            }
            switch function.name {
            case "balanceOf":
                let address = function.decodeInputData(transaction.data)?["0"] as? EthereumAddress
                XCTAssertEqual(address, userAddress)
                return ABIEncoder.encode(types: [.uint(bits: 256)], values: [expectedBalance] as [AnyObject])!
            case "allowance":
                let transactionInput = function.decodeInputData(transaction.data)
                XCTAssertEqual(transactionInput?["0"] as? EthereumAddress, userAddress)
                XCTAssertEqual(transactionInput?["1"] as? EthereumAddress, delegate)
                return ABIEncoder.encode(types: [.uint(bits: 256)], values: [expectedAllowance] as [AnyObject])!
            default:
                // Unexpected function called
                XCTFail("Called function '\(String(describing: function.name))' which wasn't supposed to be called.")
                return Data()
            }
        }

        let balance = try await st20token.getBalance(account: userAddress)
        let allowance = try await st20token.getAllowance(originalOwner: userAddress, delegate: delegate)
        XCTAssertEqual(balance, expectedBalance)
        XCTAssertEqual(allowance, expectedAllowance)
    }

    func testSecurityTokenInvestors() async throws {
        let expectedNumberOfInvestors = BigUInt.randomInteger(lessThan: BigUInt(10000000000))
//        let expectedInvestors = [EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901")!,EthereumAddress("0x2dD33957C90880bE4Ee9fd5F703110BDA2E579EC")!]

        ethMock.onCallTransaction = { transaction in
            guard let function = self.securityToken.contract.contract.getFunctionCalled(transaction.data) else {
                XCTFail("Failed to decode function call to determine what shall be returned")
                return Data()
            }
            switch function.name {
            case "investorCount":
                return ABIEncoder.encode(types: [.uint(bits: 256)], values: [expectedNumberOfInvestors] as [AnyObject])!
//            case "investors":
//                return ABIEncoder.encode(types: [.array(type: .address, length: 0)],
//                                         values: [expectedInvestors] as [AnyObject])!
            default:
                // Unexpected function called
                XCTFail("Called function '\(String(describing: function.name))' which wasn't supposed to be called.")
                return Data()
            }
        }

        let investorsCount = try await securityToken.investorCount()
        XCTAssertEqual(investorsCount, expectedNumberOfInvestors)
//        XCTAssertEqual(investors, expectedInvestors)
    }

    func testSecurityTokenGranularity() async throws {
        let expectedGranularity = BigUInt.randomInteger(lessThan: BigUInt(10000000000))
        
        ethMock.onCallTransaction = { transaction in
            guard let function = self.securityToken.contract.contract.getFunctionCalled(transaction.data) else {
                XCTFail("Failed to decode function call to determine what shall be returned")
                return Data()
            }
            switch function.name {
            case "granularity":
                return ABIEncoder.encode(types: [.uint(bits: 256)], values: [expectedGranularity] as [AnyObject])!
            default:
                // Unexpected function called
                XCTFail("Called function '\(String(describing: function.name))' which wasn't supposed to be called.")
                return Data()
            }
        }

        let granularity = try await securityToken.getGranularity()
        XCTAssertEqual(granularity, expectedGranularity)
    }
}
