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

@available(*, deprecated)
final class ResultUnwrapOperation: Web3Operation {
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
            return processSuccess(payload as AnyObject)
        }
    }
}

@available(*, deprecated)
final class ConversionOperation<T>: Web3Operation {
    override func main() {
        if (error != nil) {
            return self.processError(self.error!)
        }
        guard let _ = self.next else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard inputData != nil else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let input = inputData! as? T else {return processError(Web3Error.dataError)}
        return processSuccess(input as AnyObject)
    }
}

@available(*, deprecated)
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

@available(*, deprecated)
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

@available(*, deprecated)
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

@available(*, deprecated)
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

@available(*, deprecated)
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
                guard let addr = EthereumAddress(addrString) else {
                    return processError(Web3Error.dataError)
                }
                if (addr.isValid) {
                    toReturn.append(addr)
                }
            }
            return processSuccess(toReturn as AnyObject)
        }
    }
}

@available(*, deprecated)
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

@available(*, deprecated)
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

@available(*, deprecated)
final class JoinOperation: Web3Operation {
    convenience init(_ web3Instance: web3, queue: OperationQueue? = nil, operations: [Web3Operation]) {
        self.init(web3Instance, queue: queue, inputData: operations as AnyObject)
    }
    
    override func main() {
        if (error != nil) {
            return self.processError(self.error!)
        }
        guard let _ = self.next else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard inputData != nil else {return processError(Web3Error.inputError("Invalid input supplied"))}
        guard let operations = inputData! as? [Web3Operation] else {return processError(Web3Error.dataError)}
        var resultsArray = [AnyObject]()
        let lockQueue = DispatchQueue.init(label: "joinQueue")
        var expectedOperations = operations.count
        var earlyReturn = false
        
        let joiningCallback = { (res: Result<AnyObject, Web3Error>) -> () in
            switch res {
            case .success(let result):
                lockQueue.sync() {
                    expectedOperations = expectedOperations - 1
                    guard let ev = result as? [AnyObject] else {
                        if (!earlyReturn) {
                            earlyReturn = true
                            return self.processError(Web3Error.dataError)
                        } else {
                            return
                        }
                    }
                    resultsArray.append(contentsOf: ev)
                    guard let currentQueue = OperationQueue.current else {
                        if (!earlyReturn) {
                            earlyReturn = true
                            return self.processError(Web3Error.dataError)
                        } else {
                            return
                        }
                    }
                    
                    if expectedOperations == 0 {
                        if (!earlyReturn) {
                            earlyReturn = true
                            currentQueue.underlyingQueue?.async(execute: {
                                self.processSuccess(resultsArray as AnyObject)
                            })
                        } else {
                            return
                        }
                    }
                }
            case .failure(let error):
                lockQueue.sync() {
                    if (!earlyReturn) {
                        earlyReturn = true
                        return self.processError(error)
                    } else {
                        return
                    }
                }
            }
        }
        for op in operations {
            op.next = OperationChainingType.callback(joiningCallback, self.expectedQueue)
        }
        self.expectedQueue.addOperations(operations, waitUntilFinished: false)
    }
}
