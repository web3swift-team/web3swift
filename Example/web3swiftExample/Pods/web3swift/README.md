<img align="left" width="25" height="25" src="https://user-images.githubusercontent.com/28599454/41086111-af4bc3b0-6a41-11e8-9f9f-2d642b12666e.png">[Ask questions](https://stackoverflow.com/questions/tagged/web3swift)
## Important notices
The work for 2.0 release is about to start. Ideas for new more Swift idiomatic API are welcome in issues.

# web3swift

[![Version](https://img.shields.io/cocoapods/v/web3swift.svg?style=flat)](http://cocoapods.org/pods/web3swift)
[![License](https://img.shields.io/cocoapods/l/web3swift.svg?style=flat)](http://cocoapods.org/pods/web3swift)
[![Platform](https://img.shields.io/cocoapods/p/web3swift.svg?style=flat)](http://cocoapods.org/pods/web3swift)
[![support](https://brianmacdonald.github.io/Ethonate/svg/eth-support-blue.svg)](https://brianmacdonald.github.io/Ethonate/address#0x6394b37Cf80A7358b38068f0CA4760ad49983a1B)

**web3swift** is your toolbelt for any kind interactions with Ethereum network.


- [web3swift](#web3swift)
+ [Features:](#features-)
* [Design decisions](#design-decisions)
* [Example](#example)
* [Installation](#installation)
+ [Requirements](#requirements)
+ [CocoaPods](#cocoapods)
* [Getting started](#getting-started)
+ [Create Account](#create-account)
+ [Save keystore to the memory](#save-keystore-to-the-memory)
+ [Initializing Ethereum address](#initializing-ethereum-address)
+ [Setting options](#setting-options)
+ [Encoding Transaction](#encoding-transaction)
+ [Signing Transaction](#signing-transaction)
+ [Getting ETH balance](#getting-eth-balance)
+ [Getting gas price](#getting-gas-price)
+ [Sending ETH](#sending-eth)
+ [ERC20 Iteraction:](#erc20-iteraction-)
- [Getting ERC20 token balance](#getting-erc20-token-balance)
- [Sending ERC20](#sending-erc20)
* [Apps using this library](#apps-using-this-library)
* [Future plans](#future-plans)
+ [Extra features:](#extra-features-)
* [Stay in touch](#stay-in-touch)
+ [Contribution](#contribution)
+ [Communication](#communication)
+ [Special thanks to](#special-thanks-to)
* [Authors](#authors)
* [License](#license)


### Features:

- Swift implementation of [web3.js](https://github.com/ethereum/web3.js/) functionality :zap:
- Interaction with remote node via JSON RPC :thought_balloon:
- Smart-contract ABI parsing :book:
- ABI deconding (V2 is supported with return of structures from public functions. Part of 0.4.22 Solidity compiler)
- RLP encoding
- Interactions (read/write to Smart contracts) :arrows_counterclockwise:
- Local keystore management (`geth` compatible)
- Literally following the standards:
- [BIP32](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki) HD Wallets: Deterministic Wallet
- [BIP39](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki) (Seed phrases)
- [BIP44](https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki) (Key generation prefixes)
- [EIP-155](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-155.md) (Replay attacks protection) *enforced!*

**Account Managment:**
- [x] Create Account
- [x] Import Account
- [x] Manage user's private keys through encrypted keystore abstractions

**Transactions operations:**
- [x] Sign transactions
- [x] Send transactions, call functions of smart-contracts, estimate gas costs
- [x] Serialize and deserialize transactions and results to native Swift types
- [x] Check transaction results and get the receipt
- [x] Parse event logs for the transaction
- [x] Convenience functions for chain state: block number, gas price
- [x] Batched requests in concurrent mode, check balances of 580 tokens (from the latest MyEtherWallet repo) over 3 seconds


## Design decisions

- Not every JSON RPC function is exposed yet, and priority is given to the ones required for mobile devices
- Functionality was focused on serializing and signing transactions locally on the device to send raw transactions to Ethereum network
- Requirements for password input on every transaction are indeed a design decision. Interface designers can save user passwords with the user's consent
- Public function for private key export is exposed for user convenience but marked as UNSAFE_ :) Normal workflow takes care of EIP155 compatibility and proper clearing of private key data from memory

## Example

You can try it yourself by running the example project:

- Clone the repo: `git clone https://github.com/matterinc/web3swift.git`
- Move to the repo: `cd web3swift/Example/web3swiftExample`
- Install Dependencies: `pod install`
- Open: `open ./web3swiftExample.xcworkspace`


## Installation

### Requirements

Web3swift requires `Swift 4.1` and `iOS 9.0` or `macOS 10.11` although we recommend using the latest iOS and MacOS versions for your safety. Don't forget to set the iOS version in a Podfile. Otherwise, you get an error if the deployment target is less than the latest SDK.

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ sudo gem install cocoapods
```

To integrate web3swift into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'

target '<Your Target Name>' do
    use_frameworks!
    pod 'web3swift'
end
```

Then, run the following command:

```bash
$ pod install
```

## Getting started

Here are a few use cases:

### Create Account

```swift
    // Create keystore and account with password.
    
	let keystore = try! EthereumKeystoreV3(password: "changeme"); // generates a private key internally if node "privateKey" parameter supplied
        let account = keystore!.addresses![0]
        print(account)
	
        let data = try! keystore!.serialize() // internally serializes to JSON
        print(try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions(rawValue:0)))
        let key = try! keystore!.UNSAFE_getPrivateKeyData(password: "changeme", account: account) // you should rarely use this and expose a key manually	
```

### Save keystore to the memory

```swift
//First you need a `KeystoreManager` instance:
guard let userDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first,
    let keystoreManager = KeystoreManager.managerForPath(userDirectory + "/keystore")
else {
    fatalError("Couldn't create a KeystoreManager.")
}

//Next you create a new Keystore:

let newKeystore = try? EthereumKeystoreV3(password: "YOUR_PASSWORD")

// Then you save the created keystore to the file system:

let newKeystoreJSON = try? JSONEncoder().encode(newKeystore.keystoreParams)
FileManager.default.createFile(atPath: "\(keystoreManager.path)/keystore.json", contents: newKeystoreJSON, attributes: nil)

// Later you can retreive it:

if let address = keystoreManager.addresses?.first,
let retrievedKeystore = keystoreManager.walletForAddress(address) as? EthereumKeystoreV3 {
    return retrievedKeystore
}
```

### Initializing Ethereum address
```swift
let coldWalletAddress = EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B")
let constractAddress = EthereumAddress("0x45245bc59219eeaaf6cd3f382e078a461ff9de7b", ignoreChecksum: true)
```
Ethereum addresses are checksum checked if they are not lowercased or uppercased and always length checked

### Setting options

```swift
var options = Web3Options.defaultOptions()
    // public var to: EthereumAddress? = nil - to what address transaction is aimed
    // public var from: EthereumAddress? = nil - form what address it should be sent (either signed locally or on the node)
    // public var gasLimit: BigUInt? = BigUInt(90000) - default gas limit
    // public var gasPrice: BigUInt? = BigUInt(5000000000) - default gas price, quite small
    // public var value: BigUInt? = BigUInt(0) - amount of WEI sent along the transaction
options.gasPrice = gasPrice
options.gasLimit = gasLimit
options.from = EthereumAddress("0xE6877A4d8806e9A9F12eB2e8561EA6c1db19978d")
```

### Encoding Transaction

```
//TODO
```

### Signing Transaction

```
//TODO
```
### Getting ETH balance
```swift
let address = EthereumAddress("0xE6877A4d8806e9A9F12eB2e8561EA6c1db19978d")!
let web3Main = Web3.InfuraMainnetWeb3()
let balanceResult = web3Main.eth.getBalance(address)
guard case .success(let balance) = balanceResult else {return}
```
### Getting gas price
```swift
let web3Main = Web3.InfuraMainnetWeb3()
let gasPriceResult = web3Main.eth.getGasPrice()
guard case .success(let gasPrice) = gasPriceResult else {return}
```

### Sending ETH
```swift
let web3Rinkeby = Web3.InfuraRinkebyWeb3()
web3Rinkeby.addKeystoreManager(bip32keystoreManager) // attach a keystore if you want to sign locally. Otherwise unsigned request will be sent to remote node
options.from = bip32ks?.addresses?.first! // specify from what address you want to send it
intermediateSend = web3Rinkeby.contract(Web3.Utils.coldWalletABI, at: coldWalletAddress, abiVersion: 2)!.method(options: options)! // an address with a private key attached in not different from any other address, just has very simple ABI
let sendResultBip32 = intermediateSend.send(password: "changeme")
```

### ERC20 Iteraction:

#### Getting ERC20 token balance
```swift
let contractAddress = EthereumAddress("0x45245bc59219eeaaf6cd3f382e078a461ff9de7b")! // BKX token on Ethereum mainnet
let contract = web3.contract(Web3.Utils.erc20ABI, at: contractAddress, abiVersion: 2)! // utilize precompiled ERC20 ABI for your concenience
guard let bkxBalanceResult = contract.method("balanceOf", parameters: [coldWalletAddress] as [AnyObject], options: options)?.call(options: nil) else {return} // encode parameters for transaction
guard case .success(let bkxBalance) = bkxBalanceResult, let bal = bkxBalance["0"] as? BigUInt else {return} // bkxBalance is [String: Any], and parameters are enumerated as "0", "1", etc in order of being returned. If returned parameter has a name in ABI, it is also duplicated
print("BKX token balance = " + String(bal))
```

#### Sending ERC20
```swift
var convenienceTransferOptions = Web3Options.defaultOptions()
convenienceTransferOptions.gasPrice = gasPriceRinkeby
let convenienceTokenTransfer = web3Rinkeby.eth.sendERC20tokensWithNaturalUnits(tokenAddress: EthereumAddress("0xa407dd0cbc9f9d20cdbd557686625e586c85b20a")!, from: (ks?.addresses?.first!)!, to: EthereumAddress("0x6394b37Cf80A7358b38068f0CA4760ad49983a1B")!, amount: "0.0001", options: convenienceTransferOptions) // there are also convenience functions to send ETH and ERC20 under the .eth structure
let gasEstimateResult = convenienceTokenTransfer!.estimateGas(options: nil)
guard case .success(let gasEstimate) = gasEstimateResult else {return}
convenienceTransferOptions.gasLimit = gasEstimate
let convenienceTransferResult = convenienceTokenTransfer!.send(password: "changeme", options: convenienceTransferOptions)
switch convenienceTransferResult {
    case .success(let res):
        print("Token transfer successful")
        print(res)
    case .failure(let error):
        print(error)
}
```

## Apps using this library

If you are using `web3swift` in your app or know of an app that uses it, please add it to this list: [Apps using this library](https://github.com/matterinc/web3swift/wiki/Apps-using-web3swift)
It would be much appreciated! 👍

Here is some examples:

* [MEWconnect-iOS](https://github.com/MyEtherWallet/MEWconnect-iOS)
* [Peepeth iOS client](https://github.com/matterinc/PeepethClient)
* [Ethereum & ERC20Tokens Wallet](https://itunes.apple.com/us/app/ethereum-erc20tokens-wallet/id1386738877?ls=1&mt=8)
* [BankexWallet](https://github.com/BANKEX/Pay-iOS)
* [GeoChain](https://github.com/awallish/GeoChain)
* [TRX-Wallet](https://github.com/NewHorizonLabs/TRX-Wallet)
* [YOUR APP CAN BE THERE (click me)](https://github.com/matterinc/web3swift/wiki/Apps-using-web3swift/_edit) :wink:

If you've used this project in a live app, please let us know!

*If you are using `web3swift` in your app or know of an app that uses it, please add it to [this](https://github.com/matterinc/web3swift/wiki/Apps-using-web3swift) list.*



## Plans

- Full reference `web3js` functionality
- Light Ethereum subprotocol (LES) integration


### Extra features:

For the latest version, please check [develop](https://github.com/matterinc/web3swift/tree/develop) branch.
Changes made to this branch will be merged into the [master](https://github.com/matterinc/web3swift/tree/master) branch at some point.

---


## Stay in touch

When using this pod, please make references to this repo and give your start! :)
*Nothing makes developers happier than seeing someone else use our work and go wild with it.*


If you are using web3swift in your app or know of an app that uses it, please add it to [this list](https://github.com/matterinc/web3swift/wiki/Apps-using-web3swift).


### Contribution 


- If you **have a feature request**, [open an issue](https://github.com/matterinc/web3swift/issues).
- If you **want to contribute**, [submit a pull request](https://github.com/matterinc/web3swift/pulls).


### Communication

- if you **need help**, use [Stack Overflow](https://stackoverflow.com/questions/tagged/web3swift) (tag 'web3swift')
- If you'd like to **ask a general question**, use [Stack Overflow](http://stackoverflow.com/questions/tagged/web3swift).
- If you **found a bug**, [open an issue](https://github.com/matterinc/web3swift/issues).


### Special thanks to

- Gnosis team and their library [Bivrost-swift](https://github.com/gnosis/bivrost-swift) for inspiration for the ABI decoding approach
- [Trust iOS Wallet](https://github.com/TrustWallet/trust-wallet-ios) for the collaboration and discussion of the initial idea
- Official Ethereum and Solidity docs, everything was written from ground truth standards
- 
## Authors

Alex Vlasov, [@shamatar](https://github.com/shamatar),  alex.m.vlasov@gmail.com

Petr Korolev, [@skywinder](https://github.com/skywinder)

## License

web3swift is available under the Apache License 2.0 license. See the [LICENSE](https://github.com/matterinc/web3swift/blob/master/LICENSE) file for more info.
