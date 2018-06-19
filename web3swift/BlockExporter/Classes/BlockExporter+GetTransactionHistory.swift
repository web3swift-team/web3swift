//
//  BlockExporter+GetTransactionHistory.swift
//  web3swift-iOS
//
//  Created by Георгий Фесенко on 19/06/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import PromiseKit

enum ListId: String {
    case listOfETH
    case listOfTokens
}

extension Scan {
    public func getTransactionsHistory(address publicAddress: String, tokenName name: String = "Ether", page: Int = 1, size: Int = 50) -> Promise<[Transaction]> {
        
        //Configuring http request
        var listId: ListId
        if name == "Ether" {
            listId = .listOfETH
        } else {
            listId = .listOfTokens
        }
        
        let url = URL(string: urlStringList)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let internalParams: [String: Any] = ["entityId": publicAddress, "page": page, "size": size]
        let parameters: [String: Any] = ["listId": listId.rawValue, "moduleId": "address", "params": internalParams]
        
        
        return Promise<[Transaction]> {seal in
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
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

public struct Response: Decodable {
    let rows: [Transaction]
    let head: Head
}

public struct Transaction: Decodable {
    
    let id: String
    let hash: String
    let block: Int
    let addrFrom: String
    let addrTo: String
    let isoTime: String
    let type: String
    let status: Int
    let error: String
    let isContract: Int
    let isInner: Int
    let value: String
    let token: Token
    let txFee: String
    let gasUsed: Double
    let gasCost: Double
    
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case hash
        case block
        case addrFrom = "addrfrom"
        case addrTo = "addrto"
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
    let addr: String
    let name: String
    let smbl: String
    let dcm: Int
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



