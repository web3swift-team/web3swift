//
//  Created by Alexander Vlasov.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt
import Core

public class EthereumContract: DefaultContractProtocol {

    public var transactionOptions: TransactionOptions? = TransactionOptions.defaultOptions
    public var address: EthereumAddress? = nil

    public let abi: [ABI.Element]

    private(set) public lazy var methods: [String: [ABI.Element.Function]] = {
        var methods = [String: [ABI.Element.Function]]()

        func appendFunction(_ key: String, _ value: ABI.Element.Function) {
            var array = methods[key] ?? []
            array.append(value)
            methods[key] = array
        }

        for case let .function(function) in abi where function.name != nil {
            appendFunction(function.name!, function)
            appendFunction(function.signature, function)
            appendFunction(function.methodString.addHexPrefix().lowercased(), function)

            /// ABI cannot have two functions with exactly the same name and input arguments
            if (methods[function.signature]?.count ?? 0) > 1 {
                fatalError("Given ABI is invalid: contains two functions with possibly different return values but exactly the same name and input parameters!")
            }
        }
        return methods
    }()

    private(set) public lazy var allMethods: [ABI.Element.Function] = {
        return methods.filter { pair in
            let data = Data.fromHex(pair.key)
            return data?.count == 4
        }.values.flatMap { $0 }
    }()

    private(set) public lazy var events: [String: ABI.Element.Event] = {
        var events = [String: ABI.Element.Event]()
        for case let .event(event) in abi {
            events[event.name] = event
        }
        return events
    }()

    private(set) public lazy var allEvents: [ABI.Element.Event] = {
        return Array(events.values)
    }()

    private(set) public lazy var constructor: ABI.Element.Constructor = {
        for element in abi {
            switch element {
            case let .constructor(constructor):
                return constructor
            default:
                continue
            }
        }
        return ABI.Element.Constructor(inputs: [], constant: false, payable: false)
    }()

    public init(abi: [ABI.Element]) {
        self.abi = abi
    }

    public init(abi: [ABI.Element], at: EthereumAddress) {
        self.abi = abi
        address = at
    }

    public required init?(_ abiString: String, at: EthereumAddress? = nil) {
        do {
            let jsonData = abiString.data(using: .utf8)
            let abi = try JSONDecoder().decode([ABI.Record].self, from: jsonData!)
            let abiNative = try abi.map({ (record) -> ABI.Element in
                return try record.parse()
            })
            self.abi = abiNative
            if at != nil {
                self.address = at
            }
        } catch {
            return nil
        }
    }

}
