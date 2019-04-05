# Usage

## Introduction

To work with platforms based on blockchain technology, in particular with Ethereum-like blockchains, developer must be fluent in concepts such as a crypto wallet, private and public key, smart contract, token and others. We will use these concepts without explaining their meanings. For more information about Ethereum, we recommend reading the book [Mastering Ethereum](https://github.com/ethereumbook/ethereumbook), by Andreas M. Antonopoulos and Gavin Wood.

**To create keystore we forced our users to use some password, which will be used in some operations, like transactions sending. We believe that security is important for such operations and this increases its level. You are free to use a pre-compiled password in your code, that is not set by the keystore user, at your own risk.**

*In code examples we used force-unwrapped Swift optionals for better readability of example code. We recommend that you do not use this method to get rid of optional values.*

### Preffered models

To describe the library's capabilities, we will use the models described below, however you can use the models that are convenient for you.

#### Preffered keys Wallet Model (Account)

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

#### Create Account With Private Key

```swift
let password = "web3swift" // We recommend here and everywhere to use the password set by the user.
let keystore = try! EthereumKeystoreV3(password: password)!
let name = "New Wallet"
let keyData = try! JSONEncoder().encode(keystore.keystoreParams)
let address = keystore.addresses!.first!.address
let wallet = Wallet(address: address, data: keyData, name: name, isHD: false)
```

#### Create Account With Mnemonics Phrase

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

#### Import Account With Private Key

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

#### Import Account With Mnemonics Phrase

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

#### Get wallet Private key

```swift
let password = "web3swift"
let ethereumAddress = EthereumAddress(wallet.address)!
let pkData = try! keysoreManager.UNSAFE_getPrivateKeyData(password: password, account: ethereumAddress).toHexString()
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

#### Initializing Ethereum Address

```swift
let coldWalletAddress = EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B")!
let contractAddress = EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901", ignoreChecksum: true)!
```
Ethereum addresses are checksum checked if they are not lowercased or uppercased and always length checked

### Get Balance

#### Getting ETH balance

```swift
let walletAddress = EthereumAddress(wallet.address)! // Address which balance we want to know
let balanceResult = try! web3.eth.getBalance(address: walletAddress)
let balanceString = Web3.Utils.formatToEthereumUnits(balanceResult, toUnits: .eth, decimals: 3)!
```

#### Getting ERC20 token balance

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

##### Preparing Transaction For Sending Ether

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

##### Preparing Transaction For Sending ERC-20 Tokens

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

##### Preparing Write Transaction for sending to some Contract and use its method

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

##### Preparing Read Transaction to call some Contract method

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

##### Writing

```swift
let password = "web3swift"
let result = try! transaction.send(password: password)
```

##### Reading
  
```swift
let result = try! transaction.call()
```

### Chain state

#### Get Block number

```swift
let blockNumber = try! web3.eth.getBlockNumber()
```

## Infura Websockets

### Subscribe on new pending transactions

```swift
let delegate: Web3SocketDelegate = DelegateClass() // Some delegate class which will receive messages from endpoint
let socketProvider = InfuraWebsocketProvider.connectToSocket(.Mainnet, delegate: delegate)
try! socketProvider.subscribeOnNewPendingTransactions()
```

### Get latest new pending transactions

```swift
let delegate: Web3SocketDelegate = DelegateClass() // Some delegate class which will receive messages from endpoint
let socketProvider = InfuraWebsocketProvider.connectToSocket(.Mainnet, delegate: delegate)
try! socketProvider.filter(method: .newPendingTransactionFilter)
```
