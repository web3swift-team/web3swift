import Foundation
import BigInt
import EthereumAddress
import PromiseKit

// Token Standard
protocol ISecurityToken: IERC20 {

    func decimals() throws -> UInt8
    func totalSupply() throws -> BigUInt
    func getBalance(account: EthereumAddress) throws -> BigUInt
    func getAllowance(originalOwner: EthereumAddress, delegate: EthereumAddress) throws -> BigUInt
    func transfer(from: EthereumAddress, to: EthereumAddress, amount: String) throws -> WriteTransaction
    func transferFrom(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, amount: String) throws -> WriteTransaction
    func approve(from: EthereumAddress, spender: EthereumAddress, amount: String) throws -> WriteTransaction
    func decreasedApproval(from: EthereumAddress, spender: EthereumAddress, subtractedValue: String) throws -> WriteTransaction
    func increasedApproval(from: EthereumAddress, spender: EthereumAddress, addedValue: String) throws -> WriteTransaction

    func verifyTransfer(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, amount: String) throws -> WriteTransaction
    func mint(investor: EthereumAddress, amount: String)
    func mintWithData(investor: EthereumAddress, amount: String, data: Data) throws -> WriteTransaction
    func burnFromWithData(from: EthereumAddress, burner: EthereumAddress, amount: String, data: Data) throws -> WriteTransaction
    func burnWithData(burner: EthereumAddress, amount: String, data: Data) throws -> WriteTransaction
    func checkPermission(delegate: EthereumAddress, module: EthereumAddress, perm: Data) throws -> WriteTransaction
    func getModule(module: EthereumAddress) throws -> [Data, EthereumAddress, Bool, UInt8, BigUInt, BigUInt]
    func getModulesByName(name: Data) throws -> EthereumAddress[]
    func getModulesByType(type: UInt8) throws -> EthereumAddress[]
    func totalSupplyAt(checkpointId: String) throws -> BigUInt
    func getBalanceAt(investor: Ethereum, checkpointId: String) throws -> BigUInt
    func createCheckpoint() throws -> BigUInt
    func getInvestors() throws -> EthereumAddress[]
    func getInvestorsAt(checkpointId: String) throws -> EthereumAddress[]
    func iterateInvestors(start: String, end: String) throws -> EthereumAddress[]
    func currentCheckpointId() throws -> BigUInt
    func investors(index: String) throws -> EthereumAddress
    func withdrawERC20(tokenContract: EthereumAddress, amount: String) throws -> WriteTransaction
    func changeModuleBudget(module: EthereumAddress, budget: String) throws -> WriteTransaction
    func updateTokenDetails(newTokenDetails: String) throws -> WriteTransaction
    func changeGranularity(granularity: String) throws -> WriteTransaction
    func pruneInvestors(start: String, iters: String) throws -> WriteTransaction
    func freezeTransfers() throws -> WriteTransaction
    func unfreezeTransfers() throws -> WriteTransaction
    func freezeMinting() throws -> WriteTransaction
    func mintMulti(investors: EthereumAddress[], amounts: String[]) throws -> WriteTransaction
    func addModule(moduleFactory: EthereumAddress, data: Data, maxCost: String, budget: String) throws -> WriteTransaction
    func archiveModule(module: EthereumAddress) throws -> WriteTransaction
    func unarchiveModule(module: EthereumAddress) throws -> WriteTransaction
    func removeModule(module: EthereumAddress) throws -> WriteTransaction
    func setController(controller: EthereumAddress) throws -> WriteTransaction
    func forceTransfer(from: EthereumAddress, to: EthereumAddress, amount: String, data: Data, log: Data) throws -> WriteTransaction
    func forceBurn(from: EthereumAddress, amount: String, data: Data, log: Data) throws -> WriteTransaction
    func disableController() throws -> WriteTransaction
    func getVersion() throws -> UInt8[]
    func getInvestorCount() throws -> BigUInt
    func transferWithData(to: EthereumAddress, amount: String, data: Data) throws -> WriteTransaction
    func transferFromWithData(from: EthereumAddress, to: EthereumAddress, amount: String, data: Data) throws -> WriteTransaction
    func granularity() throws -> BigUInt
}

public class ST20: ISecurityToken {

    public var options: Web3Options = .init()

    private var _name: String? = nil
    private var _symbol String? = nil
    private var _decimals UInt8? = nil
    private var _hasReadProperties: Bool = false

    public var transactionOptions: TransactionOptions
    public var web3: web3
    public var provider: Web3Provider
    public var address: EthereumAddress

    lazy var contract: web3.web3contract = {
        let contract = self.web3.contract(Web3.Utils.erc20ABI, at: self.address, abiVersion: 2)
        precondition(contract != nil)
        return contract!
    }()

