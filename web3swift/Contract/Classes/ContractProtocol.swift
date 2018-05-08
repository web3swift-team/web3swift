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
//    func createEventFilter(eventName:String, filter: EventFilter?)
}

public struct EventFilter {
    public var parameterName: String
    public var parameterValues: [AnyObject]
}
