//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt
import Web3Core

public class ENS {

    public let web3: Web3
    public let registry: Registry
    private(set) var resolver: Resolver?
    private(set) var baseRegistrar: BaseRegistrar?
    private(set) var registrarController: ETHRegistrarController?
    private(set) var reverseRegistrar: ReverseRegistrar?

    public init?(web3: Web3) {
        self.web3 = web3
        guard let registry = Registry(web3: web3) else {
            return nil
        }
        self.registry = registry
    }

    public func setENSResolver(_ resolver: Resolver) throws {
        guard resolver.web3.provider.url == self.web3.provider.url else {
            throw Web3Error.processingError(desc: "Resolver should use same provider as ENS")
        }
        self.resolver = resolver
    }

    public func setENSResolver(withDomain domain: String) async throws {
        guard let resolver = try? await self.registry.getResolver(forDomain: domain) else {
            throw Web3Error.processingError(desc: "No resolver for this domain")
        }
        self.resolver = resolver
    }

    public func setBaseRegistrar(_ baseRegistrar: BaseRegistrar) throws {
        guard baseRegistrar.web3.provider.url == self.web3.provider.url else {
            throw Web3Error.processingError(desc: "Base registrar should use same provider as ENS")
        }
        self.baseRegistrar = baseRegistrar
    }

    public func setBaseRegistrar(withAddress address: EthereumAddress) {
        let baseRegistrar = BaseRegistrar(web3: web3, address: address)
        self.baseRegistrar = baseRegistrar
    }

    public func setRegistrarController(_ registrarController: ETHRegistrarController) throws {
        guard registrarController.web3.provider.url == self.web3.provider.url else {
            throw Web3Error.processingError(desc: "Registrar controller should use same provider as ENS")
        }
        self.registrarController = registrarController
    }

    public func setRegistrarController(withAddress address: EthereumAddress) {
        let registrarController = ETHRegistrarController(web3: web3, address: address)
        self.registrarController = registrarController
    }

    public func setReverseRegistrar(_ reverseRegistrar: ReverseRegistrar) throws {
        guard reverseRegistrar.web3.provider.url == self.web3.provider.url else {
            throw Web3Error.processingError(desc: "Registrar controller should use same provider as ENS")
        }
        self.reverseRegistrar = reverseRegistrar
    }

    public func setReverseRegistrar(withAddress address: EthereumAddress) {
        let reverseRegistrar = ReverseRegistrar(web3: web3, address: address)
        self.reverseRegistrar = reverseRegistrar
    }

    lazy var defaultTransaction: CodableTransaction = {
        return CodableTransaction.emptyTransaction
    }()

    // MARK: - Convenience public resolver methods
    public func getAddress(forNode node: String) async throws -> EthereumAddress {
        guard let resolver = try? await self.registry.getResolver(forDomain: node) else {
            throw Web3Error.processingError(desc: "Failed to get resolver for domain")
        }
        guard let isAddrSupports = try? await resolver.supportsInterface(interfaceID: .addr) else {
            throw Web3Error.processingError(desc: "Resolver don't support interface with this ID")
        }
        guard isAddrSupports else {
            throw Web3Error.processingError(desc: "Address isn't supported")
        }
        guard let addr = try? await resolver.getAddress(forNode: node) else {
            throw Web3Error.processingError(desc: "Can't get address")
        }
        return addr
    }

    // FIXME: Rewrite this to CodableTransaction
    public func setAddress(forNode node: String, address: EthereumAddress, options: CodableTransaction? = nil, password: String) async throws -> TransactionSendingResult {
        guard let resolver = try? await self.registry.getResolver(forDomain: node) else {
            throw Web3Error.processingError(desc: "Failed to get resolver for domain")
        }
        guard let isAddrSupports = try? await resolver.supportsInterface(interfaceID: .addr) else {
            throw Web3Error.processingError(desc: "Resolver don't support interface with this ID")
        }
        guard isAddrSupports else {
            throw Web3Error.processingError(desc: "Address isn't supported")
        }
        var options = options ?? defaultTransaction
        options.to = resolver.resolverContractAddress
        guard let result = try? await resolver.setAddress(forNode: node, address: address, options: options, password: password) else {
            throw Web3Error.processingError(desc: "Can't get result")
        }
        return result
    }