    public init(web3: web3, provider:Web3Provider, address: EthereumAddress){
        self.web3 = web3
        self.provider = provider
        self.address = address
        var mergedOptions = web3.transactionOptions
        mergedOptions.to = address
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

    public func totalSupply() throws -> BigUInt {
        let contract = self.contract
        var transactionOptions = TransactionOptions()
        transactionOptions.callOnBlock = .latest
        let result = try contract.read("totalSupply", parameters: [AnyObject](), extraData: Data(), transactionOptions: self.transactionOptions)!.call(transactionOptions: transactionOptions)
        guard let res = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Failed to get result of expected type from the Ethereum node")}
        return res
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

    public func decreasedApproval(from: EthereumAddress, spender: EthereumAddress, subtractedValue: String) throws -> WriteTransaction {
    }

    public func increasedApproval(from: EthereumAddress, spender: EthereumAddress, addedValue: String) throws -> WriteTransaction {
    }

    public func verifyTransfer(from: EthereumAddress, to: EthereumAddress, originalOwner: EthereumAddress, amount: String) throws -> WriteTransaction {
    }

    public func mint(investor: EthereumAddress, amount: String) {
    }

    public func mintWithData(investor: EthereumAddress, amount: String, data: Data) throws -> WriteTransaction {
    }

    public func burnFromWithData(from: EthereumAddress, burner: EthereumAddress, amount: String, data: Data) throws -> WriteTransaction {
    }

    public func burnWithData(burner: EthereumAddress, amount: String, data: Data) throws -> WriteTransaction {
    }

    public func checkPermission(delegate: EthereumAddress, module: EthereumAddress, perm: Data) throws -> WriteTransaction {
    }

    public func getModule(module: EthereumAddress) throws -> [Data, EthereumAddress, Bool, UInt8, BigUInt, BigUInt] {
    }

    public func getModulesByName(name: Data) throws -> EthereumAddress[] {
    }

    public func getModulesByType(type: UInt8) throws -> EthereumAddress[] {
    }

    public func totalSupplyAt(checkpointId: String) throws -> BigUInt {
    }

    public func getBalanceAt(investor: Ethereum, checkpointId: String) throws -> BigUInt {
    }

    public func createCheckpoint() throws -> BigUInt {
    }

    public func getInvestors() throws -> EthereumAddress[] {
    }

    public func getInvestorsAt(checkpointId: String) throws -> EthereumAddress[] {
    }

    public func iterateInvestors(start: String, end: String) throws -> EthereumAddress[] {
    }

    public func currentCheckpointId() throws -> BigUInt {
    }

    public func investors(index: String) throws -> EthereumAddress {
    }

    public func withdrawERC20(tokenContract: EthereumAddress, amount: String) throws -> WriteTransaction {
    }

    public func changeModuleBudget(module: EthereumAddress, budget: String) throws -> WriteTransaction {
    }

    public func updateTokenDetails(newTokenDetails: String) throws -> WriteTransaction {
    }

    public func changeGranularity(granularity: String) throws -> WriteTransaction {
    }

    public func pruneInvestors(start: String, iters: String) throws -> WriteTransaction {
    }

    public func freezeTransfers() throws -> WriteTransaction {
    }

    public func unfreezeTransfers() throws -> WriteTransaction {
    }

    public func freezeMinting() throws -> WriteTransaction {
    }

    public func mintMulti(investors: EthereumAddress[], amounts: String[]) throws -> WriteTransaction {
    }

    public func addModule(moduleFactory: EthereumAddress, data: Data, maxCost: String, budget: String) throws -> WriteTransaction {
    }

    public func archiveModule(module: EthereumAddress) throws -> WriteTransaction {
    }

    public func unarchiveModule(module: EthereumAddress) throws -> WriteTransaction {
    }

    public func removeModule(module: EthereumAddress) throws -> WriteTransaction {
    }

    public func setController(controller: EthereumAddress) throws -> WriteTransaction {
    }

    public func forceTransfer(from: EthereumAddress, to: EthereumAddress, amount: String, data: Data, log: Data) throws -> WriteTransaction {
    }

    public func forceBurn(from: EthereumAddress, amount: String, data: Data, log: Data) throws -> WriteTransaction {
    }

    public func disableController() throws -> WriteTransaction {
    }

    public func getVersion() throws -> UInt8[] {
    }

    public func getInvestorCount() throws -> BigUInt {
    }

    public func transferWithData(to: EthereumAddress, amount: String, data: Data) throws -> WriteTransaction {
    }

    public func transferFromWithData(from: EthereumAddress, to: EthereumAddress, amount: String, data: Data) throws -> WriteTransaction {
    }

    public func granularity() throws -> BigUInt {
    }

}
