//
//  ABIDecoderTests.swift
//  
//
//  Created by liugang zhang on 2023/3/16.
//

import Foundation
import Web3Core
import XCTest
import BigInt
@testable import web3swift

final class ABIDecoderTests: XCTestCase {

    func testDecodeMulticall() throws {
        //  get result from http
        //
        //  let requests = tokenAddress.map { address -> AnyObject in
        //      let callData = erc20_balanceof.encodeParameters([account as NSString])
        //      return [address, callData as Any] as AnyObject
        //  } as AnyObject
        //
        //  let read = contract.createReadOperation(
        //      "tryAggregate",
        //      parameters: [false, requests] as [AnyObject]
        //  )
        //  let results = try await read?.callContractMethod()

        let data = Data(hex: "0x00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000004fe6dab4abca350650")
        let contract = try EthereumContract(Self.multiCall2, at: nil)
        let erc20_balanceof = try EthereumContract(Web3.Utils.erc20ABI).methods["balanceOf"]!.first!
        guard let decodedData = contract.decodeReturnData("tryAggregate", data: data) else {
            throw Web3Error.processingError(desc: "Can not decode returned parameters")
        }

        guard let returnData = decodedData["returnData"] as? [[Any]] else {
            throw Web3Error.dataError
        }
        var resultArray = [BigUInt]()
        for i in 0..<2 {
            guard let data = returnData[i][1] as? Data,
                  let balance = erc20_balanceof.decodeReturnData(data)["0"] as? BigUInt else {
                resultArray.append(0)
                continue
            }
            resultArray.append(balance)
        }
        print(resultArray)
        XCTAssert(resultArray.count == 2)
    }

