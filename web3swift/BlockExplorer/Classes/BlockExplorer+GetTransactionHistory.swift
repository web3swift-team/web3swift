//
//  BlockExporter+GetTransactionHistory.swift
//  web3swift-iOS
//
//  Created by Георгий Фесенко on 19/06/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import PromiseKit
import BigInt

extension BlockExplorer {
    public func getTransactionHistory(address: EthereumAddress, tokenName name: String = "Ether", page: Int = 1, size: Int = 50) -> Promise<[TransactionHistoryRecord]> {
        let address = address.address
        return getTransactionsHistory(address: address, tokenName: name, page: page, size: size)
    }
    
    public func getTransactionsHistory(address publicAddress: String, tokenName name: String = "Ether", page: Int = 1, size: Int = 50) -> Promise<[TransactionHistoryRecord]> {
        
        //Configuring http request
        let listId: ListId = (name == "Ether") ? .listOfETH : .listOfTokens
        let url = URL(string: urlStringList)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let internalParams = InternalParam(entityId: publicAddress, page: page, size: size)
        let parameters = Body(listId: listId.rawValue, moduleId: "address", params: internalParams)

        return Promise<[TransactionHistoryRecord]> {seal in
            do {
                request.httpBody = try JSONEncoder().encode(parameters)
            } catch {
                seal.reject(error)
            }
            //Performing the request
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                if let error = error { seal.reject(error); return }
                guard let data = data else { return }
                
                do {
                    //Parsing JSON
                    let jsonResponce = try JSONDecoder().decode(Response.self, from: data)
                    if listId == .listOfETH {
                        seal.fulfill(jsonResponce.rows)
                    } else {
                        seal.fulfill( jsonResponce.rows.filter { $0.token.name == name } )
                    }
                } catch {
                    seal.reject(error)
                }
            })
            task.resume()
        }
    }
}

//MARK: - Decodable structures

public struct Response: Decodable {
    let rows: [TransactionHistoryRecord]
    let head: Head
}

public struct TransactionHistoryRecord: Decodable {
    
    public let id: String
    public let hash: Data
    public let block: BigUInt
    public let addressFrom: EthereumAddress
    public let addressTo: EthereumAddress
    public let isoTime: String
    public let type: TransactionType
    public let status: TransactionStatus
    public let error: String
    public let isContract: Bool
    public let isInner: Bool
    public let value: BigUInt // in wei
    public let token: Token
    public let txFee: BigUInt // in wei
    public let gasUsed: BigUInt // in wei
    public let gasCost: BigUInt // in wei
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: CodingKeys.id)
        let hashString = try container.decode(String.self, forKey: CodingKeys.hash)
        guard let hashData  = Data.fromHex(hashString) else {
            throw Web3Error.transactionSerializationError
        }
        hash = hashData
        let intBlock = try container.decode(UInt64.self, forKey: CodingKeys.block)
        block = BigUInt.init(integerLiteral: intBlock)
        var stringAddressFrom = try container.decode(String.self, forKey: CodingKeys.addressFrom)
        if !stringAddressFrom.hasHexPrefix() {
            stringAddressFrom = stringAddressFrom.addHexPrefix()
        }
        guard let nativeAddressFrom = EthereumAddress(stringAddressFrom) else {
            throw Web3Error.transactionSerializationError
        }
        addressFrom = nativeAddressFrom
        var stringAddressTo = try container.decode(String.self, forKey: CodingKeys.addressTo)
        if !stringAddressTo.hasHexPrefix() {
            stringAddressTo = stringAddressTo.addHexPrefix()
        }
        guard let nativeAddressTo = EthereumAddress(stringAddressTo) else {
            throw Web3Error.transactionSerializationError
        }
        addressTo = nativeAddressTo
        isoTime = try container.decode(String.self, forKey: CodingKeys.isoTime)
        let stringType = try container.decode(String.self, forKey: CodingKeys.type)
        var nativeType: TransactionType
        switch stringType {
        case "tx":
            nativeType = .tx
        case "call":
            nativeType = .call
        case "create":
            nativeType = .create
        case "suicide":
            nativeType = .suicide
        case "token":
            nativeType = .token
        default:
            nativeType = .tx
        }
        type = nativeType
        
        let intStatus = try container.decode(Int.self, forKey: CodingKeys.status)
        status = intStatus == 0 ? .failed : .succeeded
        error = try container.decode(String.self, forKey: CodingKeys.error)
        let intIsContract = try container.decode(Int.self, forKey: CodingKeys.isContract)
        isContract = intIsContract == 0 ? false : true
        let intIsInner = try container.decode(Int.self, forKey: CodingKeys.isInner)
        isInner = intIsInner == 0 ? false : true
        let stringValue  = try container.decode(String.self, forKey: CodingKeys.value)
        guard let uintValue = UInt64(stringValue, radix: 16) else {
            throw Web3Error.transactionSerializationError
        }
        value = BigUInt(integerLiteral: uintValue)
        token = try container.decode(Token.self, forKey: CodingKeys.token)
        let stringTxFee = try container.decode(String.self, forKey: CodingKeys.txFee)
        guard let uintTxFee = UInt64(stringTxFee, radix: 16) else {
            throw Web3Error.transactionSerializationError
        }
        
        txFee = BigUInt.init(integerLiteral: uintTxFee)
        let intGasUsed = try container.decode(UInt64.self, forKey: CodingKeys.gasUsed)
        gasUsed = BigUInt(integerLiteral: intGasUsed)
        let intGasCost = try container.decode(UInt64.self, forKey: CodingKeys.gasCost)
        gasCost = BigUInt(integerLiteral: intGasCost)
    }
    
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case hash
        case block
        case addressFrom = "addrfrom"
        case addressTo = "addrto"
        case isoTime = "isotime"
        case type
        case status
        case error
        case isContract = "iscontract"
        case isInner = "isinner"
        case value
        case token
        case txFee = "txfee"
        case gasUsed = "gasused"
        case gasCost = "gascost"
    }
    
}

public struct Token: Decodable {
    public let address: EthereumAddress?
    public let name: String
    public let symbol: String
    public let decimal: Int
    
    enum CodingKeys: String, CodingKey {
        case address = "addr"
        case name
        case symbol = "smbl"
        case decimal = "dcm"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let stringAddress = try container.decode(String.self, forKey: CodingKeys.address)
        if !stringAddress.isEmpty {
            guard let nativeAddress = EthereumAddress(stringAddress, type: .normal, ignoreChecksum: true) else {
                throw Web3Error.transactionSerializationError
            }
            address = nativeAddress
        } else {
            address = nil
        }
        name = try container.decode(String.self, forKey: .name)
        symbol = try container.decode(String.self, forKey: .symbol)
        decimal = try container.decode(Int.self, forKey: .decimal)
    }
}

public struct Head: Decodable {
    let totalEntities: Int
    let pageNumber: Int
    let pageSize: Int
    let listId: String
    let moduleId: String
    let entityId: String
    let updateTime: String
}

//MARK: - enums
public enum TransactionType {
    case tx, call, create, suicide, token
}

public enum TransactionStatus {
    case failed, succeeded
}

public enum ListId: String {
    case listOfETH
    case listOfTokens
}

//MARK: - HTTP body structures
public struct Body:Codable {
    let listId:String
    let moduleId:String
    let params:InternalParam
}

public struct InternalParam:Codable {
    let entityId:String
    let page:Int
    let size:Int
}



