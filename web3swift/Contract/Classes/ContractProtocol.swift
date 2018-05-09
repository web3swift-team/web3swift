//
//  ContractProtocol.swift
//  web3swift
//
//  Created by Alexander Vlasov on 04.04.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation

public protocol ContractProtocol {
    var address: EthereumAddress? {get set}
    var options: Web3Options? {get set}
    var allMethods: [String] {get}
    var allEvents: [String] {get}
    func deploy(bytecode:Data, parameters: [AnyObject], extraData: Data, options: Web3Options?) -> EthereumTransaction?
    func method(_ method:String, parameters: [AnyObject], extraData: Data, options: Web3Options?) -> EthereumTransaction?
    init?(_ abiString: String, at: EthereumAddress?)
    func decodeReturnData(_ method:String, data: Data) -> [String:Any]?
    func decodeInputData(_ method:String, data: Data) -> [String:Any]?
    func parseEvent(_ eventLog: EventLog) -> (eventName:String?, eventData:[String:Any]?)
    func testBloomForEventPrecence(eventName: String, bloom: EthereumBloomFilter) -> Bool?
//    func allEvents() -> [String: [String: Any]?]
}

public protocol EventFilterComparable {
    func isEqualTo(_ other: AnyObject) -> Bool
}

public protocol EventFilterEncodable {
    func eventFilterEncoded() -> String?
}

public protocol EventFilterable: EventFilterComparable, EventFilterEncodable {
    
}

public struct EventFilter {
    public enum Block {
        case latest
        case pending
        case blockNumber(UInt64)
        
        var encoded: String {
            switch self {
            case .latest:
                return "latest"
            case .pending:
                return "pending"
            case .blockNumber(let number):
                return String(number, radix: 16).addHexPrefix()
            }
        }
    }
    public var fromBlock: Block?
    public var toBlock: Block?
    public var addresses: [EthereumAddress]?
    public var parameterFilters: [[EventFilterable]?]?
}