    public func getName(forNode node: String) async throws -> String {
        guard let resolver = try? await self.registry.getResolver(forDomain: node) else {
            throw Web3Error.processingError(desc: "Failed to get resolver for domain")
        }
        guard let isNameSupports = try? await resolver.supportsInterface(interfaceID: .name) else {
            throw Web3Error.processingError(desc: "Resolver don't support interface with this ID")
        }
        guard isNameSupports else {
            throw Web3Error.processingError(desc: "Name isn't supported")
        }
        guard let name = try? await resolver.getCanonicalName(forNode: node) else {
            throw Web3Error.processingError(desc: "Can't get name")
        }
        return name
    }

    // FIXME: Rewrite this to CodableTransaction
    public func setName(forNode node: String, name: String, options: CodableTransaction? = nil, password: String) async throws -> TransactionSendingResult {
        guard let resolver = try? await self.registry.getResolver(forDomain: node) else {
            throw Web3Error.processingError(desc: "Failed to get resolver for domain")
        }
        guard let isNameSupports = try? await resolver.supportsInterface(interfaceID: .name) else {
            throw Web3Error.processingError(desc: "Resolver don't support interface with this ID")
        }
        guard isNameSupports else {
            throw Web3Error.processingError(desc: "Name isn't supported")
        }
        var options = options ?? defaultTransaction
        options.to = resolver.resolverContractAddress
        guard let result = try? await resolver.setCanonicalName(forNode: node, name: name, options: options, password: password) else {
            throw Web3Error.processingError(desc: "Can't get result")
        }
        return result
    }

    // FIXME: Rewrite this to CodableTransaction
    public func getContent(forNode node: String) async throws -> Data {
        guard let resolver = try? await self.registry.getResolver(forDomain: node) else {
            throw Web3Error.processingError(desc: "Failed to get resolver for domain")
        }
        guard let isContentSupports = try? await resolver.supportsInterface(interfaceID: .content) else {
            throw Web3Error.processingError(desc: "Resolver don't support interface with this ID")
        }
        guard isContentSupports else {
            throw Web3Error.processingError(desc: "Content isn't supported")
        }
        guard let content = try? await resolver.getContentHash(forNode: node) else {
            throw Web3Error.processingError(desc: "Can't get content")
        }
        return content
    }

    // FIXME: Rewrite this to CodableTransaction
    public func setContent(forNode node: String, hash: String, options: CodableTransaction? = nil, password: String) async throws -> TransactionSendingResult {
        guard let resolver = try? await self.registry.getResolver(forDomain: node) else {
            throw Web3Error.processingError(desc: "Failed to get resolver for domain")
        }
        guard let isContentSupports = try? await resolver.supportsInterface(interfaceID: .content) else {
            throw Web3Error.processingError(desc: "Resolver don't support interface with this ID")
        }
        guard isContentSupports else {
            throw Web3Error.processingError(desc: "Content isn't supported")
        }
        var options = options ?? defaultTransaction
        options.to = resolver.resolverContractAddress
        guard let result = try? await resolver.setContentHash(forNode: node, hash: hash, options: options, password: password) else {
            throw Web3Error.processingError(desc: "Can't get result")
        }
        return result
    }

    public func getABI(forNode node: String, contentType: ENS.Resolver.ContentType) async throws -> (BigUInt, Data) {
        guard let resolver = try? await self.registry.getResolver(forDomain: node) else {
            throw Web3Error.processingError(desc: "Failed to get resolver for domain")
        }
        guard let isABISupports = try? await resolver.supportsInterface(interfaceID: .ABI) else {
            throw Web3Error.processingError(desc: "Resolver don't support interface with this ID")
        }
        guard isABISupports else {
            throw Web3Error.processingError(desc: "ABI isn't supported")
        }
        guard let abi = try? await resolver.getContractABI(forNode: node, contentType: contentType) else {
            throw Web3Error.processingError(desc: "Can't get ABI")
        }
        return abi
    }