    public static let multiCall2 = """
                     [
                       {
                         "inputs": [
                           {
                             "components": [
                               {
                                 "internalType": "address",
                                 "name": "target",
                                 "type": "address"
                               },
                               {
                                 "internalType": "bytes",
                                 "name": "callData",
                                 "type": "bytes"
                               }
                             ],
                             "internalType": "struct Multicall2.Call[]",
                             "name": "calls",
                             "type": "tuple[]"
                           }
                         ],
                         "name": "aggregate",
                         "outputs": [
                           {
                             "internalType": "uint256",
                             "name": "blockNumber",
                             "type": "uint256"
                           },
                           {
                             "internalType": "bytes[]",
                             "name": "returnData",
                             "type": "bytes[]"
                           }
                         ],
                         "payable": false,
                         "stateMutability": "view",
                         "type": "function"
                       },
                       {
                         "inputs": [
                           {
                             "components": [
                               {
                                 "internalType": "address",
                                 "name": "target",
                                 "type": "address"
                               },
                               {
                                 "internalType": "bytes",
                                 "name": "callData",
                                 "type": "bytes"
                               }
                             ],
                             "internalType": "struct Multicall2.Call[]",
                             "name": "calls",
                             "type": "tuple[]"
                           }
                         ],
                         "name": "blockAndAggregate",
                         "outputs": [
                           {
                             "internalType": "uint256",
                             "name": "blockNumber",
                             "type": "uint256"
                           },
                           {
                             "internalType": "bytes32",
                             "name": "blockHash",
                             "type": "bytes32"
                           },
                           {
                             "components": [
                               {
                                 "internalType": "bool",
                                 "name": "success",
                                 "type": "bool"
                               },
                               {
                                 "internalType": "bytes",
                                 "name": "returnData",
                                 "type": "bytes"
                               }
                             ],
                             "internalType": "struct Multicall2.Result[]",
                             "name": "returnData",
                             "type": "tuple[]"
                           }
                         ],
                         "stateMutability": "nonpayable",
                         "type": "function"
                       },
                       {
                         "inputs": [
                           {
                             "internalType": "uint256",
                             "name": "blockNumber",
                             "type": "uint256"
                           }
                         ],
                         "name": "getBlockHash",
                         "outputs": [
                           {
                             "internalType": "bytes32",
                             "name": "blockHash",
                             "type": "bytes32"
                           }
                         ],
                         "stateMutability": "view",
                         "type": "function"
                       },
                       {
                         "inputs": [],
                         "name": "getBlockNumber",
                         "outputs": [
                           {
                             "internalType": "uint256",
                             "name": "blockNumber",
                             "type": "uint256"
                           }
                         ],
                         "stateMutability": "view",
                         "type": "function"
                       },
                       {
                         "inputs": [],
                         "name": "getCurrentBlockCoinbase",
                         "outputs": [
                           {
                             "internalType": "address",
                             "name": "coinbase",
                             "type": "address"
                           }
                         ],
                         "stateMutability": "view",
                         "type": "function"
                       },
                       {
                         "inputs": [],
                         "name": "getCurrentBlockDifficulty",
                         "outputs": [
                           {
                             "internalType": "uint256",
                             "name": "difficulty",
                             "type": "uint256"
                           }
                         ],
                         "stateMutability": "view",
                         "type": "function"
                       },
                       {
                         "inputs": [],
                         "name": "getCurrentBlockGasLimit",
                         "outputs": [
                           {
                             "internalType": "uint256",
                             "name": "gaslimit",
                             "type": "uint256"
                           }
                         ],
                         "stateMutability": "view",
                         "type": "function"
                       },
                       {
                         "inputs": [],
                         "name": "getCurrentBlockTimestamp",
                         "outputs": [
                           {
                             "internalType": "uint256",
                             "name": "timestamp",
                             "type": "uint256"
                           }
                         ],
                         "stateMutability": "view",
                         "type": "function"
                       },
                       {
                         "inputs": [
                           {
                             "internalType": "address",
                             "name": "addr",
                             "type": "address"
                           }
                         ],
                         "name": "getEthBalance",
                         "outputs": [
                           {
                             "internalType": "uint256",
                             "name": "balance",
                             "type": "uint256"
                           }
                         ],
                         "stateMutability": "view",
                         "type": "function"
                       },
                       {
                         "inputs": [],
                         "name": "getLastBlockHash",
                         "outputs": [
                           {
                             "internalType": "bytes32",
                             "name": "blockHash",
                             "type": "bytes32"
                           }
                         ],
                         "stateMutability": "view",
                         "type": "function"
                       },
                       {
                         "inputs": [
                           {
                             "internalType": "bool",
                             "name": "requireSuccess",
                             "type": "bool"
                           },
                           {
                             "components": [
                               {
                                 "internalType": "address",
                                 "name": "target",
                                 "type": "address"
                               },
                               {
                                 "internalType": "bytes",
                                 "name": "callData",
                                 "type": "bytes"
                               }
                             ],
                             "internalType": "struct Multicall2.Call[]",
                             "name": "calls",
                             "type": "tuple[]"
                           }
                         ],
                         "name": "tryAggregate",
                         "outputs": [
                           {
                             "components": [
                               {
                                 "internalType": "bool",
                                 "name": "success",
                                 "type": "bool"
                               },
                               {
                                 "internalType": "bytes",
                                 "name": "returnData",
                                 "type": "bytes"
                               }
                             ],
                             "internalType": "struct Multicall2.Result[]",
                             "name": "returnData",
                             "type": "tuple[]"
                           }
                         ],
                         "payable": false,
                         "stateMutability": "view",
                         "type": "function"
                       },
                       {
                         "inputs": [
                           {
                             "internalType": "bool",
                             "name": "requireSuccess",
                             "type": "bool"
                           },
                           {
                             "components": [
                               {
                                 "internalType": "address",
                                 "name": "target",
                                 "type": "address"
                               },
                               {
                                 "internalType": "bytes",
                                 "name": "callData",
                                 "type": "bytes"
                               }
                             ],
                             "internalType": "struct Multicall2.Call[]",
                             "name": "calls",
                             "type": "tuple[]"
                           }
                         ],
                         "name": "tryBlockAndAggregate",
                         "outputs": [
                           {
                             "internalType": "uint256",
                             "name": "blockNumber",
                             "type": "uint256"
                           },
                           {
                             "internalType": "bytes32",
                             "name": "blockHash",
                             "type": "bytes32"
                           },
                           {
                             "components": [
                               {
                                 "internalType": "bool",
                                 "name": "success",
                                 "type": "bool"
                               },
                               {
                                 "internalType": "bytes",
                                 "name": "returnData",
                                 "type": "bytes"
                               }
                             ],
                             "internalType": "struct Multicall2.Result[]",
                             "name": "returnData",
                             "type": "tuple[]"
                           }
                         ],
                         "stateMutability": "nonpayable",
                         "type": "function"
                       }
                     ]
                     """
}
