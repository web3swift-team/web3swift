//
//  Web3+Eth.swift
//  web3swift
//
//  Created by Alexander Vlasov on 22.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt
import Result

extension web3.Eth {
    
    public func sendTransaction(_ transaction: EthereumTransaction, options: Web3Options, password:String = "BANKEXFOUNDATION") -> Result<TransactionSendingResult, Web3Error> {
        do {
            let result = try self.sendTransactionPromise(transaction, options: options, password: password).wait()
            return Result(result)
        } catch {
            if let err = error as? Web3Error {
                return Result.failure(err)
            }
            return Result.failure(Web3Error.generalError(error))
        }
    }

    func call(_ transaction: EthereumTransaction, options: Web3Options, onBlock:String = "latest") -> Result<Data, Web3Error> {
        do {
            let result = try self.callPromise(transaction, options: options, onBlock: onBlock).wait()
            return Result(result)
        } catch {
            if let err = error as? Web3Error {
                return Result.failure(err)
            }
            return Result.failure(Web3Error.generalError(error))
        }
    }
    
    public func sendRawTransaction(_ transaction: Data) -> Result<TransactionSendingResult, Web3Error> {
        do {
            let result = try self.sendRawTransactionPromise(transaction).wait()
            return Result(result)
        } catch {
            if let err = error as? Web3Error {
                return Result.failure(err)
            }
            return Result.failure(Web3Error.generalError(error))
        }
    }
    
    public func sendRawTransaction(_ transaction: EthereumTransaction) -> Result<TransactionSendingResult, Web3Error> {
        do {
            let result = try self.sendRawTransactionPromise(transaction).wait()
            return Result(result)
        } catch {
            if let err = error as? Web3Error {
                return Result.failure(err)
            }
            return Result.failure(Web3Error.generalError(error))
        }
    }
    
    public func getTransactionCount(address: EthereumAddress, onBlock: String = "latest") -> Result<BigUInt, Web3Error> {
        do {
            let result = try self.getTransactionCountPromise(address: address, onBlock: onBlock).wait()
            return Result(result)
        } catch {
            if let err = error as? Web3Error {
                return Result.failure(err)
            }
            return Result.failure(Web3Error.generalError(error))
        }
    }
    
    public func getBalance(address: EthereumAddress, onBlock: String = "latest") -> Result<BigUInt, Web3Error> {
        do {
            let result = try self.getBalancePromise(address: address, onBlock: onBlock).wait()
            return Result(result)
        } catch {
            if let err = error as? Web3Error {
                return Result.failure(err)
            }
            return Result.failure(Web3Error.generalError(error))
        }
    }
    
    public func getBlockNumber() -> Result<BigUInt, Web3Error> {
        do {
            let result = try self.getBlockNumberPromise().wait()
            return Result(result)
        } catch {
            if let err = error as? Web3Error {
                return Result.failure(err)
            }
            return Result.failure(Web3Error.generalError(error))
        }
    }
    

    public func getGasPrice() -> Result<BigUInt, Web3Error> {
        do {
            let result = try self.getGasPricePromise().wait()
            return Result(result)
        } catch {
            if let err = error as? Web3Error {
                return Result.failure(err)
            }
            return Result.failure(Web3Error.generalError(error))
        }
    }
    
    public func getTransactionDetails(_ txhash: Data) -> Result<TransactionDetails, Web3Error> {
        do {
            let result = try self.getTransactionDetailsPromise(txhash).wait()
            return Result(result)
        } catch {
            if let err = error as? Web3Error {
                return Result.failure(err)
            }
            return Result.failure(Web3Error.generalError(error))
        }
    }
    
    public func getTransactionDetails(_ txhash: String) -> Result<TransactionDetails, Web3Error> {
        do {
            let result = try self.getTransactionDetailsPromise(txhash).wait()
            return Result(result)
        } catch {
            if let err = error as? Web3Error {
                return Result.failure(err)
            }
            return Result.failure(Web3Error.generalError(error))
        }
    }
    
    public func getTransactionReceipt(_ txhash: Data) -> Result<TransactionReceipt, Web3Error> {
        do {
            let result = try self.getTransactionReceiptPromise(txhash).wait()
            return Result(result)
        } catch {
            if let err = error as? Web3Error {
                return Result.failure(err)
            }
            return Result.failure(Web3Error.generalError(error))
        }
    }
    
    public func getTransactionReceipt(_ txhash: String) -> Result<TransactionReceipt, Web3Error> {
        do {
            let result = try self.getTransactionReceiptPromise(txhash).wait()
            return Result(result)
        } catch {
            if let err = error as? Web3Error {
                return Result.failure(err)
            }
            return Result.failure(Web3Error.generalError(error))
        }
    }
    
    public func estimateGas(_ transaction: EthereumTransaction, options: Web3Options?, onBlock: String = "latest") -> Result<BigUInt, Web3Error> {
        do {
            let result = try self.estimateGasPromise(transaction, options: options, onBlock: onBlock).wait()
            return Result(result)
        } catch {
            if let err = error as? Web3Error {
                return Result.failure(err)
            }
            return Result.failure(Web3Error.generalError(error))
        }
    }
    
    public func getAccounts() -> Result<[EthereumAddress],Web3Error> {
        do {
            let result = try self.getAccountsPromise().wait()
            return Result(result)
        } catch {
            if let err = error as? Web3Error {
                return Result.failure(err)
            }
            return Result.failure(Web3Error.generalError(error))
        }
    }
    
