//
//  Created by Alexander Vlasov.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt

/// Default representation of a smart contract. Created out of an array of ``ABI/Element`` which could be functions, events,
/// constructor, errors and optional ``EthereumAddress`` that could be set later.
public class EthereumContract: DefaultContractProtocol {

    public var address: EthereumAddress?

    public let abi: [ABI.Element]
    public let methods: [String: [ABI.Element.Function]]
    public let allMethods: [ABI.Element.Function]
    public let events: [String: ABI.Element.Event]
    public let allEvents: [ABI.Element.Event]
    public let errors: [String: ABI.Element.EthError]
    public let allErrors: [ABI.Element.EthError]
    public let constructor: ABI.Element.Constructor

    public init(abi: [ABI.Element], at: EthereumAddress? = nil) throws {
        self.abi = abi
        address = at

        methods = try abi.getFunctions()
        allMethods = methods.filter { pair in
            let data = Data.fromHex(pair.key)
            return data?.count == 4
        }.values.flatMap { $0 }
        events = abi.getEvents()
        allEvents = Array(events.values)
        constructor = abi.getConstructor()
        errors = abi.getErrors()
        allErrors = Array(errors.values)
    }

    public convenience required init(_ abiString: String, at: EthereumAddress? = nil) throws {
        let jsonData = abiString.data(using: .utf8)
        let abi = try JSONDecoder().decode([ABI.Record].self, from: jsonData!)
        let abiNative = try abi.map({ record -> ABI.Element in
            return try record.parse()
        })
        try self.init(abi: abiNative, at: at)
    }
}
