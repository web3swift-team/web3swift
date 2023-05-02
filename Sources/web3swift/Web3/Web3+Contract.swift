//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import Web3Core

extension Web3 {

    /// The contract instance. Initialized in runtime from ABI string (that is a JSON array). In addition an existing contract address can be supplied to provide the default "to" address in all the following requests. ABI version is 2 by default and should not be changed.
    public func contract(_ abiString: String, at: EthereumAddress? = nil, abiVersion: Int = 2) -> Contract? {
        return Contract(web3: self, abiString: abiString, at: at, abiVersion: abiVersion)
    }

    // FIXME: Rewrite this to CodableTransaction
    /// Web3 instance bound contract instance.
    public class Contract {
        public let contract: EthereumContract
        public let web3: Web3
        public var transaction = CodableTransaction.emptyTransaction

        // FIXME: Rewrite this to CodableTransaction
        /// Initialize the bound contract instance by supplying the Web3 provider bound object, ABI, Ethereum address and some default
        /// options for further function calls. By default the contract inherits options from the web3 object. Additionally supplied "options"
        /// do override inherited ones.
        public init?(web3 web3Instance: Web3, abiString: String, at: EthereumAddress? = nil, transaction: CodableTransaction = .emptyTransaction, abiVersion: Int = 2) {
            self.web3 = web3Instance
            self.transaction = transaction
            switch abiVersion {
            case 1:
                return nil
            case 2:
                // TODO: should throw
                guard let contract = try? EthereumContract(abiString, at: at) else { return nil }
                self.contract = contract
            default:
                return nil
            }

            if let at = at {
                self.contract.address = at
                self.transaction.to = at
            }
        }

        // MARK: Writing Data flow
        // FIXME: Rewrite this to CodableTransaction
        /// Deploys a constact instance using the previously provided  ABI, some bytecode, constructor parameters and options.
        /// If extraData is supplied it is appended to encoded bytecode and constructor parameters.
        ///
        /// Returns a "Transaction intermediate" object.
        public func prepareDeploy(bytecode: Data,
                                  constructor: ABI.Element.Constructor? = nil,
                                  parameters: [Any]? = nil,
                                  extraData: Data? = nil) -> WriteOperation? {
            // MARK: Writing Data flow
            guard let data = self.contract.deploy(bytecode: bytecode,
                                                  constructor: constructor,
                                                  parameters: parameters,
                                                  extraData: extraData)
            else { return nil }

            if let network = self.web3.provider.network {
                transaction.chainID = network.chainID
            }

            transaction.value = 0
            transaction.data = data
            transaction.to = .contractDeploymentAddress()

            return WriteOperation(transaction: transaction,
                                  web3: web3,
                                  contract: contract)
        }

        // FIXME: Actually this is not rading contract or smth, this is about composing appropriate binary data to iterate with it later.
        // FIXME: Rewrite this to CodableTransaction
        /// Creates and object responsible for calling a particular function of the contract. If method name is not found in ABI - returns nil.
        /// If extraData is supplied it is appended to encoded function parameters. Can be useful if one wants to call
        /// the function not listed in ABI. "Parameters" should be an array corresponding to the list of parameters of the function.
        /// Elements of "parameters" can be other arrays or instances of String, Data, BigInt, BigUInt, Int or EthereumAddress.
        ///
        /// Returns a "Transaction intermediate" object.
        public func createReadOperation(_ method: String = "fallback", parameters: [Any] = [], extraData: Data = Data()) -> ReadOperation? {
            // MARK: - Encoding ABI Data flow
            guard let data = contract.method(method, parameters: parameters, extraData: extraData) else { return nil }

            transaction.data = data

            if let network = web3.provider.network {
                transaction.chainID = network.chainID
            }

            // MARK: Read data from ABI flow
            return .init(transaction: transaction, web3: web3, contract: contract, method: method)
        }

        // FIXME: Rewrite this to CodableTransaction
        /// Creates and object responsible for calling a particular function of the contract. If method name is not found in ABI - returns nil.
        /// If extraData is supplied it is appended to encoded function parameters. Can be useful if one wants to call
        /// the function not listed in ABI. "Parameters" should be an array corresponding to the list of parameters of the function.
        /// Elements of "parameters" can be other arrays or instances of String, Data, BigInt, BigUInt, Int or EthereumAddress.
        ///
        /// Returns a "Transaction intermediate" object.
        public func createWriteOperation(_ method: String = "fallback", parameters: [Any] = [], extraData: Data = Data()) -> WriteOperation? {
            guard let data = contract.method(method, parameters: parameters, extraData: extraData) else { return nil }
            transaction.data = data
            if let network = web3.provider.network {
                transaction.chainID = network.chainID
            }
            return .init(transaction: transaction, web3: web3, contract: contract, method: method)
        }
    }
}
