//
//  Web3+Eth.swift
//  web3swift
//
//  Created by Alexander Vlasov on 22.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt
import PromiseKit
import AwaitKit

extension web3.Eth {
    public func getTransactionCount(address: EthereumAddress, onBlock: String? = nil) -> Promise<BigUInt?> {
        return async {
            guard address.isValid else {return nil}
            var request = JSONRPCrequest()
            request.method = JSONRPCmethod.getTransactionCount
            let params = [address.address.lowercased(), "latest"] as Array<Encodable>
            let pars = JSONRPCparams(params: params)
            request.params = pars
            let response = try await(self.provider.send(request: request))
            if response == nil {
                return nil
            }
            guard let res = response else {return nil}
            if let error = res["error"] as? String {
                print(error as String)
                return nil
            }
            guard let resultString = res["result"] as? String else {return nil}
            let responseData = Data(Array<UInt8>(hex: resultString.lowercased().stripHexPrefix()))
            guard responseData != Data() else {return nil}
            let txcount = BigUInt(responseData)
            return txcount
        }
    }

}
