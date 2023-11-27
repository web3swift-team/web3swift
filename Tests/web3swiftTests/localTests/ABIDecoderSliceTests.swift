//
//  ABIDecoderSliceTests.swift
//  localTests
//
//  Created by 6od9i on 24.03.2023.
//

import Foundation
import Web3Core
import XCTest
import BigInt
@testable import web3swift

final class ABIDecoderSliceTests: XCTestCase {
    func testBallancesDataSlice() throws {
        /// Arrange
        let balanceofMethod = try EthereumContract(Web3.Utils.erc20ABI).methods["balanceOf"]!.first!
        let correctValues = ["13667129429770787859", "3298264", "47475", "19959", "607690442193821", "999170411478050086"]
        let hex6Responses =
        "000000000000000000000000000000000000000000000000bdab65ce08c65c1300000000000000000000000000000000000000000000000000000000003253d8000000000000000000000000000000000000000000000000000000000000b9730000000000000000000000000000000000000000000000000000000000004df7000000000000000000000000000000000000000000000000000228b0f4f0bb9d0000000000000000000000000000000000000000000000000dddc432063ae526"
        let data = Data(hex: hex6Responses)
        let answerSize = 32
        var startIndex = 0
        var results = [String]()

        /// Act
        while startIndex < data.count {
            let slice = data[startIndex ..< startIndex + answerSize]
            startIndex += answerSize
            guard let bigInt = try balanceofMethod.decodeReturnData(slice)["0"] as? BigUInt else {
                throw Web3Error.processingError(desc: "Can not decode returned parameters")
            }
            let value = Utilities.formatToPrecision(bigInt, units: .wei)
            results.append(value)
        }

        /// Assert
        XCTAssertEqual(correctValues, results)
    }

    func testDecodeMulticallDifferentValues() async throws {
        /// Arrange
        let multiCall2Contract = try EthereumContract(Self.multiCall2, at: nil)
        let differentRequestsContract = try EthereumContract(Self.differentRequestsContract, at: nil)

        let data = Data(hex: "0000000000000000000000000000000000000000000000000000000001980dd40000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000000300000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000120000000000000000000000000000000000000000000000000000000000000016000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000001af3f329e8be154074d8769d1ffa4ee058b1dbc3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000038d7ea4c68000000000000000000000000000000000000000000000000000000000006358d8a5000000000000000000000000000000000000000000000000000000007628d02500000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000212295b818158b400000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000")

        let methods = [differentRequestsContract.methods["arrayValue"]?.first,
                       differentRequestsContract.methods["firstValue"]?.first,
                       differentRequestsContract.methods["secondValue"]?.first].compactMap({$0})

        XCTAssertEqual(methods.count, 3)

        /// Act
        let decodedData = try multiCall2Contract.decodeReturnData("aggregate", data: data)

        guard let returnData = decodedData["returnData"] as? [Data] else {
            throw Web3Error.dataError
        }

        XCTAssertEqual(returnData.count, 3)

        for item in methods.enumerated() {
            XCTAssertNotNil(try item.element.decodeReturnData(returnData[item.offset])["0"])
        }
    }

    func testDecodeMulticallCopy() throws {
        /// Arrange
        let data = Data(hex: "0x00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000004fe6dab4abca350650")
        let contract = try EthereumContract(Self.multiCall2, at: nil)
        let erc20_balanceof = try EthereumContract(Web3.Utils.erc20ABI).methods["balanceOf"]!.first!

        /// Act
        let decodedData = try contract.decodeReturnData("tryAggregate", data: data)

        guard let returnData = decodedData["returnData"] as? [[Any]] else {
            throw Web3Error.dataError
        }
        var resultArray = [BigUInt]()
        for i in 0..<2 {
            guard let data = returnData[i][1] as? Data,
                  let balance = try? erc20_balanceof.decodeReturnData(data)["0"] as? BigUInt else {
                resultArray.append(0)
                continue
            }
            resultArray.append(balance)
        }

        /// Assert
        XCTAssert(resultArray.count == 2)
    }
}

extension ABIDecoderSliceTests {
    public static let differentRequestsContract = "[{\"inputs\":[],\"name\":\"firstValue\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"arrayValue\",\"outputs\":[{\"internalType\":\"contract IERC20\",\"name\":\"token\",\"type\":\"address\"},{\"internalType\":\"enum IInstanceV1.Period\",\"name\":\"period\",\"type\":\"uint8\"},{\"internalType\":\"uint256\",\"name\":\"value\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"startTime\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"endTime\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"secondValue\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"}]"

