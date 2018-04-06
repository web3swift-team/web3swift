//
//  Web3+NativePrimitivesConversionOperations.swift
//  web3swift
//
//  Created by Alexander Vlasov on 06.04.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import Result
import BigInt

final class TransactionReceiptConversionOperation: Web3Operation {
    
    override func main() {
        if (error != nil) {
            return self.processError(self.error!)
        }
        guard inputData != nil else {return}
        guard let input = inputData! as? [String: AnyObject] else {return processError(Web3Error.dataError)}
        guard let receipt = TransactionReceipt(input) else {
            return processError(Web3Error.dataError)
        }
        return processSuccess(receipt as AnyObject)
    }
}

final class BlockConversionOperation: Web3Operation {
    
    override func main() {
        if (error != nil) {
            return self.processError(self.error!)
        }
        guard inputData != nil else {return}
        guard let input = inputData! as? Data else {return processError(Web3Error.dataError)}
        guard let block = try? JSONDecoder().decode(Block.self, from: input) else {
            return processError(Web3Error.dataError)
        }
        return processSuccess(block as AnyObject)
    }
}
