![matter-github-swift](https://github.com/matterinc/web3swift/blob/develop/web3swift-logo.png)

# web3swift

[![Build Status](https://travis-ci.com/matter-labs/web3swift.svg?branch=develop)](https://travis-ci.com/matter-labs/web3swift)
[![Swift](https://img.shields.io/badge/Swift-4.0-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Platform](https://img.shields.io/cocoapods/p/web3swift.svg?style=flat)](http://cocoapods.org/pods/web3swift)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/web3swift.svg?style=flat)](http://cocoapods.org/pods/web3swift)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/web3swift.svg?style=flat)](http://cocoapods.org/pods/web3swift)
[![support](https://brianmacdonald.github.io/Ethonate/svg/eth-support-blue.svg)](https://brianmacdonald.github.io/Ethonate/address#0xe22b8979739d724343bd002f9f432f5990879901)
[![Stackoverflow](https://img.shields.io/badge/stackoverflow-ask-blue.svg)](https://stackoverflow.com/questions/tagged/web3swift)

**web3swift** is your toolbelt for any kind interactions with Ethereum network.


  * [Ready Features](#features)
  * [Design Decisions](#design-decisions)
  * [Requirements](#requirements)
  * [Migration Guides](#migration-guides)
  * [Communication](#communication)
  * [Installation](#installation)
    + [CocoaPods](#cocoapods)
    + [Carthage](#carthage)
  * [Example Project](#example-project)
  * [Popular questions](#popular-questions)
  * [What's next](#whats-next)
  * [Credits](#credits)
    + [Security Disclosure](#security-disclosure)
  * [Donations](#donations)
  * [License](#license)

---
  - [Usage Doc](https://github.com/matterinc/web3swift/blob/develop/Documentation/Usage.md)
	- **Account Management** 
		- [Create Account](https://github.com/matterinc/web3swift/blob/develop/Documentation/Usage.md#create-account)
		- [Import Account](https://github.com/matterinc/web3swift/blob/develop/Documentation/Usage.md#import-account)
		- [Manage Keystore](https://github.com/matterinc/web3swift/blob/develop/Documentation/Usage.md#manage-keystore)
		- [Ethereum Address](https://github.com/matterinc/web3swift/blob/develop/Documentation/Usage.md#ethereum-address)
		- [Get Balance](https://github.com/matterinc/web3swift/blob/develop/Documentation/Usage.md#get-balance)
	- **Transactions Operations** 
		- [Prepare Transaction](https://github.com/matterinc/web3swift/blob/develop/Documentation/Usage.md#prepare-transaction)
		- [Send Transaction](https://github.com/matterinc/web3swift/blob/develop/Documentation/Usage.md#send-transaction)
	- **Chain State** 
		- [Get Block Number](https://github.com/matterinc/web3swift/blob/develop/Documentation/Usage.md#get-block-number)


## Ready Features

- [x] Swift implementation of [web3.js](https://github.com/ethereum/web3.js/) functionality :zap:
- [x] Interaction with remote node via JSON RPC :thought_balloon:
- [x] Local keystore management (`geth` compatible)
- [x] Smart-contract ABI parsing :book:
- [x] ABI deconding (V2 is supported with return of structures from public functions. Part of 0.4.22 Solidity compiler)
- [x] Ethereum Name Service (ENS) support - a secure & decentralised way to address resources both on and off the blockchain using simple, human-readable names
- [x] Interactions (read/write to Smart contracts) :arrows_counterclockwise:
- [x] Parsing TxPool content into native values (ethereum addresses and transactions) - easy to get pending transactions
- [x] Event loops functionality
- [x] Supports Web3View functionality - WKWebView with injected "web3" provider
- [x] Possibility to add or remove "middleware" that intercepts, modifies and even cancel transaction workflow on stages "before assembly", "after assembly"and "before submission"
- [x] Literally following the standards:
	- [x] [BIP32](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki) HD Wallets: Deterministic Wallet
	- [x] [BIP39](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki) (Seed phrases)
	- [x] [BIP44](https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki) (Key generation prefixes)
	- [x] [EIP-20](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md) (A standard interface for tokens - ERC-20)
	- [x] [EIP-67](https://github.com/ethereum/EIPs/issues/67) (Standard URI scheme with metadata, value and byte code)
	- [x] [EIP-155](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-155.md) (Replay attacks protection) *enforced!*
	- [x] [EIP-681](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-681.md) (A standard way of representing various transactions, especially payment requests in Ethers and ERC-20 tokens as URLs)
	- [x] [EIP-721](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md) (A standard interface for non-fungible tokens, also known as deeds - ERC-721)
	- [x] [EIP-165](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md) (Standard Interface Detection, also known as ERC-165)
	- [x] [EIP-777](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-777.md) (New Advanced Token Standard, also known as ERC-777)
	- [x] [EIP-820](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-820.md) (Pseudo-introspection Registry Contract, also known as ERC-820)
	- [x] [EIP-888](https://github.com/ethereum/EIPs/issues/888) (MultiDimensional Token Standard, also known as ERC-888)
	- [x] [EIP-1400](https://github.com/ethereum/EIPs/issues/1411) (Security Token Standard, also known as ERC-1400)
	- [x] [EIP-1410](https://github.com/ethereum/EIPs/issues/1410) (Partially Fungible Token Standard, also known as ERC-1410)
	- [x] [EIP-1594](https://github.com/ethereum/EIPs/issues/1594) (Core Security Token Standard, also known as ERC-1594)
	- [x] [EIP-1643](https://github.com/ethereum/EIPs/issues/1643) (Document Management Standard, also known as ERC-1643)
	- [x] [EIP-1644](https://github.com/ethereum/EIPs/issues/1644) (Controller Token Operation Standard, also known as ERC-1644)
	- [x] [EIP-1633](https://github.com/ethereum/EIPs/issues/1634) (Re-Fungible Token, also known as ERC-1633)
	- [x] [EIP-721x](https://github.com/loomnetwork/erc721x) (An extension of ERC721 that adds support for multi-fungible tokens and batch transfers, while being fully backward-compatible, also known as ERC-721x)
	- [x] [EIP-1155](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1155.md) (Multi Token Standard, also known as ERC-1155)
	- [x] [EIP-1376](https://github.com/ethereum/EIPs/issues/1376) (Service-Friendly Token, also known as ERC-1376)
	
- [x] RLP encoding
- [x] Batched requests in concurrent mode
- [x] Base58 encoding scheme
- [x] Formatting to and from Ethereum Units
- [x] Comprehensive Unit and Integration Test Coverage

## Design Decisions

- Not every JSON RPC function is exposed yet, and priority is given to the ones required for mobile devices
- Functionality was focused on serializing and signing transactions locally on the device to send raw transactions to Ethereum network
- Requirements for password input on every transaction are indeed a design decision. Interface designers can save user passwords with the user's consent
- Public function for private key export is exposed for user convenience but marked as UNSAFE_ :) Normal workflow takes care of EIP155 compatibility and proper clearing of private key data from memory

## Requirements

- iOS 9.0+ / macOS 10.11+
- Xcode 9.0+
- Swift 4.1+

## Migration Guides

- [web3swift 2.0 Migration Guide](https://github.com/matterinc/web3swift/blob/documentation/Documentation/web3swift%202.0%20Migration%20Guide.md)

## Communication

When using this lib, please make references to this repo and give your start! :)
*Nothing makes developers happier than seeing someone else use our work and go wild with it.*

If you are using web3swift in your app or know of an app that uses it, please add it to [this list](https://github.com/matterinc/web3swift/wiki/Apps-using-web3swift).

- If you **need help**, use [Stack Overflow](https://stackoverflow.com/questions/tagged/web3swift) and tag `web3swift`.
- If you need to **find or understand an API**, check [our documentation](http://web3swift.github.io/web3swift/).
- If you'd like to **see web3swift best practices**, check [Apps using this library](https://github.com/matterinc/web3swift/wiki/Apps-using-web3swift).
- If you **found a bug**, [open an issue](https://github.com/matterinc/web3swift/issues).
- If you **have a feature request**, [open an issue](https://github.com/matterinc/web3swift/issues).
- If you **want to contribute**, [submit a pull request](https://github.com/matterinc/web3swift/pulls).

## Installation

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

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](https://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate web3swift into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "matterinc/web3swift" "carthage"
```

Run `carthage update` to build the framework and drag the built `web3swift.framework` into your Xcode project.

## Example Project

You can try lib by running the example project:

- Clone the repo: `git clone https://github.com/matterinc/web3swift.git`
- Move to the repo: `cd web3swift/Example/web3swiftExample`
- Install Dependencies: `pod install`
- Open: `open ./web3swiftExample.xcworkspace`

## Popular questions

#### Is it possible to get Mnemonic Phrase (Seed Phrase) from Private key using web3swift?

In web3swift there is no backward conversion from Private key to Mnemonic Phrase. Also it is theoretically impossible to recover a phrase from a Private key. After Seed Phrase is converted to some initial entropy the “master key is derived” and the initial entropy is discarded.

The simplest solution is to encrypt the phrase using users pincode and save it in some other secure keystore.
Mnemonic Phrase is very sensitive data and you must be very careful to let the user get it.
Our advise if you want to show it to user - ask to save a Passphrase when creating BIP32Keystore. 

#### How to interact with custom smart-contract with web3swift?

For example: you want to interact with smart-contract and all you know is - its address (address example: 0xfa28eC7198028438514b49a3CF353BcA5541ce1d).

You can get the ABI of your contract directly from [Remix IDE](https://remix.ethereum.org/) ([Solution](https://ethereum.stackexchange.com/questions/27536/where-to-find-contract-abi-in-new-version-of-online-remix-solidity-compiler?rq=1))

Then you should use contract address and ABI in creating contract object. In example we use Infura Mainnet:
```swift
let yourContractABI: String = <CONTRACT JSON ABI>
let toEthereumAddress: EthereumAddress? = <DESTINATION ETHEREUM ADDRESS>
let abiVersion: Int = <ABI VERSION NUMBER>

let contract = Web3.InfuraMainnetWeb3().contract(yourContractABI, at: toEthereumAddress, abiVersion: abiVersion)
```
Here is the example how you should call some contract method:
```swift
let method: String = <CONTRACT METHOD NAME>
let parameters: [AnyObject] = <PARAMETERS>
let extraData: Data = <DATA>
let transactionOptions: TransactionOptions = <OPTIONS>

let transaction = contract.read(method, parameters: parameters, extraData: extraData, transactionOptions: transactionOptions)
```

Here is the example how you should send transaction to some contract method:
```swift
let method: String = <CONTRACT METHOD NAME>
let parameters: [AnyObject] = <PARAMETERS>
let extraData: Data = <DATA>
let transactionOptions: TransactionOptions = <OPTIONS>

let transaction = contract.write(method, parameters: parameters, extraData: extraData, transactionOptions: transactionOptions)
```

#### How to set test local node?
You can write something like that:
```swift
func setLocalNode(port: Int = 8545) -> Web3? {
    guard let web3 = Web3(url: URL(string: "http://127.0.0.1:\(port)")!) else { return nil }
    return web3
}
```

## What's next

- [x] [R-Token](https://github.com/harborhq/r-token) (Smart Contracts for applying regulatory compliance to tokenized securities issuance and trading)
- [x] [SRC-20](https://swarm.fund/swarm-basics/) (Swarm protocol that enables the tokenization of assets on the blockchain - Security Tokens)
- [x] [ST-20](https://github.com/PolymathNetwork/polymath-core) (ST-20 token is an Ethereum-based token implemented on top of the ERC-20 protocol that adds the ability for tokens to control transfers based on specific rules)
- [x] [Objective-C] - a proxy bridge to build your DApp on Objective-C using web3swift
- [x] [Performance Improvements]
- [x] [More convenient methods for basic namespaces]
- [x] [Complete Documentation](https://web3swift.github.io/web3swift)


## Credits

Alex Vlasov, [@shamatar](https://github.com/shamatar),  alex.m.vlasov@gmail.com

Petr Korolev, [@skywinder](https://github.com/skywinder)

### Security Disclosure

If you believe you have identified a security vulnerability with web3swift, you should report it as soon as possible via email to [Alex Vlasov](https://github.com/shamatar) alex.m.vlasov@gmail.com. Please do not post it to a public issue tracker.

## Donations

[The Matters](https://github.com/orgs/matterinc/people) are charged with open-sorсe and do not require money for using their web3swift lib.
We want to continue to do everything we can to move the needle forward.
If you use any of our libraries for work, see if your employers would be interested in donating. Any amount you can donate today to help us reach our goal would be greatly appreciated.

Our Ether wallet address: 0xe22b8979739d724343bd002f9f432f5990879901

![Donate](http://qrcoder.ru/code/?0xe22b8979739d724343bd002f9f432f5990879901&4&0)

## License

web3swift is available under the Apache License 2.0 license. See the [LICENSE](https://github.com/matterinc/web3swift/blob/documentation/LICENSE) for details.
