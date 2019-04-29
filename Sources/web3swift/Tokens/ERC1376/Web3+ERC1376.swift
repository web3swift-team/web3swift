//
//  Web3+ERC1376.swift
//  web3swift-iOS
//
//  Created by Anton Grigorev on 20/12/2018.
//  Copyright © 2018 The Matter Inc. All rights reserved.
//

import Foundation
import BigInt
//import EthereumAddress
import PromiseKit

public enum IERC1376DelegateMode: UInt {
    case PublicMsgSender = 0
    case PublicTxOrigin = 1
    case PrivateMsgSender = 2
    case PrivateTxOrigin = 3
}

public struct DirectDebitInfo {
    let amount: BigUInt
    let startTime: BigUInt
    let interval: BigUInt
}

public struct DirectDebit {
    let info: DirectDebitInfo
    let epoch: BigUInt
}

extension DirectDebit: Hashable {
}

extension DirectDebitInfo: Hashable {
}

//Service-Friendly Token Standard
protocol IERC1376: IERC20 {
    func approve(from: EthereumAddress, spender: EthereumAddress, expectedValue: String, newValue: String) throws -> WriteTransaction
    func increaseAllowance(from: EthereumAddress, spender: EthereumAddress, value: String) throws -> WriteTransaction
    func decreaseAllowance(from: EthereumAddress, spender: EthereumAddress, value: String, strict: Bool) throws -> WriteTransaction
    func setERC20ApproveChecking(from: EthereumAddress, approveChecking: Bool) throws -> WriteTransaction
    
    func spendableAllowance(owner: EthereumAddress, spender: EthereumAddress) throws -> BigUInt
    func transfer(from: EthereumAddress, data: String) throws -> WriteTransaction
    func transferAndCall(from: EthereumAddress, to: EthereumAddress, value: String, data: [UInt8]) throws -> WriteTransaction
    
    func nonceOf(owner: EthereumAddress) throws -> BigUInt
    func increaseNonce(from: EthereumAddress) throws -> WriteTransaction
    func delegateTransferAndCall(from: EthereumAddress,
                                 nonce: BigUInt,
                                 fee: BigUInt,
                                 gasAmount: BigUInt,
                                 to: EthereumAddress,
                                 value: String,
                                 data: [UInt8],
                                 mode: IERC1376DelegateMode,
                                 v: UInt8,
                                 r: Data,
                                 s: Data) throws -> WriteTransaction
    
    func directDebit(debtor: EthereumAddress, receiver: EthereumAddress) throws -> DirectDebit
    func setupDirectDebit(from: EthereumAddress, receiver: EthereumAddress, info: DirectDebitInfo) throws -> WriteTransaction
    func terminateDirectDebit(from: EthereumAddress, receiver: EthereumAddress) throws -> WriteTransaction
    func withdrawDirectDebit(from: EthereumAddress, debtor: EthereumAddress) throws -> WriteTransaction
    func withdrawDirectDebit(from: EthereumAddress, debtors: [EthereumAddress], strict: Bool) throws -> WriteTransaction
}

public class ERC1376: IERC1376 {
    
    private var _name: String? = nil
    private var _symbol: String? = nil
    private var _decimals: UInt8? = nil
    private var _hasReadProperties: Bool = false
    
    public var transactionOptions: TransactionOptions
    public var web3: web3
    public var provider: Web3Provider
    public var address: EthereumAddress
    public var abi: String
    
    lazy var contract: web3.web3contract = {
        let contract = self.web3.contract(self.abi, at: self.address, abiVersion: 2)
        precondition(contract != nil)
        return contract!
    }()
    
    public init(web3: web3, provider: Web3Provider, address: EthereumAddress, abi: String = Web3.Utils.erc1376ABI) {
        self.web3 = web3
        self.provider = provider
        self.address = address
        var mergedOptions = web3.transactionOptions
        mergedOptions.to = address
        self.abi = abi
        self.transactionOptions = mergedOptions
    }
    
    public var name: String {
        self.readProperties()
        if self._name != nil {
            return self._name!
        }
        return ""
    }
    
    public var symbol: String {
        self.readProperties()
        if self._symbol != nil {
            return self._symbol!
        }
        return ""
    }
    
