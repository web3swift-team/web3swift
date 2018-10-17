//
//  Web3+Eth+ObjC.swift
//  web3swift
//
//  Created by Alexander Vlasov on 08.08.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation

@objc(web3Eth)
public final class _ObjCweb3Eth: NSObject {
    private (set) weak var web3: web3?
    
    init(web3: _ObjCweb3?) {
        self.web3 = web3?._web3
    }
    
    public func getBalance(address: _ObjCEthereumAddress, onBlock: NSString = "latest", error: NSErrorPointer) -> _ObjCBigUInt? {
        guard let addr = address.address else {
            error?.pointee = Web3Error.inputError(desc: "Address is empty") as NSError
            return nil
        }
        guard let result = self.web3?.eth.getBalance(address: addr, onBlock: onBlock as String) else {
            error?.pointee = Web3Error.processingError(desc: "Web3 object was not properly initialized") as NSError
            return nil
        }
        switch result {
        case .success(let balance):
            let biguint = _ObjCBigUInt(value: balance)
            return biguint
        case .failure(let web3error):
            error?.pointee = web3error as NSError
            return nil
        }
    }
    
    public func getBlockNumber(error: NSErrorPointer) -> _ObjCBigUInt? {
        guard let result = self.web3?.eth.getBlockNumber() else {
            error?.pointee = Web3Error.inputError(desc: "Web3 object was not properly initialized") as NSError
            return nil
        }
        switch result {
        case .success(let blockNumber):
            let biguint = _ObjCBigUInt(value: blockNumber)
            return biguint
        case .failure(let web3error):
            error?.pointee = web3error as NSError
            return nil
        }
    }
    
    public func getGasPrice(error: NSErrorPointer) -> _ObjCBigUInt? {
        guard let result = self.web3?.eth.getGasPrice() else {
            error?.pointee = Web3Error.inputError(desc: "Web3 object was not properly initialized") as NSError
            return nil
        }
        switch result {
        case .success(let blockNumber):
            let biguint = _ObjCBigUInt(value: blockNumber)
            return biguint
        case .failure(let web3error):
            error?.pointee = web3error as NSError
            return nil
        }
    }
    
    public func sendTransaction(_ transaction: _ObjCEthereumTransaction, options: _ObjCWeb3Options, password: NSString = "web3swift", error: NSErrorPointer) -> _ObjCTransctionSendingResult? {
        guard let result = self.web3?.eth.sendTransaction(transaction.transtaction, options: options.options, password: password) else {
            error?.pointee = Web3Error.inputError(desc: "Web3 object was not properly initialized") as NSError
            return nil
        }
        switch result {
        case .success(let res):
            let sendingResult = _ObjCTransctionSendingResult(result: res)
            return sendingResult
        case .failure(let web3error):
            error?.pointee = web3error as NSError
            return nil
        }
    }
    
    public func sendRawTransaction(_ transaction: NSData, error: NSErrorPointer) -> _ObjCTransctionSendingResult? {
        guard let result = self.web3?.eth.sendRawTransaction(transaction) else {
            error?.pointee = Web3Error.inputError(desc: "Web3 object was not properly initialized") as NSError
            return nil
        }
        switch result {
        case .success(let res):
            let sendingResult = _ObjCTransctionSendingResult(result: res)
            return sendingResult
        case .failure(let web3error):
            error?.pointee = web3error as NSError
            return nil
        }
    }
    
    public func sendRawTransaction(_ transaction: _ObjCEthereumTransaction, error: NSErrorPointer) -> _ObjCTransctionSendingResult? {
        guard let result = self.web3?.eth.sendRawTransaction(transaction.transaction) else {
            error?.pointee = Web3Error.inputError(desc: "Web3 object was not properly initialized") as NSError
            return nil
        }
        switch result {
        case .success(let res):
            let sendingResult = _ObjCTransctionSendingResult(result: res)
            return sendingResult
        case .failure(let web3error):
            error?.pointee = web3error as NSError
            return nil
        }
    }
    
    public func getTransactionCount(address: _ObjCEthereumAddress, onBlock: NSString = "latest", error: NSErrorPointer) -> _ObjCBigUInt? {
        guard let result = self.web3?.eth.getTransactionCount(address: address.address) else {
            error?.pointee = Web3Error.inputError(desc: "Web3 object was not properly initialized") as NSError
            return nil
        }
        switch result {
        case .success(let count):
            let biguint = _ObjCBigUInt(value: count)
            return biguint
        case .failure(let web3error):
            error?.pointee = web3error as NSError
            return nil
        }
    }
    
    public func getTransactionDetails(_ txhash: NSData, error: NSErrorPointer) -> _ObjCTransactionDetails? {
        guard let result = self.web3?.eth.getTransactionDetails(txhash) else {
            error?.pointee = Web3Error.inputError(desc: "Web3 object was not properly initialized") as NSError
            return nil
        }
        switch result {
        case .success(let res):
            let details = _ObjCTransactionDetails(details: res)
            return details
        case .failure(let web3error):
            error?.pointee = web3error as NSError
            return nil
        }
    }
    
