//
//  Web3+DataFetchOperation.swift
//  web3swift
//
//  Created by Alexander Vlasov on 05.04.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import Result

final class DataFetchOperation: Web3Operation {
    
    override func main() {
        if (error != nil) {
            return self.processError(self.error!)
        }
        guard inputData != nil else {return}
        guard let input = inputData! as? JSONRPCrequest else {return}
        guard let result = self.web3.provider.send(request: input) else {return processError(Web3Error.connectionError)}
        processSuccess(result as AnyObject)
        return
    }
}