    public static let multiCall2 = "[{\"inputs\":[{\"components\":[{\"internalType\":\"address\",\"name\":\"target\",\"type\":\"address\"},{\"internalType\":\"bytes\",\"name\":\"callData\",\"type\":\"bytes\"}],\"internalType\":\"struct Multicall2.Call[]\",\"name\":\"calls\",\"type\":\"tuple[]\"}],\"name\":\"aggregate\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"blockNumber\",\"type\":\"uint256\"},{\"internalType\":\"bytes[]\",\"name\":\"returnData\",\"type\":\"bytes[]\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"components\":[{\"internalType\":\"address\",\"name\":\"target\",\"type\":\"address\"},{\"internalType\":\"bytes\",\"name\":\"callData\",\"type\":\"bytes\"}],\"internalType\":\"struct Multicall2.Call[]\",\"name\":\"calls\",\"type\":\"tuple[]\"}],\"name\":\"blockAndAggregate\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"blockNumber\",\"type\":\"uint256\"},{\"internalType\":\"bytes32\",\"name\":\"blockHash\",\"type\":\"bytes32\"},{\"components\":[{\"internalType\":\"bool\",\"name\":\"success\",\"type\":\"bool\"},{\"internalType\":\"bytes\",\"name\":\"returnData\",\"type\":\"bytes\"}],\"internalType\":\"struct Multicall2.Result[]\",\"name\":\"returnData\",\"type\":\"tuple[]\"}],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"blockNumber\",\"type\":\"uint256\"}],\"name\":\"getBlockHash\",\"outputs\":[{\"internalType\":\"bytes32\",\"name\":\"blockHash\",\"type\":\"bytes32\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"getBlockNumber\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"blockNumber\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"getCurrentBlockCoinbase\",\"outputs\":[{\"internalType\":\"address\",\"name\":\"coinbase\",\"type\":\"address\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"getCurrentBlockDifficulty\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"difficulty\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"getCurrentBlockGasLimit\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"gaslimit\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"getCurrentBlockTimestamp\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"timestamp\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"addr\",\"type\":\"address\"}],\"name\":\"getEthBalance\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"balance\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"getLastBlockHash\",\"outputs\":[{\"internalType\":\"bytes32\",\"name\":\"blockHash\",\"type\":\"bytes32\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bool\",\"name\":\"requireSuccess\",\"type\":\"bool\"},{\"components\":[{\"internalType\":\"address\",\"name\":\"target\",\"type\":\"address\"},{\"internalType\":\"bytes\",\"name\":\"callData\",\"type\":\"bytes\"}],\"internalType\":\"struct Multicall2.Call[]\",\"name\":\"calls\",\"type\":\"tuple[]\"}],\"name\":\"tryAggregate\",\"outputs\":[{\"components\":[{\"internalType\":\"bool\",\"name\":\"success\",\"type\":\"bool\"},{\"internalType\":\"bytes\",\"name\":\"returnData\",\"type\":\"bytes\"}],\"internalType\":\"struct Multicall2.Result[]\",\"name\":\"returnData\",\"type\":\"tuple[]\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bool\",\"name\":\"requireSuccess\",\"type\":\"bool\"},{\"components\":[{\"internalType\":\"address\",\"name\":\"target\",\"type\":\"address\"},{\"internalType\":\"bytes\",\"name\":\"callData\",\"type\":\"bytes\"}],\"internalType\":\"struct Multicall2.Call[]\",\"name\":\"calls\",\"type\":\"tuple[]\"}],\"name\":\"tryBlockAndAggregate\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"blockNumber\",\"type\":\"uint256\"},{\"internalType\":\"bytes32\",\"name\":\"blockHash\",\"type\":\"bytes32\"},{\"components\":[{\"internalType\":\"bool\",\"name\":\"success\",\"type\":\"bool\"},{\"internalType\":\"bytes\",\"name\":\"returnData\",\"type\":\"bytes\"}],\"internalType\":\"struct Multicall2.Result[]\",\"name\":\"returnData\",\"type\":\"tuple[]\"}],\"stateMutability\":\"nonpayable\",\"type\":\"function\"}]"
}
