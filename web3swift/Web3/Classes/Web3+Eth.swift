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
    
    /// Send an EthereumTransaction object to the network. Transaction is either signed locally if there is a KeystoreManager
    /// object bound to the web3 instance, or sent unsigned to the node. For local signing the password is required.
    ///
    /// "options" object can override the "to", "gasPrice", "gasLimit" and "value" parameters is pre-formed transaction.
    /// "from" field in "options" is mandatory for both local and remote signing.
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
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
    
    /// Performs a non-mutating "call" to some smart-contract. EthereumTransaction bears all function parameters required for the call.
    /// Does NOT decode the data returned from the smart-contract.
    /// "options" object can override the "to", "gasPrice", "gasLimit" and "value" parameters is pre-formed transaction.
    /// "from" field in "options" is mandatory for both local and remote signing.
    ///
    /// "onString" field determines if value is returned based on the state of a blockchain on the latest mined block ("latest")
    /// or the expected state after all the transactions in memory pool are applied ("pending").
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
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
    
    /// Send raw Ethereum transaction data to the network.
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
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
    
    /// Send raw Ethereum transaction data to the network by first serializing the EthereumTransaction object.
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
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
    
    /// Returns a total number of transactions sent by the particular Ethereum address.
    ///
    /// "onBlock" field determines if value is returned based on the state of a blockchain on the latest mined block ("latest")
    /// or the expected state after all the transactions in memory pool are applied ("pending").
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
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
    
    /// Returns a balance of particular Ethereum address in Wei units (1 ETH = 10^18 Wei).
    ///
    /// "onString" field determines if value is returned based on the state of a blockchain on the latest mined block ("latest")
    /// or the expected state after all the transactions in memory pool are applied ("pending").
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
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
    
    /// Returns a block number of the last mined block that Ethereum node knows about.
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
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
    
    /// Returns a current gas price in the units of Wei. The node has internal algorithms for averaging over the last few blocks.
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
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
    
    /// Returns transaction details for particular transaction hash. Details indicate position of the transaction in a particular block,
    /// as well as original transaction details such as value, gas limit, gas price, etc.
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
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
    
    /// Returns transaction details for particular transaction hash. Details indicate position of the transaction in a particular block,
    /// as well as original transaction details such as value, gas limit, gas price, etc.
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
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
    
    /// Returns transaction receipt for particular transaction hash. Receipt indicate what has happened when the transaction
    /// was included in block, so it contains logs and status, such as succesful or failed transaction.
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
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
    
    /// Returns transaction receipt for particular transaction hash. Receipt indicate what has happened when the transaction
    /// was included in block, so it contains logs and status, such as succesful or failed transaction.
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
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
    
    /// Estimates a minimal amount of gas required to run a transaction. To do it the Ethereum node tries to run it and counts
    /// how much gas it consumes for computations. Setting the transaction gas limit lower than the estimate will most likely
    /// result in a failing transaction.
    ///
    /// "onString" field determines if value is returned based on the state of a blockchain on the latest mined block ("latest")
    /// or the expected state after all the transactions in memory pool are applied ("pending").
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
    /// Error can also indicate that transaction is invalid in the current state, so formally it's gas limit is infinite.
    /// An example of such transaction can be sending an amount of ETH that is larger than the current account balance.
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
    
    /// Get a list of Ethereum accounts that a node knows about.
    /// If one has attached a Keystore Manager to the web3 object it returns accounts known to the keystore.
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
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
    
    
    /// Get information about the particular block in Ethereum network. If "fullTransactions" parameter is set to "true"
    /// this call fill do a virtual join and fetch not just transaction hashes from this block,
    /// but full decoded EthereumTransaction objects.
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
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
    
    /// Get information about the particular block in Ethereum network. If "fullTransactions" parameter is set to "true"
    /// this call fill do a virtual join and fetch not just transaction hashes from this block,
    /// but full decoded EthereumTransaction objects.
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
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
    
    /// Get information about the particular block in Ethereum network. If "fullTransactions" parameter is set to "true"
    /// this call fill do a virtual join and fetch not just transaction hashes from this block,
    /// but full decoded EthereumTransaction objects.
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
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
    
    /// Get information about the particular block in Ethereum network. If "fullTransactions" parameter is set to "true"
    /// this call fill do a virtual join and fetch not just transaction hashes from this block,
    /// but full decoded EthereumTransaction objects.
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
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
    
    /// Get information about the particular block in Ethereum network. If "fullTransactions" parameter is set to "true"
    /// this call fill do a virtual join and fetch not just transaction hashes from this block,
    /// but full decoded EthereumTransaction objects.
    ///
    /// This function is synchronous!
    ///
    ///
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
    
    
    /**
     Convenience wrapper to send Ethereum to another address. Internally it creates a virtual contract and encodes all the options and data.
     - Parameters:
        - to: EthereumAddress to send funds to
        - amount: BigUInt indicating the amount in wei
        - extraData: Additional data to attach to the transaction
        - options: Web3Options to override the default gas price, gas limit. "Value" field of the options is ignored and the "amount" parameter is used instead
     
     - returns:
        - TransactionIntermediate object
     
     */
    public func sendETH(to: EthereumAddress, amount: BigUInt, extraData: Data = Data(), options: Web3Options? = nil) -> TransactionIntermediate? {
        let contract = self.web3.contract(Web3.Utils.coldWalletABI, at: to, abiVersion: 2)
        guard var mergedOptions = Web3Options.merge(self.options, with: options) else {return nil}
        mergedOptions.value = amount
        let intermediate = contract?.method("fallback", extraData: extraData, options: mergedOptions)
        return intermediate
    }
    
    /**
     *Convenience wrapper to send Ethereum to another address. Internally it creates a virtual contract and encodes all the options and data.*
     
     - parameters:
         - to: EthereumAddress to send funds to
         - amount: String in "units" demonimation. It can contain either "," or "." decimal separator.
         - units: Ethereum units indicating the denomination of amout about
         - extraData: Additional data to attach to the transaction
         - options: Web3Options to override the default gas price, gas limit. "Value" field of the options is ignored and the "amount" parameter is used instead
     
     - returns:
        - TransactionIntermediate object

     * String "1.01" and units: .eth will result in sending 1.01 ETH to another address*
     */
    public func sendETH(to: EthereumAddress, amount: String, units: Web3.Utils.Units = .eth, extraData: Data = Data(), options: Web3Options? = nil) -> TransactionIntermediate? {
        guard let value = Web3.Utils.parseToBigUInt(amount, units: .eth) else {return nil}
        return sendETH(to: to, amount: value, extraData: extraData, options: options)
    }
    
    /**
     *Convenience wrapper to send Ethereum to another address. Internally it creates a virtual contract and encodes all the options and data.*
     
     - parameters:
         - from: EthereumAddress to send funds from
         - to: EthereumAddress to send funds to
         - amount: String in "units" demonimation. It can contain either "," or "." decimal separator.
         - units: Ethereum units indicating the denomination of amout about
         - extraData: Additional data to attach to the transaction
         - options: Web3Options to override the default gas price, gas limit. "Value" field of the options is ignored and the "amount" parameter is used instead. "From" parameter is also ignored.
     
     - returns:
         - TransactionIntermediate object
     
     * String "1.01" and units: .eth will result in sending 1.01 ETH to another address*
     */
    public func sendETH(from: EthereumAddress, to: EthereumAddress, amount: String, units: Web3.Utils.Units = .eth, extraData: Data = Data(), options: Web3Options? = nil) -> TransactionIntermediate? {
        guard let value = Web3.Utils.parseToBigUInt(amount, units: .eth) else {return nil}
        guard var mergedOptions = Web3Options.merge(self.options, with: options) else {return nil}
        mergedOptions.from = from
        return sendETH(to: to, amount: value, extraData: extraData, options: mergedOptions)
    }
    
    /**
     *Convenience wrapper to send ERC20 tokens to another address. Internally it creates a virtual contract and encodes all the options and data. Assumes that the sender knows the decimal units of the underlying token.*
     
     - parameters:
         - tokenAddress: EthereumAddress of the token contract
         - from: EthereumAddress to send tokens from
         - to: EthereumAddress to send tokens to
         - amount: BigUInt indicating the number of tokens in the the smallest indivisible units (mind that sender knows the number of decimals)
         - options: Web3Options to override the default gas price, gas limit. "Value" field of the options is ignored and the "amount" parameter is used instead. "From" parameter is also ignored.
     
     - returns:
        - TransactionIntermediate object
     
     */
    public func sendERC20tokensWithKnownDecimals(tokenAddress: EthereumAddress, from: EthereumAddress, to: EthereumAddress, amount: BigUInt, options: Web3Options? = nil) -> TransactionIntermediate? {
        let contract = self.web3.contract(Web3.Utils.erc20ABI, at: tokenAddress, abiVersion: 2)
        guard var mergedOptions = Web3Options.merge(self.options, with: options) else {return nil}
        mergedOptions.from = from
        guard let intermediate = contract?.method("transfer", parameters: [to, amount] as [AnyObject], options: mergedOptions) else {return nil}
        return intermediate
    }
    
    /**
     *Convenience wrapper to send ERC20 tokens to another address. Internally it creates a virtual contract and encodes all the options and data. Pulls the number of decimals of the token under the hood.*
     
     - parameters:
         - tokenAddress: EthereumAddress of the token contract
         - from: EthereumAddress to send tokens from
         - to: EthereumAddress to send tokens to
         - amount: String in "natura" demonimation. It can contain either "," or "." decimal separator.
         - options: Web3Options to override the default gas price, gas limit. "Value" field of the options is ignored and the "amount" parameter is used instead. "From" parameter is also ignored.
     
     - returns:
        - TransactionIntermediate object
     
     - important: This call is synchronous
     
     * If the amount is  "1.01" and token has 9 decimals it will result in sending 1010000000 of the smallest invidisible token units.*
     */
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
