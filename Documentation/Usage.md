# Usage

---
## Table of contents:

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
- [About source and GitHub repositories](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#about-source-and-github-repositories)

- [Introduction](#introduction)
  - [Preffered models](#preffered-models)
    - [Preferred keys Wallet Model (Account)](#preferred-keys-wallet-model-account)
    - [Preffered ERC-20 Model](#preffered-erc-20-model)
- [Account Management](#account-management)
  - [Create Account](#create-account)
    - [With Private Key](#with-private-key)
    - [With Mnemonics Phrase](#with-mnemonics-phrase)
  - [Import Account](#import-account)
    - [With Private Key](#with-private-key-1)
    - [With Mnemonics Phrase](#with-mnemonics-phrase-1)
  - [Get Keystore Manager from wallet data](#get-keystore-manager-from-wallet-data)
  - [Get private key](#get-private-key)
- [Ethereum Endpoints interaction](#ethereum-endpoints-interaction)
  - [web3 instance](#web3-instance)
  - [Ethereum Address](#ethereum-address)
    - [Initializing](#initializing)
  - [Get Balance](#get-balance)
    - [Get ETH balance](#get-eth-balance)
    - [Get ERC20 token balance](#get-erc20-token-balance)
  - [Transactions Operations](#transactions-operations)
    - [Prepare Transaction](#prepare-transaction)
      - [Send Ether](#send-ether)
      - [Send ERC-20 Token](#send-erc-20-token)
      - [Write Transaction and call smart contract method](#write-transaction-and-call-smart-contract-method)
      - [Read Transaction to call smart contract method](#read-transaction-to-call-smart-contract-method)
    - [Send Transaction](#send-transaction)
      - [Write](#write)
      - [Read](#read)
  - [Chain state](#chain-state)
    - [Get Block number](#get-block-number)
- [Websockets](#websockets)
  - [Web3socketDelegate](#web3socketdelegate)
  - [Custom Websocket Provider](#custom-websocket-provider)
    - [Connect to custom endpoint](#connect-to-custom-endpoint)
    - [Send message](#send-message)
  - [Infura Websocket interactions](#infura-websocket-interactions)
    - [Connect to Infura endpoint](#connect-to-infura-endpoint)
    - [Connect to custom Infura-like endpoint](#connect-to-custom-infura-like-endpoint)
    - [Set a filter in the node to notify when something happened](#set-a-filter-in-the-node-to-notify-when-something-happened)
    - [Get new pending transactions](#get-new-pending-transactions)
    - [Create a new subscription over particular events](#create-a-new-subscription-over-particular-events)
    - [Subscribe on new pending transactions](#subscribe-on-new-pending-transactions)
		- [Subscribe on logs](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#subscribe-on-logs)
		- [Subscribe on new heads](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#subscribe-on-new-heads)
- [ENS](#ens)
  - [Registry](#registry)
  - [Resolver](#resolver)
  - [BaseRegistrar](#baseregistrar)
  - [RegistrarController](#registrarcontroller)
  - [ReverseRegistrar](#reverseregistrar)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Introduction

To work with platforms based on blockchain technology, in particular with Ethereum-like blockchains, a developer must be fluent in concepts such as a crypto wallet, private and public key, smart contract, token and others. We will use these concepts without explaining their meanings. For more information about Ethereum, we recommend reading the book [Mastering Ethereum](https://github.com/ethereumbook/ethereumbook), by Andreas M. Antonopoulos and Gavin Wood.

**To create keystore we forced our users to use some password, which will be used in some operations, like transactions sending. We believe that security is essential for such, and this increases its level. You are free to use a pre-compiled password in your code, that is not set by the keystore user, at your own risk.**

*In code examples we used force-unwrapped Swift optionals for better readability of example code. We recommend that you do not use this method to get rid of optional values.*

### Preffered models

To describe the library's capabilities, we will use the models described below. However, you can use the models that are convenient for you.

#### Preferred keys Wallet Model (Account)

```swift
struct Wallet {
    let address: String
    let data: Data
    let name: String
    let isHD: Bool
}

struct HDKey {
    let name: String?
    let address: String
}
```

#### Preffered ERC-20 Model

```swift
class ERC20Token {
    var name: String
    var address: String
    var decimals: String
    var symbol: String
}
```

## Account Management

### Create Account

#### With Private Key

```swift
let password = "web3swift" // We recommend here and everywhere to use the password set by the user.
let keystore = try! EthereumKeystoreV3(password: password)!
let name = "New Wallet"
let keyData = try! JSONEncoder().encode(keystore.keystoreParams)
let address = keystore.addresses!.first!.address
let wallet = Wallet(address: address, data: keyData, name: name, isHD: false)
```

#### With Mnemonics Phrase

```swift
let password = "web3swift"
let bitsOfEntropy: Int = 128 // Entropy is a measure of password strength. Usually used 128 or 256 bits.
let mnemonics = try! BIP39.generateMnemonics(bitsOfEntropy: bitsOfEntropy)!
let keystore = try! BIP32Keystore(
    mnemonics: mnemonics,
    password: password,
    mnemonicsPassword: "",
    language: .english)!
let name = "New HD Wallet"
let keyData = try! JSONEncoder().encode(keystore.keystoreParams)
let address = keystore.addresses!.first!.address
let wallet = Wallet(address: address, data: keyData, name: name, isHD: true)
```

### Import Account

#### With Private Key

```swift
let password = "web3swift"
let key = "L2HRewdY7SSpB2jjKq6mwLes86umkWBuUSPZWE35Q8Pbbr8wVyss124sf124dfsf" // Some private key
let formattedKey = key.trimmingCharacters(in: .whitespacesAndNewlines)
let dataKey = Data.fromHex(formattedKey)!
let keystore = try! EthereumKeystoreV3(privateKey: dataKey, password: password)!
let name = "New Wallet"
let keyData = try! JSONEncoder().encode(keystore.keystoreParams)
let address = keystore.addresses!.first!.address
let wallet = Wallet(address: address, data: keyData, name: name, isHD: false)
```

#### With Mnemonics Phrase

```swift
let password = "web3swift"
let mnemonics = "fine have legal roof fury bread egg knee wrong idea must edit" // Some mnemonic phrase
let keystore = try! BIP32Keystore(
    mnemonics: mnemonics,
    password: password,
    mnemonicsPassword: "",
    language: .english)!
let name = "New HD Wallet"
let keyData = try! JSONEncoder().encode(keystore.keystoreParams)
let address = keystore.addresses!.first!.address
let wallet = Wallet(address: address, data: keyData, name: name, isHD: true)
```

### Get Keystore Manager from wallet data

```swift
let data = wallet.data
let keystoreManager: KeystoreManager
if wallet.isHD {
    let keystore = BIP32Keystore(data)!
    keystoreManager = KeystoreManager([keystore])
} else {
    let keystore = EthereumKeystoreV3(data)!
    keystoreManager = KeystoreManager([keystore])
}
```

### Get private key

```swift
let password = "web3swift"
let ethereumAddress = EthereumAddress(wallet.address)!
let pkData = try! keystoreManager.UNSAFE_getPrivateKeyData(password: password, account: ethereumAddress).toHexString()
```

## Ethereum Endpoints interaction

### web3 instance

Firstly you need to initialize 'web3' instance for almost all further operations:
```swift
// common Http/Https provider
let endpoint = "https://some.endpoint"
let web3 = web3(provider: Web3HttpProvider(URL(string: endpoint)!)!)
// precompiled Infura providers
let web3 = Web3.InfuraMainnetWeb3() // Mainnet Infura Endpoint Provider
let web3 = Web3.InfuraRinkebyWeb3() // Rinkeby Infura Endpoint Provider
let web3 = Web3.InfuraRopstenWeb3() // Ropsten Infura Endpoint Provider
```

Then you will need to attach keystore manager to web3 instance:
```swift
web3.addKeystoreManager(keystoreManager)
```

### Ethereum Address

#### Initializing

```swift
let coldWalletAddress = EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B")!
let contractAddress = EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901", ignoreChecksum: true)!
```
Ethereum addresses are checksum checked if they are not lowercased or uppercased and always length checked

### Get Balance

#### Get ETH balance

```swift
let walletAddress = EthereumAddress(wallet.address)! // Address which balance we want to know
let balanceResult = try! web3.eth.getBalance(address: walletAddress)
let balanceString = Web3.Utils.formatToEthereumUnits(balanceResult, toUnits: .eth, decimals: 3)!
```

#### Get ERC20 token balance

```swift
let walletAddress = EthereumAddress(wallet.address)! // Your wallet address
let exploredAddress = EthereumAddress(wallet.address)! // Address which balance we want to know. Here we used same wallet address
let erc20ContractAddress = EthereumAddress(token.address)!
let contract = web3.contract(Web3.Utils.erc20ABI, at: erc20ContractAddress, abiVersion: 2)!
var options = TransactionOptions.defaultOptions
options.from = walletAddress
options.gasPrice = .automatic
options.gasLimit = .automatic
let method = "balanceOf"
let tx = contract.read(
    method,
    parameters: [exploredAddress] as [AnyObject],
    extraData: Data(),
    transactionOptions: options)!
let tokenBalance = try! tx.call()
let balanceBigUInt = tokenBalance["0"] as! BigUInt
let balanceString = Web3.Utils.formatToEthereumUnits(balanceResult, toUnits: .eth, decimals: 3)!
```

### Transactions Operations

#### Prepare Transaction

##### Send Ether

```swift
let value: String = "1.0" // In Ether
let walletAddress = EthereumAddress(wallet.address)! // Your wallet address
let toAddress = EthereumAddress(toAddressString)!
let contract = web3.contract(Web3.Utils.coldWalletABI, at: toAddress, abiVersion: 2)!
let amount = Web3.Utils.parseToBigUInt(value, units: .eth)
var options = TransactionOptions.defaultOptions
options.value = amount
options.from = walletAddress
options.gasPrice = .automatic
options.gasLimit = .automatic
let tx = contract.write(
    "fallback",
    parameters: [AnyObject](),
    extraData: Data(),
    transactionOptions: options)!
```

##### Send ERC-20 Token

```swift
let value: String = "1.0" // In Tokens
let walletAddress = EthereumAddress(wallet.address)! // Your wallet address
let toAddress = EthereumAddress(toAddressString)!
let erc20ContractAddress = EthereumAddress(token.address)!
let contract = web3.contract(Web3.Utils.erc20ABI, at: erc20ContractAddress, abiVersion: 2)!
let amount = Web3.Utils.parseToBigUInt(value, units: .eth)
var options = TransactionOptions.defaultOptions
options.value = amount
options.from = walletAddress
options.gasPrice = .automatic
options.gasLimit = .automatic
let method = "transfer"
let tx = contract.write(
    method,
    parameters: [toAddress, amount] as [AnyObject],
    extraData: Data(),
    transactionOptions: options)!
```

##### Write Transaction and call smart contract method

```swift
let value: String = "0.0" // Any amount of Ether you need to send
let walletAddress = EthereumAddress(wallet.address)! // Your wallet address
let contractMethod = "SOMECONTRACTMETHOD" // Contract method you want to write
let contractABI = "..." // Contract ABI
let contractAddress = EthereumAddress(contractAddressString)!
let abiVersion = 2 // Contract ABI version
let parameters: [AnyObject] = [...]() // Parameters for contract method
let extraData: Data = Data() // Extra data for contract method
let contract = web3.contract(contractABI, at: contractAddress, abiVersion: abiVersion)!
let amount = Web3.Utils.parseToBigUInt(value, units: .eth)
var options = TransactionOptions.defaultOptions
options.value = amount
options.from = walletAddress
options.gasPrice = .automatic
options.gasLimit = .automatic
let tx = contract.write(
    contractMethod,
    parameters: parameters,
    extraData: extraData,
    transactionOptions: options)!
```

##### Read Transaction from call smart contract method

```swift
let walletAddress = EthereumAddress(wallet.address)! // Your wallet address
let contractMethod = "SOMECONTRACTMETHOD" // Contract method you want to call
let contractABI = "..." // Contract ABI
let contractAddress = EthereumAddress(contractAddressString)!
let abiVersion = 2 // Contract ABI version
let parameters: [AnyObject] = [...]() // Parameters for contract method
let extraData: Data = Data() // Extra data for contract method
let contract = web3.contract(contractABI, at: contractAddress, abiVersion: abiVersion)!
var options = TransactionOptions.defaultOptions
options.from = walletAddress
options.gasPrice = .automatic
options.gasLimit = .automatic
let tx = contract.read(
    contractMethod,
    parameters: parameters,
    extraData: extraData,
    transactionOptions: options)!
```

#### Send Transaction

##### Write

```swift
let password = "web3swift"
let result = try! transaction.send(password: password)
```

##### Read

```swift
let result = try! transaction.call()
```

### Chain state

#### Get Block number

```swift
let blockNumber = try! web3.eth.getBlockNumber()
```

## Websockets

### Web3socketDelegate

To receive messages from endpoint you need to create a class that adopts to Web3SocketDelegate protocol.
Later, to open a connection to WebSocket server, you will use socket provider (`WebsocketProvider` or `InfuraWebsocketProvider`). And we recommend you to make it a property, so it doesn't get deallocated right after being setup.
```swift
class DelegateClass: Web3SocketDelegate {
    var socketProvider: WebsocketProvider? = nil // WebSocket Provider
    var socketProvider: InfuraWebsocketProvider? = nil // Infura WebSocket Provider

    // Protocol method, here will be messages, received from WebSocket server
    func received(message: Any) {
            // Make something with message
        }
}
```

### Custom Websocket Provider

#### Connect to custom endpoint

You can create WebsocketProvider and connect/disconnect it.
```swift
socketProvider = WebsocketProvider("ws://your.endpoint", delegate: delegate)
socketProvider.connectSocket()
/// Some code
/// ...
socketProvider.disconnectSocket()
```

Or you can create already connected WebsocketProvider
```swift
socketProvider = WebsocketProvider.connectToSocket("ws://your.endpoint", delegate: delegate)
```

#### Send message

```swift
// String message
socketProvider.writeMessage(String())
// Data message
socketProvider.writeMessage(Data())
```

### Infura Websocket interactions

#### Connect to Infura endpoint

```swift
socketProvider = InfuraWebsocketProvider.connectToInfuraSocket(.Mainnet, delegate: delegate)
```

#### Connect to custom Infura-like endpoint

```swift
socketProvider = InfuraWebsocketProvider.connectToSocket("ws://your.endpoint", delegate: delegate)
```

#### Set a filter in the node to notify when something happened

To study possible filters read [Infura WSS filters documentation](https://infura.io/docs/ethereum/wss/introduction)

```swift
// Getting logs
try! socketProvider.setFilterAndGetLogs(method: <InfuraWebsocketMethod>, params: <[Encodable]?>)
// Getting changes
try! socketProvider.setFilterAndGetChanges(method: <InfuraWebsocketMethod>, params: <[Encodable]?>)
```
Or you can provide parameters in more convenient way:
```swift
// Getting logs
try! socketProvider.setFilterAndGetLogs(method: <InfuraWebsocketMethod>, address: <EthereumAddress?>, fromBlock: <BlockNumber?>, toBlock: <BlockNumber?>, topics: <[String]?>)
// Getting changes
try! socketProvider.setFilterAndGetChanges(method: <InfuraWebsocketMethod>, address: <EthereumAddress?>, fromBlock: <BlockNumber?>, toBlock: <BlockNumber?>, topics: <[String]?>)
```

####  Get new pending transactions

```swift
try! socketProvider.setFilterAndGetLogs(method: .newPendingTransactionFilter)
```

#### Create a new subscription over particular events

To study possible subscriptions read [Infura WSS subscriptions documentation](https://infura.io/docs/ethereum/wss/eth_subscribe)

```swift
try! socketProvider.subscribe(params: <[Encodable]>)
```

#### Subscribe on new pending transactions

```swift
try! socketProvider.subscribeOnNewPendingTransactions()
```

#### Subscribe on logs

```swift
try! socketProvider.subscribeOnLogs(addresses: <[EthereumAddress]?>, topics: <[String]?>)
```

#### Subscribe on new heads

```swift
try! socketProvider.subscribeOnNewHeads()
```

## ENS

You need ENS instance for future actions:
```swift
let web = web3(provider: InfuraProvider(Networks.Mainnet)!)
let ens = ENS(web3: web)!
```

### Registry

You can get/set owner, resolver, ttl via ENS property registry:
```swift
let owner = try! ens.registry.getOwner(node: node)
let resultSettingOwner = try! ens.registry.setOwner(node: node, owner: owner, options: options, password: password)
...
```

### Resolver

You use convenient resolver methods from ENS instance:
```swift
let address = try! ens.getAddress(forNode: node)
let name = try! ens.getName(forNode: node)
let content = try! ens.getContent(forNode: node)
let abi = try! ens.getABI(forNode: node)
let pubkey = try! ens.getPublicKey(forNode: node)
let text = try! ens.getText(forNode: node, key: key)

let result = try! ens.setAddress(forNode: node, address: address, options: options, password: password)
let result = try! ens.setName(forNode: node, name: name, options: options, password: password)
let result = try! ens.setContent(forNode: node, hash: hash, options: options, password: password)
let result = try! ens.setABI(forNode: node, contentType: .JSON, data: data, options: options, password: password)
let result = try! ens.setPublicKey(forNode: node, publicKey: publicKey, options: options, password: password)
let result = try! ens.setText(forNode: node, key: key, value: value, options: options, password: password)
```
or you can get resolver to use its methods directly:
```swift
let resolver = try! ens.registry.getResolver(forDomain: domain)
let doSomething = try! resolver. ...
```
or set it as ENS instance property and use its methods from it:
```swift
try! ens.setENSResolver(withDomain: domain)
let doSomething = try! ens.resolver!. ...
```

### BaseRegistrar
You can set BaseRegistrar as ENS instance property and use its methods from it:
```swift
ens.setBaseRegistrar(withAddress: address)
let doSomething = try! ens.baseRegistrar!. ...
```

### RegistrarController
You can set RegistrarController as ENS instance property and use its methods from it:
```swift
ens.setRegistrarController(withAddresss: address)
let doSomething = try! ens.registrarController!. ...
```

### ReverseRegistrar
You can set ReverseRegistrar as ENS instance property and use its methods from it:
```swift
ens.setReverseRegistrar(withAddresss: address)
let doSomething = try! ens.reverseRegistrar!. ...
```
