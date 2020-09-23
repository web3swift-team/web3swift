
# web3swift 2.0 Migration Guide

web3swift 2.0 is the latest major release of web3swift by Matter, Swift implementation of web3.js functionality for iOS and macOS. Following Semantic Versioning conventions, 2.0 introduces major release API-breaking changes.

This guide is provided in order to ease the transition of existing applications using web3swift 1.x to the latest APIs, as well as explain the design and structure of new and updated functionality.

- [Requirements](#requirements)
- [Benefits of Upgrading](#benefits-of-upgrading)
- [Follow naming convention](#follow-naming-convention)
- [New pods](#new-pods)
- [Breaking API Changes](#breaking-api-changes)
	- [Setting Transaction Options](#setting-transaction-options)
	- [Preparing transaction](#preparing-transaction)
		- [For sending Ether](#for-sending-ether)
		- [For sending ERC20](#for-sending-erc20)
		- [For sending to contract](#for-sending-to-contract)
	- [Send transaction](#send-transaction)
		- [For sending ether or tokens to wallets and contracts](#for-sending-ether-or-tokens-to-wallets-and-contracts)
		- [For calling contract methods](#for-calling-contract-methods)
	- [Get balance](#get-balance)
		- [Get Ether balance](#get-ether-balance)
		- [Get ERC20 balance](#get-erc20-balance)
	- [Chain state](#chain-state)
		- [Get Block number](#get-block-number)

## Requirements

- iOS 9.0+, macOS 10.11.0+
- Xcode 10.0+
- Swift 4.0+

## Benefits of Upgrading

- **Complete Swift 4 Compatibility:** includes the full adoption of the new [API Design Guidelines](https://swift.org/documentation/api-design-guidelines/).
- **Separate libraries: EthereumAddress, EthereumABI:** Since there are several Matter products uses this classes, we've decided make them separate and turn in Pods.
- **New class: TransactionOptions:** "Web3Options" is no longer used, instead new class introduced: "TransactionOptions" used to specify gas price, limit, nonce policy, value.
- **New classes: Write Transaction & Read Transaction:** "TransactionIntermediate" is no longer used, instead two new classes introduced: "ReadTransaction" and "WriteTransaction", that have a variable "transactionOptions" used to specify gas price, limit, nonce policy, value
- **WKWebView with injected "web3" provider:** create a simple DApps' browser with "web3" provider onboard.
- **Add or remove "middleware":** that intercepts, modifies and even cancel transaction workflow on stages "before assembly" (before obtaining nonce, gas price, etc), "after assembly" (when nonce and gas price is set for transaction) and "before submission" (right before transaction is either signed locally and is sent as raw, or just send to remote node).
- **Hooks and event loops functionality:** easy monitor properties in web3.
- **New errors handling:** more 'try-catch' less optionals for errors handling.
- **Removed "Result" framework:** usage of "Result" framework was removed due to large amount if name conflicts, now functions throw instead of returning "Result" wrapper.

---

## New pods

Now EthereumAddress and Ethereum ABI are separate projects. Use "//import EthereumAddress" and "import Ethereum ABI" everywhere you use them.

## Breaking API Changes

web3swift 2.0 has fully adopted all the new Swift 4 changes and conventions, including the new [API Design Guidelines](https://swift.org/documentation/api-design-guidelines/). Because of this, almost every API in web3swift has been modified in some way. We can't possibly document every single change, so we're going to attempt to identify the most important API changes to help you through those sometimes less than helpful compiler errors.

### Setting Transaction Options

Since setting transaction options is the most important operation for building transaction in web3swift, here are some examples of web3swift 1.x building transaction options compared to their new equivalents in web3swift 2.0.

```swift
// web3swift 1.0
var options = Web3Options()
options.gasLimit = BigUInt(0)
options.gasPrice = BigUInt(0)
options.value = BigUInt(0)
options.to = EthereumAddress("<Reciever address>")!
options.from = EthereumAddress("<Sender address>")!

// web3swift 2.0
var options = TransactionOptions()
options.callOnBlock = .pending // or .latest / or .exactBlockNumber(BigUInt)
options.nonce = .pending // or .latest / or .manual(BigUInt)
options.gasLimit = .automatic // or .manual(BigUInt) / or .limited(BigUInt) / or .withMargin(Double)
options.gasPrice = .automatic // or .manual(BigUInt) / or .withMargin(Double)
options.to = EthereumAddress("<Reciever address>")!
options.from = EthereumAddress("<Sender address>")!
```

### Preparing transaction

In web3swift 1.0 you specified transactions for Ether, ERC20 and to contract in different, inconvenient and unobvious ways. From 2.0 on it became more convenient and obvious.

#### For sending Ether

```swift
// web3swift 1.0
guard let destinationEthAddress = EthereumAddress(destinationAddressString) else {return}
guard let amount = Web3.Utils.parseToBigUInt(amountString, units: .eth) else {return}
guard let selectedKey = KeysService().selectedWallet()?.address else {return}
let web3 = web3swift.web3(provider: InfuraProvider(Networks.Mainnet)!) //or any other network
web3.addKeystoreManager(KeysService().keystoreManager())
let ethAddressFrom = EthereumAddress(selectedKey)
var options = Web3Options.defaultOptions()
options.from = ethAddressFrom
options.value = BigUInt(amount)
guard let contract = web3.contract(Web3.Utils.coldWalletABI, at: destinationEthAddress) else {return}
guard let estimatedGas = contract.method(options: options)?.estimateGas(options: nil).value else {return}
options.gasLimit = estimatedGas
guard let gasPrice = web3.eth.getGasPrice().value else {return}
options.gasPrice = gasPrice
guard let transaction = contract.method(options: options) else {return}
return transaction

// web3swift 2.0
guard let destinationEthAddress = EthereumAddress(destinationAddressString) else {return}
guard let amount = Web3.Utils.parseToBigUInt(amountString, units: .eth) else {return}
guard let selectedKey = KeysService().selectedWallet()?.address else {return}
let web3 = Web3.InfuraMainnetWeb3() //or any other network
web3.addKeystoreManager(KeysService().keystoreManager())
guard let ethAddressFrom = EthereumAddress(selectedKey) else {return}
guard let contract = web3.contract(Web3.Utils.coldWalletABI, at: destinationEthAddress, abiVersion: 2) else {return}
guard let writeTX = contract.write("fallback") else {return}
writeTX.transactionOptions.from = ethAddressFrom
writeTX.transactionOptions.value = value
return writeTX
```

#### For sending ERC20

```swift
// web3swift 1.0
guard let destinationEthAddress = EthereumAddress(destinationAddressString) else {return}
guard let amount = Web3.Utils.parseToBigUInt(amountString, units: .eth) else {return}
let web3 = web3swift.web3(provider: InfuraProvider(Networks.Mainnet)!) //or any other network
web3.addKeystoreManager(KeysService().keystoreManager())
let contract = self.contract(for: token, web3: web3)
var options = Web3Options.defaultOptions()
guard let tokenAddress = EthereumAddress(token), 
      let fromAddress = Web3SwiftService.currentAddress,
      let intermediate = web3.eth.sendERC20tokensWithNaturalUnits(tokenAddress: tokenAddress,
                                                                  from: fromAddress,
                                                                  to: destinationEthAddress,
                                                                  amount: amountString) else {return}
//MARK: - Just to check that everything is all right
guard let _ = contract?.method(options: options)?.estimateGas(options: options).value else {return}
guard let gasPrice = web3.eth.getGasPrice().value else {return}
options.from = Web3SwiftService.currentAddress
options.gasPrice = gasPrice
options.value = 0
options.to = EthereumAddress(token)
let parameters = [destinationEthAddress, amount] as [Any]
guard let transaction = contract?.method("transfer",
                                         parameters: parameters as [AnyObject],
                                         options: options) else {return}
return transaction

// web3swift 2.0
guard let contractAddress = EthereumAddress(contractAddressString) else {return}
guard let amount = Web3.Utils.parseToBigUInt(amountString, units: .eth) else {return}
guard let selectedKey = KeysService().selectedWallet()?.address else {return}
let web3 = Web3.InfuraMainnetWeb3() //or any other network
web3.addKeystoreManager(KeysService().keystoreManager())
guard let ethAddressFrom = EthereumAddress(selectedKey) else {return}
guard let contract = web3.contract(Web3.Utils.erc20ABI, at: contractAddress, abiVersion: 2) else {return}
guard let writeTX = contract.write("transfer") else {return}
writeTX.transactionOptions.from = ethAddressFrom
writeTX.transactionOptions.value = value
return writeTX
```

#### For sending to contract

```swift
// web3swift 1.0
let wallet = TransactionsService.keyservice.selectedWallet()
guard let address = wallet?.address else {return}
guard let ethAddressFrom = EthereumAddress(address) else {return}
guard let ethContractAddress = EthereumAddress(contractAddress) else {return}
let web3 = Web3.InfuraMainnetWeb3() //or any other web
web3.addKeystoreManager(TransactionsService.keyservice.keystoreManager())
var options = predefinedOptions ?? Web3Options.defaultOptions()
options.from = ethAddressFrom
options.to = ethContractAddress
options.value = options.value ?? 0
guard let contract = web3.contract(contractAbi,
                                   at: ethContractAddress,
                                   abiVersion: 2) else {return}
guard let gasPrice = web3.eth.getGasPrice().value else {return}
options.gasPrice = predefinedOptions?.gasPrice ?? gasPrice
guard let transaction = contract.method(method,
                                        parameters: data,
                                        options: options) else {return}
guard case .success(let estimate) = transaction.estimateGas(options: options) else {return}
print("estimated cost: \(estimate)")
return transaction

// web3swift 2.0
guard let contractAddress = EthereumAddress(contractAddressString) else {return}
guard let amount = Web3.Utils.parseToBigUInt(amountString, units: .eth) else {return}
guard let selectedKey = KeysService().selectedWallet()?.address else {return}
let web3 = Web3.InfuraMainnetWeb3() //or any other network
web3.addKeystoreManager(KeysService().keystoreManager())
guard let ethAddressFrom = EthereumAddress(selectedKey) else {return}
guard let contract = web3.contract(contractAbi, at: contractAddress, abiVersion: 2) else {return}
guard let writeTX = contract.write(method,
                                   parameters: parameters,
                                   extraData: data,
                                   transactionOptions: predefinedOptions) else {return}
writeTX.transactionOptions.from = ethAddressFrom
writeTX.transactionOptions.value = value
return writeTX
```

### Send transaction

In web3swift 1.0 you specified sending operations with only value and to contract in different, inconvenient and unobvious ways. From 2.0 on you can use two methods: Send to send ether or tokens and Call for calling contract methods.

#### For sending ether or tokens to wallets and contracts

```swift
// web3swift 1.0
let result = transaction.send(password: <your password>,
                                options: options)
if let error = result.error {return}
guard let value = result.value else {return}
return value

// web3swift 2.0
let options = options ?? transaction.transactionOptions
guard let result = password == nil ?
    try? transaction.send() :
    try? transaction.send(password: <your password>, transactionOptions: options) else {return}
return result
```

#### For calling contract methods

```swift
// web3swift 1.0
let result = transaction.send(password: <your password>,
                              options: transaction.options)
if let error = result.error {return}
guard let value = result.value else {return}
return value

// web3swift 2.0
let options = options ?? transaction.transactionOptions
guard let result = try? transaction.call(transactionOptions: options) else {return}
return result
```

### Get balance

### Get Ether balance

```swift
// web3swift 1.0
let address = EthereumAddress("<Address>")!
let web3Main = Web3.InfuraMainnetWeb3()
let balanceResult = web3Main.eth.getBalance(address)
guard case .success(let balance) = balanceResult else {return}
let balanceString = Web3.Utils.formatToEthereumUnits(balance, toUnits: .eth, decimals: 3)

// web3swift 2.0
let address = EthereumAddress("<Address>")!
let web3 = Web3.InfuraMainnetWeb3()
let balance = try web3.eth.getBalance(address: address)
let balanceString = Web3.Utils.formatToEthereumUnits(balance, toUnits: .eth, decimals: 3)
```

### Get ERC20 balance

```swift
// web3swift 1.0
let contractAddress = EthereumAddress("<Contract ddress>")! // w3s token on Ethereum mainnet
let contract = web3.contract(Web3.Utils.erc20ABI, at: contractAddress, abiVersion: 2)! // utilize precompiled ERC20 ABI for your concenience
guard let w3sBalanceResult = contract.method("balanceOf",
					     parameters: [coldWalletAddress] as [AnyObject],
					     options: options)?.call(options: nil) else {return} // encode parameters for transaction
guard case .success(let w3sBalance) = w3sBalanceResult, let bal = w3sBalance["0"] as? BigUInt else {return} // w3sBalance is [String: Any], and parameters are enumerated as "0", "1", etc in order of being returned. If returned parameter has a name in ABI, it is also duplicated

// web3swift 2.0
let contractAddress = EthereumAddress("<Contract address>")! // w3s token on Ethereum mainnet
let contract = web3.contract(Web3.Utils.erc20ABI, at: contractAddress, abiVersion: 2) // utilize precompiled ERC20 ABI for your concenience
let userAddress = EthereumAddress("<address>")!
guard let readTX = contract?.read("balanceOf", parameters: [addressOfUser] as [AnyObject]) else {return}
readTX.transactionOptions.from = EthereumAddress("<address>")!
let tokenBalance = try readTX.callPromise().wait()
guard let balance = tokenBalance["0"] as? BigUInt else {return}
```

### Chain state

### Get Block number

```swift
// web3swift 1.0
let web3 = WalletWeb3Factory.web3()
let res = web3.eth.getBlockNumber()
switch res {
case .failure(let error):
    return error
case .success(let number):
    return number
}

// web3swift 2.0
do {
  let number = try web3.eth.getBlockNumber()
  return number
} catch let error {
  return error
}
```
