# web3swift

## Important notice:

### [We’re participating in the @gitcoin Grants CLR Round 4](https://gitcoin.co/grants/358/web3swift )

### Drop a few $ into this grant and leverage your power to help. #QuadraticFunding makes every donated DAI count! 💸

Cheers! <https://gitcoin.co/grants/358/web3swift >

![matter-github-swift](https://github.com/matter-labs/web3swift/blob/develop/web3swift-logo.png)
[![Build Status](https://travis-ci.com/matter-labs/web3swift.svg?branch=develop)](https://travis-ci.com/matter-labs/web3swift)
[![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Platform](https://img.shields.io/cocoapods/p/web3swift.svg?style=flat)](http://cocoapods.org/pods/web3.swift.pod)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/web3.swift.pod.svg?style=flat)](http://cocoapods.org/pods/web3.swift.pod)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/web3swift.svg?style=flat)](http://cocoapods.org/pods/web3.swift.pod)
[![support](https://brianmacdonald.github.io/Ethonate/svg/eth-support-blue.svg)](https://brianmacdonald.github.io/Ethonate/address#0xe22b8979739d724343bd002f9f432f5990879901)
[![Stackoverflow](https://img.shields.io/badge/stackoverflow-ask-blue.svg)](https://stackoverflow.com/questions/tagged/web3swift)

**web3swift** is your toolbelt for any kind interactions with Ethereum network.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Design Decisions](#design-decisions)
- [Projects that using web3swift](#projects-that-using-web3swift)
- [Installation](#installation)
  - [Requirements](#requirements)
  - [Migration Guides](#migration-guides)
- [Documentation](#documentation)
  - [Example](#example)
- [FAQ](#faq)
- [Credits](#credits)
  - [What we have already done](#what-we-have-already-done)
  - [Future steps](#future-steps)
- [Contribute](#contribute)
- [Security Disclosure](#security-disclosure)
- [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


## Design Decisions

- Not every JSON RPC function is exposed yet, and priority is given to the ones required for mobile devices
- Functionality was focused on serializing and signing transactions locally on the device to send raw transactions to Ethereum network
- Requirements for password input on every transaction are indeed a design decision. Interface designers can save user passwords with the user's consent
- Public function for private key export is exposed for user convenience but marked as UNSAFE_ :) Normal workflow takes care of EIP155 compatibility and proper clearing of private key data from memory

## Projects that using web3swift

If you are using this library in your project, please [add a link](https://github.com/matter-labs/web3swift/edit/develop/README.md) to this repo.

* [MyEtherWallet/MEWconnect-iOS](https://github.com/MyEtherWallet/MEWconnect-iOS)
* [Peepeth iOS client](https://github.com/matterinc/PeepethClient)
* [Ethereum & ERC20Tokens Wallet](https://itunes.apple.com/us/app/ethereum-erc20tokens-wallet/id1386738877?ls=1&mt=8)
* [BankexWallet](https://github.com/BANKEX/Pay-iOS)
* [GeoChain](https://github.com/awallish/GeoChain)
* [NewHorizonLabs/TRX-Wallet](https://github.com/NewHorizonLabs/TRX-Wallet)
* [SteadyAction/EtherWalletKit](https://github.com/SteadyAction/EtherWalletKit)
* [UP Wallet/loopr-ios](https://github.com/Loopring/loopr-ios)
* [MyENS Wallet](https://github.com/barrasso/enswallet)
* [LoanStar](https://github.com/barrasso/loan-star)
* [AlphaWallet](https://github.com/AlphaWallet/alpha-wallet-ios)
* [Follow_iOS](https://github.com/FollowInc/Follow_iOS)
* [Biomedical Data Sharing dApp - Geolocation](https://github.com/HD2i/Geolocation-iOS)
* [Alice Wallet](https://github.com/alicedapp/AliceX)
* [YOUR APP CAN BE THERE (click me)](https://github.com/matter-labs/web3swift/edit/develop/README.md) :wink:

*Nothing makes developers happier than seeing someone else use our work and go wild with it.*


## Installation

- CocoaPods

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

- Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](https://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate web3swift into your Xcode project using Carthage, specify it in your `Cartfile`.
Create an empty Cartfile with the touch command and open it:

```bash
$ touch Cartfile
$ open -a Xcode Cartfile
```

Add the following line to the Cartfile and save it:

```ogdl
github "matter-labs/web3swift" "master"
```

Run `carthage update` to build the framework. By default, Carthage performs checkouts and builds in a new directory 'Carthage' in the same location as your Cartfile. Open this directory, go to 'Build' directory, choose iOS or macOS directory and use the framework from the chosen directory in your Xcode project.


### Requirements

- iOS 9.0+ / macOS 10.11+
- Xcode 10.2+
- Swift 5.0+

### Migration Guides

- [web3swift 2.0 Migration Guide](https://github.com/matterinc/web3swift/blob/master/Documentation/web3swift%202.0%20Migration%20Guide.md)


---
## Documentation

Full source please look at [Documentation folder](https://github.com/matter-labs/web3swift/blob/master/Documentation/)

Here are quick references for basic features:

- [Preffered models](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#preffered-models)
    - [Preffered keys Wallet Model (Account)](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#preffered-keys-wallet-model-account)
    - [Preffered ERC-20 Model](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#preffered-erc-20-model)
- [Account Management](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#account-management)
  - [Create Account](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#create-account)
    - [With Private Key](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#with-private-key)
    - [With Mnemonics Phrase](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#with-mnemonics-phrase)
  - [Import Account](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#import-account)
    - [With Private Key](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#with-private-key-1)
    - [With Mnemonics Phrase](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#with-mnemonics-phrase-1)
  - [Get Keystore Manager from wallet data](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#get-keystore-manager-from-wallet-data)
  - [Get wallet private key](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#get-wallet-private-key)
- [Ethereum Endpoints interaction](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#ethereum-endpoints-interaction)
  - [web3 instance](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#web3-instance)
  - [Ethereum Address](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#ethereum-address)
    - [Initializing](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#initializing)
  - [Get Balance](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#get-balance)
    - [Get ETH balance](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#get-eth-balance)
    - [Get ERC20 token balance](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#get-erc20-token-balance)
  - [Transactions Operations](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#transactions-operations)
    - [Prepare Transaction](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#prepare-transaction)
      - [Send Ether](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#send-ether)
      - [Send ERC-20 Token](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#send-erc-20-token)
      - [Write Transaction and call smart contract method](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#write-transaction-and-call-smart-contract-method)
      - [Read Transaction to call smart contract method](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#read-transaction-to-call-smart-contract-method)
    - [Send Transaction](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#send-transaction)
      - [Write](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#write)
      - [Read](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#read)
  - [Chain state](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#chain-state)
    - [Get Block number](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#get-block-number)
- [Websockets](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#websockets)
  - [Web3socketDelegate](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#web3socketdelegate)
  - [Custom Websocket Provider](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#custom-websocket-provider)
    - [Connect to custom endpoint](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#connect-to-custom-endpoint)
    - [Send message](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#send-message)
  - [Infura Websocket interactions](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#infura-websocket-interactions)
    - [Connect to Infura endpoint](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#connect-to-infura-endpoint)
    - [Connect to custom Infura-like endpoint](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#connect-to-custom-infura-like-endpoint)
    - [Create a filter in the node to notify when something happened](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#create-a-filter-in-the-node-to-notify-when-something-happened)
    - [Get new pending transactions](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#get-new-pending-transactions)
    - [Create a new subscription over particular events](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#create-a-new-subscription-over-particular-events)
    - [Subscribe on new pending transactions](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#subscribe-on-new-pending-transactions)
- [ENS](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#ens)
  - [Registry](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#registry)
  - [Resolver](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#resolver)
  - [BaseRegistrar](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#baseregistrar)
  - [RegistrarController](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#registrarcontroller)
  - [ReverseRegistrar](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md#reverseregistrar)


### Example

You can try lib by running the example project:

- Clone the repo: `git clone https://github.com/matter-labs/web3swift.git`
- Move to the repo: `cd web3swift/Example/web3swiftExample`
- Install Dependencies: `pod install`
- Open: `open ./web3swiftExample.xcworkspace`

## FAQ

> Is it possible to get a Mnemonic Phrase (Seed Phrase) from Private key using web3swift?

In web3swift there is no backward conversion from Private key to Mnemonic Phrase. Also it is theoretically impossible to recover a phrase from a Private key. After Seed Phrase is converted to some initial entropy the “master key is derived” and the initial entropy is discarded.

The simplest solution is to encrypt the phrase using users pincode and save it in some other secure keystore.
Mnemonic Phrase is very sensitive data and you must be very careful to let the user get it.
Our advise if you want to show it to a user - ask to save a Passphrase when creating BIP32Keystore.

> How to interact with custom smart-contract with web3swift?

For example: you want to interact with smart-contract and all you know is - its address (address example: 0xfa28eC7198028438514b49a3CF353BcA5541ce1d).

You can get the ABI of your contract directly from [Remix IDE](https://remix.ethereum.org/) ([Solution](https://ethereum.stackexchange.com/questions/27536/where-to-find-contract-abi-in-new-version-of-online-remix-solidity-compiler?rq=1))

Then you should use contract address and ABI in creating contract object. In example we use Infura Mainnet:
```swift
let yourContractABI: String = <CONTRACT JSON ABI>
let toEthereumAddress: EthereumAddress = <DESTINATION ETHEREUM ADDRESS>
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

> How to set test local node?
You can write something like that:
```swift
func setLocalNode(port: Int = 8545) -> Web3? {
    guard let web3 = Web3(url: URL(string: "http://127.0.0.1:\(port)")!) else { return nil }
    return web3
}
```

## Credits

Alex Vlasov, [@shamatar](https://github.com/shamatar)

Petr Korolev, [@skywinder](https://github.com/skywinder)

Anton Grigorev, [@baldyash](https://github.com/BaldyAsh)


### What we have already done

- [x] Swift implementation of [web3.js](https://github.com/ethereum/web3.js/) functionality :zap:
- [x] Interaction with remote node via JSON RPC :thought_balloon:
- [x] Local keystore management (`geth` compatible)
- [x] Smart-contract ABI parsing :book:
- [x] ABI deconding (V2 is supported with return of structures from public functions. Part of 0.4.22 Solidity compiler)
- [x] Ethereum Name Service (ENS) support - a secure & decentralised way to address resources both on and off the blockchain using simple, human-readable names
- [x] Interactions (read/write to Smart contracts) :arrows_counterclockwise:
- [x] Complete Infura Ethereum API support, patial Websockets API support
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
    - [x] [ST-20](https://github.com/PolymathNetwork/polymath-core) - ST-20 token is an Ethereum-based token implemented on top of the ERC-20 protocol that adds the ability for tokens to control transfers based on specific rules

- [x] RLP encoding
- [x] Batched requests in concurrent mode
- [x] Base58 encoding scheme
- [x] Formatting to and from Ethereum Units
- [x] Comprehensive Unit and Integration Test Coverage


### Future steps

- [x] Objective-C - a proxy bridge to build your DApp on Objective-C using web3swift
- [x] Complete Documentation (https://web3swift.github.io/web3swift)
- [x] Modularity with the basic Web3 subspec/SPM (the most basic functions like transaction signing and interacting with an http rpc server) and other modules with additional functionality
- [x] [R-Token](https://github.com/harborhq/r-token) - Smart Contracts for applying regulatory compliance to tokenized securities issuance and trading
- [x] Support IPFS via Infura public IPFS gateway
- [x] Support more blockchains - Ripple, Bitcoin, EOS, etc.
- [x] Performance Improvements
- [x] More convenient methods for basic namespaces

## Contribute

- If you **need help**, [open an issue](https://github.com/matter-labs/web3swift/issues).
- If you need to **find or understand an API**, check [our documentation](https://github.com/matter-labs/web3swift/blob/master/Documentation/Usage.md).
- If you'd like to **see web3swift best practices**, check [Apps using this library](https://github.com/matter-labs/web3swift/wiki/Apps-using-web3swift).
- If you **found a bug**, [open an issue](https://github.com/matter-labs/web3swift/issues).
- If you **have a feature request**, [open an issue](https://github.com/matter-labs/web3swift/issues).
- If you **want to contribute**, [submit a pull request](https://github.com/matter-labs/web3swift/pulls).
- Donation Our Ether wallet address: 0xe22b8979739d724343bd002f9f432f5990879901

![Donate](http://qrcoder.ru/code/?0xe22b8979739d724343bd002f9f432f5990879901&4&0)


## Security Disclosure

If you believe you have identified a security vulnerability with web3swift, you should report it as soon as possible via email to [hello@matter-labs.io](mailto:hello@matter-labs.io). Please do not post it to a public issue tracker.

[Matter Labs](https://github.com/orgs/matter-labs/people) are charged with open-sourсe and do not require money for using their web3swift lib.
We want to continue to do everything we can to move the needle forward.
If you use any of our libraries for work, see if your employers would be interested in donating. Any amount you can donate today to help us reach our goal would be greatly appreciated.

## License

web3swift is available under the Apache License 2.0 license. See the [LICENSE](https://github.com/matter-labs/web3swift/blob/master/LICENSE) for details.