    public func getTransactionDetails(_ txhash: NSString, error: NSErrorPointer) -> _ObjCTransactionDetails? {
        guard let result = self.web3?.eth.getTransactionDetails(txhash) else {
            error?.pointee = Web3Error.inputError(desc: "Web3 object was not properly initialized") as NSError
            return nil
        }
        switch result {
        case .success(let res):
            let details = _ObjCTransactionDetails(details: res)
            return details
        case .failure(let web3error):
            error?.pointee = web3error as NSError
            return nil
        }
    }
    
    public func getTransactionReceipt(_ txhash: NSString, error: NSErrorPointer) -> _ObjCTransactionReceipt? {
        guard let result = self.web3?.eth.getTransactionReceipt(txhash) else {
            error?.pointee = Web3Error.inputError(desc: "Web3 object was not properly initialized") as NSError
            return nil
        }
        switch result {
        case .success(let res):
            let receipt = _ObjCTransactionReceipt(receipt: res)
            return receipt
        case .failure(let web3error):
            error?.pointee = web3error as NSError
            return nil
        }
    }
    
    public func getTransactionReceipt(_ txhash: NSData, error: NSErrorPointer) -> _ObjCTransactionReceipt? {
        guard let result = self.web3?.eth.getTransactionReceipt(txhash) else {
            error?.pointee = Web3Error.inputError(desc: "Web3 object was not properly initialized") as NSError
            return nil
        }
        switch result {
        case .success(let res):
            let receipt = _ObjCTransactionReceipt(receipt: res)
            return receipt
        case .failure(let web3error):
            error?.pointee = web3error as NSError
            return nil
        }
    }
    
    public func estimateGas(_ transaction: _ObjCEthereumTransaction, options: _ObjCWeb3Options?, onBlock: NSString = "latest", error: NSErrorPointer) -> _ObjCBigUInt? {
        guard let result = self.web3?.eth.estimateGas(transaction.transaction, options: options.options, onBlock: onBlock) else {
            error?.pointee = Web3Error.inputError(desc: "Web3 object was not properly initialized") as NSError
            return nil
        }
        switch result {
        case .success(let res):
            let biguint = _ObjCBigUInt(value: res)
            return biguint
        case .failure(let web3error):
            error?.pointee = web3error as NSError
            return nil
        }
    }
    
    public func getAccounts(error: NSErrorPointer) -> _ObjCEthereumAddress? {
        guard let result = self.web3?.eth.getAccounts() else {
            error?.pointee = Web3Error.inputError(desc: "Web3 object was not properly initialized") as NSError
            return nil
        }
        switch result {
        case .success(let res):
            let address = _ObjCEthereumAddress(address: res)
            return address
        case .failure(let web3error):
            error?.pointee = web3error as NSError
            return nil
        }
    }
    
    public func getBlockByHash(_ hash: NSString, fullTransactions: bool = NO, error: NSErrorPointer) -> _ObjCBlock? {
        guard let result = self.web3?.eth.getBlockByHash(hash, fullTransactions) else {
            error?.pointee = Web3Error.inputError(desc: "Web3 object was not properly initialized") as NSError
            return nil
        }
        switch result {
        case .success(let res):
            let block = _ObjCBlock(block: res)
            return block
        case .failure(let web3error):
            error?.pointee = web3error as NSError
            return nil
        }
    }
    
    public func getBlockByHash(_ hash: NSData, fullTransactions: bool = NO, error: NSErrorPointer) -> _ObjCBlock? {
        guard let result = self.web3?.eth.getBlockByHash(hash, fullTransactions) else {
            error?.pointee = Web3Error.inputError(desc: "Web3 object was not properly initialized") as NSError
            return nil
        }
        switch result {
        case .success(let res):
            let block = _ObjCBlock(block: res)
            return block
        case .failure(let web3error):
            error?.pointee = web3error as NSError
            return nil
        }
    }
    
    public func getBlockByNumber(_ number: NSUInt64, fullTransactions: bool = NO, error: NSErrorPointer) -> _ObjCBlock? {
        guard let result = self.web3?.eth.getBlockByNumber(number, fullTransactions) else {
            error?.pointee = Web3Error.inputError(desc: "Web3 object was not properly initialized") as NSError
            return nil
        }
        switch result {
        case .success(let res):
            let block = _ObjCBlock(block: res)
            return block
        case .failure(let web3error):
            error?.pointee = web3error as NSError
            return nil
        }
    }
    
