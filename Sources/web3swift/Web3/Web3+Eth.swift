//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt

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
    public func sendTransaction(_ transaction: EthereumTransaction, transactionOptions: TransactionOptions, password:String = "web3swift") async throws -> TransactionSendingResult {
        try await self.sendTransactionPromise(transaction, transactionOptions: transactionOptions, password: password)
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
    func call(_ transaction: EthereumTransaction, transactionOptions: TransactionOptions) async throws -> Data {
        try await self.callPromise(transaction, transactionOptions: transactionOptions)
    }

    /// Send raw Ethereum transaction data to the network.
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
    public func sendRawTransaction(_ transaction: Data) async throws -> TransactionSendingResult {
        try await self.sendRawTransactionPromise(transaction)
    }

    /// Send raw Ethereum transaction data to the network by first serializing the EthereumTransaction object.
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
    public func sendRawTransaction(_ transaction: EthereumTransaction) async throws -> TransactionSendingResult {
        try await self.sendRawTransactionPromise(transaction)
    }

    /// Returns a total number of transactions sent by the particular Ethereum address.
    ///
    /// "onBlock" field determines if value is returned based on the state of a blockchain on the latest mined block ("latest")
    /// or the expected state after all the transactions in memory pool are applied ("pending").
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
    public func getTransactionCount(address: EthereumAddress, onBlock: String = "latest") async throws -> BigUInt {
        try await self.getTransactionCountPromise(address: address, onBlock: onBlock)
    }

    /// Returns a balance of particular Ethereum address in Wei units (1 ETH = 10^18 Wei).
    ///
    /// "onString" field determines if value is returned based on the state of a blockchain on the latest mined block ("latest")
    /// or the expected state after all the transactions in memory pool are applied ("pending").
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
    public func getBalance(address: EthereumAddress, onBlock: String = "latest") async throws -> BigUInt {
        try await self.getBalancePromise(address: address, onBlock: onBlock)
    }

    /// Returns a block number of the last mined block that Ethereum node knows about.
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
    public func getBlockNumber() async throws -> BigUInt {
        try await self.getBlockNumberPromise()
    }

    /// Returns a current gas price in the units of Wei. The node has internal algorithms for averaging over the last few blocks.
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
    public func getGasPrice() async throws -> BigUInt {
        try await self.getGasPricePromise()
    }

    /// Returns transaction details for particular transaction hash. Details indicate position of the transaction in a particular block,
    /// as well as original transaction details such as value, gas limit, gas price, etc.
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
    public func getTransactionDetails(_ txhash: Data) async throws -> TransactionDetails {
        try await self.getTransactionDetailsPromise(txhash)
    }

    /// Returns transaction details for particular transaction hash. Details indicate position of the transaction in a particular block,
    /// as well as original transaction details such as value, gas limit, gas price, etc.
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
    public func getTransactionDetails(_ txhash: String) async throws -> TransactionDetails {
        try await self.getTransactionDetailsPromise(txhash)
    }

    /// Returns transaction receipt for particular transaction hash. Receipt indicate what has happened when the transaction
    /// was included in block, so it contains logs and status, such as succesful or failed transaction.
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
    public func getTransactionReceipt(_ txhash: Data) async throws -> TransactionReceipt {
        try await self.getTransactionReceiptPromise(txhash)
    }

    /// Returns transaction receipt for particular transaction hash. Receipt indicate what has happened when the transaction
    /// was included in block, so it contains logs and status, such as succesful or failed transaction.
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
    public func getTransactionReceipt(_ txhash: String) async throws -> TransactionReceipt {
        try await self.getTransactionReceiptPromise(txhash)
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
    public func estimateGas(_ transaction: EthereumTransaction, transactionOptions: TransactionOptions?) async throws -> BigUInt {
        try await self.estimateGasPromise(transaction, transactionOptions: transactionOptions)
    }

    /// Get a list of Ethereum accounts that a node knows about.
    /// If one has attached a Keystore Manager to the web3 object it returns accounts known to the keystore.
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
    public func getAccounts() async throws -> [EthereumAddress] {
        try await self.getAccountsPromise()
    }


    /// Get information about the particular block in Ethereum network. If "fullTransactions" parameter is set to "true"
    /// this call fill do a virtual join and fetch not just transaction hashes from this block,
    /// but full decoded EthereumTransaction objects.
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
    public func getBlockByHash(_ hash: String, fullTransactions: Bool = false) async throws -> Block {
        try await self.getBlockByHashPromise(hash, fullTransactions: fullTransactions)
    }

    /// Get information about the particular block in Ethereum network. If "fullTransactions" parameter is set to "true"
    /// this call fill do a virtual join and fetch not just transaction hashes from this block,
    /// but full decoded EthereumTransaction objects.
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
    public func getBlockByHash(_ hash: Data, fullTransactions: Bool = false) async throws -> Block {
        try await self.getBlockByHashPromise(hash, fullTransactions: fullTransactions)
    }

    /// Get information about the particular block in Ethereum network. If "fullTransactions" parameter is set to "true"
    /// this call fill do a virtual join and fetch not just transaction hashes from this block,
    /// but full decoded EthereumTransaction objects.
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
    public func getBlockByNumber(_ number: UInt64, fullTransactions: Bool = false) async throws -> Block {
        try await self.getBlockByNumberPromise(number, fullTransactions: fullTransactions)
    }

    /// Get information about the particular block in Ethereum network. If "fullTransactions" parameter is set to "true"
    /// this call fill do a virtual join and fetch not just transaction hashes from this block,
    /// but full decoded EthereumTransaction objects.
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
    public func getBlockByNumber(_ number: BigUInt, fullTransactions: Bool = false) async throws -> Block {
        try await self.getBlockByNumberPromise(number, fullTransactions: fullTransactions)
    }

    /// Get information about the particular block in Ethereum network. If "fullTransactions" parameter is set to "true"
    /// this call fill do a virtual join and fetch not just transaction hashes from this block,
    /// but full decoded EthereumTransaction objects.
    ///
    /// This function is synchronous!
    ///
    ///
    public func getBlockByNumber(_ block:String, fullTransactions: Bool = false) async throws -> Block {
        try await self.getBlockByNumberPromise(block, fullTransactions: fullTransactions)
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
    public func sendETH(to: EthereumAddress, amount: BigUInt, extraData: Data = Data(), transactionOptions: TransactionOptions? = nil) -> WriteTransaction? {
        let contract = self.web3.contract(Web3.Utils.coldWalletABI, at: to, abiVersion: 2)
        var mergedOptions = self.web3.transactionOptions.merge(transactionOptions)
        mergedOptions.value = amount
        let writeTX = contract?.write("fallback", extraData: extraData, transactionOptions: mergedOptions)
        return writeTX
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
    public func sendETH(to: EthereumAddress, amount: String, units: Web3.Utils.Units = .eth, extraData: Data = Data(), transactionOptions: TransactionOptions? = nil) -> WriteTransaction? {
        guard let value = Web3.Utils.parseToBigUInt(amount, units: .eth) else {return nil}
        return sendETH(to: to, amount: value, extraData: extraData,  transactionOptions: transactionOptions)
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
    public func sendETH(from: EthereumAddress, to: EthereumAddress, amount: String, units: Web3.Utils.Units = .eth, extraData: Data = Data(),  transactionOptions: TransactionOptions? = nil) -> WriteTransaction? {
        guard let value = Web3.Utils.parseToBigUInt(amount, units: .eth) else {return nil}
        var mergedOptions = self.web3.transactionOptions.merge(transactionOptions)
        mergedOptions.from = from
        return sendETH(to: to, amount: value, extraData: extraData, transactionOptions: mergedOptions)
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
    public func sendERC20tokensWithKnownDecimals(tokenAddress: EthereumAddress, from: EthereumAddress, to: EthereumAddress, amount: BigUInt, transactionOptions: TransactionOptions? = nil) -> WriteTransaction? {
        let contract = self.web3.contract(Web3.Utils.erc20ABI, at: tokenAddress, abiVersion: 2)
        var mergedOptions = self.web3.transactionOptions.merge(transactionOptions)
        mergedOptions.from = from
        guard let writeTX = contract?.write("transfer", parameters: [to, amount] as [AnyObject], transactionOptions: mergedOptions) else {return nil}
        return writeTX
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
    public func sendERC20tokensWithNaturalUnits(tokenAddress: EthereumAddress, from: EthereumAddress, to: EthereumAddress, amount: String,  transactionOptions: TransactionOptions? = nil) async throws -> WriteTransaction? {
        let contract = self.web3.contract(Web3.Utils.erc20ABI, at: tokenAddress, abiVersion: 2)
        var mergedOptions = self.web3.transactionOptions.merge(transactionOptions)
        mergedOptions.from = from
        let resp = try await contract?.read("decimals", transactionOptions: mergedOptions)?.callPromise()
        var decimals = BigUInt(0)
        guard let response = resp, let dec = response["0"], let decTyped = dec as? BigUInt else {return nil}
        decimals = decTyped
        let intDecimals = Int(decimals)
        guard let value = Web3.Utils.parseToBigUInt(amount, decimals: intDecimals) else {return nil}
        return sendERC20tokensWithKnownDecimals(tokenAddress: tokenAddress, from: from, to: to, amount: value, transactionOptions: mergedOptions)
    }

}
