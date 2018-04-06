//
//  Web3+ConversionOperations.swift
//  web3swift
//
//  Created by Alexander Vlasov on 05.04.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import Result
import BigInt

final class BigUIntConversionOperation: Web3Operation {
    
    override func main() {
        if (error != nil) {
            return self.processError(self.error!)
        }
        guard let _ = self.next else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard inputData != nil else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let input = inputData! as? [String: Any] else {return processError(Web3Error.dataError)}
        let result = ResultUnwrapper.getResponse(input)
        switch result {
        case .failure(let error):
            return processError(error)
        case .success(let payload):
            guard let resultString = payload as? String else {
                return processError(Web3Error.dataError)
            }
            guard let biguint = BigUInt(resultString.stripHexPrefix().lowercased(), radix: 16) else {
                return processError(Web3Error.dataError)
            }
            return processSuccess(biguint as AnyObject)
        }
    }
}

final class JSONasDataConversionOperation: Web3Operation {
    
    override func main() {
        if (error != nil) {
            return self.processError(self.error!)
        }
        guard let _ = self.next else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard inputData != nil else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let input = inputData! as? [String: Any] else {return processError(Web3Error.dataError)}
        let result = ResultUnwrapper.getResponse(input)
        switch result {
        case .failure(let error):
            return processError(error)
        case .success(let payload):
            guard let resultJSON = payload as? [String:AnyObject] else {
                return processError(Web3Error.dataError)
            }
            guard let resultData = try? JSONSerialization.data(withJSONObject: resultJSON) else {
                return processError(Web3Error.dataError)
            }
            return processSuccess(resultData as AnyObject)
        }
    }
}

final class DictionaryConversionOperation: Web3Operation {
    
    override func main() {
        if (error != nil) {
            return self.processError(self.error!)
        }
        guard let _ = self.next else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard inputData != nil else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let input = inputData! as? [String: Any] else {return processError(Web3Error.dataError)}
        let result = ResultUnwrapper.getResponse(input)
        switch result {
        case .failure(let error):
            return processError(error)
        case .success(let payload):
            guard let dict = payload as? [String:Any] else {
                return processError(Web3Error.dataError)
            }
            return processSuccess(dict as AnyObject)
        }
    }
}

final class StringDictionaryConversionOperation: Web3Operation {
    
    override func main() {
        if (error != nil) {
            return self.processError(self.error!)
        }
        guard let _ = self.next else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard inputData != nil else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let input = inputData! as? [String: Any] else {return processError(Web3Error.dataError)}
        let result = ResultUnwrapper.getResponse(input)
        switch result {
        case .failure(let error):
            return processError(error)
        case .success(let payload):
            guard let dict = payload as? [String:String] else {
                return processError(Web3Error.dataError)
            }
            return processSuccess(dict as AnyObject)
        }
    }
}

final class AddressArrayConversionOperation: Web3Operation {
    
    override func main() {
        if (error != nil) {
            return self.processError(self.error!)
        }
        guard let _ = self.next else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard inputData != nil else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let input = inputData! as? [String: Any] else {return processError(Web3Error.dataError)}
        let result = ResultUnwrapper.getResponse(input)
        switch result {
        case .failure(let error):
            return processError(error)
        case .success(let payload):
            guard let resultArray = payload as? [String]  else {
                return processError(Web3Error.dataError)
            }
            var toReturn = [EthereumAddress]()
            for addrString in resultArray {
                let addr = EthereumAddress(addrString)
                if (addr.isValid) {
                    toReturn.append(addr)
                }
            }
            return processSuccess(toReturn as AnyObject)
        }
    }
}

final class DataConversionOperation: Web3Operation {
    
    override func main() {
        if (error != nil) {
            return self.processError(self.error!)
        }
        guard let _ = self.next else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard inputData != nil else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let input = inputData! as? [String: Any] else {return processError(Web3Error.dataError)}
        let result = ResultUnwrapper.getResponse(input)
        switch result {
        case .failure(let error):
            return processError(error)
        case .success(let payload):
            guard let dataString = payload as? String  else {
                return processError(Web3Error.dataError)
            }
            guard let data = Data.fromHex(dataString) else {
                return processError(Web3Error.dataError)
            }
            return processSuccess(data as AnyObject)
        }
    }
}

final class StringConversionOperation: Web3Operation {
    
    override func main() {
        if (error != nil) {
            return self.processError(self.error!)
        }
        guard let _ = self.next else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard inputData != nil else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let input = inputData! as? [String: Any] else {return processError(Web3Error.dataError)}
        let result = ResultUnwrapper.getResponse(input)
        switch result {
        case .failure(let error):
            return processError(error)
        case .success(let payload):
            guard let resultString = payload as? String  else {
                return processError(Web3Error.dataError)
            }
            return processSuccess(resultString as AnyObject)
        }
    }
}

final class FlattenOperation: Web3Operation {
    
    override func main() {
        if (error != nil) {
            return self.processError(self.error!)
        }
        guard let _ = self.next else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard inputData != nil else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let input = inputData! as? [AnyObject?] else {return processError(Web3Error.dataError)}
        let notNilElements = input.filter { (el) -> Bool in
            return el != nil
        }
        return processSuccess(notNilElements as AnyObject)
    
    }
}
