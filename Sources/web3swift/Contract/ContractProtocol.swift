//
//  ContractProtocol.swift
//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt

public protocol ContractProtocol {
    var address: EthereumAddress? {get set}
    var transactionOptions: TransactionOptions? {get set}
    var allMethods: [String] {get}
    var allEvents: [String] {get}
    func deploy(bytecode: Data, parameters: [AnyObject], extraData: Data) -> EthereumTransaction?
    func method(_ method: String, parameters: [AnyObject], extraData: Data) -> EthereumTransaction?
    init?(_ abiString: String, at: EthereumAddress?)
    func decodeReturnData(_ method: String, data: Data) -> [String: Any]?
    func decodeInputData(_ method: String, data: Data) -> [String: Any]?
    func decodeInputData(_ data: Data) -> [String: Any]?
    func parseEvent(_ eventLog: EventLog) -> (eventName:String?, eventData:[String: Any]?)
    func testBloomForEventPrecence(eventName: String, bloom: EthereumBloomFilter) -> Bool?
}

public protocol EventFilterComparable {
    func isEqualTo(_ other: AnyObject) -> Bool
}

public protocol EventFilterEncodable {
    func eventFilterEncoded() -> String?
}

public protocol EventFilterable: EventFilterComparable, EventFilterEncodable { }

extension BigUInt: EventFilterable { }
extension BigInt: EventFilterable { }
extension Data: EventFilterable { }
extension String: EventFilterable { }
extension EthereumAddress: EventFilterable { }

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

    public init(fromBlock: Block? = nil,
                toBlock: Block? = nil,
                addresses: [EthereumAddress]? = nil,
                parameterFilters: [[EventFilterable]?]? = nil) {
        self.fromBlock = fromBlock
        self.toBlock = toBlock
        self.addresses = addresses
        self.parameterFilters = parameterFilters
    }

    public var fromBlock: Block?
    public var toBlock: Block?
    public var addresses: [EthereumAddress]?
    public var parameterFilters: [[EventFilterable]?]?

    public func rpcPreEncode() -> EventFilterParameters {
        var encoding = EventFilterParameters()
        if self.fromBlock != nil {
            encoding.fromBlock = self.fromBlock!.encoded
        }
        if self.toBlock != nil {
            encoding.toBlock = self.toBlock!.encoded
        }
        if self.addresses != nil {
            if self.addresses!.count == 1 {
                encoding.address = [self.addresses![0].address]
            } else {
                var encodedAddresses = [String?]()
                for addr in self.addresses! {
                    encodedAddresses.append(addr.address)
                }
                encoding.address = encodedAddresses
            }
        }
        return encoding
    }
}