    public func getBlockByHash(_ hash: String, fullTransactions: Bool = false) -> Result<Block,Web3Error> {
        do {
            let result = try self.getBlockByHashPromise(hash, fullTransactions: fullTransactions).wait()
            return Result(result)
        } catch {
            if let err = error as? Web3Error {
                return Result.failure(err)
            }
            return Result.failure(Web3Error.generalError(error))
        }
    }
    
    public func getBlockByHash(_ hash: Data, fullTransactions: Bool = false) -> Result<Block,Web3Error> {
        do {
            let result = try self.getBlockByHashPromise(hash, fullTransactions: fullTransactions).wait()
            return Result(result)
        } catch {
            if let err = error as? Web3Error {
                return Result.failure(err)
            }
            return Result.failure(Web3Error.generalError(error))
        }
    }
    
    public func getBlockByNumber(_ number: UInt64, fullTransactions: Bool = false) -> Result<Block,Web3Error> {
        do {
            let result = try self.getBlockByNumberPromise(number, fullTransactions: fullTransactions).wait()
            return Result(result)
        } catch {
            if let err = error as? Web3Error {
                return Result.failure(err)
            }
            return Result.failure(Web3Error.generalError(error))
        }
    }
    
    public func getBlockByNumber(_ number: BigUInt, fullTransactions: Bool = false) -> Result<Block,Web3Error> {
        do {
            let result = try self.getBlockByNumberPromise(number, fullTransactions: fullTransactions).wait()
            return Result(result)
        } catch {
            if let err = error as? Web3Error {
                return Result.failure(err)
            }
            return Result.failure(Web3Error.generalError(error))
        }
    }
    
    public func getBlockByNumber(_ block:String, fullTransactions: Bool = false) -> Result<Block,Web3Error> {
        do {
            let result = try self.getBlockByNumberPromise(block, fullTransactions: fullTransactions).wait()
            return Result(result)
        } catch {
            if let err = error as? Web3Error {
                return Result.failure(err)
            }
            return Result.failure(Web3Error.generalError(error))
        }
    }
    
    public func sendETH(to: EthereumAddress, amount: BigUInt, extraData: Data = Data(), options: Web3Options? = nil) -> TransactionIntermediate? {
        let contract = self.web3.contract(Web3.Utils.coldWalletABI, at: to, abiVersion: 2)
        guard var mergedOptions = Web3Options.merge(self.options, with: options) else {return nil}
        mergedOptions.value = amount
        let intermediate = contract?.method("fallback", extraData: extraData, options: mergedOptions)
        return intermediate
    }
    
    public func sendETH(to: EthereumAddress, amount: String, units: Web3.Utils.Units = .eth, extraData: Data = Data(), options: Web3Options? = nil) -> TransactionIntermediate? {
        guard let value = Web3.Utils.parseToBigUInt(amount, units: .eth) else {return nil}
        return sendETH(to: to, amount: value, extraData: extraData, options: options)
    }
    
    public func sendETH(from: EthereumAddress, to: EthereumAddress, amount: String, units: Web3.Utils.Units = .eth, extraData: Data = Data(), options: Web3Options? = nil) -> TransactionIntermediate? {
        guard let value = Web3.Utils.parseToBigUInt(amount, units: .eth) else {return nil}
        guard var mergedOptions = Web3Options.merge(self.options, with: options) else {return nil}
        mergedOptions.from = from
        return sendETH(to: to, amount: value, extraData: extraData, options: mergedOptions)
    }
    
    public func sendERC20tokensWithKnownDecimals(tokenAddress: EthereumAddress, from: EthereumAddress, to: EthereumAddress, amount: BigUInt, options: Web3Options? = nil) -> TransactionIntermediate? {
        let contract = self.web3.contract(Web3.Utils.erc20ABI, at: tokenAddress, abiVersion: 2)
        guard var mergedOptions = Web3Options.merge(self.options, with: options) else {return nil}
        mergedOptions.from = from
        guard let intermediate = contract?.method("transfer", parameters: [to, amount] as [AnyObject], options: mergedOptions) else {return nil}
        return intermediate
    }
    
    public func sendERC20tokensWithNaturalUnits(tokenAddress: EthereumAddress, from: EthereumAddress, to: EthereumAddress, amount: String, options: Web3Options? = nil) -> TransactionIntermediate? {
        let contract = self.web3.contract(Web3.Utils.erc20ABI, at: tokenAddress, abiVersion: 2)
        guard var mergedOptions = Web3Options.merge(self.options, with: options) else {return nil}
        mergedOptions.from = from
        guard let intermediate = contract?.method("decimals", options: mergedOptions) else {return nil}
        let callResult = intermediate.call(options: mergedOptions, onBlock: "latest")
        var decimals = BigUInt(0)
        switch callResult {
        case .success(let response):
            guard let dec = response["0"], let decTyped = dec as? BigUInt else {return nil}
            decimals = decTyped
            break
        case .failure(_):
            break
        }
        let intDecimals = Int(decimals)
        guard let value = Web3.Utils.parseToBigUInt(amount, decimals: intDecimals) else {return nil}
        return sendERC20tokensWithKnownDecimals(tokenAddress: tokenAddress, from: from, to: to, amount: value, options: options)
    }
    
}
