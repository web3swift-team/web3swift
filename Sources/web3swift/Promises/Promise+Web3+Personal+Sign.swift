//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import PromiseKit

extension web3.Personal {

    public func signPersonalMessagePromise(message: Data, from: EthereumAddress, password: String = "web3swift") -> Promise<Data> {
        let queue = web3.requestDispatcher.queue
        if self.web3.signer == nil {
            let hexData = message.toHexString().addHexPrefix()
            let request = JSONRPCRequestFabric.prepareRequest(.personalSign, parameters: [from.address.lowercased(), hexData])
            return self.web3.dispatch(request).map(on: queue) {response in
                guard let value: Data = response.getValue() else {
                    if response.error != nil {
                        throw Web3Error.nodeError(desc: response.error!.message)
                    }
                    throw Web3Error.nodeError(desc: "Invalid value from Ethereum node")
                }
                return value
            }
        }
        return self.web3.signer!.sign(message: message, with: from, using: password, on: queue)
    }
}