    public func getBlockByNumber(_ number: _ObjCBigUInt, fullTransactions: bool = NO, error: NSErrorPointer) -> _ObjCBlock? {
        guard let result = self.web3?.eth.getBlockByNumber(number.biguint, fullTransactions) else {
            error?.pointee = Web3Error.inputError(desc: "Web3 object was not properly initialized") as NSError
            return nil
        }
        switch result {
        case .success(let res):
            let block = _ObjCBlock(block: res)
            return block
        case .failure(let web3error):
            error?.pointee = web3error as NSError
            return nil
        }
    }
    
    public func getBlockByNumber(_ block: NSString, fullTransactions: bool = NO, error: NSErrorPointer) -> _ObjCBlock? {
        guard let result = self.web3?.eth.getBlockByNumber(block, fullTransactions) else {
            error?.pointee = Web3Error.inputError(desc: "Web3 object was not properly initialized") as NSError
            return nil
        }
        switch result {
        case .success(let res):
            let block = _ObjCBlock(block: res)
            return block
        case .failure(let web3error):
            error?.pointee = web3error as NSError
            return nil
        }
    }
    
    public func sendETH(to: _ObjCEthereumAddress, amount: _ObjCBigUInt, extraData: NSData = NSData(), options: _ObjCWeb3Options? = nil, error: NSErrorPointer) -> _ObjCTransactionIntermediate? {
        guard let result = self.web3?.eth.sendETH(to.address, amount.biguint, extraData, options.options) else {
            error?.pointee = Web3Error.inputError(desc: "Web3 object was not properly initialized") as NSError
            return nil
        }
        switch result {
        case .success(let res):
            let transaction = _ObjCTransactionIntermediate(transaction: res)
            return transaction
        case .failure(let web3error):
            error?.pointee = web3error as NSError
            return nil
        }
    }
    
    public func sendETH(to: _ObjCEthereumAddress, amount: NSString, units: _ObjCWeb3._ObjCUtils._ObjCUnits = .eth, extraData: NSData = NSData(), options: _ObjCWeb3Options? = nil, error: NSErrorPointer) -> _ObjCTransactionIntermediate? {
        guard let result = self.web3?.eth.sendETH(to.address, amount, units, extraData, options) else {
            error?.pointee = Web3Error.inputError(desc: "Web3 object was not properly initialized") as NSError
            return nil
        }
        switch result {
        case .success(let res):
            let transaction = _ObjCTransactionIntermediate(transaction: res)
            return transaction
        case .failure(let web3error):
            error?.pointee = web3error as NSError
            return nil
        }
    }
    
    public func sendETH(from: _ObjCEthereumAddress, to: _ObjCEthereumAddress, amount: NSString, units: _ObjCWeb3._ObjCUtils._ObjCUnits = .eth, extraData: NSData = NSData(), options: _ObjCWeb3Options? = nil, error: NSErrorPointer) -> _ObjCTransactionIntermediate? {
        guard let result = self.web3?.eth.sendETH(from.address, to.address, amount, units, extraData, options) else {
            error?.pointee = Web3Error.inputError(desc: "Web3 object was not properly initialized") as NSError
            return nil
        }
        switch result {
        case .success(let res):
            let transaction = _ObjCTransactionIntermediate(transaction: res)
            return transaction
        case .failure(let web3error):
            error?.pointee = web3error as NSError
            return nil
        }
    }
    
    public func sendERC20tokensWithKnownDecimals(tokenAddress: _ObjCEthereumAddress, from: _ObjCEthereumAddress, to: _ObjCEthereumAddress, amount: _ObjCBigUInt, options: _ObjCWeb3Options? = nil, error: NSErrorPointer) -> _ObjCTransactionIntermediate? {
        guard let result = self.web3?.eth.sendERC20tokensWithKnownDecimals(tokenAddress.address, from.address, to.address, amount.biguint, options.options) else {
            error?.pointee = Web3Error.inputError(desc: "Web3 object was not properly initialized") as NSError
            return nil
        }
        switch result {
        case .success(let res):
            let transaction = _ObjCTransactionIntermediate(transaction: res)
            return transaction
        case .failure(let web3error):
            error?.pointee = web3error as NSError
            return nil
        }
    }
    
    public func sendERC20tokensWithNaturalUnits(tokenAddress: _ObjCEthereumAddress, from: _ObjCEthereumAddress, to: _ObjCEthereumAddress, amount: NSString, options: _ObjCWeb3Options? = nil, error: NSErrorPointer) -> _ObjCTransactionIntermediate? {
        guard let result = self.web3?.eth.sendERC20tokensWithNaturalUnits(tokenAddress.address, from.address, to.address, amount, options.options) else {
            error?.pointee = Web3Error.inputError(desc: "Web3 object was not properly initialized") as NSError
            return nil
        }
        switch result {
        case .success(let res):
            let transaction = _ObjCTransactionIntermediate(transaction: res)
            return transaction
        case .failure(let web3error):
            error?.pointee = web3error as NSError
            return nil
        }
    }
}
