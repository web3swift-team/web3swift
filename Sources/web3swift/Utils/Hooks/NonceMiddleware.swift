//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import Core

extension Web3.Utils {
    public class NonceMiddleware: EventLoopRunnableProtocol {
        var web3: Web3?
        var nonceLookups: [EthereumAddress: BigUInt] = [EthereumAddress: BigUInt]()
        public var name: String = "Nonce lookup middleware"
        public let queue: DispatchQueue = DispatchQueue(label: "Nonce middleware queue")
        public var synchronizationPeriod: TimeInterval = 300.0 // 5 minutes
        var lastSyncTime: Date = Date()

        public func functionToRun() async {
            guard let w3 = self.web3 else { return }
            let knownKeys = Array(nonceLookups.keys)

            await withTaskGroup(of: BigUInt?.self, returning: Void.self) { group -> Void in
                knownKeys.forEach { key in
                    group.addTask { try? await w3.eth.getTransactionCount(for: key, onBlock: .latest) }
                }

                var i = 0

                for await value in group {
                    let key = knownKeys[i]
                    self.nonceLookups[key] = value
                    i = i + 1
                }
            }
        }

        public init() { }
    }
}