    public var decimals: UInt8 {
        self.readProperties()
        if self._decimals != nil {
            return self._decimals!
        }
        return 255
    }
    
    public func readProperties() {
        if self._hasReadProperties {
            return
        }
        let contract = self.contract
        guard contract.contract.address != nil else {return}
        var transactionOptions = TransactionOptions.defaultOptions
        transactionOptions.callOnBlock = .latest
        guard let namePromise = contract.read("name", parameters: [] as [AnyObject], extraData: Data(), transactionOptions: transactionOptions)?.callPromise() else {return}
        
        guard let symbolPromise = contract.read("symbol", parameters: [] as [AnyObject], extraData: Data(), transactionOptions: transactionOptions)?.callPromise() else {return}
        
        guard let decimalPromise = contract.read("decimals", parameters: [] as [AnyObject], extraData: Data(), transactionOptions: transactionOptions)?.callPromise() else {return}
        
        let allPromises = [namePromise, symbolPromise, decimalPromise]
        let queue = self.web3.requestDispatcher.queue
        when(resolved: allPromises).map(on: queue) { (resolvedPromises) -> Void in
            guard case .fulfilled(let nameResult) = resolvedPromises[0] else {return}
            guard let name = nameResult["0"] as? String else {return}
            self._name = name
            
            guard case .fulfilled(let symbolResult) = resolvedPromises[1] else {return}
            guard let symbol = symbolResult["0"] as? String else {return}
            self._symbol = symbol
            
            guard case .fulfilled(let decimalsResult) = resolvedPromises[2] else {return}
            guard let decimals = decimalsResult["0"] as? BigUInt else {return}
            self._decimals = UInt8(decimals)
            
            self._hasReadProperties = true
            }.wait()
    }
    
    public func getBalance(account: EthereumAddress) throws -> BigUInt {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try contract.read("balanceOf", parameters: [account] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)!.call(transactionOptions: transactionOptions)
        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }
    
    public func getAllowance(originalOwner: EthereumAddress, delegate: EthereumAddress) throws -> BigUInt {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try contract.read("allowance", parameters: [originalOwner, delegate] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)!.call(transactionOptions: transactionOptions)
        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }
    
    public func transfer(from: EthereumAddress, to: EthereumAddress, amount: String) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address
        basicOptions.callOnBlock = .latest
        
        // get the decimals manually
        let callResult = try contract.read("decimals", transactionOptions: basicOptions)!.call()
        var decimals = BigUInt(0)
        guard let dec = callResult["0"], let decTyped = dec as? BigUInt else {
            throw Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals")}
        decimals = decTyped
        
        let intDecimals = Int(decimals)
        guard let value = Web3.Utils.parseToBigUInt(amount, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }
        let tx = contract.write("transfer", parameters: [to, value] as [AnyObject], transactionOptions: basicOptions)!
        return tx
    }
    