    // FIXME: Rewrite this to CodableTransaction
    public func setABI(forNode node: String, contentType: ENS.Resolver.ContentType, data: Data, options: CodableTransaction? = nil, password: String) async throws -> TransactionSendingResult {
        guard let resolver = try? await self.registry.getResolver(forDomain: node) else {
            throw Web3Error.processingError(desc: "Failed to get resolver for domain")
        }
        guard let isABISupports = try? await resolver.supportsInterface(interfaceID: .ABI) else {
            throw Web3Error.processingError(desc: "Resolver don't support interface with this ID")
        }
        guard isABISupports else {
            throw Web3Error.processingError(desc: "ABI isn't supported")
        }
        var options = options ?? defaultTransaction
        options.to = resolver.resolverContractAddress
        guard let result = try? await resolver.setContractABI(forNode: node, contentType: contentType, data: data, options: options, password: password) else {
            throw Web3Error.processingError(desc: "Can't get result")
        }
        return result
    }

    public func getPublicKey(forNode node: String) async throws -> PublicKey {
        guard let resolver = try? await self.registry.getResolver(forDomain: node) else {
            throw Web3Error.processingError(desc: "Failed to get resolver for domain")
        }
        guard let isPKSupports = try? await resolver.supportsInterface(interfaceID: .pubkey) else {
            throw Web3Error.processingError(desc: "Resolver don't support interface with this ID")
        }
        guard isPKSupports else {
            throw Web3Error.processingError(desc: "Public Key isn't supported")
        }
        guard let pk = try? await resolver.getPublicKey(forNode: node) else {
            throw Web3Error.processingError(desc: "Can't get Public Key")
        }
        return pk
    }

    // FIXME: Rewrite this to CodableTransaction
    public func setPublicKey(forNode node: String, publicKey: PublicKey, options: CodableTransaction? = nil, password: String) async throws -> TransactionSendingResult {
        guard let resolver = try? await self.registry.getResolver(forDomain: node) else {
            throw Web3Error.processingError(desc: "Failed to get resolver for domain")
        }
        guard let isPKSupports = try? await resolver.supportsInterface(interfaceID: .pubkey) else {
            throw Web3Error.processingError(desc: "Resolver don't support interface with this ID")
        }
        guard isPKSupports else {
            throw Web3Error.processingError(desc: "Public Key isn't supported")
        }
        var options = options ?? defaultTransaction
        options.to = resolver.resolverContractAddress
        guard let result = try? await resolver.setPublicKey(forNode: node, publicKey: publicKey, options: options, password: password) else {
            throw Web3Error.processingError(desc: "Can't get result")
        }
        return result
    }

    public func getText(forNode node: String, key: String) async throws -> String {
        guard let resolver = try? await self.registry.getResolver(forDomain: node) else {
            throw Web3Error.processingError(desc: "Failed to get resolver for domain")
        }
        guard let isTextSupports = try? await resolver.supportsInterface(interfaceID: .text) else {
            throw Web3Error.processingError(desc: "Resolver don't support interface with this ID")
        }
        guard isTextSupports else {
            throw Web3Error.processingError(desc: "Text isn't supported")
        }
        guard let text = try? await resolver.getTextData(forNode: node, key: key) else {
            throw Web3Error.processingError(desc: "Can't get text")
        }
        return text
    }

    // FIXME: Rewrite this to CodableTransaction
    public func setText(forNode node: String, key: String, value: String, options: CodableTransaction? = nil, password: String) async throws -> TransactionSendingResult {
        guard let resolver = try? await self.registry.getResolver(forDomain: node) else {
            throw Web3Error.processingError(desc: "Failed to get resolver for domain")
        }
        guard let isTextSupports = try? await resolver.supportsInterface(interfaceID: .text) else {
            throw Web3Error.processingError(desc: "Resolver don't support interface with this ID")
        }
        guard isTextSupports else {
            throw Web3Error.processingError(desc: "Text isn't supported")
        }
        var options = options ?? defaultTransaction
        options.to = resolver.resolverContractAddress
        guard let result = try? await resolver.setTextData(forNode: node, key: key, value: value, options: options, password: password) else {
            throw Web3Error.processingError(desc: "Can't get result")
        }
        return result
    }
}
