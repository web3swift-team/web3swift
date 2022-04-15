//
//  Created by Alexander Vlasov.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt

public struct EthereumContract: ContractProtocol {
    public var transactionOptions: TransactionOptions? = TransactionOptions.defaultOptions
    public var address: EthereumAddress? = nil

    var _abi: [ABI.Element]

    public var allEvents: [String] {
        return events.keys.compactMap({ (s) -> String in
            return s
        })
    }

    public var allMethods: [String] {
        return methods.keys.compactMap({ (s) -> String in
            return s
        })
    }

    public struct EventFilter {
        public var parameterName: String
        public var parameterValues: [AnyObject]
    }

    public var methods: [String: ABI.Element] {
        var toReturn = [String: ABI.Element]()
        for m in self._abi {
            switch m {
            case .function(let function):
                guard let name = function.name else {continue}
                toReturn[name] = m
            default:
                continue
            }
        }
        return toReturn
    }

    public var constructor: ABI.Element? {
        var toReturn: ABI.Element? = nil
        for m in self._abi {
            if toReturn != nil {
                break
            }
            switch m {
            case .constructor(_):
                toReturn = m
                break
            default:
                continue
            }
        }
        if toReturn == nil {
            let defaultConstructor = ABI.Element.constructor(ABI.Element.Constructor(inputs: [], constant: false, payable: false))
            return defaultConstructor
        }
        return toReturn
    }

    public var events: [String: ABI.Element.Event] {
        var toReturn = [String: ABI.Element.Event]()
        for m in self._abi {
            switch m {
            case .event(let event):
                let name = event.name
                toReturn[name] = event
            default:
                continue
            }
        }
        return toReturn
    }

    public init?(_ abiString: String, at: EthereumAddress? = nil) {
        do {
            let jsonData = abiString.data(using: .utf8)
            let abi = try JSONDecoder().decode([ABI.Record].self, from: jsonData!)
            let abiNative = try abi.map({ (record) -> ABI.Element in
                return try record.parse()
            })
            _abi = abiNative
            if at != nil {
                self.address = at
            }
        }
        catch{
            return nil
        }
    }

    public init(abi: [ABI.Element]) {
        _abi = abi
    }

    public init(abi: [ABI.Element], at: EthereumAddress) {
        _abi = abi
        address = at
    }

    public func deploy(bytecode: Data, parameters: [AnyObject] = [AnyObject](), extraData: Data = Data()) -> EthereumTransaction? {
        let to: EthereumAddress = EthereumAddress.contractDeploymentAddress()
        guard let constructor = self.constructor else {return nil}
        guard let encodedData = constructor.encodeParameters(parameters) else {return nil}
        var fullData = bytecode
        if encodedData != Data() {
            fullData.append(encodedData)
        } else if extraData != Data() {
            fullData.append(extraData)
        }
        let params = EthereumParameters(gasLimit: BigUInt(0), gasPrice: BigUInt(0))
        let transaction = EthereumTransaction(to: to, value: BigUInt(0), data: fullData, parameters: params)
        return transaction
    }

    public func method(_ method: String = "fallback", parameters: [AnyObject] = [AnyObject](), extraData: Data = Data()) -> EthereumTransaction? {
        guard let to = self.address else {return nil}

        if (method == "fallback") {
            let params = EthereumParameters(gasLimit: BigUInt(0), gasPrice: BigUInt(0))
            let transaction = EthereumTransaction(to: to, value: BigUInt(0), data: extraData, parameters: params)

            return transaction
        }
        let foundMethod = self.methods.filter { (key, value) -> Bool in
            return key == method
        }
        guard foundMethod.count == 1 else {return nil}
        let abiMethod = foundMethod[method]
        guard let encodedData = abiMethod?.encodeParameters(parameters) else {return nil}
        let params = EthereumParameters(gasLimit: BigUInt(0), gasPrice: BigUInt(0))
        let transaction = EthereumTransaction(to: to, value: BigUInt(0), data: encodedData, parameters: params)
        return transaction
    }

    public func parseEvent(_ eventLog: EventLog) -> (eventName: String?, eventData: [String: Any]?) {
        for (eName, ev) in self.events {
            if (!ev.anonymous) {
                if eventLog.topics[0] != ev.topic {
                    continue
                }
                else {
                    let logTopics = eventLog.topics
                    let logData = eventLog.data
                    let parsed = ev.decodeReturnedLogs(eventLogTopics: logTopics, eventLogData: logData)
                    if parsed != nil {
                        return (eName, parsed!)
                    }
                }
            } else {
                let logTopics = eventLog.topics
                let logData = eventLog.data
                let parsed = ev.decodeReturnedLogs(eventLogTopics: logTopics, eventLogData: logData)
                if parsed != nil {
                    return (eName, parsed!)
                }
            }
        }
        return (nil, nil)
    }

    public func testBloomForEventPrecence(eventName: String, bloom: EthereumBloomFilter) -> Bool? {
        guard let event = events[eventName] else {return nil}
        if event.anonymous {
            return true
        }
        let eventOfSuchTypeIsPresent = bloom.test(topic: event.topic)
        return eventOfSuchTypeIsPresent
    }

    public func decodeReturnData(_ method: String, data: Data) -> [String: Any]? {
        if method == "fallback" {
            return [String: Any]()
        }
        guard let function = methods[method] else {return nil}
        guard case .function(_) = function else {return nil}
        return function.decodeReturnData(data)
    }

    public func decodeInputData(_ method: String, data: Data) -> [String: Any]? {
        if method == "fallback" {
            return nil
        }
        guard let function = methods[method] else {return nil}
        switch function {
        case .function(_):
            return function.decodeInputData(data)
        case .constructor(_):
            return function.decodeInputData(data)
        default:
            return nil
        }
    }

    public func decodeInputData(_ data: Data) -> [String: Any]? {
        guard data.count % 32 == 4 else {return nil}
        let methodSignature = data[0..<4]
        let foundFunction = self._abi.filter { (m) -> Bool in
            switch m {
            case .function(let function):
                return function.methodEncoding == methodSignature
            default:
                return false
            }
        }
        guard foundFunction.count == 1 else {
            return nil
        }
        let function = foundFunction[0]
        return function.decodeInputData(Data(data[4 ..< data.count]))
    }
}