    public func transferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, amount: String) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address
        basicOptions.callOnBlock = .latest
        
        // get the decimals manually
        let callResult = try contract.read("decimals", transactionOptions: basicOptions)!.call()
        var decimals = BigUInt(0)
        guard let dec = callResult["0"], let decTyped = dec as? BigUInt else {
            throw Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals")}
        decimals = decTyped
        
        let intDecimals = Int(decimals)
        guard let value = Web3.Utils.parseToBigUInt(amount, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }
        
        let tx = contract.write("transferFrom", parameters: [originalOwner, to, value] as [AnyObject], transactionOptions: basicOptions)!
        return tx
    }
    
    public func setAllowance(from: EthereumAddress, to: EthereumAddress, newAmount: String) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address
        basicOptions.callOnBlock = .latest
        
        // get the decimals manually
        let callResult = try contract.read("decimals", transactionOptions: basicOptions)!.call()
        var decimals = BigUInt(0)
        guard let dec = callResult["0"], let decTyped = dec as? BigUInt else {
            throw Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals")}
        decimals = decTyped
        
        let intDecimals = Int(decimals)
        guard let value = Web3.Utils.parseToBigUInt(newAmount, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }
        
        let tx = contract.write("setAllowance", parameters: [to, value] as [AnyObject], transactionOptions: basicOptions)!
        return tx
    }
    
    public func approve(from: EthereumAddress, spender: EthereumAddress, amount: String) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address
        basicOptions.callOnBlock = .latest
        
        // get the decimals manually
        let callResult = try contract.read("decimals", transactionOptions: basicOptions)!.call()
        var decimals = BigUInt(0)
        guard let dec = callResult["0"], let decTyped = dec as? BigUInt else {
            throw Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals")}
        decimals = decTyped
        
        let intDecimals = Int(decimals)
        guard let value = Web3.Utils.parseToBigUInt(amount, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }
        
        let tx = contract.write("approve", parameters: [spender, value] as [AnyObject], transactionOptions: basicOptions)!
        return tx
    }
    
    public func totalSupply() throws -> BigUInt {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try contract.read("totalSupply", parameters: [AnyObject](), extraData: Data(), transactionOptions: self.transactionOptions)!.call(transactionOptions: transactionOptions)
        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }
    
    func approve(from: EthereumAddress, spender: EthereumAddress, expectedValue: String, newValue: String) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address
        basicOptions.callOnBlock = .latest
        
        // get the decimals manually
        let callResult = try contract.read("decimals", transactionOptions: basicOptions)!.call()
        var decimals = BigUInt(0)
        guard let dec = callResult["0"], let decTyped = dec as? BigUInt else {
            throw Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals")}
        decimals = decTyped
        
        let intDecimals = Int(decimals)
        guard let eValue = Web3.Utils.parseToBigUInt(expectedValue, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }
        guard let nValue = Web3.Utils.parseToBigUInt(newValue, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }
        
        let tx = contract.write("approve", parameters: [spender, eValue, nValue] as [AnyObject], transactionOptions: basicOptions)!
        return tx
    }
    
    func increaseAllowance(from: EthereumAddress, spender: EthereumAddress, value: String) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address
        basicOptions.callOnBlock = .latest
        
        // get the decimals manually
        let callResult = try contract.read("decimals", transactionOptions: basicOptions)!.call()
        var decimals = BigUInt(0)
        guard let dec = callResult["0"], let decTyped = dec as? BigUInt else {
            throw Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals")}
        decimals = decTyped
        
        let intDecimals = Int(decimals)
        guard let amount = Web3.Utils.parseToBigUInt(value, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }
        
        let tx = contract.write("increaseAllowance", parameters: [spender, amount] as [AnyObject], transactionOptions: basicOptions)!
        return tx
    }
    
    func decreaseAllowance(from: EthereumAddress, spender: EthereumAddress, value: String, strict: Bool) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address
        basicOptions.callOnBlock = .latest
        
        // get the decimals manually
        let callResult = try contract.read("decimals", transactionOptions: basicOptions)!.call()
        var decimals = BigUInt(0)
        guard let dec = callResult["0"], let decTyped = dec as? BigUInt else {
            throw Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals")}
        decimals = decTyped
        
        let intDecimals = Int(decimals)
        guard let amount = Web3.Utils.parseToBigUInt(value, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }
        
        let tx = contract.write("decreaseAllowance", parameters: [spender, amount, strict] as [AnyObject], transactionOptions: basicOptions)!
        return tx
    }
    
    func setERC20ApproveChecking(from: EthereumAddress, approveChecking: Bool) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address
        
        let tx = contract.write("setERC20ApproveChecking", parameters: [approveChecking] as [AnyObject], transactionOptions: basicOptions)!
        return tx
    }
    
    func spendableAllowance(owner: EthereumAddress, spender: EthereumAddress) throws -> BigUInt {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try contract.read("spendableAllowance", parameters: [owner, spender] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)!.call(transactionOptions: transactionOptions)
        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }
    
    func transfer(from: EthereumAddress, data: String) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address
        basicOptions.callOnBlock = .latest
        
        // get the decimals manually
        let callResult = try contract.read("decimals", transactionOptions: basicOptions)!.call()
        var decimals = BigUInt(0)
        guard let dec = callResult["0"], let decTyped = dec as? BigUInt else {
            throw Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals")}
        decimals = decTyped
        
        let intDecimals = Int(decimals)
        guard let value = Web3.Utils.parseToBigUInt(data, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }
        let tx = contract.write("transfer", parameters: [value] as [AnyObject], transactionOptions: basicOptions)!
        return tx
    }
    
    func transferAndCall(from: EthereumAddress, to: EthereumAddress, value: String, data: [UInt8]) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address
        basicOptions.callOnBlock = .latest
        
        // get the decimals manually
        let callResult = try contract.read("decimals", transactionOptions: basicOptions)!.call()
        var decimals = BigUInt(0)
        guard let dec = callResult["0"], let decTyped = dec as? BigUInt else {
            throw Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals")}
        decimals = decTyped
        
        let intDecimals = Int(decimals)
        guard let amount = Web3.Utils.parseToBigUInt(value, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }
        let tx = contract.write("transferAndCall", parameters: [to, amount, data] as [AnyObject], transactionOptions: basicOptions)!
        return tx
    }
    
    func nonceOf(owner: EthereumAddress) throws -> BigUInt {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try contract.read("nonceOf", parameters: [owner] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)!.call(transactionOptions: transactionOptions)
        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }
    
    func increaseNonce(from: EthereumAddress) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address
        basicOptions.callOnBlock = .latest
        
        let tx = contract.write("increaseNonce", parameters: [] as [AnyObject], transactionOptions: basicOptions)!
        return tx
    }
    
    func delegateTransferAndCall(from: EthereumAddress, nonce: BigUInt, fee: BigUInt, gasAmount: BigUInt, to: EthereumAddress, value: String, data: [UInt8], mode: IERC1376DelegateMode, v: UInt8, r: Data, s: Data) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address
        basicOptions.callOnBlock = .latest
        
        // get the decimals manually
        let callResult = try contract.read("decimals", transactionOptions: basicOptions)!.call()
        var decimals = BigUInt(0)
        guard let dec = callResult["0"], let decTyped = dec as? BigUInt else {
            throw Web3Error.inputError(desc: "Contract may be not ERC20 compatible, can not get decimals")}
        decimals = decTyped
        
        let intDecimals = Int(decimals)
        guard let amount = Web3.Utils.parseToBigUInt(value, decimals: intDecimals) else {
            throw Web3Error.inputError(desc: "Can not parse inputted amount")
        }
        
        let modeValue = mode.rawValue
        
        let tx = contract.write("delegateTransferAndCall", parameters: [nonce, fee, gasAmount, to, amount, data, modeValue, v, r, s] as [AnyObject], transactionOptions: basicOptions)!
        return tx
    }
    
    func directDebit(debtor: EthereumAddress, receiver: EthereumAddress) throws -> DirectDebit {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try contract.read("directDebit", parameters: [debtor, receiver] as [AnyObject], extraData: Data(), transactionOptions: self.transactionOptions)!.call(transactionOptions: transactionOptions)
        guard let res = result["0"] as? DirectDebit else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
    }
    
    func setupDirectDebit(from: EthereumAddress, receiver: EthereumAddress, info: DirectDebitInfo) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address
        
        let tx = contract.write("setupDirectDebit", parameters: [receiver, info] as [AnyObject], transactionOptions: basicOptions)!
        return tx
    }
    
    func terminateDirectDebit(from: EthereumAddress, receiver: EthereumAddress) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address
        
        let tx = contract.write("terminateDirectDebit", parameters: [receiver] as [AnyObject], transactionOptions: basicOptions)!
        return tx
    }
    
    func withdrawDirectDebit(from: EthereumAddress, debtor: EthereumAddress) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address
        
        let tx = contract.write("withdrawDirectDebit", parameters: [debtor] as [AnyObject], transactionOptions: basicOptions)!
        return tx
    }
    
    func withdrawDirectDebit(from: EthereumAddress, debtors: [EthereumAddress], strict: Bool) throws -> WriteTransaction {
        let contract = self.contract
        var basicOptions = TransactionOptions()
        basicOptions.from = from
        basicOptions.to = self.address
        
        let tx = contract.write("withdrawDirectDebit", parameters: [debtors, strict] as [AnyObject], transactionOptions: basicOptions)!
        return tx
    }
}
